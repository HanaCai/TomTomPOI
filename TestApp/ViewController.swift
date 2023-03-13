//
//  ViewController.swift
//  TestApp
//
//  Created by Hana Cai on 12/29/2022.
//

import UIKit
import MapKit
import CoreMotion
import ARKit


class ViewController: UIViewController {
    //MARK: - Constants
    let locationManager = CLLocationManager()
    let motionManager = CMMotionManager()
    let viewModel = ViewModel()

    //MARK: - IBOutlets Vars
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var senserView: UIView!
    @IBOutlet weak var sceneView: ARSCNView!
    
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViewModel()
        requestLocation()
        setAndListenToAccelerometer()
        setUpSceneView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //startSceneViewSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
        stopListeningToAccelerometer()
    }
    
    //MARK: - Setup methods
    func setupViewModel(){
        viewModel.onDidFetchedPlaces = { [weak self] responseModel in
            guard let responseModel = responseModel, let self = self else{return}
            self.prepareMapViewFrom(responseModel)
            self.prepareSceneViewFrom(responseModel)
        }
    }
    
    func setUpSceneView(){
        // Create a new scene
        let scene = SCNScene()
        // Set the scene to the view
        sceneView.scene = scene
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    private func requestLocation(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    private func mapRegion(with center: CLLocationCoordinate2D, miles: Double)-> MKCoordinateRegion{
        let span = MKCoordinateSpan.init(latitudeDelta: spanDegreeFromMiles(miles/10), longitudeDelta: spanDegreeFromMiles(miles/10))
        return MKCoordinateRegion(center: center, span: span)
    }
    
    func prepareSceneViewFrom(_ model: ResponseModel){
        for item in model.results{
            guard let geoBias = item.position else{continue}
            viewModel.addModel(location: CLLocation.init(latitude: geoBias.lat, longitude: geoBias.lon), sceneView: sceneView )
        }
    }
    
    func prepareMapViewFrom(_ model: ResponseModel){
        let annotations: [MKPointAnnotation] = viewModel.getAnnotationUsing(model)
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
    }
    
    func updateSenserUI(_ yAcceleration: Double){
        let isPhoneIsLiltedFromFlatToUp = (-yAcceleration)>0.5
        senserView.isHidden = isPhoneIsLiltedFromFlatToUp ? false : true
    }
}


extension ViewController: CLLocationManagerDelegate{
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse{
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let currentLocation = location.coordinate
        
        viewModel.userLocation = location
        let region = mapRegion(with: currentLocation, miles: AppConstants.regionRadiusInMiles)
        mapView.setRegion(region, animated: true)
        viewModel.requestPlacesFor(currentLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension ViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId, for: annotation)
        pinView.tintColor = .orange
        pinView.canShowCallout = true
        return pinView
        
    }
}

//MARK: - Accelerometer Setup
extension ViewController{
    func setAndListenToAccelerometer(){
        // How frequently to read accelerometer updates, in seconds
        motionManager.accelerometerUpdateInterval = 0.5
        // Start accelerometer updates on a specific thread
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            // Handle acceleration update
            guard let data = data else{return}
            self?.updateSenserUI(data.acceleration.y)
        }
    }
    
    func stopListeningToAccelerometer(){
        motionManager.stopAccelerometerUpdates()
    }
}

//MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate{}


