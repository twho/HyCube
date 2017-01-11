//
//  TaskViewController.swift
//  HyCube
//
//  Created by Michael Ho on 12/2/16.
//  Copyright © 2016 hycube.com. All rights reserved.
//

import UIKit
import PubNub

struct TaskItem {
    var uuid: String
    var taskName: String
    var taskFreq: String
    var taskAssign: String
    var taskSensor: String
}

class TaskViewController: UIViewController, PNObjectEventListener, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var mainChannelName: String = "HyCubeTask4"
    var deletedChannelName: String = ""
    var taskListItems: [TaskItem] = []
    var deletedTaskItems: [TaskItem] = []
    var allTaskItems: [TaskItem] = []
    var uuids: [String] = []
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
    var fromAddTaskVC: Bool = false
    var allUserNames: [String] = []
    var allUserIds: [String] = []
    var mode: Int = 0
    
    let serialQueue: DispatchQueue = DispatchQueue(label: "pageHistoryQueue", attributes: [])
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.allUserIds = defaults.array(forKey: "myFriendsId") as! [String]
        self.allUserNames = defaults.array(forKey: "myFriendsName") as! [String]
        deletedChannelName = "\(mainChannelName)-deleted"
        showActivityIndicator()
        tableView.dataSource = self
        tableView.delegate = self
        appDelegate.client.addListener(self)
        appDelegate.client.subscribeToChannels([mainChannelName], withPresence: false)
        appDelegate.client.subscribeToChannels([deletedChannelName], withPresence: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Check if the segue is coming from the add task view controller with flag
        //If it is, don't retrieve history from PubNub
        if !fromAddTaskVC {
            updateTableView(displayMode: mode)
        } else {
            fromAddTaskVC = false
        }
    }
    
    //When user swipes to delete, a message is sent to the "deleted" channel
    //This makes sure that when a new user joins, these messages won't be shown in their todo list
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let message : [String : AnyObject] = ["uuid" : taskListItems[indexPath.row].uuid as AnyObject, "taskName" : taskListItems[indexPath.row].taskName as AnyObject, "taskFreq" : taskListItems[indexPath.row].taskFreq as AnyObject, "taskAssign" : taskListItems[indexPath.row].taskAssign as AnyObject, "taskSensor" : taskListItems[indexPath.row].taskSensor as AnyObject, "index": indexPath.row as AnyObject]
            appDelegate.client.publish(message, toChannel: self.deletedChannelName, withCompletion: { (status) in
                self.showActivityIndicator()
                if status.isError == true {
                    self.activityIndicator.stopAnimating()
                }
            })
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskListItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell")! as! TaskTableViewCell
        cell.tvTask.text = taskListItems[indexPath.row].taskName
        cell.ivAssign.image = getImgByUserName(userName: taskListItems[indexPath.row].taskAssign)
        cell.tvFreq.text = taskListItems[indexPath.row].taskFreq
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "TaskToTaskViewIdentifier", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "TaskToTaskViewIdentifier") {
            //prepare for segue to the details view controller
            let destinationVC = segue.destination as! EditTaskViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            destinationVC.cellTaskItem = taskListItems[(indexPath?.row)!]
        }
    }

    
    func getImgByUserName(userName: String) -> UIImage{
        var userImage = UIImage(named: "ic_people")
        let idIndex = allUserNames.index(of: userName)
        let facebookProfileUrl = URL(string: "http://graph.facebook.com/\(allUserIds[idIndex!])/picture?type=large")
        if let data = NSData(contentsOf: facebookProfileUrl!) {
            userImage = UIImage(data: data as Data)
        }
        return userImage!
    }
    
    //When a message is received, it is added to the tableview if it's not from the "deleted" channel
    //Otherwise, it's removed from the table
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        print("\(message.data.message!) at \(message.data.channel)")
        if(mainChannelName == "\(message.data.channel)" && !uuids.contains((message.data.message as! [String:AnyObject])["uuid"] as! String)){
            activityIndicator.stopAnimating()
            uuids.append((message.data.message as! [String:AnyObject])["uuid"] as! String)
            taskListItems.append(TaskItem(uuid: (message.data.message as! [String:AnyObject])["uuid"] as! String, taskName: (message.data.message as! [String:AnyObject])["taskName"] as! String, taskFreq: (message.data.message as! [String:AnyObject])["taskFreq"] as! String, taskAssign: (message.data.message as! [String:AnyObject])["taskAssign"] as! String, taskSensor: (message.data.message as! [String:AnyObject])["taskSensor"] as! String))
            tableView.reloadData()
        } else if(deletedChannelName == "\(message.data.channel)") {
            activityIndicator.stopAnimating()
            print((message.data.message as! [String:AnyObject]))
            taskListItems.remove(at: (message.data.message as! [String:AnyObject])["index"] as! Int)
            let indexPath = IndexPath.init(row: (message.data.message as! [String:AnyObject])["index"] as! Int, section: 0)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
    }
    
    //Page history of specified channel using semaphore and return array with history task items
    //mytask:mode = 0, alltask:mode = 1
    func pageHistory(_ channelName: String, mode: Int) -> [TaskItem] {
        
        var uuidArray: [TaskItem] = []
        var shouldStop: Bool = false
        var isPaging: Bool = false
        var startTimeToken: NSNumber = 0
        let itemLimit: Int = 100
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        let myName = defaults.string(forKey: "myName")
        
        self.appDelegate.client.historyForChannel(channelName, start: nil, end: nil, limit: 100, reverse: true, includeTimeToken: true, withCompletion: { (result, status) in
            for message in (result?.data.messages)! {
                if let resultMessage = (message as! [String:AnyObject])["message"] {
                    if(mode == 0) {
                        if(myName == resultMessage["taskAssign"] as! String){
                            uuidArray.append(TaskItem(uuid: resultMessage["uuid"] as! String, taskName: resultMessage["taskName"] as! String, taskFreq: resultMessage["taskFreq"] as! String, taskAssign: resultMessage["taskAssign"] as! String, taskSensor: resultMessage["taskSensor"] as! String))
                        }
                    } else {
                        uuidArray.append(TaskItem(uuid: resultMessage["uuid"] as! String, taskName: resultMessage["taskName"] as! String, taskFreq: resultMessage["taskFreq"] as! String, taskAssign: resultMessage["taskAssign"] as! String, taskSensor: resultMessage["taskSensor"] as! String))
                    }
                    self.uuids.append(resultMessage["uuid"] as! String)
                }
            }
            
            if let endTime = result?.data.end {
                startTimeToken = endTime
            }
            
            if result?.data.messages.count == itemLimit {
                isPaging = true
            }
            semaphore.signal()
        })
        
        semaphore.wait(timeout: DispatchTime.distantFuture)
        
        while isPaging && !shouldStop {
            self.appDelegate.client.historyForChannel(channelName, start: startTimeToken, end: nil, limit: 100, reverse: true, includeTimeToken: true, withCompletion: { (result, status) in
                for message in (result?.data.messages)! {
                    if let resultMessage = (message as! [String:AnyObject])["message"] {
                        if(mode == 0) {
                            if(myName == resultMessage["taskAssign"] as! String){
                                uuidArray.append(TaskItem(uuid: resultMessage["uuid"] as! String, taskName: resultMessage["taskName"] as! String, taskFreq: resultMessage["taskFreq"] as! String, taskAssign: resultMessage["taskAssign"] as! String, taskSensor: resultMessage["taskSensor"] as! String))
                            }
                        } else {
                            uuidArray.append(TaskItem(uuid: resultMessage["uuid"] as! String, taskName: resultMessage["taskName"] as! String, taskFreq: resultMessage["taskFreq"] as! String, taskAssign: resultMessage["taskAssign"] as! String, taskSensor: resultMessage["taskSensor"] as! String))
                        }
                        self.uuids.append(resultMessage["uuid"] as! String)
                    }
                }
                
                if let endTime = result?.data.end {
                    startTimeToken = endTime
                }
                
                if (result?.data.messages.count)! < itemLimit {
                    shouldStop = true
                }
                semaphore.signal()
            })
            
            semaphore.wait(timeout: DispatchTime.distantFuture)
        }
        return uuidArray
    }
    
    
    //Check all history items against deleted items and update tableView
    func checkAgainstDeletedAndUpdateTable() {
        for task in self.allTaskItems {
            if !self.deletedTaskItems.contains(where: {$0.uuid == task.uuid}) {
                self.taskListItems.append(TaskItem(uuid: task.uuid, taskName: task.taskName, taskFreq: task.taskFreq, taskAssign: task.taskAssign, taskSensor: task.taskSensor))
            }
        }
        //Update UI on main thread
        DispatchQueue.main.async(execute: { () -> Void in
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
        })
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        //segmented control
        mode = sender.selectedSegmentIndex
        updateTableView(displayMode: sender.selectedSegmentIndex)
    }
    
    func updateTableView(displayMode: Int){
        showActivityIndicator()
        serialQueue.async { [unowned self] () -> Void in
            self.taskListItems = []
            self.deletedTaskItems = []
            self.allTaskItems = []
            self.deletedTaskItems = self.pageHistory(self.deletedChannelName, mode: displayMode)
            self.allTaskItems = self.pageHistory(self.mainChannelName, mode: displayMode)
            self.checkAgainstDeletedAndUpdateTable()
        }
    }
    
    //Spinning indicator when loading request
    func showActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
}
