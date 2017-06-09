# 🔲 iOS11 QR-Code Example
A quick example showing how to use the `Vision` system-framework in iOS 11 and Swift 4.

## Prerequisites
* Xcode 9 Beta (tested with B1)

## Getting Started
First, import the `Vision` framework.
```swift
import Vision
```
Next, create a barcode-request that will call the completion-handler asynchronously when it detects a code:
```swift
// Create a barcode detection-request
let barcodeRequest = VNDetectBarcodesRequest(completionHandler: {(request, error) in
    
    // Loopm through the found results
    for result in request.results! {
        
        // Cast the result to a barcode-observation
        if let barcode = result as? VNBarcodeObservation {
            
            // Print barcode-values
            print("Symbology: \(barcode.symbology.rawValue)")
            
            if let desc = barcode.barcodeDescriptor as? CIQRCodeDescriptor {
                let content = String(data: desc.errorCorrectedPayload, encoding: .utf8)
                
                // FIXME: This currently returns nil. I did not find any docs on how to encode the data properly so far.
                print("Payload: \(String(describing: content))")
                print("Error-Correction-Level: \(desc.errorCorrectionLevel)")
                print("Symbol-Version: \(desc.symbolVersion)")
            }
        }
    }
})
```
Finally, call the image-request-handler with the previously create barcode-request:
```swift
// Create an image handler and use the CGImage your UIImage instance
// FIXME: I did not find any docs on how to configure the options properly so far.
let handler = VNImageRequestHandler(cgImage: #imageLiteral(resourceName: "qr-code").cgImage!, options: [.properties : ""])

// Perform the barcode-request. This will call the completion-handler of the barcode-request.
guard let _ = try? handler.perform([barcodeRequest]) else {
    return print("Could not perform barcode-request!")
}
```
That's it! Run the app on the simulator / device and detect QR-codes.

## More Ideas
This does not show how to use the camera to detect QR-codes on the fly, so this repository should be extended
to do so - if there is a public API for that already.

## Author
Hans Knöchel ([@hansemannnn](https://twitter.com/hansemannnn))
