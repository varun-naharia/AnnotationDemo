//
//  AddPlaceViewController.swift
//  Maxting
//
//  Created by Varun Naharia on 05/04/17.
//  Copyright © 2017 Logictrix. All rights reserved.
//

import UIKit
import MapKit

class AddPlaceViewController: UIViewController,MKMapViewDelegate,UIImagePickerControllerDelegate,UIPopoverControllerDelegate,UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, WDImagePickerDelegate {
    var mapImage:UIImage!
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var lblPlaceName: UILabel!
    @IBOutlet weak var txtPlaceName: CustomTextField!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var txtLevel: CustomTextField!
    @IBOutlet weak var lblUnit: UILabel!
    @IBOutlet weak var txtUnit: CustomTextField!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var txtAddress: CustomTextField!
    @IBOutlet weak var imgMap: UIImageView!
    @IBOutlet weak var lblStoreFront: UILabel!
    @IBOutlet weak var btnStorefrontPhoto: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet var pickerView: UIPickerView!
    var data:[String] = ["B2","B1","1","2","3","4","5","Other"]
    var imageArr:[[String:Any]] = []
    var annotationCoordinates:CLLocationCoordinate2D!
    var address:String = ""
    //image picker
    let imagepicker : UIImagePickerController?=UIImagePickerController()
    fileprivate var wdImagePicker: WDImagePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // imgMap.image = mapImage
        LocationManager.sharedInstance.getLocation { (location) in
            self.mapView.setCenter(coordinate: location.coordinate, zoomLevel: 16, animated: true)
            if(self.address != "")
            {
                self.txtAddress.text = self.address
            }
            else
            {
                Utilities.getAddressFrom(location: CLLocation(latitude: self.annotationCoordinates.latitude, longitude: self.annotationCoordinates.longitude), completion: { (address) in
                        self.txtAddress.text = address
                })
            }
//            self.addRadiusCircle(location: location)
            let annotation = MKPointAnnotation()
            annotation.coordinate = self.annotationCoordinates
            self.mapView.addAnnotation(annotation)
        }
        txtPlaceName.becomeFirstResponder()
        txtLevel.inputView = picker
        self.addDoneButtonOnKeyboard()
        txtLevel.text = "1"
        btnStorefrontPhoto.layer.borderColor = UIColor.gray.cgColor
        btnStorefrontPhoto.layer.borderWidth = 1
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        Utilities.setStatusBarColor(color: UIColor(red: 0.71, green: 0.28, blue: 0.27, alpha: 1.00), controller: self)
        Utilities.setNavigationColor(controller: self, backgroundColor: UIColor(red: 0.94, green: 0.36, blue: 0.35, alpha: 1.00), tintColor: .white, titleTextColor: .white, barStyle: UIBarStyle.blackTranslucent)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Utilities.setStatusBarColor(color: UIColor(red: 0.68, green: 0.68, blue: 0.68, alpha: 0.50), controller: self)
        Utilities.setNavigationColor(controller: self, backgroundColor: UIColor(red: 0.94, green: 0.36, blue: 0.35, alpha: 0.00), tintColor: .white, titleTextColor: .white, barStyle: UIBarStyle.blackTranslucent)
    }
    
    @IBAction func addPhotoAction(_ sender: Any) {
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        {
            UIAlertAction in
            
        }
        // Add the actions
        // picker?.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        // Present the controller
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openCamera()
    {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            wdImagePicker = WDImagePicker(sourceType: .camera)
            wdImagePicker.cropSize = CGSize(width: 300, height: 150)
            wdImagePicker.delegate = self
            
            wdImagePicker.imagePickerController.modalPresentationStyle = UIModalPresentationStyle.popover
            wdImagePicker.imagePickerController.popoverPresentationController?.sourceView = btnStorefrontPhoto
            wdImagePicker.imagePickerController.popoverPresentationController?.sourceRect = btnStorefrontPhoto.bounds
            
            present(wdImagePicker.imagePickerController, animated: true, completion: nil)
            
//            imagepicker?.allowsEditing = true
//            imagepicker?.sourceType = UIImagePickerControllerSourceType.camera
//            imagepicker?.cameraCaptureMode = .photo
//            imagepicker?.delegate = self
//            imagepicker?.modalPresentationStyle = .fullScreen
//            present(imagepicker!,animated: true,completion: nil)
        } else {
            let alertVC = UIAlertController(
                title: "No Camera",
                message: "Sorry, this device has no camera",
                preferredStyle: .alert)
            let okAction = UIAlertAction(
                title: "OK",
                style:.default,
                handler: nil)
            alertVC.addAction(okAction)
            present(
                alertVC,
                animated: true,
                completion: nil)
        }
    }
    
    func openGallary()
    {
        wdImagePicker = WDImagePicker(sourceType: .photoLibrary)
        wdImagePicker.cropSize = CGSize(width: 300, height: 150)
        wdImagePicker.delegate = self
        
        wdImagePicker.imagePickerController.modalPresentationStyle = UIModalPresentationStyle.popover
        wdImagePicker.imagePickerController.popoverPresentationController?.sourceView = btnStorefrontPhoto
        wdImagePicker.imagePickerController.popoverPresentationController?.sourceRect = btnStorefrontPhoto.bounds
        
        present(wdImagePicker.imagePickerController, animated: true, completion: nil)
        
//        imagepicker?.delegate = self
//        imagepicker?.allowsEditing = true
//        imagepicker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
//        if UIDevice.current.userInterfaceIdiom == .phone
//        {
//            self.present(imagepicker!, animated: true, completion: nil)
//        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagepicker?.dismiss(animated: true, completion: {
            if let origionalImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                self.btnStorefrontPhoto.setBackgroundImage(origionalImage, for: .normal)
                self.btnStorefrontPhoto.setImage(origionalImage, for: .normal)
                 DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(3), execute: {
                    APIController().uploadImage(image: origionalImage, successHandler: { (imageName) in
                        self.imageArr.append(["Image":imageName])
                        
                    })
                })
            }
        })
        
        
    }
    
    func imagePicker(_ imagePicker: WDImagePicker, pickedImage: UIImage?) {
        self.btnStorefrontPhoto.setBackgroundImage(pickedImage, for: .normal)
        self.btnStorefrontPhoto.setImage(pickedImage, for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(3), execute: {
            APIController().uploadImage(image: pickedImage!, successHandler: { (imageName) in
                self.imageArr.append(["Image":imageName])
                
            })
        })
        wdImagePicker.imagePickerController.dismiss(animated: true, completion: nil)
    }


    @IBAction func nextAction(_ sender: Any) {
        if(isValid())
        {
            let apiController:APIController = APIController()
            apiController.addPlace(placeName: self.txtPlaceName.text!, userId:"57" , lvl: self.txtLevel.text!, unit: self.txtUnit.text!, address: self.txtAddress.text!, lati: "\(self.annotationCoordinates.latitude)", lng: "\(self.annotationCoordinates.longitude)", imageList: imageArr, successHandler: { (jsonResponse) in
                /*{
                    "status" : "1",
                    "data" : {
                        "UserId" : 1,
                        "PlaceUnit" : 1,
                        "UpdatedDate" : null,
                        "Latitude" : "26.9003615151843",
                        "PlaceAddress" : "A-24 Sahkar Marg, Jaipur Rajasthan",
                        "Longitude" : "75.799768557437",
                        "PlaceName" : "Varun iOS ",
                        "PlaceLevel" : "B2",
                        "CreatedDate" : "\/Date(1492684604704)\/",
                        "PlaceId" : 157
                    },
                    "message" : "success"
                }*/
                if(jsonResponse["message"].string != "Place Already added!")
                {
                    let homeVC:HomeViewController = self.navigationController?.childViewControllers[(self.navigationController?.childViewControllers.count)!-2] as! HomeViewController
                    homeVC.addedAnnotation = self.annotationCoordinates
                    homeVC.isPlaceAdded = true
                    self.navigationController?.popViewController(animated: true)
                }
                else
                {
                    ServiceManager.alert(message: "The place you are trying to add already exists. Please check-in to that one")
                }
            })
        }
        
    }
    
    func isValid() -> Bool {
        
        var valid:Bool = true;
        
        let placename = txtPlaceName.text
        
        let unit = txtUnit.text
        
        if (placename?.isEmpty)! {
            txtPlaceName.setError(error: "enter place name");
            valid = false;
        }
        
        if (unit?.isEmpty)! {
            txtUnit.setError(error: "enter unit* value");
            valid = false;
        }
        
        if(imageArr.count == 0){
            valid = false;
            ServiceManager.alert(message: "Add Place Picture");
        }
        
        return valid;
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            if annotation is MKUserLocation
            {
                return nil
            }
            var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
            if annotationView == nil{
                annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "Pin")
                annotationView?.canShowCallout = false
                //                annotationView?.isDraggable = true
                annotationView?.image = UIImage(named: "alert")
            }else{
                annotationView?.annotation = annotation
            }
            annotationView?.image = UIImage(named: "icecream")
            return annotationView
        }
        
        return nil
    }
    
    func addRadiusCircle(location: CLLocation){
        self.mapView.delegate = self
        let circle = MKCircle(center: location.coordinate, radius: 100 as CLLocationDistance)
        circle.title = "Circle"
        self.mapView.add(circle)
        
//        let dot = MKCircle(center: location.coordinate, radius: 5 as CLLocationDistance)
//        dot.title = "dot"
//        self.mapView.add(dot)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if(overlay.title! == "Circle")
        {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.blue
            circle.fillColor = UIColor(red: 0, green: 0, blue: 255, alpha: 0.1)
            circle.lineWidth = 1
            return circle
        }
        else
        {
            let dot = MKCircleRenderer(overlay: overlay)
            dot.strokeColor = UIColor.blue
            dot.fillColor = UIColor.blue
            dot.lineWidth = 1
            return dot
        }
    }
    
    //Add these delegates in class
    @IBOutlet var picker: UIPickerView!
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(row < 7)
        {
            txtLevel.text = data[row]
        }
        else
        {
            txtLevel.inputView = nil
            txtLevel.keyboardType = .numberPad
            txtLevel.resignFirstResponder()
            txtLevel.becomeFirstResponder()
        }
    }
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        var items:[UIBarButtonItem] = []
        
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneButtonAction))
        let space:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        items.append(space)
        items.append(done)
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        self.txtLevel.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction()
    {
        if(pickerView.selectedRow(inComponent: 0) < 7)
        {
            txtLevel.text = data[pickerView.selectedRow(inComponent: 0)]
            
        }
        else
        {
            txtLevel.inputView = pickerView
        }
        
        self.txtLevel.resignFirstResponder()
    }
    

}
