# IOSAppTimeTracker

Native iOS application for time tracking with Jira integration.

## Features

- Settings screen for Jira API credentials (base URL, API token)
- Automatic project fetching from Jira API
- Manual time entry screen
- Local storage of logs
- Summary/export functionality

## Tech Stack

- SwiftUI for UI framework
- SwiftData for local persistence
- URLSession for API calls with rate limit handling

## Project Structure

- `Sources/` - Main application code
- `Resources/` - Assets and configuration
- `Tests/` - Unit and integration tests
