//
//  POIViewController+ARSCNViewDelegate.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/19.
//

import ARKit
import UIKit
import MapKit

// MARK: - MKMapViewDelegate
@available(iOS 11.0, *)
extension NavigationViewController: MKMapViewDelegate {
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
    
    // let map can scale
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first,
              let view = touch.view else { return }
        
        if mapView == view || mapView.recursiveSubviews().contains(view) {
            centerMapOnUserLocation = false
        } else {
            let location = touch.location(in: self.view)
            
            if location.x <= 40 && adjustNorthByTappingSidesOfScreen {
                print("left side of the screen")
                sceneLocationView.moveSceneHeadingAntiClockwise()
            } else if location.x >= view.frame.size.width - 40 && adjustNorthByTappingSidesOfScreen {
                print("right side of the screen")
                sceneLocationView.moveSceneHeadingClockwise()
            }
        }
    }
}

@available(iOS 11.0, *)
extension NavigationViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("Added SCNNode: \(node)")    // you probably won't see this fire
    }

    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
        print("willUpdate: \(node)")    // you probably won't see this fire
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        print("Camera: \(camera)")
    }
}

@available(iOS 11.0, *)
extension NavigationViewController: ARSessionDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        let alertController = UIAlertController(title: NSLocalizedString("警告"), message: NSLocalizedString("內存空間不足，請關閉AR導航，重新啟動"), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("確定"), style: .default, handler: { _ in
            self.dismiss(animated: true)
        }))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension DispatchQueue {
    func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
        self.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: execute)
    }
}

extension UIView {
    func recursiveSubviews() -> [UIView] {
        var recursiveSubviews = self.subviews
        subviews.forEach { recursiveSubviews.append(contentsOf: $0.recursiveSubviews()) }
        return recursiveSubviews
    }
}
