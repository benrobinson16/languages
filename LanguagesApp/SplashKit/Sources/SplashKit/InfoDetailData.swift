import Foundation
import SwiftUI

/// Represents the data required to display an info detail row.
public struct InfoDetailData: Identifiable {
    
    /// The image (generally a symbol) to display.
    let image: Image
    
    /// The title of the row (e.g. "New feature")
    let title: String
    
    /// The body of the row (e.g. "This is a new feature to ThisApp and we think you'll love it!")
    let body: String
    
    /// Conformance to `Identifiable`.
    public let id = UUID()
    
    public init(image: Image,
                title: String,
                body: String) {
        self.image = image
        self.title = title
        self.body = body
    }
}
