import Cocoa
import FlutterMacOS
import PDFKit

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    let pdfChannel = FlutterMethodChannel(
      name: "pilot_app/pdf_text",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    pdfChannel.setMethodCallHandler { call, result in
      guard call.method == "extractText",
            let typedData = call.arguments as? FlutterStandardTypedData,
            let document = PDFDocument(data: typedData.data) else {
        result(FlutterError(code: "invalid_pdf", message: "The selected file could not be opened as a PDF.", details: nil))
        return
      }
      let text = (0..<document.pageCount)
        .compactMap { document.page(at: $0)?.string }
        .joined(separator: "\n")
      result(text)
    }

    super.awakeFromNib()
  }
}
