//
//  ViewController.swift
//  QRCode-Example
//
//  Created by Hans Knöchel on 09.06.17.
//  Copyright © 2017 Hans Knoechel. All rights reserved.
//

import UIKit
import Vision
import AVKit

class ViewController: UIViewController {
    
    @IBOutlet var previewView: VideoPreviewView!
    
    var captureSession: AVCaptureSession!
    
    var isCaptureSessionConfigured = false
    
    //MARK: overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        previewView.session = captureSession
        
        // TODO get image from camera to scan
        //scanImageFromCamera()
        
        //scanImage(cgImage: #imageLiteral(resourceName: "qr-code").cgImage!)
        //scanImage(cgImage: #imageLiteral(resourceName: "bar-code").cgImage!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isCaptureSessionConfigured {
            if !captureSession.isRunning {
                captureSession.startRunning()
            }
        }
        else {
            configureCaptureSession()
            isCaptureSessionConfigured = true
            captureSession.startRunning()
            previewView.updateVideoOrientationForDeviceOrientation()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    //MARK: private methods
    
    private func configureCaptureSession() {
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Unable to find capture device")
            return
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            print("Unable to obtain video input")
            return
        }
        
        let capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput.isHighResolutionCaptureEnabled = true
        capturePhotoOutput.isLivePhotoCaptureEnabled = capturePhotoOutput.isLivePhotoCaptureSupported
        
        guard captureSession.canAddInput(videoInput) else {
            print("Unable to add input")
            return
        }
        guard captureSession.canAddOutput(capturePhotoOutput) else {
            print("Unable to add output")
            return
        }
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        captureSession.addInput(videoInput)
        captureSession.addOutput(capturePhotoOutput)
        captureSession.commitConfiguration()
        
    }
    
    private func scanImage(cgImage: CGImage) {
        
        let barcodeRequest = VNDetectBarcodesRequest(completionHandler: {(request, error) in
            self.reportResults(results: request.results)
        })
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [.properties : ""])
        
        guard let _ = try? handler.perform([barcodeRequest]) else {
            return print("Could not perform barcode-request!")
        }
        
    }
    
    private func reportResults(results: [Any]?) {
        
        // Loop through the found results
        print("Barcode observation")
        if results == nil {
            print("No results found.")
        }
        else {
            print("Number of results found: \(results!.count)")
            for result in results! {
                
                // Cast the result to a barcode-observation
                if let barcode = result as? VNBarcodeObservation {
                    
                    if let payload = barcode.payloadStringValue {
                        print("Payload: \(payload)")
                    }
                    
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
        }
        print("")
    }
    
}

