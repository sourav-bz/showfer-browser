import AVFoundation
import Starscream

class TranscriptionManager: ObservableObject, WebSocketDelegate {
    @Published var transcriptText: String = ""
    @Published var isRecording = false
    @Published var errorMessage: String?
    
    private let apiKey = "Token 5b5fa4fca5088ea38ae72f4a1a57824c087a17be"
    private let audioEngine = AVAudioEngine()
    private let jsonDecoder: JSONDecoder
    private var converter: AVAudioConverter?
    
    private lazy var socket: WebSocket = {
        var urlComponents = URLComponents(string: "wss://api.deepgram.com/v1/listen")!
        urlComponents.queryItems = [
            URLQueryItem(name: "encoding", value: "linear16"),
            URLQueryItem(name: "sample_rate", value: "44100"),
            URLQueryItem(name: "channels", value: "1"),
            URLQueryItem(name: "model", value: "nova"),
            URLQueryItem(name: "smart_format", value: "true"),
            URLQueryItem(name: "filler_words", value: "true")
        ]
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.setValue(apiKey, forHTTPHeaderField: "Authorization")
        return WebSocket(request: urlRequest)
    }()
    
    init() {
        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        self.socket.delegate = self
    }
    
    func startTranscription() {
        guard !isRecording else { return }
        
        do {
            try setupAudioSession()
            try setupAudioEngine()
            socket.connect()
            isRecording = true
        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
            print("Failed to start transcription: \(error)")
        }
    }
    
    private func setupAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true)
    }
    
    private func setupAudioEngine() throws {
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        // Create mono format
        guard let monoFormat = AVAudioFormat(
            commonFormat: inputFormat.commonFormat,
            sampleRate: inputFormat.sampleRate,
            channels: 1,
            interleaved: false) else {
            throw NSError(domain: "TranscriptionManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create mono format"])
        }
        
        let mixerNode = AVAudioMixerNode()
        audioEngine.attach(mixerNode)
        
        // Connect input to mixer
        audioEngine.connect(inputNode, to: mixerNode, format: inputFormat)
        
        // Install tap on mixer node
        mixerNode.installTap(onBus: 0, bufferSize: 4096, format: monoFormat) { [weak self] buffer, time in
            guard let self = self else { return }
            
            let pcmBuffer = self.convert(buffer: buffer, from: monoFormat)
            if let data = self.toNSData(buffer: pcmBuffer) {
                self.socket.write(data: data)
            }
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    private func convert(buffer: AVAudioPCMBuffer, from format: AVAudioFormat) -> AVAudioPCMBuffer {
        // Create output format (linear PCM, 16-bit integer)
        let outputFormat = AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: format.sampleRate,
            channels: 1,
            interleaved: true)!
        
        // Create converter if needed
        if converter == nil {
            converter = AVAudioConverter(from: format, to: outputFormat)
        }
        
        // Create output buffer
        let frameCount = AVAudioFrameCount(buffer.frameLength)
        guard let outputBuffer = AVAudioPCMBuffer(
            pcmFormat: outputFormat,
            frameCapacity: frameCount
        ) else {
            return buffer
        }
        
        // Convert buffer
        var error: NSError?
        let inputBlock: AVAudioConverterInputBlock = { inNumPackets, outStatus in
            outStatus.pointee = .haveData
            return buffer
        }
        
        guard let converter = converter else { return buffer }
        
        converter.convert(to: outputBuffer,
                         error: &error,
                         withInputFrom: inputBlock)
        
        outputBuffer.frameLength = frameCount
        
        if let error = error {
            print("Conversion error: \(error)")
            return buffer
        }
        
        return outputBuffer
    }
    
    private func toNSData(buffer: AVAudioPCMBuffer) -> Data? {
        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
        return Data(bytes: audioBuffer.mData!, count: Int(audioBuffer.mDataByteSize))
    }
    
    func stopTranscription() {
        audioEngine.stop()
        audioEngine.reset()
        socket.disconnect()
        isRecording = false
        DispatchQueue.main.async {
            self.transcriptText = ""
        }
    }
    
    // MARK: - WebSocketDelegate Methods
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .text(let text):
            if let jsonData = text.data(using: .utf8),
               let response = try? jsonDecoder.decode(DeepgramResponse.self, from: jsonData) {
                handleTranscript(response)
            }
        case .error(let error):
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Unknown error"
            }
            stopTranscription()
        case .connected:
            print("WebSocket connected")
        case .disconnected(let reason, let code):
            print("WebSocket disconnected: \(reason) with code: \(code)")
            stopTranscription()
        case .cancelled:
            print("WebSocket cancelled")
            stopTranscription()
        case .viabilityChanged(let isViable):
            print("WebSocket viability changed: \(isViable)")
        case .reconnectSuggested(let shouldReconnect):
            if shouldReconnect {
                socket.connect()
            }
        case .binary(let data):
            print("Received binary data of size: \(data.count)")
        case .pong:
            break
        case .ping:
            break
        }
    }
    
    private func handleTranscript(_ response: DeepgramResponse) {
        guard let transcript = response.channel.alternatives.first?.transcript,
              response.isFinal && !transcript.isEmpty else {
            return
        }
        
        DispatchQueue.main.async {
            if self.transcriptText.isEmpty {
                self.transcriptText = transcript
            } else {
                self.transcriptText += " " + transcript
            }
        }
    }
}

struct DeepgramResponse: Codable {
    let isFinal: Bool
    let channel: Channel
    
    struct Channel: Codable {
        let alternatives: [Alternative]
    }
    
    struct Alternative: Codable {
        let transcript: String
    }
} 