import Foundation

class OpenAIService {
    private let apiKey = "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"
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    func generateResponse(for text: String, screenshotBase64: String? = nil) async throws -> AIResponse {
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let tools = [
            [
                "type": "function",
                "function": [
                    "name": "search_google",
                    "description": "Search Google for a specific query",
                    "parameters": [
                        "type": "object",
                        "properties": [
                            "query": [
                                "type": "string",
                                "description": "The search query to look up on Google"
                            ]
                        ],
                        "required": ["query"]
                    ]
                ]
            ],
            [
                "type": "function",
                "function": [
                    "name": "input_text",
                    "description": "Provide corrected or suggested text for the active input field",
                    "parameters": [
                        "type": "object",
                        "properties": [
                            "text": [
                                "type": "string",
                                "description": "The corrected or suggested text to input"
                            ]
                        ],
                        "required": ["text"]
                    ]
                ]
            ]
        ]
        
        let messages: [[String: Any]] = {
            var messageContent: [[String: Any]] = [
                ["type": "text", "text": text]
            ]
            
            if let screenshotBase64 = screenshotBase64, 
               !screenshotBase64.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                messageContent.append([
                    "type": "image_url",
                    "image_url": [
                        "url": "data:image/jpeg;base64,\(screenshotBase64)"
                    ]
                ])
            }
            
            return [
                ["role": "system", "content": """
                You are a helpful browser assistant with two main functions:

                1. For search requests (search_google):
                - When users explicitly ask to search or look up information

                2. For text input assistance (input_text):
                - ONLY when you see an input field, text box, or form in the screenshot
                - When users need grammar or spelling corrections in an input field
                - When users ask for help composing messages or filling out forms in an input field

                For screenshots containing input fields:
                - Analyze the context and purpose of the input field
                - Consider any existing text that needs correction
                - Provide appropriate text that matches the field's purpose
                - Ensure your response uses proper grammar and tone for the context
                - Use formal language for professional contexts and casual language for informal contexts

                Always use the appropriate function call instead of providing direct responses when applicable.
                If you see an input field in the screenshot, prioritize using input_text over providing suggestions in chat.
                """],
                ["role": "user", "content": messageContent]
            ]
        }()

        print("Messages:", messages)
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": messages,
            "tools": tools,
            "tool_choice": "auto",
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Print raw response for debugging
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw API Response:", jsonString)
        }
        
        let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        // Check for tool calls first
        if let toolCall = response.choices.first?.message.toolCalls?.first {
            switch toolCall.function.name {
            case "search_google":
                do {
                    let arguments = try JSONDecoder().decode(SearchArguments.self, from: Data(toolCall.function.arguments.utf8))
                    print("Search query:", arguments.query) // Debug print
                    return .search(query: arguments.query)
                } catch {
                    print("Error decoding search arguments:", error) // Debug print
                    return .text("Error processing search request")
                }
            case "input_text":
                do {
                    let arguments = try JSONDecoder().decode(InputTextArguments.self, from: Data(toolCall.function.arguments.utf8))
                    print("Input text:", arguments.text) // Debug print
                    return .input(text: arguments.text)
                } catch {
                    print("Error decoding input text arguments:", error) // Debug print
                    return .text("Error processing input text request")
                }
            default:
                return .text("Unsupported tool call")
            }
        }
        
        // If no tool calls, return the content
        return .text(response.choices.first?.message.content ?? "No response")
    }
}

struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String?
        let toolCalls: [ToolCall]?
        
        enum CodingKeys: String, CodingKey {
            case content
            case toolCalls = "tool_calls"
        }
    }
    
    struct ToolCall: Codable {
        let id: String
        let type: String
        let function: FunctionCall
    }
    
    struct FunctionCall: Codable {
        let name: String
        let arguments: String
    }
}

struct SearchArguments: Codable {
    let query: String
}

struct InputTextArguments: Codable {
    let text: String
}

enum AIResponse {
    case text(String)
    case search(query: String)
    case input(text: String)
} 