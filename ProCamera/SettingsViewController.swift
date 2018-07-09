//
//  SettingsViewController.swift
//  ProCamera
//
//  Created by Hao Wang on 3/8/15.
//  Copyright (c) 2015 Hao Wang. All rights reserved.
//

import UIKit


class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, settingsDelegate {
    
    fileprivate let settings = [
        "Grid",
        "Geo Tagging",
        "Lossless Quality"
    ]
    var settingsValue: [String: Bool] = [String: Bool]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        return UIInterfaceOrientationMask.allButUpsideDown
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.view.window?.reloadInputViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let settingsValueTmp = UserDefaults.standard.object(forKey: "settingsStore") as? [String: Bool]
        if settingsValueTmp != nil {
            settingsValue = settingsValueTmp!
        } else {
            settingsValue = [String: Bool]()
        }
        print("\(settingsValue) View did load")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: { () -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: "settingsUpdatedNotification"), object: nil, userInfo: self.settingsValue)
        })
    }
    
    func changeSetting(_ name: String, value: Bool) {
        switch name {
        case settings[0], settings[1], settings[2]:
            settingsValue[name] = value
        default:
            let x = 1
        }
        print("\(self.settingsValue) changeSetting")
        //set data
        UserDefaults.standard.set(settingsValue, forKey: "settingsStore")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("\(self.settingsValue) cellForRowAtIndexPath")
        if indexPath.row < 4 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "settingBoolCell") as! SettingBoolTableViewCell
            var on: Bool? = self.settingsValue[settings[indexPath.row]]
            if on == nil {
                on = false
            }
            cell.switchBtn.setOn(on!, animated: true)
            cell.settingName.text = settings[indexPath.row]
            cell.delegate = self
            return cell
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "settingOptionsCell") as! SettingOptionsTableViewCell
            cell.settingName.text = settings[indexPath.row]
            cell.optionVal.text = "Default" //place holder
            return cell
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
