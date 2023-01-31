import Foundation
import SwiftUI

/// Represents the data required to display an info detail row.
public struct InfoDetailData: Identifiable {
    
    /// The image to display
    let image: Image
    
    /// The title of the row
    let title: String
    
    /// The body of the row
    let body: String
    
    /// Conformance to `Identifiable`
    public let id = UUID()
    
    /// Memberwise initialiser
    /// - Parameters:
    ///   - image: The image to display
    ///   - title: The title to display right of the image
    ///   - body: The body to display beneath the title
    public init(image: Image, title: String, body: String) {
        self.image = image
        self.title = title
        self.body = body
    }
}
