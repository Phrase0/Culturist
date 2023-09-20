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

class BookShopMapViewController: UIViewController, CLLocationManagerDelegate {

    var bookShopCollection = [BookShop]()
    var bookShopManager = BookShopManager()
    let locationManager = CLLocationManager()
    
    var latitude: Double?
    var longitude: Double?
    let mapView = MKMapView()
    
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
        
        let initialLocation = CLLocation(latitude: latitude ?? 25.039, longitude: longitude ?? 121.532)
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
        // Request user location permission
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
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
    
    // MARK: - MKMapViewDelegate
    extension BookShopMapViewController: MKMapViewDelegate {
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            // get user tap mark
            guard let annotation = view.annotation as? MKPointAnnotation else { return }
            //  find the same name in bookShopCollection
            if let selectedBookShop = bookShopCollection.first(where: { $0.name == annotation.title }) {
                guard let bookShopViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookShopViewController") as? BookShopViewController else { return }
                bookShopViewController.bookShop = selectedBookShop
                //navigationController?.pushViewController(bookShopViewController, animated: true)
                present(bookShopViewController, animated: true)                
            }
        }
        
    }
