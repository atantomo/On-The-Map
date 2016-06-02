//
//  TabbedTableViewController.swift
//  On The Map
//
//  Created by Andrew Tantomo on 2016/02/11.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit

class TabbedTableViewController: UIViewController {

    @IBOutlet weak var studentTableView: UITableView!

    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        studentTableView.dataSource = self
        studentTableView.delegate = self

        reloadStudentInformation()
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reloadStudentInformation() {

        let blockerView = BlockerView(frame: view.frame)
        view.addSubview(blockerView)
        ParseClient.sharedInstance().getStudentLocations() { result, errorString in

            self.removeViewAsync(blockerView)

            let tabCtrl = self.tabBarController as! TabbedController
            tabCtrl.userExists = ParseClient.sharedInstance().userExists

            if let err = errorString {
                self.displayError(err)
                return
            }
            if let res = result {
                StudentData.data = res
                self.loadDataAsync()
            }
        }
    }

    func loadDataAsync() {

        dispatch_async(dispatch_get_main_queue()) {
            self.studentTableView.reloadData()
        }
    }
}

extension TabbedTableViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return StudentData.data.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let tableCell = tableView.dequeueReusableCellWithIdentifier("StudentTableCell", forIndexPath: indexPath)
        tableCell.textLabel?.text = StudentData.data[indexPath.row].firstName + " " + StudentData.data[indexPath.row].lastName
        tableCell.detailTextLabel?.text = StudentData.data[indexPath.row].mapString
        return tableCell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let url = NSURL(string: StudentData.data[indexPath.row].mediaURL)!
        UIApplication.sharedApplication().openURL(url)
        return
    }
}