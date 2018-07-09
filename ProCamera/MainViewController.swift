//
//  ViewController.swift
//  ProCamera
//
//  Created by Hao Wang on 3/8/15.
//  Copyright (c) 2015 Hao Wang. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import QuartzCore


class MainViewController: AVCoreViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var histogramView: HistogramView!
    
    @IBOutlet weak var meterCenter: UIView!
    @IBOutlet weak var meterView: MeterView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var exposureDurationSlider: UISlider!
    @IBOutlet weak var exposureValueSlider: UISlider!
    @IBOutlet weak var shutterSpeedLabel: UILabel!
    @IBOutlet weak var isoValueLabel: UILabel!
    @IBOutlet weak var albumButton: UIImageView!
    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var controllView: UIView!
    @IBOutlet weak var whiteBalanceSlider: UISlider!
    var viewAppeared = false
    
    @IBOutlet weak var meterImage: UIImageView!
    @IBOutlet weak var isoSlider: UISlider!
    
    @IBOutlet weak var evValue: UILabel!
    @IBOutlet weak var takePhotoButton: UIButton!
    //let sessionQueue = dispatch_queue_create("session_queue", nil)
    @IBOutlet weak var innerPhotoButton: UIView!
    
    @IBOutlet weak var previewView: UIView!
    var currentSetAttr: String! //The current attr to change

    
    @IBOutlet weak var asmButton: UIButton!
    let enabledLabelColor = UIColor.white
    let disabledLabelColor = UIColor.gray
    let currentlyEditedLabelColor = UIColor.yellow
    
    // Setting buttons
    @IBOutlet weak var wbButton: UIButton!
    @IBOutlet weak var shutterButton: UIButton!
    @IBOutlet weak var isoButton: UIButton!
    @IBOutlet weak var evButton: UIButton!
    
    @IBOutlet weak var wbIconButton: UIButton!
    
    var gridEnabled: Bool = false
    
    var scrollViewInitialX: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let settingsValueTmp = UserDefaults.standard.object(forKey: "settingsStore") as? [String: Bool]
        settingsUpdated(settingsValueTmp)
        //Listen to notif
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.settingsUpdatedObserver(_:)), name: NSNotification.Name(rawValue: "settingsUpdatedNotification"), object: nil)
        
        // Make the "take photo" button circular
        takePhotoButton.layer.cornerRadius = (takePhotoButton.bounds.size.height/2)
        innerPhotoButton.layer.cornerRadius = (innerPhotoButton.bounds.size.height/2)
        
        // Make the ASM button have a border and be circular
        asmButton.layer.borderWidth = 2.0
        asmButton.layer.borderColor = UIColor.gray.cgColor
        asmButton.layer.cornerRadius = (asmButton.bounds.size.height/2)
        shootMode = 0 //TODO: persist this
        
        // Handle swiping on scroll view to hide
        let recognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(MainViewController.scrollSwipedRight))
        self.scrollView.addGestureRecognizer(recognizer)
        recognizer.direction = UISwipeGestureRecognizerDirection.right;
        self.scrollView.delaysContentTouches = true
        
        let buttonTypesForGestures = [
            "didSwipeWbButton": wbButton,
            "didSwipeEvButton": evButton,
            "didSwipeIsoButton": isoButton,
            "didSwipeShutterButton": shutterButton
        ]
        
        for (action, button) in buttonTypesForGestures {
            let newRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector(action))
            newRecognizer.direction = UISwipeGestureRecognizerDirection.left;
            button?.addGestureRecognizer(newRecognizer)
        }
        
        updateASM()
    }
    
    func settingsUpdated(_ settingsVal: [String: Bool]!) {
        if settingsVal != nil && settingsVal!["Grid"] != nil {
            gridEnabled = settingsVal["Grid"]!
            if gridEnabled {
                //Set BG color to none
                gridView.isOpaque = false
                gridView.backgroundColor = UIColor.clear
            }
            gridView.isHidden = !gridEnabled
        }
    }
    
    func settingsUpdatedObserver(_ notification: Notification) {
        let settingsVal = notification.userInfo as? [String: Bool]
        settingsUpdated(settingsVal)
    }
    
    func scrollSwipedRight() {
        print("Scroll swiped right")
        destroyMeterView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.initialize()
        histogramView.isOpaque = false
        histogramView.backgroundColor = UIColor.clear
        scrollView.delegate = self
    }
    
    override func postInitilize() {
        super.postInitilize()
        if viewAppeared{
            initView()
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        return UIInterfaceOrientationMask.landscapeLeft
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    func initView() {
        previewView.layer.insertSublayer(super.previewLayer, at: 0)
        previewLayer.frame = previewView.bounds
        //tmp
        setWhiteBalanceMode(.temperature(5000))
        changeExposureMode(AVCaptureExposureMode.autoExpose)
        updateASM()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewAppeared = true
        if super.initialized {
            initView()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapAlbumButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "cameraRollSegue", sender: self)
    }
    
    @IBAction func didPressTakePhoto(_ sender: AnyObject) {
        takePhoto()
        beforeSavePhoto()
    }
    @IBAction func didZoom(_ sender: UIPinchGestureRecognizer) {
        var scale = sender.scale
        print(scale)
        //TODO: Detect all touches are in preview layer
        if sender.state == UIGestureRecognizerState.began {
            
        } else if sender.state == UIGestureRecognizerState.changed {
            zoomVideoOutput(scale)
        } else if sender.state == UIGestureRecognizerState.ended {
            currentScale = tempScale
        }
        
    }
    
    func toggleISO(_ enabled: Bool) {
        if enabled {
            isoValueLabel.textColor = enabledLabelColor
            isoSlider.isHidden = false
        } else {
            isoValueLabel.textColor = disabledLabelColor
            isoSlider.isHidden = true
        }
        //hack force hidden
        isoSlider.isHidden = true
    }
    
    func toggleExposureDuration(_ enabled: Bool) {
        if enabled {
            shutterSpeedLabel.textColor = enabledLabelColor
            exposureDurationSlider.isHidden = false
        } else {
            shutterSpeedLabel.textColor = disabledLabelColor
            exposureDurationSlider.isHidden = true
        }
        //hack force hidden
        exposureDurationSlider.isHidden = true
    }
    
    func toggleExposureValue(_ enabled: Bool) {
        if enabled {
            evValue.textColor = enabledLabelColor
            exposureValueSlider.isHidden = false
        } else {
            evValue.textColor = disabledLabelColor
            exposureValueSlider.isHidden = true
        }
        //hack force hidden
        exposureValueSlider.isHidden = true
    }
    
    func toggleWhiteBalance(_ enabled: Bool) {
        if enabled {
            whiteBalanceSlider.isHidden = false
        } else {
            whiteBalanceSlider.isHidden = true
        }
        //hack force hidden
        whiteBalanceSlider.isHidden = true
    }
    
    @IBAction func didPressFlash(_ sender: UIButton) {
        if flashOn {
            toggleFlashUI(false)
        } else {
            toggleFlashUI(true)
        }
        setFlashMode(!flashOn)
    }
    
    func toggleFlashUI(_ on: Bool) {
        if on {
            flashBtn.setImage(UIImage(named: "flash"), for: UIControlState())
        } else {
            flashBtn.setImage(UIImage(named: "no-flash"), for: UIControlState())
        }
    }
    
    func updateASM() {
        var buttonTitle = "A"
        switch shootMode {
        case 1:
            buttonTitle = "Tv"
            changeExposureMode(.custom)
            changeExposureDuration(getCurrentValueNormalized("SS"))
            changeEV(getCurrentValueNormalized("EV"))
            isoMode = .auto
            toggleISO(false)
            toggleExposureDuration(true)
            toggleExposureValue(true)
        case 2:
            buttonTitle = "M"
            changeExposureMode(.custom)
            changeExposureDuration(getCurrentValueNormalized("SS"))
            isoMode = .custom
            changeISO(getCurrentValueNormalized("ISO"))
            toggleISO(true)
            toggleExposureDuration(true)
            toggleExposureValue(false)
        default:
            buttonTitle = "A"
            changeExposureMode(.autoExpose)
            currentISOValue = nil
            currentExposureDuration = nil
            toggleISO(false)
            toggleExposureDuration(false)
            toggleExposureValue(false)
        }
        changeTemperature(getCurrentValueNormalized("WB"))
        asmButton.setTitle(buttonTitle, for: UIControlState())
    }
    
    @IBAction func didPressASM(_ sender: AnyObject) {
        print("Pressed ASM cycler")
        scrollView.isHidden = true
        shootMode = shootMode + 1
        if shootMode! > 2 {
            shootMode = 0
        }
        updateASM()
        destroyMeterView()
    }
    
    
    @IBAction func didMoveISO(_ sender: UISlider) {
        if shootMode == 2 {
            //only works on manual mode
            let value = sender.value
            changeISO(value)
        }
    }
    
    @IBAction func didMoveShutterSpeed(_ sender: UISlider) {
        changeExposureDuration(sender.value)
    }
    @IBAction func didMoveWhiteBalance(_ sender: UISlider) {
        //Todo move this to different
        let value = sender.value
        print(value)
        changeTemperature(value)
    }
    @IBAction func didMoveEV(_ sender: UISlider) {
        changeEV(sender.value)
    }
    
    func didSwipeEvButton() {
        activateEvControl()
    }
    
    @IBAction func didPressEvButton(_ sender: UIButton) {
        activateEvControl()
    }
    
    func activateEvControl() {
        if shootMode == 1 {
            onPressedControl("EV")
        }
    }
    
    func didSwipeIsoButton() {
        activateIsoControl()
    }
    
    @IBAction func didPressIsoButton(_ sender: UIButton) {
        print("Pressed ISO")
        activateIsoControl()
    }
    
    func activateIsoControl() {
        if shootMode == 2 {
            onPressedControl("ISO")
        }
    }
    
    func didSwipeShutterButton() {
        activateShutterControl()
    }
    
    @IBAction func didPressShutterButton(_ sender: UIButton) {
        print("Pressed Shutter")
        activateShutterControl()
    }
    
    func activateShutterControl() {
        if shootMode == 1 || shootMode == 2 {
            onPressedControl("SS")
        }
    }
    
    func didSwipeWbButton() {
        activateWbControl()
    }
    
    @IBAction func didPressWBButton(_ sender: UIButton) {
        print("Pressed WB")
        activateWbControl()
    }
    
    func activateWbControl() {
        print("Toggling wb")
        onPressedControl("WB")
    }
    
    func updateHighlight() {
        switch currentSetAttr {
            case "ISO":
                isoValueLabel.textColor = currentlyEditedLabelColor
            case "SS":
                shutterSpeedLabel.textColor = currentlyEditedLabelColor
            case "EV":
                evValue.textColor = currentlyEditedLabelColor
        default:
            wbIconButton.setImage(UIImage(named: "wb_sunny_yellow"), for: UIControlState())
        }
        
    }
    
    func onPressedControl(_ controlName: String) {
        if (scrollView.isHidden) {
            self.currentSetAttr = controlName
            openMeterView()
        } else {
            if (controlName == currentSetAttr) {
                destroyMeterView()
            } else {
                closeMeterView({
                    self.currentSetAttr = controlName
                    self.openMeterView()
                })
            }
        }
    }
    
    func toggleMeterView() {
        if (scrollView.isHidden) {
            openMeterView()
        } else {
            destroyMeterView()
        }
    }
    
    func openMeterView() {
        initMeterView()
        updateHighlight()
    }
    
    func initMeterView() {
        let scrollViewAlpha: CGFloat = 0.6
        scrollView.isHidden = false
        //kill scrolling if any
        let offset = scrollView.contentOffset
        scrollView.setContentOffset(offset, animated: false)
        meterCenter.isHidden = false
        //important for scroll view to work properly
        scrollView.contentSize = meterView.frame.size
        let value = getCurrentValueNormalized(currentSetAttr)!
        
        print(value)
        let scrollMax = scrollView.contentSize.height -
            scrollView.frame.height
        scrollView.contentOffset.y = CGFloat(value) * scrollMax
        
        //Changing scrollView background to overlay style
        scrollView.isOpaque = false
        scrollView.backgroundColor = UIColor(white: 0.3, alpha: 0.5)
        
        //hide the image. Fixme: should remove the image from storyboard
        self.meterImage.isHidden = true
        //self.meterImage.image = drawMeterImage()
        
        meterView.isOpaque = false //meter view is transparent
        
        //meterView.frame = CGRectMake(0, 0, meterView.frame.width, 300.0)
        //meterView.bounds = meterView.frame
        //print("meterView: Frame \(meterView.bounds)")
        
        // To refresh the view, to call drawRect
        meterView.setNeedsDisplay()
        
        scrollViewInitialX = scrollViewInitialX != 0 ? scrollViewInitialX : self.scrollView.center.x
        self.scrollView.center.x = scrollViewInitialX + 35.0
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
            self.scrollView.alpha = scrollViewAlpha
            self.scrollView.center.x = self.scrollViewInitialX
        }, completion: nil)
    }
    
    func destroyMeterView() {
        closeMeterView({})
    }
    
    func closeMeterView(_ completion: @escaping () -> Void) {
        self.meterCenter.isHidden = true
        scrollViewInitialX = scrollViewInitialX != 0 ? scrollViewInitialX : self.scrollView.center.x
        print("current X is \(self.scrollView.center.x)")
        self.scrollView.center.x = scrollViewInitialX
        print("Initial X is \(scrollViewInitialX)")
        self.updateASM()
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                self.scrollView.alpha = 0.0
                self.scrollView.center.x = self.scrollViewInitialX + 35.0
            }) { (isComplete: Bool) -> Void in
                self.scrollView.isHidden = true
                self.wbIconButton.setImage(UIImage(named: "wb_sunny copy"), for: .normal)
                completion()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollMax = scrollView.contentSize.height -
            scrollView.frame.height
        var scrollOffset = scrollView.contentOffset.y
        if scrollOffset < 0 {
            scrollOffset = 0
        } else if scrollOffset > scrollMax {
            scrollOffset = scrollMax
        }
        let value = Float(scrollOffset / scrollMax)
        switch currentSetAttr {
            case "EV":
                changeEV(value)
            case "ISO":
                changeISO(value)
            case "SS":
                changeExposureDuration(value)
            case "WB":
                changeTemperature(value)
            default:
                let _ = 0
        }
    }
    
    override func postCalcHistogram() {
        super.postCalcHistogram()
        histogramView.didUpdateHistogramRaw(histogramRaw)
    }
    
    override func beforeSavePhoto() {
        super.beforeSavePhoto()
        albumButton.image = lastImage
    }
    
    override func postChangeCameraSetting() {
        super.postChangeCameraSetting()
        //let's calc the denominator
        DispatchQueue.main.async {
            if self.currentExposureDuration != nil {
                 self.shutterSpeedLabel.text = "1/\(self.FloatToDenominator(Float(self.currentExposureDuration!)))"
            } else {
                self.shutterSpeedLabel.text = "Auto"
            }
            if self.currentISOValue != nil {
                self.isoValueLabel.text = "\(Int(self.capISO(self.currentISOValue!)))"
            } else {
                self.isoValueLabel.text = "Auto"
            }
            
            if self.shootMode == 1 { //only in TV mode
                //map 0 - EV_MAX, to -3 - 3
                // self.exposureValue / EV_MAX = x / 6.0
                // x -= 3.0
                let expoVal = self.exposureValue / self.EVMaxAdjusted * 6.0 - 3.0
                self.evValue.text = expoVal.format(".1") //1 digit
            } else {
                self.evValue.text = "Auto"
            }
        }
    }
    
    /*
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("barCell", forIndexPath: indexPath) as ControllCollectionViewCell
        if currentSetAttr != nil {
            switch currentSetAttr {
            case "EV":
                cell.valueLabel.text = String(indexPath.row)
            case "ISO":
                cell.valueLabel.text = String(indexPath.row)
            case "SS":
                cell.valueLabel.text = String(indexPath.row)
            default:
                cell.valueLabel.text = String(indexPath.row)
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 25
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.hidden = true //hide the view
    }
    */

    @IBAction func onTapPreview(_ sender: UITapGestureRecognizer) {
        destroyMeterView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cameraRollSegue" {
            let vcNav = segue.destination as? UINavigationController
            if vcNav != nil {
                let vc = vcNav!.viewControllers[0] as? CameraRollViewController
                if vc != nil {
                    vc!.lastImage = self.lastImage
                }
            }
            
        }
    }
}

