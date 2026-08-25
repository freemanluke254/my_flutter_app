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
      switch call.method {
      case "extractText":
        guard let typedData = call.arguments as? FlutterStandardTypedData,
              let document = PDFDocument(data: typedData.data) else {
          result(FlutterError(code: "invalid_pdf", message: "The selected file could not be opened as a PDF.", details: nil))
          return
        }
        let text = (0..<document.pageCount)
          .compactMap { document.page(at: $0)?.string }
          .joined(separator: "\n")
        result(text)
      case "renderFirstPage":
        guard let path = call.arguments as? String,
              let document = PDFDocument(url: URL(fileURLWithPath: path)),
              let page = document.page(at: 0) else {
          result(FlutterError(code: "invalid_pdf_path", message: "The PDF preview could not be opened.", details: nil))
          return
        }
        let thumbnail = page.thumbnail(of: NSSize(width: 420, height: 280), for: .mediaBox)
        guard let tiff = thumbnail.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let png = bitmap.representation(using: .png, properties: [:]) else {
          result(FlutterError(code: "preview_failed", message: "The PDF preview could not be rendered.", details: nil))
          return
        }
        result(FlutterStandardTypedData(bytes: png))
      case "renderPdfPage":
        guard let arguments = call.arguments as? [String: Any],
              let path = arguments["path"] as? String,
              let pageIndex = arguments["page"] as? Int,
              let width = arguments["width"] as? Double,
              let height = arguments["height"] as? Double,
              let document = PDFDocument(url: URL(fileURLWithPath: path)),
              let page = document.page(at: pageIndex) else {
          result(FlutterError(code: "invalid_pdf_page", message: "The requested PDF page could not be opened.", details: nil))
          return
        }
        let image = page.thumbnail(
          of: NSSize(width: width, height: height),
          for: .mediaBox
        )
        guard let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let png = bitmap.representation(using: .png, properties: [:]) else {
          result(FlutterError(code: "page_render_failed", message: "The PDF page could not be rendered.", details: nil))
          return
        }
        result(FlutterStandardTypedData(bytes: png))
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }
}
