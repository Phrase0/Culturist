//
//  MapViewController.swift
//  Culturist
//
//  Created by Peiyun on 2024/3/6.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var userAnnotation: MKPointAnnotation?
    
    var routes: [MKRoute]?
    var updateUserLocationTimer: Timer?
    
    var name: String?
    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.isZoomEnabled = true
        mapView.showsUserLocation = true
        
        routes?.forEach { mapView.addOverlay($0.polyline) }
        
        setCloseButton()
        setLocationManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setRegion()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - functions
    func setCloseButton() {
        let closeImage = UIImage.asset(.Icons_36px_Close_Black)?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(backButtonTapped))
    }
    
    @objc private func backButtonTapped() {
        self.dismiss(animated: true)
    }
    
    func setRegion() {
        // Check if userAnnotation is available
        guard let userAnnotation = userAnnotation else {
            return
        }
        
        // Get the coordinates of the userAnnotation
        let centerCoordinate = userAnnotation.coordinate
        // Define a span for the region (adjust these values according to your requirements)
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        // Create a region using the center coordinate and span
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        
        // Set the region on the mapView
        mapView.setRegion(region, animated: true)
    }
    
    func setLocationManager() {
        // Request location authorization and start updating the user's location
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

// MARK: - MKMapViewDelegate
@available(iOS 11.0, *)
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 3
        renderer.strokeColor = UIColor.systemCyan.withAlphaComponent(0.7)
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation),
              let pointAnnotation = annotation as? MKPointAnnotation else { return nil }
        let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
        if pointAnnotation == self.userAnnotation {
            marker.displayPriority = .required
            marker.glyphImage = UIImage(named: "user")
        } else {
            marker.displayPriority = .required
            marker.markerTintColor = UIColor(hue: 0.267, saturation: 0.67, brightness: 0.77, alpha: 1.0)
            marker.glyphImage = UIImage(named: "compass")
        }
        return marker
    }
}

extension MapViewController: CLLocationManagerDelegate {
    // update location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last?.coordinate else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Remove existing overlays
            self.mapView.removeOverlays(self.mapView.overlays)

            if self.userAnnotation == nil {
                self.userAnnotation = MKPointAnnotation()
                self.mapView.addAnnotation(self.userAnnotation!)

                // add destinationAnnotation
                let destinationLocation = CLLocationCoordinate2D(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
                let destinationAnnotation = MKPointAnnotation()
                destinationAnnotation.coordinate = destinationLocation
                destinationAnnotation.title = self.name
                self.mapView.addAnnotation(destinationAnnotation)
            }

            UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
                self.userAnnotation?.coordinate = currentLocation
            }, completion: nil)

            routes?.forEach { self.mapView.addOverlay($0.polyline) }
        }
    }
}

