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
import NVActivityIndicatorView

class CoffeeShopMapViewController: UIViewController, CLLocationManagerDelegate {
    
    var coffeeShopCollection = [CoffeeShop]()
    var coffeeShopManager = CoffeeShopManager()
    let locationManager = CLLocationManager()
    
    var exhibitionLocation: String?
    var latitude: Double?
    var longitude: Double?
    let mapView = MKMapView()
    
    let loading = NVActivityIndicatorView(frame: .zero, type: .ballGridPulse, color: .GR0, padding: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAnimation()
        loading.startAnimating()
        
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
        if let latitude = latitude, let longitude = longitude {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let customAnnotation = CustomAnnotation(coordinate: coordinate, title: exhibitionLocation, pinColor: .GR1!)
            self.mapView.addAnnotation(customAnnotation)
        }
        
        let regionRadius: CLLocationDistance = 500
        let coordinateRegion = MKCoordinateRegion(
            center: initialLocation.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
        
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.delegate = self
        
        // closeBtn
        let closeImage = UIImage.asset(.Icons_36px_Close_Black)?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(backButtonTapped))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Request user location permission
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func setAnimation() {
        view.addSubview(loading)
        loading.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
    }
    
    @objc private func backButtonTapped() {
        self.dismiss(animated: true)
    }
    
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
                    self.mapView.addAnnotation(annotation)
                }
            }
            self.loading.stopAnimating()
        }
    }
    
    func manager(_ manager: CoffeeShopManager, didFailWith error: Error) {
        // print(error.localizedDescription)
        self.loading.stopAnimating()
    }
}

// MARK: - MKMapViewDelegate
extension CoffeeShopMapViewController: MKMapViewDelegate {
    // set exhibitionLocation pincolor
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            // Do not change the style of user location annotation
            return nil
        }
        if let customAnnotation = annotation as? CustomAnnotation {
            let annotationView = MKPinAnnotationView(annotation: customAnnotation, reuseIdentifier: "customAnnotation")
            annotationView.pinTintColor = customAnnotation.pinColor
            annotationView.canShowCallout = true
            return annotationView
        }
        return nil
    }
    
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
