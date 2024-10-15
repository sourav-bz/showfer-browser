import Foundation

struct Tab: Identifiable {
    let id = UUID()
    var title: String
    var url: URL?
}
