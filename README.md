# TwinTalk

TwinTalk is an iOS chat application that enables users to have conversations with an AI assistant. The app is built using SwiftUI and follows modern iOS development practices.

## Architecture

The application follows a clean MVVM (Model-View-ViewModel) architecture with the following key components:

### Core Components
- **Models**: 
  - `Session`: Represents a chat session with metadata (id, date, title, category, summary)
  - `Message`: Represents individual messages in a chat (id, text, sender, timestamp)
  - Core Data entities (`SessionEntity`, `MessageEntity`) for local persistence

- **Views**:
  - `ContentView`: Main container view with tab bar navigation
  - `HistoryView`: Displays chat history
  - `CreateSession`: Handles new chat session creation
  - Various chat and UI components

- **ViewModels**:
  - `TwinTalkViewModel`: Manages application state and business logic
  - Handles data fetching, session management, and message sending

- **Services**:
  - `NetworkService`: Handles API communication with mock backend
  - `PersistenceManager`: Manages Core Data operations and local storage

### Data Flow
1. User interactions trigger ViewModel methods
2. ViewModel coordinates between NetworkService and PersistenceManager
3. Data is persisted locally using Core Data
4. UI updates automatically through SwiftUI's data binding

## Running the Application

### Prerequisites
- Xcode 15.0 or later
- iOS 16.6 or later
- Swift 5.0

### Setup
1. **Mock Data Setup**:
   - Go to [mocky.io](https://designer.mocky.io/)
   - Create a new mock endpoint
   - Set the response body to the following JSON:
   ```json
   [
     {
       "id": "session_001",
       "date": "2025-05-29T14:23:00Z",
       "title": "Career Planning",
       "category": "career",
       "summary": "Discussed possible career development paths and how to find a new job.",
       "messages": [
         {
           "text": "I want to change my job, but I don't know where to start.",
           "sender": "user",
           "timestamp": "2025-05-29T14:23:05Z"
         },
         {
           "text": "Let's look at your skills and goals. What do you want from your next job?",
           "sender": "AI",
           "timestamp": "2025-05-29T14:23:10Z"
         }
       ]
     },
     {
       "id": "session_002",
       "date": "2025-05-28T18:45:00Z",
       "title": "Emotional Check-in",
       "category": "emotions",
       "summary": "Discussed stress and ways to manage it.",
       "messages": [
         {
           "text": "Lately I've been feeling exhausted.",
           "sender": "user",
           "timestamp": "2025-05-28T18:45:15Z"
         },
         {
           "text": "That's completely normal. Would you like to talk about what's causing your fatigue?",
           "sender": "AI",
           "timestamp": "2025-05-28T18:45:20Z"
         }
       ]
     },
     {
       "id": "session_003",
       "date": "2025-05-26T10:10:00Z",
       "title": "Relationship Challenges",
       "category": "relationships",
       "summary": "Talked about conflicts in a relationship and ways to improve communication.",
       "messages": [
         {
           "text": "My partner and I keep arguing over little things.",
           "sender": "user",
           "timestamp": "2025-05-26T10:10:12Z"
         },
         {
           "text": "Can you give an example of your latest argument? That would help understand the dynamics.",
           "sender": "AI",
           "timestamp": "2025-05-26T10:10:20Z"
         }
       ]
     },
     {
       "id": "session_004",
       "date": "2025-05-24T09:30:00Z",
       "title": "Developing Self-Discipline",
       "category": "self-development",
       "summary": "Explored techniques for building self-discipline and setting achievable goals.",
       "messages": [
         {
           "text": "I can't seem to work out regularly.",
           "sender": "user",
           "timestamp": "2025-05-24T09:30:10Z"
         },
         {
           "text": "Let's think about what's holding you back and what small steps could help.",
           "sender": "AI",
           "timestamp": "2025-05-24T09:30:15Z"
         }
       ]
     }
   ]
   ```
   - Clone the repository
   - Open `TwinTalk.xcodeproj` in Xcode
   - Copy the generated URL and update `sessionsEndpoint` in `NetworkService.swift` with the new URL path (the part after `/v3/`)
   - Select your target device (iPhone simulator or physical device)
   - Build and run the application (⌘R)

## Mocked Components

The application currently uses several mocked components for development and testing:

1. **Backend API**:
   - The app uses mocky.io as a temporary backend service
   - All API endpoints are configured in `NetworkService.swift`
   - The service follows REST principles and handles:
     - Fetching chat sessions (GET request)
     - Note: Message sending (POST request) is currently simulated locally since mocky.io doesn't support POST requests
     - Error handling and response validation
   - In production, these endpoints would be replaced with a real backend service

2. **AI Responses**:
   - Currently uses simulated AI responses with a 1-second delay
   - In production, this would be replaced with actual AI service integration

3. **Network Layer**:
   - Implements a protocol-based network service for easy testing
   - Includes mock session handling and error scenarios

## Improvement Ideas

1. **Features**:
   - Implement real AI service integration
   - Add user authentication and profile management
   - Support for media messages (images, voice notes)
   - Message search functionality
   - Chat categories customization

2. **Technical**:
   - Add comprehensive unit tests
   - Implement WebSocket for real-time messaging:
     - Use URLSessionWebSocketTask for WebSocket connection
     - Implement connection state management (connected, disconnected, reconnecting)
     - Handle message queuing during disconnection
     - Add heartbeat mechanism to keep connection alive
     - Implement automatic reconnection with exponential backoff
   - Add offline support with message queue
   - Implement proper error handling and retry mechanisms
   - Add analytics and crash reporting

3. **UI/UX**:
   - Add dark mode support
   - Implement message reactions
   - Add typing indicators
   - Support for message deletion
   - Add accessibility features

4. **Performance**:
   - Implement message pagination
   - Add image caching
   - Optimize Core Data operations
   - Implement proper memory management for large chat histories

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is proprietary and confidential. All rights reserved. 
