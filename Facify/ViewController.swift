//
//  ViewController.swift
//  Facify
//
//  Created by Khurram on 20/03/2018.
//  Copyright © 2018 Khurram. All rights reserved.
//
import AVFoundation
import UIKit

class ViewController: UIViewController {

override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    if isCameraAuthorized() {
        configureCamera()
    }
    cv.completionBlock = { result, imageSize in
        for face in self.facesLayers {
            face.removeFromSuperlayer()
        }
        self.facesLayers.removeAll()
        guard let newFaces = result else {
            return
        }
        let viewSize = self.view.frame.size
        for value in newFaces {
            let layer = CALayer()
            var faceRect = value.cgRectValue
            faceRect.origin.x /= imageSize.width
            faceRect.origin.y /= imageSize.height
            faceRect.size.width /= imageSize.width
            faceRect.size.height /= imageSize.height
            
            faceRect.origin.x *= viewSize.width
            faceRect.size.width *= viewSize.width
            faceRect.origin.y *= viewSize.height
            faceRect.size.height *= viewSize.height
        
            layer.frame = faceRect
            layer.borderColor = UIColor.green.cgColor
            layer.borderWidth = 3.0
            self.view.layer.addSublayer(layer)
            self.facesLayers.append(layer)
        }
    }
}

override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
}
private var cameraView: CameraView {
    return view as! CameraView
}
private var facesLayers = [CALayer]()
private let session = AVCaptureSession()
private let cv = CVWrapper()
}
// MARK: - Authorization
extension ViewController {
private func isCameraAuthorized() -> Bool {
    let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    switch authorizationStatus {
    case .notDetermined:
        AVCaptureDevice.requestAccess(for: AVMediaType.video,
                                      completionHandler: { (granted:Bool) -> Void in
                                        if granted {
                                            DispatchQueue.main.async {
                                                self.configureCamera()
                                            }
                                        }
        })
        return true
    case .authorized:
        return true
    case .denied, .restricted: return false
    }
}
}
// MARK: - Configurations
extension ViewController {
private func configureCamera() {
    cameraView.session = session
    let cameraDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
    if cameraDevices.devices.isEmpty {
        return
    }
    let cameraDevice: AVCaptureDevice = cameraDevices.devices.first!
    do {
        let captureDeviceInput = try AVCaptureDeviceInput(device: cameraDevice)
        if session.canAddInput(captureDeviceInput) {
            session.addInput(captureDeviceInput)
        }
    }
    catch {
        print("Error occured \(error)")
        return
    }
    session.sessionPreset = .medium
    let videoDataOutput = AVCaptureVideoDataOutput()
    videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Buffer Queue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil))
    if session.canAddOutput(videoDataOutput) {
        session.addOutput(videoDataOutput)
    }
    cameraView.videoPreviewLayer.videoGravity = .resize
    session.startRunning()
}
}
// MARK: - Camera Delegate
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
        return
    }
    cv.detectFaces(pixelBuffer)
}
}
