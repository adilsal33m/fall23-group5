import SwiftUI
import CoreData

class SlotsViewModel: ObservableObject
{
	@Published var slots: [Slot] = [Slot()]
	@Published var classroomName: String = ""
	var onSave: (() -> Void)?

	func addSlot() 
	{ slots.append(Slot()) }

	func saveToCoreData(context: NSManagedObjectContext) 
	{
		let newTimetable = TimetableEntity(context: context)
		newTimetable.classroomName = classroomName

		for slotInfo in slots 
		{
			let newSlot = SlotEntity(context: context)
			newSlot.startTime = slotInfo.startTime
			newSlot.endTime = slotInfo.endTime
			newSlot.eventName = slotInfo.eventName
			newTimetable.addToSlots(newSlot)
		}

		do 
		{ try context.save() } 
		catch
		{ print("Failed to save timetable: \(error.localizedDescription)") }
	}

	func saveSlotsToFile() 
	{
		guard !classroomName.isEmpty else 
		{
			print("Classroom name is empty")
			return
		}

		let fileName = "\(classroomName).json"
		let documentsDirectory = FileManager
			.default
			.urls(for: .documentDirectory, in: .userDomainMask)
			.first
		let fileURL = documentsDirectory?.appendingPathComponent(fileName)

		do 
		{
			let data = try JSONEncoder().encode(slots)
			try data.write(to: fileURL!, options: [.atomicWrite])
			print("Data saved to \(fileURL!.path)")
		} 
		catch
		{ print("Error saving data: \(error.localizedDescription)") }

		onSave?()
	}
}
