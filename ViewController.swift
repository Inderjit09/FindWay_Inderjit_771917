//
//  ViewController.swift
//  FindWay_Inderjit_C0771917
//
//  Created by MacBook on 2020-06-10.
//  Copyright © 2020 Inder. All rights reserved.

import UIKit
import MapKit
import CoreLocation
import AVFoundation

class ViewController: UIViewController
{
    @IBOutlet weak var btnFindMyWay: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    
    let geoCoder = CLGeocoder()
    var directionsArray: [MKDirections] = []
    
    @IBOutlet weak var zoomIn: UIButton!
    @IBOutlet weak var zoomOut: UIButton!
    
    @IBOutlet weak var label: UILabel!
    
    var route: MKRoute?
    var steps: [MKRoute.Step] = []
    var stepCounter = 0
    var navigationStarted = false
    let locationDistance = 500
    var showMapRoute = false
    
    var speechSynthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        checkLocationServices()
        mapView.isZoomEnabled = false
        
        addDoubleTap()  }
    
    @IBAction func zoomIn(_ sender: UIButton) {
        var region = MKCoordinateRegion()
        var span = MKCoordinateSpan()
        region.center = self.mapView.region.center

        span.latitudeDelta = self.mapView.region.span.latitudeDelta/2.0002
        span.longitudeDelta = self.mapView.region.span.longitudeDelta/2.0002
        region.span = span;
        mapView.setRegion(region, animated: true)  }
    
    @IBAction func zoomOut(_ sender: UIButton)  {
        var region = MKCoordinateRegion()
        var span = MKCoordinateSpan()
        region.center = self.mapView.region.center

        span.latitudeDelta = self.mapView.region.span.latitudeDelta*2.0002
        span.longitudeDelta = self.mapView.region.span.longitudeDelta*2.0002
        region.span = span;
        mapView.setRegion(region, animated: true)  }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest  }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate  {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters ,longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)  }  }

   func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization() }  }

    func addDoubleTap() {
        print("add double tap called")
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(tap) }
    
    @objc func doubleTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.mapView)
        let locCor = mapView.convert(location, toCoordinateFrom: mapView)

        let annotation = MKPointAnnotation()
annotation.coordinate = locCor
//        annotation.title = "A"
//        annotation.subtitle = "B"
         self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.addAnnotation(annotation)
        
         let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(locationManager.location!) {
            [weak self] (placemarks, error) in
             guard let self = self
             else { return }
        
             if let _ = error { return }
             guard let placemark = placemarks?.last else { return }
            var address: String = ""
        
             if placemark.subThoroughfare != nil {
                 address += placemark.subThoroughfare! + " " }
             
             if placemark.thoroughfare != nil {
                 address += placemark.thoroughfare! + "\n"  }
             
             if placemark.subLocality != nil {
                 address += placemark.subLocality! + "\n"  }
             
             if placemark.subAdministrativeArea != nil {
                 address += placemark.subAdministrativeArea! + "\n"  }
             
             if placemark.postalCode != nil {
                 address += placemark.postalCode! + "\n"  }
             
             if placemark.country != nil {
                 address += placemark.country! + "\n" }
             
             self.label.text = address
             DispatchQueue.main.async {
                 self.label.text = address  }  }  }
   
    
    @IBAction func walkingMode(_ sender: UIButton)  {
        let startingCoordinates = (locationManager.location?.coordinate)!
        let destinationCoordinates = (mapView.annotations.last?.coordinate)!
                
        let starting = MKPlacemark(coordinate: startingCoordinates)
        let destination = MKPlacemark(coordinate: destinationCoordinates)
                
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: starting)
        request.destination = MKMapItem(placemark: destination)

        request.transportType = .walking
        request.requestsAlternateRoutes = true
                
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
        if let error = error{ print(error.localizedDescription)
            return }
                        
        guard let response = response, let route = response.routes.first else { return }
        self.route = route
                    
        self.mapView.addOverlay(route.polyline)
        self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16), animated: true)
            
            for monitoredRegions in self.locationManager.monitoredRegions  {
                self.locationManager.stopMonitoring(for: monitoredRegions)  }
            let steps = route.steps
            self.steps = steps
            
            for i in 0..<steps.count    {
                let step = steps[i]
                print(step.instructions)
                print(step.distance)
                
                let region = CLCircularRegion(center: step.polyline.coordinate, radius: 20, identifier: "\(i)")
                self.locationManager.startMonitoring(for: region)     }
            self.stepCounter += 1
            let initialMessage = "In \(steps[self.stepCounter].distance) Meters \(steps[self.stepCounter].instructions), then \(steps[self.stepCounter + 1].distance) Meters \(steps[self.stepCounter + 1].instructions)"
            self.label.text = initialMessage
            let speechutterence = AVSpeechUtterance(string: initialMessage)
            self.speechSynthesizer.speak(speechutterence)  }  }
    
    @IBAction func btnFindMyWayTapped(_ sender: UIButton)  {
        let startingCoordinates = (locationManager.location?.coordinate)!
        let destinationCoordinates = (mapView.annotations.last?.coordinate)!

        let starting = MKPlacemark(coordinate: startingCoordinates)
        let destination = MKPlacemark(coordinate: destinationCoordinates)

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: starting)
        request.destination = MKMapItem(placemark: destination)

        request.transportType = .automobile
        request.requestsAlternateRoutes = true

        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
        if let error = error{ print(error.localizedDescription)
            return }

        guard let response = response, let route = response.routes.first else { return }
        self.route = route

        self.mapView.addOverlay(route.polyline)
        self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16), animated: true)  }  }
   
    func steps(route: MKRoute)  {
        for monitoredRegions in locationManager.monitoredRegions  {
            locationManager.stopMonitoring(for: monitoredRegions)  }
        let steps = route.steps
        self.steps = steps
        
        for i in 0..<steps.count  {
            let step = steps[i]
            print(step.instructions)
            print(step.distance)
            
            let region = CLCircularRegion(center: step.polyline.coordinate, radius: 20, identifier: "\(i)")
            locationManager.startMonitoring(for: region)  }
        stepCounter += 1
        let initialMessage = "In \(steps[stepCounter].distance) Meters \(steps[stepCounter].instructions), then \(steps[stepCounter + 1].distance) Meters \(steps[stepCounter + 1].instructions)"
        label.text = initialMessage
        let speechutterence = AVSpeechUtterance(string: initialMessage)
        speechSynthesizer.speak(speechutterence)  }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                mapView.showsUserLocation = true
                centerViewOnUserLocation()
                locationManager.startUpdatingLocation()
                break
            
            case .denied:
                break
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                break
            case .restricted:
                break
            case .authorizedAlways:
            break   }   }   }

extension ViewController: CLLocationManagerDelegate  {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mapView.setRegion(region, animated: true)  }  }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status:CLAuthorizationStatus)  {
        checkLocationAuthorization()   }  }
    
extension ViewController: MKMapViewDelegate  {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer   {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .systemBlue
        
        return renderer  }  }
