

    import UIKit
    import SceneKit
    import ARKit
    import SwiftUI
    //mustafa
    class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
        // MARK: - IBOutlets
        
        @IBOutlet weak var sessionInfoView: UIView!
        @IBOutlet weak var sessionInfoLabel: UILabel!
        @IBOutlet weak var sceneView: ARSCNView!
        @IBOutlet weak var saveExperienceButton: UIButton!
        @IBOutlet weak var loadExperienceButton: UIButton!
        @IBOutlet weak var snapshotThumbnail: UIImageView!

        var scannedRoom: String?
        var isExperienceLoaded = false
        
        lazy var documentsURL: URL = {
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return urls[0]
        }()
        
        // MARK: - View Life Cycle
        
        // Lock the orientation of the app to the orientation in which it is launched
        override var shouldAutorotate: Bool {
            return false
        }
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Read in any already saved map to see if we can load one.
            if mapDataFromFile != nil {
                self.loadExperienceButton.isHidden = false
            }
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            guard ARWorldTrackingConfiguration.isSupported else {
                fatalError("""
                    ARKit is not available on this device. For apps that require ARKit
                    for core functionality, use the `arkit` key in the key in the
                    `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                    the app from installing. (If the app can't be installed, this error
                    can't be triggered in a production scenario.)
                    In apps where AR is an additive feature, use `isSupported` to
                    determine whether to show UI for launching AR experiences.
                """) // For details, see https://developer.apple.com/documentation/arkit
            }
            
            // Start the view's AR session.
            sceneView.session.delegate = self
            sceneView.session.run(defaultConfiguration)
            
            sceneView.debugOptions = [ .showFeaturePoints ]
            
            // Prevent the screen from being dimmed after a while as users will likely
            // have long periods of interaction without touching the screen or buttons.
            UIApplication.shared.isIdleTimerDisabled = true
            
            addSwiftUIButton()
            
        }
        
        func presentTimetableVC() {
            // Use the current scannedRoom value, defaulting to "room 3" if nil
            let currentRoom = scannedRoom ?? "room 3"
            let timetableVC = Timetable(roomNumber: currentRoom)
            let hostingController = UIHostingController(rootView: timetableVC)
            self.present(hostingController, animated: true, completion: nil)
        }


        private func addSwiftUIButton() {
            guard isExperienceLoaded else {
                    return // Do not add button if experience is not loaded
                }
            // Initialize the SwiftUI view with a closure that presents the Timetable view.
            let swiftUIButton = SwiftUIButtonView {
                self.presentTimetableVC() // Present Timetable when the SwiftUI button is tapped.
            }

            // Rest of the code to add the hosting controller remains the same...
            let hostingController = UIHostingController(rootView: swiftUIButton)
            addChild(hostingController)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(hostingController.view)
            hostingController.didMove(toParent: self)
            
            NSLayoutConstraint.activate([
                hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                hostingController.view.widthAnchor.constraint(equalToConstant: 150),
                hostingController.view.heightAnchor.constraint(equalToConstant: 38.5)
            ])
        }
//        private func addSwiftUIButton() {
//
//            // Create an instance of SwiftUIButtonView with a closure that calls timetableButtonTapped
//            let swiftUIButton = SwiftUIButtonView {
//                self.scannedRoom = self.scannedRoom ?? "" // Default to empty if no room is scanned
//
//                self.timetableButtonTapped(self)  // Call timetableButtonTapped when the SwiftUI button is tapped
//            }
//
//            let hostingController = UIHostingController(rootView: swiftUIButton)
//            addChild(hostingController)
//            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview(hostingController.view)
//            hostingController.didMove(toParent: self)
//
//            NSLayoutConstraint.activate([
//                hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//                hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//                hostingController.view.widthAnchor.constraint(equalToConstant: 150),
//                hostingController.view.heightAnchor.constraint(equalToConstant: 38.5)
//            ])
//        }
        
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            // Pause the view's AR session.
            sceneView.session.pause()
        }
        
        // MARK: - ARSCNViewDelegate
        
        /// - Tag: RestoreVirtualContent
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            guard anchor.name == virtualObjectAnchorName
            else { return }
            
            // save the reference to the virtual object anchor when the anchor is added from relocalizing
            if virtualObjectAnchor == nil {
                virtualObjectAnchor = anchor
            }
            node.addChildNode(virtualObject)
        }
        
        // MARK: - ARSessionDelegate
        
        func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
            updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
        }
        
        /// - Tag: CheckMappingStatus
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // Enable Save button only when the mapping status is good and an object has been placed
            switch frame.worldMappingStatus {
            case .extending, .mapped:
                saveExperienceButton.isEnabled =
                virtualObjectAnchor != nil && frame.anchors.contains(virtualObjectAnchor!)
            default:
                saveExperienceButton.isEnabled = false
            }
            
            updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
        }
        
        
        
        // MARK: - ARSessionObserver
        
        func sessionWasInterrupted(_ session: ARSession) {
            // Inform the user that the session has been interrupted, for example, by presenting an overlay.
            sessionInfoLabel.text = "Session was interrupted"
        }
        
        func sessionInterruptionEnded(_ session: ARSession) {
            // Reset tracking and/or remove existing anchors if consistent tracking is required.
            sessionInfoLabel.text = "Session interruption ended"
        }
        
        func session(_ session: ARSession, didFailWithError error: Error) {
            sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
            guard error is ARError else { return }
            
            let errorWithInfo = error as NSError
            let messages = [
                errorWithInfo.localizedDescription,
                errorWithInfo.localizedFailureReason,
                errorWithInfo.localizedRecoverySuggestion
            ]
            
            // Remove optional error messages.
            let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
            
            DispatchQueue.main.async {
                // Present an alert informing about the error that has occurred.
                let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
                let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                    alertController.dismiss(animated: true, completion: nil)
                    self.resetTracking(nil)
                }
                alertController.addAction(restartAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
            return true
        }
        
        // MARK: - Persistence: Saving and Loading
        lazy var mapSaveURL: URL = {
            do {
                return try FileManager.default
                    .url(for: .documentDirectory,
                         in: .userDomainMask,
                         appropriateFor: nil,
                         create: true)
                    .appendingPathComponent("map.arexperience")
            } catch {
                fatalError("Can't get file save URL: \(error.localizedDescription)")
            }
        }()
        
     
        @IBAction func saveExperience(_ button: UIButton) {
            sceneView.session.getCurrentWorldMap { worldMap, error in
                guard let map = worldMap else {
                    self.showAlert(title: "Can't get current world map", message: error!.localizedDescription)
                    return
                }
                
                // Add a snapshot image indicating where the map was captured.
                guard let snapshotAnchor = SnapshotAnchor(capturing: self.sceneView) else {
                    fatalError("Can't take snapshot")
                }
                map.anchors.append(snapshotAnchor)
                
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                    let baseName = "worldMap.arexperience"
                    let initialExtension = "2"
                    let fileURL = self.getNextAvailableFileName(baseURL: self.documentsURL, baseName: baseName, initialExtension: initialExtension)
                    try data.write(to: fileURL, options: [.atomic])
                    DispatchQueue.main.async {
                        // UI update for success
                        self.sessionInfoLabel.text = "Experience saved as \(fileURL.lastPathComponent)."
                        self.loadExperienceButton.isHidden = false
                        self.loadExperienceButton.isEnabled = true
                    }
                } catch {
                    DispatchQueue.main.async {
                        // Present an alert for the error
                        let alertController = UIAlertController(title: "Save Error", message: "Failed to save experience: \(error.localizedDescription)", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        
        
        func getNextAvailableFileName(baseURL: URL, baseName: String, initialExtension: String) -> URL {
            let finalName = baseName
            var count = Int(initialExtension) ?? 2
            
            while FileManager.default.fileExists(atPath: baseURL.appendingPathComponent("\(finalName)\(count)").path) {
                count += 1
            }
            
            return baseURL.appendingPathComponent("\(finalName)\(count)")
        }
        
        
        
        
        // Called opportunistically to verify that map data can be loaded from filesystem.
        var mapDataFromFile: Data? {
            return try? Data(contentsOf: mapSaveURL)
        }
        
        func loadSpecificExperience(named fileName: String) {
            let fileURL = self.documentsURL.appendingPathComponent(fileName)
            guard let data = try? Data(contentsOf: fileURL) else {
                print("Failed to load data from \(fileName)")
                return
            }
            
            let worldMap: ARWorldMap = {
                do {
                    guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) else {
                        fatalError("No ARWorldMap in archive.")
                    }
                    return worldMap
                } catch {
                    fatalError("Can't unarchive ARWorldMap from file data: \(error)")
                }
            }()
            
            // Display the snapshot image stored in the world map to aid user in relocalizing.
            if let snapshotData = worldMap.snapshotAnchor?.imageData,
               let snapshot = UIImage(data: snapshotData) {
                self.snapshotThumbnail.image = snapshot
            } else {
                print("No snapshot image in world map")
            }
            
            // Remove the snapshot anchor from the world map since we do not need it in the scene.
            worldMap.anchors.removeAll(where: { $0 is SnapshotAnchor })
            
            let configuration = self.defaultConfiguration // this app's standard world tracking settings
            configuration.initialWorldMap = worldMap
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            
            isRelocalizingMap = true
            virtualObjectAnchor = nil
            isExperienceLoaded = true

                // Refresh SwiftUI button
                addSwiftUIButton()

        }
        
        func setupAndShowTimetable(forRoom room: String) {
            self.scannedRoom = room
            self.performSegue(withIdentifier: "showTimetable", sender: nil)
        }

        
        func presentScannerView() {
            let scannerView = ScannerView { [weak self] textPerPage in
                self?.dismiss(animated: true) {
                    guard let scannedText = textPerPage?.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines) else {
                        print("No text recognized")
                        return
                    }
                    
                    print("Scanned text: \(scannedText)") // Debugging the actual recognized text
                    
                    // Check if the scanned text contains the expected substring
                    let scannedTextLowercased = scannedText.lowercased()
                    if scannedTextLowercased.contains("212") {
                        self?.scannedRoom = "room 2"
                        self?.loadSpecificExperience(named: "worldMap.arexperience4")
                    } else if scannedTextLowercased.contains("web sciences lab") {
                        self?.scannedRoom = "room 3"
                        self?.loadSpecificExperience(named: "worldMap.arexperience5")
                    } else {
                        print("Scanned text did not contain the expected phrase")
                    }

                }

            }
            let hostingController = UIHostingController(rootView: scannerView)
            self.present(hostingController, animated: true, completion: nil)
        }
        
        
        
        /// - Tag: RunWithWorldMap
        @IBAction func loadExperience(_ button: UIButton) {
            
            presentScannerView()
            
        }
        
        // MARK: - AR session management
        
        var isRelocalizingMap = false
        
        var defaultConfiguration: ARWorldTrackingConfiguration {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .vertical
            configuration.environmentTexturing = .automatic
            return configuration
        }
        
        @IBAction func resetTracking(_ sender: UIButton?) {
            sceneView.session.run(defaultConfiguration, options: [.resetTracking, .removeExistingAnchors])
            isRelocalizingMap = false
            virtualObjectAnchor = nil
            isExperienceLoaded = false
                addSwiftUIButton()
        }
        
        private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
            // Update the UI to provide feedback on the state of the AR experience.
            let message: String
            
            snapshotThumbnail.isHidden = true
            switch (trackingState, frame.worldMappingStatus) {
            case (.normal, .mapped),
                (.normal, .extending):
                if frame.anchors.contains(where: { $0.name == virtualObjectAnchorName }) {
                    // User has placed an object in scene and the session is mapped, prompt them to save the experience
                    message = "Tap 'Save Experience' to save the current map."
                } else {
                    message = "Tap on the screen to place an object."
                }
                
            case (.normal, _) where mapDataFromFile != nil && !isRelocalizingMap:
                message = "Move around to map the environment or tap 'Load Experience' to load a saved experience."
                
            case (.normal, _) where mapDataFromFile == nil:
                message = "Move around to map the environment."
                
            case (.limited(.relocalizing), _) where isRelocalizingMap:
                message = "Move your device to the location shown in the image."
                snapshotThumbnail.isHidden = false
                
            default:
                message = trackingState.localizedFeedback
            }
            
            sessionInfoLabel.text = message
            sessionInfoView.isHidden = message.isEmpty
        }
        
        // MARK: - Placing AR Content
        
        /// - Tag: PlaceObject
        @IBAction func handleSceneTap(_ sender: UITapGestureRecognizer) {
            if isRelocalizingMap && virtualObjectAnchor == nil {
                return
            }
            // Hit test to find a place for a virtual object.
            guard let hitTestResult = sceneView
                .hitTest(sender.location(in: sceneView), types: [.existingPlaneUsingGeometry, .estimatedVerticalPlane])
                .first
            else { return }
            
            // Remove exisitng anchor and add new anchor
            if let existingAnchor = virtualObjectAnchor {
                sceneView.session.remove(anchor: existingAnchor)
            }
            virtualObjectAnchor = ARAnchor(name: virtualObjectAnchorName, transform: hitTestResult.worldTransform)
            sceneView.session.add(anchor: virtualObjectAnchor!)
            if isRelocalizingMap {
                return
            }
        }
        
        var virtualObjectAnchor: ARAnchor?
        let virtualObjectAnchorName = "virtualObject"
        
        var virtualObject: SCNNode = {
            guard let sceneURL = Bundle.main.url(forResource: "button", withExtension: "scn", subdirectory: "Assets.scnassets/button"),
                  let referenceNode = SCNReferenceNode(url: sceneURL) else {
                fatalError("can't load virtual object")
            }
            referenceNode.load()
            
            return referenceNode
        }()
        
    }

