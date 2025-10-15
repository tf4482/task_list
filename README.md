# Task List App

A Flutter application for managing tasks with automatic renewal scheduling. Perfect for recurring tasks that need to be completed daily, weekly, or monthly.

## Features

### ✅ Task Management
- Create, edit, and delete tasks
- Mark tasks as complete or incomplete
- Add optional descriptions to tasks
- Persistent storage using local storage

### 🔄 Automatic Renewal
- **Daily Renewal**: Tasks reset every day
- **Weekly Renewal**: Tasks reset every 7 days
- **Monthly Renewal**: Tasks reset every month
- **No Renewal**: One-time tasks that don't repeat

### 💾 Data Persistence
- All tasks are saved locally using SharedPreferences
- Tasks persist between app sessions
- Automatic renewal checking on app launch

### 🎨 User Interface
- Clean, Material Design 3 interface
- Task cards with completion checkboxes
- Visual indicators for renewal schedules
- Next renewal date display
- Empty state guidance

## Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Platform-specific requirements:
  - Windows: Visual Studio 2022 with C++ tools
  - macOS: Xcode
  - Linux: GTK 3.0+ development libraries
  - iOS: Xcode
  - Android: Android Studio

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd task_list
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For Windows
flutter run -d windows

# For macOS
flutter run -d macos

# For Android
flutter run -d <device-id>

# For iOS
flutter run -d <device-id>

# For Web
flutter run -d chrome
```

## How to Use

### Adding a Task

1. Tap the **+** (floating action button) at the bottom right
2. Enter a task title (required)
3. Optionally add a description
4. Choose a renewal schedule:
   - **No Renewal**: Task is completed once
   - **Daily**: Resets every day
   - **Weekly**: Resets every 7 days
   - **Monthly**: Resets every month
5. Tap **Add Task**

### Editing a Task

1. Tap on any task card to open the edit screen
2. Modify the title, description, or renewal schedule
3. Tap **Update Task** to save changes

### Completing a Task

- Tap the checkbox next to a task to mark it as complete
- Tasks with renewal schedules will automatically reset on their renewal date

### Deleting a Task

- Tap the red delete icon on any task card
- The task will be permanently removed

### Refreshing Tasks

- Tap the refresh icon in the app bar to manually check for task renewals
- The app automatically checks for renewals when launched

## Project Structure

```
lib/
├── main.dart                      # App entry point and main UI
├── models/
│   └── task.dart                  # Task model with renewal logic
├── services/
│   └── task_storage.dart          # Local storage service
└── screens/
    └── task_form_screen.dart      # Add/edit task form
```

## Dependencies

- **flutter**: Framework for building the app
- **shared_preferences**: ^2.2.2 - Local data persistence
- **intl**: ^0.18.1 - Date formatting

## How Renewal Works

### Renewal Logic

When a task has a renewal schedule:
1. The app calculates the next renewal date based on the schedule type
2. Each time tasks are loaded, the app checks if the renewal date has passed
3. If a task's renewal date has passed, it automatically resets to incomplete
4. The next renewal date is recalculated

### Renewal Date Calculation

- **Daily**: Next day at 00:00
- **Weekly**: Same day next week at 00:00
- **Monthly**: Same day next month at 00:00

### Example Use Cases

- **Daily Tasks**: Morning routine, exercise, medication
- **Weekly Tasks**: Grocery shopping, cleaning, lawn care
- **Monthly Tasks**: Bills, subscriptions, maintenance checks

## Technical Details

### State Management
- Uses StatefulWidget for local state management
- Reactive UI updates when tasks change

### Data Storage
- Tasks are stored as JSON in SharedPreferences
- Each task has a unique ID based on timestamp
- Renewal dates are stored as ISO 8601 strings

### Task Model
```dart
class Task {
  String id;
  String title;
  String description;
  bool isCompleted;
  RenewalType renewalType;
  DateTime? lastRenewalDate;
  DateTime? nextRenewalDate;
  DateTime createdAt;
}
```

## Platform Support

- ✅ Windows
- ✅ macOS
- ✅ Linux
- ✅ Android
- ✅ iOS
- ✅ Web

## Future Enhancements

Potential features for future versions:
- Custom renewal intervals
- Task categories/tags
- Task priorities
- Search and filter
- Statistics and reports
- Notifications for tasks
- Cloud sync
- Export/import tasks

## License

This project is available for personal and educational use.

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

## Support

For questions or issues, please open an issue in the repository.