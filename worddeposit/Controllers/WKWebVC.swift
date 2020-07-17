import UIKit
import WebKit

class WKWebVC: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var link: String!

    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let url = URL(string: link) else { return }
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }

}
