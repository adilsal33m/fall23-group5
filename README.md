# Group 5

- Muhammad Mustafa: 22206
- Syed Danial Haseeb: 12429
- Misbah Iradat:

This application utilizes augmented reality to display the timetables for classrooms in an educational setting. Using `ARKit` and `SceneKit`, users can navigate through campus buildings, scan classroom tags, and view schedules in an interactive AR environment.

## Features

- OCR for scanning classroom tags.
- ARWorldMap for managing classroom locations.
- Interactive AR experience with virtual buttons to access classroom timetables.
- Supports vertical plane detection for placing virtual buttons.
- Ability to save and load AR experiences.

## Requirements

- iOS 13.0 or later.
- ARKit-compatible device with A9 chip or later for ARWorldMap support.
- Xcode 11 or later.

## Setup

Clone the repository and open the project in Xcode:

```sh
git clone [repo-link]
cd [project-directory]
open ARClassroomTimetable.xcodeproj
```

Ensure that you have the latest version of Xcode installed and that your device is running a compatible version of iOS.

## Usage

1. **Starting the App:**
   Launch the app on your ARKit-compatible device. The app will request permission to use the device's location and camera.

2. **Identifying Buildings:**
   The app uses GPS to determine which building you are in. Ensure that GPS services are enabled on your device.

3. **Scanning Classroom Tags:**
   Point your device's camera at a classroom tag. The app will use OCR to read the tag and match it with a stored ARWorldMap.

4. **Viewing Timetables:**
   Once a classroom is identified, virtual "i" buttons will appear on the classroom door. Tap these buttons to view the classroom's timetable.

5. **Saving and Loading Experiences:**
   The app allows users to save their current AR session and load it later for convenience.

## Development

The app is developed using Swift and utilizes Storyboards and SwiftUI for UI design. The AR experience is powered by ARKit with SceneKit as the rendering layer.

### Main Components

- `ViewController`: Handles ARKit setup, session management, and user interactions.
- `TimetableViewController`: Manages the display of classroom timetables using `UITableViewController`.
- `ARSCNView`: The primary view for rendering AR content.

### Adding AR Content

To place AR content:

1. Tap on a recognized surface to create an anchor and associate a virtual button.
2. Tapping the virtual button navigates to the timetable view.

### Handling AR Interactions

AR interactions are handled through tap gesture recognizers. The app detects taps on virtual objects and performs the appropriate navigation.

## Best Practices

- Always test AR features in a well-lit environment for best performance.
- For OCR functionality, ensure classroom tags are clear and legible.

## Troubleshooting

- If virtual objects are not appearing, ensure the app has the necessary permissions and that your device supports ARWorldMap.
- For issues related to GPS, verify location services are enabled and that the device has a clear view of the sky.
