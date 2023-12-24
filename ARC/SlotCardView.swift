import SwiftUI

struct SlotCardView: View
{
	var slot: Slot

	var body: some View 
	{
		VStack(alignment: .leading, spacing: 8) 
		{
			Text("Event: \(slot.eventName)")
				.font(.headline)
				.foregroundColor(.blue)

			HStack 
			{
				Text("Start Time:")
					.bold()
					.foregroundColor(.black)
				Text(slot.startTime)
					.foregroundColor(.black)
			}

			HStack 
			{
				Text("End Time:")
					.bold()
					.foregroundColor(.black)
				Text(slot.endTime)
					.foregroundColor(.black)
			}
		}
			.padding()
			.frame(maxWidth: .infinity)
			.background(Color.white)
			.cornerRadius(8)
			.shadow(radius: 3)
	}
}
