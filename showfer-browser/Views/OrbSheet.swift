import SwiftUI

struct OrbSheet: View {
    let aiResponse: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("AI Response")
                    .font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(Array(aiResponse.components(separatedBy: .newlines).enumerated()), id: \.offset) { index, line in
                        Text(line)
                            .textSelection(.enabled)
                            .id(index)
                    }
                }
                .padding()
            }
        }
        .padding(.top)
    }
}