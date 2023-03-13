//
//  ViewModel.swift
//  TestApp
//
//  Created by Hana Cai on 12/30/2022.
//

import Foundation
import MapKit
import CoreMotion
import ARKit

class ViewModel{
    private let heading = 0.0
    var userLocation: CLLocation = CLLocation()
    var onDidFetchedPlaces: ResponseCompletion?
}

//MARK: - SceneKit
extension ViewModel{
        
    func addModel(location: CLLocation, sceneView: ARSCNView){
        guard let modelScene = SCNScene(named: "art.scnassets/ship.scn"),
              let modelNode = modelScene.rootNode.childNode(withName: "ship", recursively: true) else{
            return
        }
        
        // Move model's pivot to its center in the Y axis
        let (minBox, maxBox) = modelNode.boundingBox
        modelNode.pivot = SCNMatrix4MakeTranslation(0, (maxBox.y - minBox.y)/2, 0)
  
        // Position the model in the correct place
        positionModel(location, modelNode: modelNode)
        
        // Add the model to the scene
        sceneView.scene.rootNode.addChildNode(modelNode)
        
        // Create arrow from the emoji
        let arrow = makeBillboardNode("⬇️".image()!)
        // Position it on top of the car
        arrow.position = SCNVector3Make(0, 4, 0)
        // Add it as a child of the car model
        modelNode.addChildNode(arrow)
    }
    
    func makeBillboardNode(_ image: UIImage) -> SCNNode {
        let plane = SCNPlane(width: 10, height: 10)
        plane.firstMaterial!.diffuse.contents = image
        let node = SCNNode(geometry: plane)
        node.constraints = [SCNBillboardConstraint()]
        return node
    }
    
    func positionModel(_ location: CLLocation, modelNode: SCNNode) {
        // Rotate node
        modelNode.transform = rotateNode(Float(-1 * (self.heading - 180).toRadians()), modelNode.transform)
        
        // Translate node
        modelNode.position = translateNode(location)
        
        // Scale node
        modelNode.scale = scaleNode(location)
    }
    
    func scaleNode (_ location: CLLocation) -> SCNVector3 {
        let distance = Float(location.distance(from: self.userLocation))
        let scale = max( min( Float(1000/distance), 1.5 ), 3 )
        return SCNVector3(x: scale, y: scale, z: scale)
    }
    
    func rotateNode(_ angleInRadians: Float, _ transform: SCNMatrix4) -> SCNMatrix4 {
        let rotation = SCNMatrix4MakeRotation(angleInRadians, 0, 1, 0)
        return SCNMatrix4Mult(transform, rotation)
    }
    
    func translateNode (_ location: CLLocation) -> SCNVector3 {
        let locationTransform = transformMatrix(matrix_identity_float4x4, userLocation, location)
        return positionFromTransform(locationTransform)
    }
    
    func positionFromTransform(_ transform: simd_float4x4) -> SCNVector3 {
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
    
    func transformMatrix(_ matrix: simd_float4x4, _ originLocation: CLLocation, _ driverLocation: CLLocation) -> simd_float4x4 {
        let bearing = bearingBetweenLocations(userLocation, driverLocation)
        let rotationMatrix = rotateAroundY(matrix_identity_float4x4, Float(bearing))
        
        let distance = Float(driverLocation.distance(from: self.userLocation))
        
        let position = vector_float4(0.0, 0.0, -distance, 0.0)
        let translationMatrix = getTranslationMatrix(matrix_identity_float4x4, position)
        
        let transformMatrix = simd_mul(rotationMatrix, translationMatrix)
        
        return simd_mul(matrix, transformMatrix)
    }
    
    func getTranslationMatrix(_ matrix: simd_float4x4, _ translation : vector_float4) -> simd_float4x4 {
        var matrix = matrix
        matrix.columns.3 = translation
        return matrix
    }

    
    func rotateAroundY(_ matrix: simd_float4x4, _ degrees: Float) -> simd_float4x4 {
        var matrix = matrix
        
        matrix.columns.0.x = cos(degrees)
        matrix.columns.0.z = -sin(degrees)
        
        matrix.columns.2.x = sin(degrees)
        matrix.columns.2.z = cos(degrees)
        return matrix.inverse
    }
    
    
    func bearingBetweenLocations(_ originLocation: CLLocation, _ driverLocation: CLLocation) -> Double {
        let lat1 = originLocation.coordinate.latitude.toRadians()
        let lon1 = originLocation.coordinate.longitude.toRadians()
        
        let lat2 = driverLocation.coordinate.latitude.toRadians()
        let lon2 = driverLocation.coordinate.longitude.toRadians()
        
        let longitudeDiff = lon2 - lon1
        
        let y = sin(longitudeDiff) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(longitudeDiff);
        
        return atan2(y, x)
    }
}


//MARK: - MAPKit
extension ViewModel{
    func getAnnotationUsing(_ model: ResponseModel)-> [MKPointAnnotation]{
        let annotations: [MKPointAnnotation] = model.results.compactMap({
            guard let geoBias = $0.position else{return nil }
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D.init(latitude: geoBias.lat, longitude: geoBias.lon)
            annotation.title = $0.poi?.name
            annotation.subtitle = $0.poi?.categories?.first
            return annotation
        })
        return annotations
    }
    
}

//MARK: - Web Service Call
extension ViewModel{
    func requestPlacesFor(_ location: CLLocationCoordinate2D){
        HTTPUtility.shared.getNearByPlacesUsing(lat: "\(location.latitude)", long: "\(location.longitude)") {[weak self] responseModel in
            self?.onDidFetchedPlaces?(responseModel)
        }
    }
}
