import SwiftUI

struct InputDetailsView: View
{
	@ObservedObject var viewModel: SlotsViewModel
	@Environment(\.managedObjectContext) var managedObjectContext

	var body: some View
	{
		VStack 
		{
			TextField("Classroom Name", text: $viewModel.classroomName)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.padding()

			ForEach($viewModel.slots.indices, id: \.self)
			{ index in SlotRowView(slot: $viewModel.slots[index]) }

			Button(action: viewModel.addSlot)
			{
				Text("Add Slot")
					.foregroundColor(.white)
					.padding()
					.background(Color.blue)
					.cornerRadius(8)
			}

			Button("Confirm") 
			{ viewModel.saveSlotsToFile() }
				.foregroundColor(.white)
				.padding()
				.background(Color.green)
				.cornerRadius(8)

			Spacer()
		}
	}
}
