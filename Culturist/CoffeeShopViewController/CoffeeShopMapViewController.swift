//
//  CoffeeShopMapViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/14.
//

import UIKit
import Alamofire
import MapKit
import CoreLocation

class CoffeeShopMapViewController: UIViewController, CLLocationManagerDelegate {
    
    var coffeeShopCollection = [CoffeeShop]()
    var coffeeShopManager = CoffeeShopManager()
    let locationManager = CLLocationManager()
    
    var latitude: Double?
    var longitude: Double?
    let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coffeeShopManager.delegate = self
        coffeeShopManager.loadCoffeeShops()
        
        // MARK: - set Map
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        
        // add mapView autolayout
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let initialLocation = CLLocation(latitude: latitude ?? 25.039, longitude: longitude ?? 121.532)
        let regionRadius: CLLocationDistance = 500
        let coordinateRegion = MKCoordinateRegion(
            center: initialLocation.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
        
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Request user location permission
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // askForPositionRequest
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.requestAlwaysAuthorization()
//        locationManager.startUpdatingLocation()
//    }

}

// MARK: - CoffeeShopManagerDelegate

extension CoffeeShopMapViewController: CoffeeShopManagerDelegate {
    func manager(_ manager: CoffeeShopManager, didGet CoffeeShopList: [CoffeeShop]) {
        DispatchQueue.main.async {
            self.coffeeShopCollection = CoffeeShopList
            
            for coffeeShop in CoffeeShopList {
                if let latitude = Double(coffeeShop.latitude),
                   let longitude = Double(coffeeShop.longitude) {
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = coffeeShop.name
                    annotation.subtitle = coffeeShop.address
                    self.mapView.addAnnotation(annotation)
                }
            }
            
        }
    }
    
    func manager(_ manager: CoffeeShopManager, didFailWith error: Error) {
        print(error.localizedDescription)
    }
}

// MARK: - MKMapViewDelegate
extension CoffeeShopMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // get user tap mark
        guard let annotation = view.annotation as? MKPointAnnotation else { return }
        // find the same name in coffeeShopCollection
        if let selectedCoffeeShop = coffeeShopCollection.first(where: { $0.name == annotation.title }) {
            guard let coffeeShopViewController = self.storyboard?.instantiateViewController(withIdentifier: "CoffeeShopViewController") as? CoffeeShopViewController else { return }
            coffeeShopViewController.coffeeShop = selectedCoffeeShop
            // navigationController?.pushViewController(coffeeShopViewController, animated: true)
            present(coffeeShopViewController, animated: true)
            
        }
    }
    
}
