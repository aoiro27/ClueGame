import SceneKit
import SwiftUI

struct ChestSceneView: UIViewRepresentable {
    var hue: Double
    var open: Bool

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = makeScene()
        view.backgroundColor = .clear
        view.antialiasingMode = .multisampling4X
        view.autoenablesDefaultLighting = false
        context.coordinator.view = view
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.animate(open: open, hue: hue)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private func makeScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.clear

        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.position = SCNVector3(2.2, 2.0, 4.4)
        camera.look(at: SCNVector3(0, 0.6, 0))
        scene.rootNode.addChildNode(camera)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 400
        ambient.light?.color = UIColor(red: 0.45, green: 0.38, blue: 0.7, alpha: 1)
        scene.rootNode.addChildNode(ambient)

        let lantern = SCNNode()
        lantern.name = "lantern"
        lantern.light = SCNLight()
        lantern.light?.type = .omni
        lantern.light?.color = UIColor(red: 1, green: 0.8, blue: 0.45, alpha: 1)
        lantern.light?.intensity = 600
        lantern.position = SCNVector3(0, 1.6, 1.4)
        scene.rootNode.addChildNode(lantern)

        let wood = UIColor(red: 0.42, green: 0.23, blue: 0.12, alpha: 1)
        let gold = UIColor(red: 0.88, green: 0.69, blue: 0.23, alpha: 1)

        let body = SCNNode(geometry: SCNBox(width: 1.7, height: 0.9, length: 1.1, chamferRadius: 0.04))
        body.geometry?.firstMaterial?.diffuse.contents = wood
        body.position = SCNVector3(0, 0.45, 0)
        scene.rootNode.addChildNode(body)

        let band = SCNNode(geometry: SCNBox(width: 1.78, height: 0.12, length: 1.18, chamferRadius: 0.02))
        band.geometry?.firstMaterial?.diffuse.contents = gold
        band.position = SCNVector3(0, 0.45, 0)
        scene.rootNode.addChildNode(band)

        let lidPivot = SCNNode()
        lidPivot.name = "lidPivot"
        lidPivot.position = SCNVector3(0, 0.9, -0.55)
        let lid = SCNNode(geometry: SCNBox(width: 1.74, height: 0.2, length: 1.14, chamferRadius: 0.04))
        lid.geometry?.firstMaterial?.diffuse.contents = wood
        lid.position = SCNVector3(0, 0.1, 0.55)
        lidPivot.addChildNode(lid)
        scene.rootNode.addChildNode(lidPivot)

        let gem = SCNNode(geometry: SCNSphere(radius: 0.28))
        gem.name = "gem"
        gem.geometry?.firstMaterial?.diffuse.contents = UIColor.cyan
        gem.geometry?.firstMaterial?.emission.contents = UIColor.cyan
        gem.position = SCNVector3(0, 0.55, 0)
        gem.scale = SCNVector3(0.01, 0.01, 0.01)
        scene.rootNode.addChildNode(gem)

        return scene
    }

    final class Coordinator {
        weak var view: SCNView?

        func animate(open: Bool, hue: Double) {
            guard let scene = view?.scene else { return }
            let color = UIColor(hue: hue / 360, saturation: 0.7, brightness: 0.7, alpha: 1)
            scene.rootNode.childNode(withName: "gem", recursively: true)?.geometry?.firstMaterial?.diffuse.contents = color
            scene.rootNode.childNode(withName: "gem", recursively: true)?.geometry?.firstMaterial?.emission.contents = color
            let lid = scene.rootNode.childNode(withName: "lidPivot", recursively: true)
            let gem = scene.rootNode.childNode(withName: "gem", recursively: true)
            let lantern = scene.rootNode.childNode(withName: "lantern", recursively: true)
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.9
            lid?.eulerAngles.x = open ? -1.85 : 0
            gem?.scale = open ? SCNVector3(1, 1, 1) : SCNVector3(0.01, 0.01, 0.01)
            gem?.position = SCNVector3(0, open ? 1.5 : 0.55, 0)
            lantern?.light?.intensity = open ? 1400 : 500
            SCNTransaction.commit()
        }
    }
}
