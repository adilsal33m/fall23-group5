import SwiftUI

struct TimetableListView: View
{
	var slots: [Slot]
	var onClose: () -> Void

	var body: some View 
	{
		VStack 
		{
			HStack
			{
				Text("Timetable")
					.font(.title)
					.bold()
					.padding(.leading)
				Spacer()
				Button(action: onClose) 
				{
					Image(systemName: "xmark.circle.fill")
						.font(.title2)
						.foregroundColor(.red)
				}
			}
				.padding(.horizontal)

			ScrollView 
			{
				LazyVStack(spacing: 12) 
				{
					ForEach(slots, id: \.self) 
					{ slot in SlotCardView(slot: slot) }
				}
			}
				.padding()
		}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background(Color(.secondarySystemBackground))
			.cornerRadius(12)
			.padding(.horizontal)
			.shadow(radius: 10)
	}
}


