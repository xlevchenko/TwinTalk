//
//  TwinTalkTests.swift
//  TwinTalkTests
//
//  Created by Olexsii Levchenko on 30.05.2025.
//


import Testing
import Foundation
@testable import TwinTalk

@Suite("NetworkService Tests")
struct NetworkServiceTests {
    
    // MARK: - Test Data
    static let mockSessionsData = """
    [
        {
            "id": "1",
            "date": "2024-01-01T10:00:00Z",
            "title": "Test Session 1",
            "category": "General",
            "summary": "Test summary 1",
            "messages": [
                {
                    "id": "msg1",
                    "text": "Hello",
                    "sender": "user",
                    "timestamp": "2024-01-01T10:00:00Z"
                },
                {
                    "id": "msg2",
                    "text": "Hi there!",
                    "sender": "ai",
                    "timestamp": "2024-01-01T10:01:00Z"
                }
            ]
        },
        {
            "id": "2", 
            "date": "2024-01-02T15:30:00Z",
            "title": "Test Session 2",
            "category": "Work",
            "summary": "Test summary 2",
            "messages": []
        }
    ]
    """.data(using: .utf8)!
    
    static let emptyArrayData = "[]".data(using: .utf8)!
    static let invalidJSONData = "invalid json".data(using: .utf8)!
    
    // MARK: - Success Tests
    
    @Test("Fetch sessions successfully returns decoded sessions")
    func fetchSessionsSuccess() async throws {
        // Given
        let mockSession = MockURLSession()
        let networkService = NetworkService.createForTesting(session: mockSession)
        
        mockSession.mockData = Self.mockSessionsData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://run.mocky.io/v3/cd42a6b7-6dc3-4681-bb68-ab4b355a4928")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        let sessions = try await networkService.fetchSessions()
        
        // Then
        #expect(sessions.count == 2)
        #expect(sessions[0].id == "1")
        #expect(sessions[0].title == "Test Session 1")
        #expect(sessions[0].category == "General")
        #expect(sessions[0].summary == "Test summary 1")
        #expect(sessions[0].messages.count == 2)
        #expect(sessions[0].messages[0].sender == .user)
        #expect(sessions[0].messages[1].sender == .ai)
        #expect(sessions[1].id == "2")
        #expect(sessions[1].title == "Test Session 2")
        #expect(sessions[1].category == "Work")
        #expect(sessions[1].messages.isEmpty)
    }
    
    @Test("Fetch sessions with empty array returns empty result")
    func fetchSessionsEmptyArray() async throws {
        // Given
        let mockSession = MockURLSession()
        let networkService = NetworkService.createForTesting(session: mockSession)
        
        mockSession.mockData = Self.emptyArrayData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://run.mocky.io/v3/cd42a6b7-6dc3-4681-bb68-ab4b355a4928")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        let sessions = try await networkService.fetchSessions()
        
        // Then
        #expect(sessions.isEmpty)
    }
    
    // MARK: - Error Tests
    @Test("Fetch sessions throws decoding error for invalid JSON")
    func fetchSessionsDecodingError() async throws {
        // Given
        let mockSession = MockURLSession()
        let networkService = NetworkService.createForTesting(session: mockSession)
        
        mockSession.mockData = Self.invalidJSONData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://run.mocky.io/v3/cd42a6b7-6dc3-4681-bb68-ab4b355a4928")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When & Then
        await #expect(throws: NetworkError.self) {
            try await networkService.fetchSessions()
        }
    }
    
    @Test("Fetch sessions handles server errors")
    func fetchSessionsServerError() async throws {
        // Given
        let mockSession = MockURLSession()
        let networkService = NetworkService.createForTesting(session: mockSession)
        
        mockSession.mockData = Self.mockSessionsData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://run.mocky.io/v3/cd42a6b7-6dc3-4681-bb68-ab4b355a4928")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When & Then
        await #expect(throws: NetworkError.self) {
            try await networkService.fetchSessions()
        }
    }
    
    // MARK: - Validation Tests
    
    @Test("Validate response succeeds for success status codes")
    func validateResponseSuccess() throws {
        // Given
        let networkService = NetworkService.shared
        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        // When & Then - Should not throw
        #expect(throws: Never.self) {
            try networkService.testValidateResponse(response)
        }
    }
    
    @Test("Create POST request sets correct headers and body")
    func createPostRequestTest() throws {
        // Given
        let networkService = NetworkService.shared
        let url = URL(string: "https://example.com")!
        let payload = TestPayload(message: "Hello, World!")
        
        // When
        let request = try networkService.testCreatePostRequest(url: url, payload: payload)
        
        // Then
        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(request.httpBody != nil)
        
        // Verify the body contains encoded payload
        let decodedPayload = try JSONDecoder().decode(TestPayload.self, from: request.httpBody!)
        #expect(decodedPayload.message == "Hello, World!")
    }
}

// MARK: - Test Helpers

extension NetworkServiceTests {
    struct TestPayload: Codable {
        let message: String
    }
}

// MARK: - Mock URLSession

class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        
        let data = mockData ?? Data()
        let response = mockResponse ?? URLResponse()
        
        return (data, response)
    }
}
