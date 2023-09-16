import UIKit
import MapKit
import CoreLocation

class CoffeeMapNavigationViewController: UIViewController {
    
    var latitude: Double?
    var longitude: Double?
    var name: String?
    
    var route: MKRoute?
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    var destinationLocation: CLLocationCoordinate2D!
    
    // add Close button
    let closeButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Set up the map
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(closeNavigation), for: .touchUpInside)
        view.addSubview(closeButton)
        
        setDirectionsRequest()
        setAutolayout()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Request user location permission
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
}



// MARK: - MKMapViewDelegate
extension CoffeeMapNavigationViewController: MKMapViewDelegate {
    // drawing map line
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(overlay: polyline)
            renderer.strokeColor = UIColor.systemCyan
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func setDirectionsRequest() {
        // Get the user's current location
        if let userLocation = locationManager.location {
            // Use the user's current location as the center of the map
            let coordinateRegion = MKCoordinateRegion(
                center: userLocation.coordinate,
                latitudinalMeters: 500,
                longitudinalMeters: 500
            )
            mapView.setRegion(coordinateRegion, animated: true)
        }
        mapView.delegate = self
        mapView.mapType = .mutedStandard
        mapView.showsUserLocation = true
        // Set the destination location using latitude and longitude
        destinationLocation = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = destinationLocation
        destinationAnnotation.title = "\(name)"
        mapView.addAnnotation(destinationAnnotation)
        
        // Create a placemark for the source (current location)
        let sourcePlacemark = MKPlacemark(coordinate: locationManager.location?.coordinate ?? CLLocationCoordinate2D())
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        
        // Create a placemark for the destination
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        // Create a directions request
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = sourceMapItem
        directionsRequest.destination = destinationMapItem
        directionsRequest.transportType = .automobile // You can choose the transportation type as needed
        
        // Calculate directions
        let directions = MKDirections(request: directionsRequest)
        directions.calculate { [self] (response, error) in
            if let error = error {
                print("Route calculation error: \(error.localizedDescription)")
                return
            }
            if let route = response?.routes.first {
                mapView.addOverlay(route.polyline, level: .aboveRoads)
                // Save route information for later use
                self.route = route
                // Start navigation
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension CoffeeMapNavigationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
}

// MARK: - extension
extension CoffeeMapNavigationViewController {
    
    @objc func closeNavigation() {
        // close map
        self.dismiss(animated: true, completion: nil)
    }
    
    func setAutolayout() {
        // Add auto-layout constraints for the mapView
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add auto-layout constraints for the Close button
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
}
