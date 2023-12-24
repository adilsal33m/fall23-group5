import SwiftUI

struct SlotRowView: View
{
	@Binding var slot: Slot

	var body: some View 
	{
		HStack 
		{
			TextField("Start Time", text: $slot.startTime)
				.textFieldStyle(RoundedBorderTextFieldStyle())

			TextField("End Time", text: $slot.endTime)
				.textFieldStyle(RoundedBorderTextFieldStyle())

			TextField("Event Name", text: $slot.eventName)
				.textFieldStyle(RoundedBorderTextFieldStyle())
		}
			.padding(.horizontal)
	}
}
