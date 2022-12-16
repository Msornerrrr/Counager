//
//  MapViewController.swift
//  JiangRichardFinalProject
//
//  Created by XuGX on 2022/11/19.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // for weather & location
    private let weatherService = WeatherService.sharedInstance
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    
    // for map & annotation
    private let annotationService = AnnotationService.sharedInstance
    var currentLocation: CLLocation?
    var selectedAnnotation: MKAnnotation?
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var descripLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var UnitSegmentedControl: UISegmentedControl!
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var saveButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // init UI
        UnitSegmentedControl.selectedSegmentIndex = 0
        saveButton.isEnabled = false
        
        // location manager setup
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self
        
        // request permission
        locationManager.requestWhenInUseAuthorization()
        
        // start updating location
        locationManager.startUpdatingLocation()
        
        // load annotation data into map, should called only once
        annotationService.load()
        annotationService.loadMap = {
            self.populateAnnotation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.startUpdatingHeading()
        saveButton.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    
    // get placemark info from location
    private func reverseGeocode(location: CLLocation, onSuccess: @escaping ((String?) -> Void)) {
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil {
                print(error!)
                return
            }
            
            onSuccess(placemarks?.first?.locality)
        }
    }
    
    private func updateUI(city: String) {
        self.weatherService.city = city
        self.weatherService.unitIndex = UnitSegmentedControl.selectedSegmentIndex
        self.weatherService.updateWeatherData() { weatherInfo in
            DispatchQueue.main.async {
                self.mainLabel.text = weatherInfo.weather[0].main
                self.descripLabel.text = weatherInfo.weather[0].description
                let tempFormated = round(weatherInfo.main.temp).formatted()
                let unit = self.weatherService.unitIndex == 0 ? "°C" : "°F"
                self.tempLabel.text = tempFormated + " " + unit
            }
        }
    }
    
    // private helper functions
    private func setLocation(coordinate: CLLocationCoordinate2D) {
        // center the map around user
        let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: center, span: span)
        myMapView.setRegion(region, animated: false)
    }
    
    // for location change
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            // update current location
            currentLocation = location
            setLocation(coordinate: location.coordinate)
            
            reverseGeocode(location: location) { city in
                if city != nil && city != self.weatherService.city {
                    self.updateUI(city: city!)
                }
            }
        }
    }
    
    
    /* for annotation method */
    private func addAnnotation(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
//        annotation.title = "title"
        myMapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }

        let id = "myAnnotationView"
        var annotationView = myMapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView
        if annotationView == nil {
            // create & assign annotation
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
            annotationView!.isDraggable = true      // draggable
            annotationView!.canShowCallout = true
        } else {
            // assign annotaiton
            annotationView!.annotation = annotation
        }
        
        // style annotation

        return annotationView
    }
    
    // update selected annotation
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedAnnotation = view.annotation
    }
    
    // dragging settings
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        switch newState {
        case .starting:
            view.dragState = .dragging
        case .ending, .canceling:
            // access updated coordinate
            // need to save
            view.dragState = .none
        default: break
        }
    }
    
    // populate annotations from annotation service
    private func populateAnnotation() {
        for annotation in self.annotationService.annotations {
            self.addAnnotation(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(truncating: annotation.latitude), longitude: CLLocationDegrees(truncating: annotation.longitude)))
        }
    }
    
    // translate current annotion into service
    private func translateAnnotation() {
        var annotations: [Annotation] = []
        for annotation in myMapView.annotations {
            if annotation is MKUserLocation { continue }    // skip user location
            let lat = NSNumber(value: annotation.coordinate.latitude)
            let lng = NSNumber(value: annotation.coordinate.longitude)
            annotations.append(Annotation(
                latitude: lat, longitude: lng
            ))
        }
        annotationService.annotations = annotations
    }
    
    
    /* IBAction */
    // click to add a pin to the center of map view
    @IBAction func addPinDidTapped(_ sender: UIButton) {
        addAnnotation(coordinate: myMapView.centerCoordinate)
        saveButton.isEnabled = true
    }
    
    // click to remove user selected pin
    @IBAction func deletePinDidTapped(_ sender: UIButton) {
        if let selectedAnnotation {
            myMapView.removeAnnotation(selectedAnnotation)
            saveButton.isEnabled = true
        }
    }
    
    // click to save pins
    @IBAction func saveDidTapped(_ sender: UIButton) {
        // save data
        translateAnnotation()
        annotationService.save()
        saveButton.isEnabled = false
    }
    
    // click to switch temperature unit
    @IBAction func UnitSegControlDidTapped(_ sender: UISegmentedControl) {
        updateUI(city: weatherService.city)
    }
    
}
