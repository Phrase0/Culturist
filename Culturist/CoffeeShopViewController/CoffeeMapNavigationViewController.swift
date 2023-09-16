import UIKit
import MapKit
import CoreLocation

class CoffeeMapNavigationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var latitude: Double?
    var longitude: Double?
    var name: String?
    
    var route: MKRoute?
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    var destinationLocation: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 请求用户位置权限
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // MARK: - 设置地图
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        
        // 添加 mapView 的自动布局约束
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 获取用户当前位置
        if let userLocation = locationManager.location {
            // 使用用户当前位置作为地图的中心点
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
        
        destinationLocation = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!) // 替换为目标经纬度
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = destinationLocation
        destinationAnnotation.title = "\(name)"
        mapView.addAnnotation(destinationAnnotation)
        
        let sourcePlacemark = MKPlacemark(coordinate: locationManager.location?.coordinate ?? CLLocationCoordinate2D())
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = sourceMapItem
        directionsRequest.destination = destinationMapItem
        directionsRequest.transportType = .automobile // 可以根据需要选择交通方式
        
        let directions = MKDirections(request: directionsRequest)
        directions.calculate { [self] (response, error) in
            if let error = error {
                print("路線計算錯誤：\(error.localizedDescription)")
                return
            }
            if let route = response?.routes.first {
                mapView.addOverlay(route.polyline, level: .aboveRoads)
                self.route = route // 保存路线信息，以便稍后使用
                
                // 开始导航
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }

    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(overlay: polyline)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer()
    }
}
