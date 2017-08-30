//
//  HomeViewController.swift
//  Maxting
//
//  Created by Varun Naharia on 30/03/17.
//  Copyright © 2017 Logictrix. All rights reserved.
//

import UIKit
import MapKit

class HomeViewController: UIViewController, MKMapViewDelegate, LocationManagerDelegate {
    let GoogleMapsAPIServerKey = "AIzaSyCcRfm46grZkxmqPmN51baEkMa4Fq_X9oc"
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var viewTip: UIView!
    @IBOutlet weak var lblTip: UILabel!
    @IBOutlet weak var viewSearch: UIView!
    var addedAnnotation:CLLocationCoordinate2D!
    var mapImage:UIImage!
    var arrAnnotation:[JSON] = []
    var arrVisibleAnnotation:[CustomPointAnnotation] = []
    var locationManager:LocationManager = LocationManager.sharedInstance
    var isFirstRun:Bool = true
    var isRegionChange:Bool = false
    var isPlaceEditing:Bool = false
    var isPlaceAdded = false
    var selectedPlace = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        isFirstRun = true
        // Do any additional setup after loading the view.
        //        self.navigationItem.setHidesBackButton(true, animated:true);
        
        //viewSearch.elevate(elevation: 5)
        let countObj = Utilities.getUserDefault(KeyToReturnValye: "NumberOfRun")
        var count = 0
        if(countObj == nil)
        {
            count = 0
        }
        else
        {
            count = countObj as! Int
        }
        if(count >= 3)
        {
            viewTip.isHidden = true
        }
        Utilities.setUserDefault(ObjectToSave: count+1 as AnyObject, KeyToSave: "NumberOfRun")
        
        //        self.mapView.showsUserLocation = true
        //        mapView.userTrackingMode = MKUserTrackingMode.follow
        LocationManager.sharedInstance.getLocation { (location) in
            self.mapView.setCenter(coordinate: location.coordinate, zoomLevel: 16, animated: true)
           
            Utilities.getAddressFrom(location: location, completion: { (locationAddress) in
                if(locationAddress != nil)
                {
                    //self.txtLocation.text = locationAddress
                }
            })
            self.addRadiusCircle(location: location)
            self.mapView.region = MKCoordinateRegionMakeWithDistance(
                location.coordinate,
                280,
                280
            );
        }
        locationManager.delegate = self
        self.getAllAddedPlace()
    }
    
    @IBAction func currentLocationAction(_ sender: UIButton) {
        LocationManager.sharedInstance.getLocation { (location) in
            self.mapView.setCenter(coordinate: location.coordinate, zoomLevel: 16, animated: true)
            self.mapView.removeAllOverlay()
            self.addRadiusCircle(location: location)
            self.reloadMapData()
            Utilities.getAddressFrom(location: location, completion: { (locationAddress) in
                if(locationAddress != nil)
                {
                    //                    self.txtLocation.text = locationAddress
                }
                self.mapView.region = MKCoordinateRegionMakeWithDistance(
                    location.coordinate,
                    280,
                    280
                );
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Add a Place"
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        Utilities.setStatusBarColor(color: UIColor(red: 0.68, green: 0.68, blue: 0.68, alpha: 0.50), controller: self)
        
        annotation = nil
        if(isPlaceAdded)
        {
            isPlaceAdded = false
            self.getAllAddedPlace()
        }
        
        if(selectedPlace != "")
        {
            let selectedAnnotation = arrVisibleAnnotation.filter({$0.data?["PlaceId"].stringValue == selectedPlace})
            for annotation in arrVisibleAnnotation {
                mapView.deselectAnnotation(annotation, animated: false)
            }
            mapView.selectAnnotation(selectedAnnotation[0], animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    func locationUpdated(location: CLLocation) {
        self.mapView.removeAllOverlay()
        self.addRadiusCircle(location: location)
    }
    var annotation:CustomPointAnnotation!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func menuAction(_ sender: Any) {
        
    }
    var annotationViewAdd:UIView!
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation
        {
            return nil
        }
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil{
            annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        }else{
            annotationView?.annotation = annotation
        }
        
        let customAnnotation:CustomPointAnnotation = annotation as! CustomPointAnnotation
        if(customAnnotation.data == nil)
        {
            annotationView?.isDraggable = true
            
            annotationView?.image = #imageLiteral(resourceName: "ic_addplace")
            annotationView?.layer.zPosition = 999
        }
        else
        {
            annotationView?.isDraggable = false
            customAnnotation.annotation = annotation
            if((customAnnotation.data?["CheckInCount"].floatValue)! > 0 && (customAnnotation.data?["CheckInCount"].floatValue)! <= ceilf(Float(AppConstants.checkinGoal/3)))
            {
                annotationView?.image = UIImage(named: "greeniecream")
            }
            else if((customAnnotation.data?["CheckInCount"].floatValue)! > ceilf(Float(AppConstants.checkinGoal/3)) && (customAnnotation.data?["CheckInCount"].floatValue)! <= ceilf(Float(AppConstants.checkinGoal/2)))
            {
                annotationView?.image = UIImage(named: "greenpink")
            }
            else if((customAnnotation.data?["CheckInCount"].floatValue)! > ceilf(Float(AppConstants.checkinGoal/2)))
            {
                annotationView?.image = UIImage(named: "icereamrgb")
            }
            else
            {
                annotationView?.image = UIImage(named: "icecream")
            }
        }
        
        formatAnnotation(pinView: annotationView!, forMapView: mapView)
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch newState {
        case .starting:
            view.dragState = .dragging
            print("start")
        case .ending, .canceling:
            view.dragState = .none
            print("end")
            if(isCoordinateInside(tappedCoordinates: (view.annotation?.coordinate)!))
            {
                let vc:AddPlaceViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddPlaceViewController") as! AddPlaceViewController
                vc.mapImage = self.mapImage
                
                let nameAddress = Utilities.getNameOf(location:(view.annotation?.coordinate)!)
                print(nameAddress)
                if(nameAddress != "")
                {
                    vc.address = nameAddress
                }
                else
                {
                    vc.address = "No Location"
                }
                vc.annotationCoordinates = view.annotation?.coordinate
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else
            {
                if(self.annotation != nil)
                {
                    self.mapView.removeAnnotation(self.annotation)
                }
                self.annotation = CustomPointAnnotation()
                self.annotation.title = ""
                self.annotation.coordinate = LocationManager.sharedInstance.location.coordinate
                self.mapView.addAnnotation(self.annotation)
                viewTip.isHidden = false
            }
            
        default: break
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapView.annotations.forEach {
            if !($0 is MKUserLocation) {
                self.mapView.removeAnnotation($0)
            }
        }
        var i = 0
        for annotationJson:JSON in self.arrAnnotation
        {
            let annotation = CustomPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: Double(annotationJson["Latitude"].string!)!, longitude: Double(annotationJson["Longitude"].string!)!)
            annotation.data = annotationJson
            annotation.index = i
            self.mapView.addAnnotation(annotation)
            i += 1
        }
        if(self.annotation != nil)
        {
            self.mapView.addAnnotation(self.annotation)
        }
        isRegionChange = true
        if(self.annotation != nil)
        {
            self.mapView.removeAnnotation(self.annotation)
        }
        self.annotation = CustomPointAnnotation()
        self.annotation.title = ""
        self.annotation.coordinate = LocationManager.sharedInstance.location.coordinate
        self.mapView.addAnnotation(self.annotation)
        //self.mapView.selectAnnotation(self.annotation, animated: true)
        reloadMapData()
    }
    
    func formatAnnotation(pinView: MKAnnotationView, forMapView: MKMapView) {
        let zoomLevel = forMapView.getZoomLevel()
        let scale = 0.05263158 * zoomLevel //Modify to whatever scale you need.
        pinView.transform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
        
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
            circle.strokeColor = UIColor(red: 0, green: 0, blue: 255, alpha: 0.1)
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
    
    let newPlaceCallOutView:UILabel = UILabel()
    var selectedAnnotationView:CustomPointAnnotation!
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation
        {
            
            return
        }
        if(selectedAnnotationView != nil)
        {
            if((selectedAnnotationView.data?["CheckInCount"].floatValue)! > 0 && (selectedAnnotationView.data?["CheckInCount"].floatValue)! <= ceilf(Float(AppConstants.checkinGoal/3)))
            {
                view.image = UIImage(named: "greeniecream")
            }
            else if((selectedAnnotationView.data?["CheckInCount"].floatValue)! > ceilf(Float(AppConstants.checkinGoal/3)) && (selectedAnnotationView.data?["CheckInCount"].floatValue)! <= ceilf(Float(AppConstants.checkinGoal/2)))
            {
                view.image = UIImage(named: "greenpink")
            }
            else if((selectedAnnotationView.data?["CheckInCount"].floatValue)! > ceilf(Float(AppConstants.checkinGoal/2)))
            {
                view.image = UIImage(named: "icereamrgb")
            }
            else
            {
                view.image = UIImage(named: "icecream")
            }
        }
        let customAnnotation:CustomPointAnnotation = view.annotation as! CustomPointAnnotation
        if customAnnotation.data == nil {
            view.image = #imageLiteral(resourceName: "ic_addplace")
        }
        else
        {
            selectedAnnotationView = customAnnotation
            if((customAnnotation.data?["CheckInCount"].floatValue)! > 0 && (customAnnotation.data?["CheckInCount"].floatValue)! <= ceilf(Float(AppConstants.checkinGoal/3)))
            {
                view.image = UIImage(named: "selectgreen")
            }
            else if((customAnnotation.data?["CheckInCount"].floatValue)! > ceilf(Float(AppConstants.checkinGoal/3)) && (customAnnotation.data?["CheckInCount"].floatValue)! <= ceilf(Float(AppConstants.checkinGoal/2)))
            {
                view.image = UIImage(named: "selectgreenpink")
            }
            else if((customAnnotation.data?["CheckInCount"].floatValue)! > ceilf(Float(AppConstants.checkinGoal/2)))
            {
                view.image = UIImage(named: "selecticecream")
            }
            else
            {
                view.image = UIImage(named: "selecticeream")
            }
            var i = 0
            var index:Int = -1
            for annotation in arrVisibleAnnotation {
                if(annotation.data?["PlaceId"] == customAnnotation.data?["PlaceId"])
                {
                    index = i
                }
                i += 1
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.annotation is MKUserLocation
        {
            return
        }
        let customAnnotation:CustomPointAnnotation = view.annotation as! CustomPointAnnotation
        if customAnnotation.data == nil {
            view.image = #imageLiteral(resourceName: "ic_addplace")
            return
        }
        if((customAnnotation.data?["CheckInCount"].floatValue)! > 0 && (customAnnotation.data?["CheckInCount"].floatValue)! <= ceilf(Float(AppConstants.checkinGoal/3)))
        {
            view.image = UIImage(named: "greeniecream")
        }
        else if((customAnnotation.data?["CheckInCount"].floatValue)! > ceilf(Float(AppConstants.checkinGoal/3)) && (customAnnotation.data?["CheckInCount"].floatValue)! <= ceilf(Float(AppConstants.checkinGoal/2)))
        {
            view.image = UIImage(named: "greenpink")
        }
        else if((customAnnotation.data?["CheckInCount"].floatValue)! > ceilf(Float(AppConstants.checkinGoal/2)))
        {
            view.image = UIImage(named: "icereamrgb")
        }
        else
        {
            view.image = UIImage(named: "icecream")
        }
        
    }
    
    
    func isTappedOnPolygon(with tapGesture:UIGestureRecognizer, on mapView: MKMapView) -> Bool {
        let tappedMapView = tapGesture.view
        let tappedPoint = tapGesture.location(in: tappedMapView)
        let tappedCoordinates = mapView.convert(tappedPoint, toCoordinateFrom: tappedMapView)
        return isCoordinateInside(tappedCoordinates: tappedCoordinates)
    }
    
    func isCoordinateInside(tappedCoordinates:CLLocationCoordinate2D)->  Bool {
        let point:MKMapPoint = MKMapPointForCoordinate(tappedCoordinates)
        
        let overlays = mapView.overlays
        for overlay in overlays {
            let polygonRenderer = MKCircleRenderer(overlay: overlay)
            let datPoint = polygonRenderer.point(for: point)
            polygonRenderer.invalidatePath()
            print("piont= \(point)\n datapoint= \(datPoint)")
            return polygonRenderer.path.contains(datPoint)
        }
        return false
    }
    
    func isAnnotationInRadius(coordinates:CLLocationCoordinate2D) -> Bool {
        
        let point:MKMapPoint = MKMapPointForCoordinate(coordinates)
        let overlays = mapView.overlays
        for overlay in overlays {
            let polygonRenderer = MKCircleRenderer(overlay: overlay)
            let datPoint = polygonRenderer.point(for: point)
            polygonRenderer.invalidatePath()
            print("piont= \(point)\n datapoint= \(datPoint)")
            return polygonRenderer.path.contains(datPoint)
        }
        return false
    }
    
    func getAllAddedPlace(){
        let apiContreoller:APIController = APIController()
        apiContreoller.getNearbyPlace(latitude: "\(LocationManager.sharedInstance.location.coordinate.latitude)", longitude: "\(LocationManager.sharedInstance.location.coordinate.longitude)", radius: "1000") { (response) in
            self.arrAnnotation = response["data"].array!
            self.mapView.removeAnnotations(self.mapView.annotations)
            var isAnnotationAdded:Bool = false
            var foundAnnotation:CustomPointAnnotation = CustomPointAnnotation()
            if let location: CLLocationCoordinate2D? = self.addedAnnotation {
                if CLLocationCoordinate2DIsValid(location!) {
                    print("Coordinate valid")
                    isAnnotationAdded = true
                    
                } else {
                    isAnnotationAdded = false
                    print("Coordinate invalid")
                }
            }
            var index = 0
            for annotationJson:JSON in self.arrAnnotation
            {
                let annotation = CustomPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: Double(annotationJson["Latitude"].string!)!, longitude: Double(annotationJson["Longitude"].string!)!)
                annotation.data = annotationJson
                annotation.index = index
                
                if(isAnnotationAdded)
                {
                    if("\(self.addedAnnotation.latitude)" == "\(annotation.coordinate.latitude)" && "\(self.addedAnnotation.longitude)" == "\(annotation.coordinate.longitude)")
                    {
                        foundAnnotation = annotation
                    }
                }
                self.mapView.addAnnotation(annotation)
                index += 1
            }
            self.reloadMapData()
            if(self.annotation != nil)
            {
                self.mapView.removeAnnotation(self.annotation)
            }
            self.annotation = CustomPointAnnotation()
            self.annotation.title = ""
            self.annotation.coordinate = LocationManager.sharedInstance.location.coordinate
            self.mapView.addAnnotation(self.annotation)
            //self.mapView.selectAnnotation(self.annotation, animated: true)
//            DispatchQueue.main.asyncAfter(deadline: .now()+DispatchTimeInterval.seconds(4), execute: {
//                self.mapView.selectAnnotation(foundAnnotation, animated: true)
//            })
            
            
        }
    }
    
    func reloadMapData() {
        self.arrVisibleAnnotation = self.getVisiblePlace()
        self.arrVisibleAnnotation = self.arrVisibleAnnotation.sorted(by: {$0.distance < $1.distance})
        if(self.arrVisibleAnnotation.count > 1)
        {
            for annotation in arrVisibleAnnotation {
                mapView.deselectAnnotation(annotation, animated: false)
            }
            self.mapView.selectAnnotation(self.arrVisibleAnnotation[1], animated: true)
        }
    }
    
    func getVisiblePlace() -> [CustomPointAnnotation] {
        
        let annotations = mapView.annotations(in: mapView.visibleMapRect)
        var tempAnnotation:[CustomPointAnnotation] = []
        for annotation in annotations {
            if(annotation is CustomPointAnnotation)
            {
                (annotation as! CustomPointAnnotation).calculateDistance(fromLocation: LocationManager.sharedInstance.location)
                
                tempAnnotation.append(annotation as! CustomPointAnnotation)
            }
        }
        return tempAnnotation
    }
    @IBAction func dismissMissTip(_ sender: UITapGestureRecognizer) {
        viewTip.isHidden = true
    }
    
}
