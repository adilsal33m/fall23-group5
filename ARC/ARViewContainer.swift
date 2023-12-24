import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable
{
	func updateUIView(_ uiView: ARView, context: Context)
	{ }
	
	@Binding var arView: ARView
	@Binding var currentMode: Mode
	@Binding var placementState: PlacementState

	func makeUIView(context: Context) -> ARView
	{
		arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped)))
		return arView
	}

	func makeCoordinator() -> Coordinator
	{ Coordinator(self) }

	class Coordinator: NSObject
	{
		var parent: ARViewContainer

		init(_ parent: ARViewContainer)
		{ self.parent = parent }

		@objc func tapped(gesture: UITapGestureRecognizer)
		{
			guard (parent.currentMode == .admin) else
			{ return }

			let location = gesture.location(in: parent.arView)
			let results = parent.arView.raycast(from: location,
																					allowing: .estimatedPlane,
																					alignment: .vertical)
			if let firstResult = results.first
			{ placeButton(at: firstResult.worldTransform) }
		}

		private func placeButton(at transform: simd_float4x4)
		{
			let buttonAnchor = ARAnchor(transform: transform)
			parent.arView.session.add(anchor: buttonAnchor)

			let buttonMesh = MeshResource.generateSphere(radius: 0.05)
			let buttonMaterial = SimpleMaterial(color: .blue, roughness: 0.5, isMetallic: false)
			let buttonEntity = ModelEntity(mesh: buttonMesh, materials: [buttonMaterial])
			buttonEntity.position = [0, 0, 0.05]

			buttonEntity.generateCollisionShapes(recursive: true)
			parent.arView.environment.lighting.intensityExponent = 1

			let anchorEntity = AnchorEntity(anchor: buttonAnchor)
			anchorEntity.addChild(buttonEntity)

			parent.arView.scene.addAnchor(anchorEntity)
			parent.placementState = .confirming(buttonEntity)
			
			DispatchQueue.main.async
			{ self.parent.placementState = .confirming(buttonEntity) }
		}
	}
}
