//
//  BookShopViewController.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/14.
//


import UIKit
import Alamofire
import MapKit
import CoreLocation

class BookShopMapViewController: UIViewController {
    
    
    var bookShopCollection = [BookShop]()
    var bookShopManager = BookShopManager()
    
    let latitude = 25.039
    let longitude = 121.532
    
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookShopManager.delegate = self
        bookShopManager.loadBookShops()
        
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
        
        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        let regionRadius: CLLocationDistance = 1000
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
        // askForPositionRequest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
}

// MARK: - BookShopManagerDelegate
extension BookShopMapViewController: BookShopManagerDelegate {
    func manager(_ manager: BookShopManager, didGet BookShopList: [BookShop]) {
        DispatchQueue.main.async {
            self.bookShopCollection = BookShopList
            
            for bookShop in BookShopList {
                if let latitude = Double(bookShop.latitude),
                   let longitude = Double(bookShop.longitude) {
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = bookShop.name
                    annotation.subtitle = bookShop.address
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    func manager(_ manager: BookShopManager, didFailWith error: Error) {
        print(error.localizedDescription)
    }
    
}
    // MARK: - CLLocationManagerDelegate
    extension BookShopMapViewController: CLLocationManagerDelegate {
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Location manager error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - MKMapViewDelegate
    extension BookShopMapViewController: MKMapViewDelegate {
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            // get user tap mark
            guard let annotation = view.annotation as? MKPointAnnotation else { return }
            // 在coffeeShopCollection中查找与标注标题匹配的咖啡店
            if let selectedBookShop = bookShopCollection.first(where: { $0.name == annotation.title }) {
                guard let bookShopViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookShopViewController") as? BookShopViewController else { return }
                bookShopViewController.bookShop = selectedBookShop
                //navigationController?.pushViewController(bookShopViewController, animated: true)
                present(bookShopViewController, animated: true)
                
            }
        }
        
    }
