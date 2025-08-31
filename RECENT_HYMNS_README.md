# Recent Hymns Functionality

This document explains how the recent hymns tracking system works in the hymn app.

## Overview

The app now tracks which hymns the user has recently opened and displays them on the home screen for quick access. This provides a better user experience by allowing users to quickly return to hymns they've recently viewed.

## How It Works

### 1. RecentHymnsService

The `RecentHymnsService` class manages the storage and retrieval of recently opened hymns:

- **Storage**: Uses `SharedPreferences` to persistently store hymn IDs
- **Maximum**: Keeps track of up to 3 recent hymns
- **Order**: Most recently opened hymns appear first
- **Deduplication**: If a hymn is opened again, it moves to the top of the list

### 2. Key Methods

- `addRecentHymn(int hymnId)`: Adds a hymn to the recent list
- `getRecentHymns({int limit = 5})`: Retrieves recent hymns as full Hymn objects
- `clearRecentHymns()`: Clears all recent hymns
- `removeRecentHymn(int hymnId)`: Removes a specific hymn from the list
- `getRecentHymnsCount()`: Gets the count of recent hymns

### 3. Integration Points

The recent hymns tracking is integrated at these points:

1. **Home Screen**: When navigating to a hymn from the home screen
2. **Hymn Detail Screen**: When a hymn detail screen is loaded
3. **Hymn List Screen**: When navigating to a hymn from the main hymn list

### 4. User Interface

- **Home Screen**: Shows up to 3 recent hymns in the "የቅርብ ጊዜ መዝሙሮች" (Recent Hymns) section
- **Empty State**: Shows a helpful message when no recent hymns exist
- **Auto-refresh**: Recent hymns list updates when returning from hymn detail screens

## Implementation Details

### Storage Format

Recent hymns are stored as a list of hymn IDs (as strings) in SharedPreferences:

```json
["1", "5", "3", "10", "2"]
```

### Performance Considerations

- Recent hymns are loaded asynchronously
- Full hymn objects are only loaded when needed
- The service handles errors gracefully
- Storage operations are non-blocking

### Data Persistence

- Recent hymns persist across app restarts
- Data is stored locally on the device
- No internet connection required

## Usage Example

```dart
// Add a hymn to recent list
await RecentHymnsService.addRecentHymn(hymnId);

// Get recent hymns
List<Hymn> recentHymns = await RecentHymnsService.getRecentHymns(limit: 3);

// Clear all recent hymns
await RecentHymnsService.clearRecentHymns();
```

## Benefits

1. **Improved UX**: Users can quickly access recently viewed hymns
2. **Faster Navigation**: Reduces time spent searching for hymns
3. **Context Awareness**: App remembers user's recent activity
4. **Offline Functionality**: Works without internet connection
5. **Lightweight**: Minimal storage and performance impact
