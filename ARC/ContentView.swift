import SwiftUI
import RealityKit
import ARKit
import CoreData

struct ContentView: View 
{
	@State private var currentMode: Mode = .admin
	@State private var arView = ARView(frame: .zero)
	@State private var placementState: PlacementState = .idle
	@State private var slotsViewModel = SlotsViewModel()
	@State private var inputClassroomName: String = ""
	@State private var timetableSlots: [Slot] = []
	@State private var showTimetable: Bool = false
	
	@Environment(\.managedObjectContext) var managedObjectContext

	var body: some View 
	{
		ZStack
		{
			ARViewContainer(arView: $arView,
											currentMode: $currentMode,
											placementState: $placementState)
				.edgesIgnoringSafeArea(.all)

			VStack
			{
				modePicker

				if currentMode == .user && !showTimetable 
				{ userModeView }

				Spacer()
			}

			if case .confirming(_) = placementState
			{ confirmationButtons }
				
			if case .inputDetails(_, let viewModel) = placementState
			{
				InputDetailsView(viewModel: viewModel)
					.environment(\.managedObjectContext, managedObjectContext)
			}

			if showTimetable 
			{
				TimetableListView(slots: timetableSlots)
				{ self.showTimetable = false }
			}
		}
	}

	private var modePicker: some View 
	{
		Picker("Mode", selection: $currentMode) 
		{
			Text("User").tag(Mode.user)
			Text("Admin").tag(Mode.admin)
		}
			.pickerStyle(SegmentedPickerStyle())
			.padding()
			.zIndex(1)
	}

	private var userModeView: some View 
	{
		VStack
		{
			TextField("Enter Classroom Name", text: $inputClassroomName)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.padding()

			Button("Load Timetable") 
			{
				loadTimetable(for: inputClassroomName)
				self.showTimetable = true
			}
				.padding()
				.background(Color.blue)
				.foregroundColor(.white)
				.cornerRadius(8)
		}
	}

	private func loadTimetable(for classroom: String) 
	{
		let fileName = "\(classroom).json"
		let documentsDirectory = FileManager
			.default
			.urls(for: .documentDirectory, in: .userDomainMask)
			.first
		let fileURL = documentsDirectory?.appendingPathComponent(fileName)

		if let url = fileURL 
		{
			do
			{
				let data = try Data(contentsOf: url)
				timetableSlots = try JSONDecoder().decode([Slot].self, from: data)
			} 
			catch
			{ print("Error loading data: \(error.localizedDescription)") }
		}
	}

	private var confirmationButtons: some View 
	{
		HStack
		{
			Button(action: confirmPlacement) 
			{
				Image(systemName: "checkmark.circle")
					.padding()
					.foregroundColor(.green)
					.font(.system(size: 40))
			}
			Button(action: cancelPlacement) 
			{
				Image(systemName: "xmark.circle")
					.padding()
					.foregroundColor(.red)
					.font(.system(size: 40))
			}
		}
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
			.zIndex(2)
	}

	private func confirmPlacement() 
	{
		if case .confirming(let buttonEntity) = placementState 
		{
			let viewModel = SlotsViewModel()
			viewModel.onSave = 
			{
				DispatchQueue.main.async 
				{
					self.placementState = .idle
					self.resetARView()
				}
			}
			placementState = .inputDetails(buttonEntity, viewModel)
		}
	}

	private func resetARView() 
	{
		let anchors = arView.session.currentFrame?.anchors
		anchors?.forEach 
		{ arView.session.remove(anchor: $0) }
	}

	private func cancelPlacement() 
	{
		if case .confirming(let buttonEntity) = placementState 
		{
			DispatchQueue.main.async 
			{
				self.arView.scene.removeAnchor(buttonEntity.anchor!)
				self.placementState = .idle
			}
		}
	}
}

