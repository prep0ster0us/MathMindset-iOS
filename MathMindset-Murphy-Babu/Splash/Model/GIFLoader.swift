import SwiftUI
import WebKit

// Reference: https://www.youtube.com/watch?v=DUOrei4n7Mo
struct GIFLoader: UIViewRepresentable {
    let gifName: String
    
    func makeUIView(context: Context) -> some WKWebView {
        let webView = WKWebView()
        if let url = Bundle.main.url(forResource: gifName, withExtension: "gif"),
           let data = try? Data(contentsOf: url) {
            webView.load(data, 
                         mimeType: "image/gif",
                         characterEncodingName: "UTF-8",
                         baseURL: url.deletingLastPathComponent()
            )
        } else {
            print("Error loading gif..")
        }
        return webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.reload()
    }
}
