import SwiftUI

struct TabsView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all) // Or any background color you prefer
            
            VStack {
                // Back button at the top
                HStack {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .padding(.leading)
                    Spacer()
                }
                .padding(.top)
                
                Spacer()
                
                // Centered text
                Text("Tabs View")
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}
