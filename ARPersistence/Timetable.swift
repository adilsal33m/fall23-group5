//
//  Timetable.swift
//  ARPersistence
//
//  Created by Muhammad Mustafa on 14/12/2023.
//  Copyright © 2023 Apple. All rights reserved.
//
import SwiftUI

struct Timetable: View {
    var roomNumber: String

    // Hardcoded timetable data
    private let timetableRoom2: [ClassInfo2] = [
        ClassInfo2(subjectName: "Mathematics", startTime: "09:00 AM", endTime: "10:00 AM"),
        ClassInfo2(subjectName: "Physics", startTime: "10:15 AM", endTime: "11:15 AM"),
        ClassInfo2(subjectName: "Chemistry", startTime: "11:30 AM", endTime: "12:30 PM"),
        ClassInfo2(subjectName: "English Literature", startTime: "01:00 PM", endTime: "02:00 PM"),
        ClassInfo2(subjectName: "History", startTime: "02:15 PM", endTime: "03:15 PM"),
        ClassInfo2(subjectName: "Art", startTime: "03:30 PM", endTime: "04:30 PM")
    ]

    private let timetableRoom3: [ClassInfo2] = [
        ClassInfo2(subjectName: "Computer Science", startTime: "10:15 AM", endTime: "11:15 AM"),
        ClassInfo2(subjectName: "Biology", startTime: "09:00 AM", endTime: "10:00 AM")
    ]

    @State private var classes: [ClassInfo2] = []

    var body: some View {
        NavigationView {
            List(classes) { classInfo in
                ClassRowView(classInfo: classInfo)
            }
            .navigationTitle("Timetable")
            // Additional view modifiers and functionalities
        }
        .onAppear {
            setupTimetable(forRoom: roomNumber) // Example call
        }
    }

    func setupTimetable(forRoom room: String) {
        switch room {
        case "room 2":
            classes = timetableRoom2
        case "room 3":
            classes = timetableRoom3
        default:
            classes = []
        }
    }
}

struct ClassInfo2: Identifiable {
    let id = UUID()
    var subjectName: String
    var startTime: String
    var endTime: String
}

struct ClassRowView: View {
    var classInfo: ClassInfo2

    var body: some View {
        HStack {
            Text(classInfo.subjectName)
                .fontWeight(.semibold)
            Spacer()
            Text("\(classInfo.startTime) - \(classInfo.endTime)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}
