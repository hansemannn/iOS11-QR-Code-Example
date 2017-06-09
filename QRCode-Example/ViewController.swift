//
//  ViewController.swift
//  QRCode-Example
//
//  Created by Hans Knöchel on 09.06.17.
//  Copyright © 2017 Hans Knoechel. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // Create an image handler and use the CGImage your UIImage instance
        // FIXME: I did not find any docs on how to configure the options properly so far.
        let handler = VNImageRequestHandler(cgImage: #imageLiteral(resourceName: "qr-code").cgImage!, options: [.properties : ""])
        
        guard let _ = try? handler.perform([barcodeRequest]) else {
            return print("Could not perform barcode-request!")
        }
    }
}

