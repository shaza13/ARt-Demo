import UIKit

import AVFoundation

import CoreML



class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

        

    @IBOutlet var imageView: UIImageView!

    

    var model: nightcafe!

    

    var captureSession: AVCaptureSession?

    var rearCamera: AVCaptureDevice?

    var rearCameraInput: AVCaptureDeviceInput?

    var videoOutput: AVCaptureVideoDataOutput?

    

    var latestImage: UIImage?

    

    override func viewDidLoad() {

        super.viewDidLoad()

        

        model = nightcafe()

        

        self.captureSession = AVCaptureSession()

        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)

        

        self.rearCamera = session.devices.first

        

        if let rearCamera = self.rearCamera {

            try? rearCamera.lockForConfiguration()

            rearCamera.focusMode = .autoFocus

            rearCamera.unlockForConfiguration()

        }

        

        if let rearCamera = self.rearCamera {

            self.rearCameraInput = try? AVCaptureDeviceInput(device: rearCamera)

            

            if let rearCameraInput = rearCameraInput {

                if captureSession!.canAddInput(rearCameraInput) {

                    captureSession?.addInput(rearCameraInput)

                }

            }

        }

        self.videoOutput = AVCaptureVideoDataOutput()

        self.videoOutput!.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))

        

        if captureSession!.canAddOutput(self.videoOutput!) {

            captureSession?.addOutput(self.videoOutput!)

        }

        

        self.captureSession?.startRunning()

        

        showStylized()

        

    }

        // Do any additional setup after loading the view.

        

        func pixelBuffer(from image: UIImage) -> CVPixelBuffer? {

            // 1

            UIGraphicsBeginImageContextWithOptions(CGSize(width: 640, height: 640), true, 2.0)

            image.draw(in: CGRect(x: 0, y: 0, width: 640, height: 640))

            UIGraphicsEndImageContext()

         

            // 2

            let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary

            var pixelBuffer : CVPixelBuffer?

            let status = CVPixelBufferCreate(kCFAllocatorDefault, 640, 640, kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)

            guard (status == kCVReturnSuccess) else {

                return nil

            }

               

            // 3

            CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

            let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

               

            // 4

            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()

            let context = CGContext(data: pixelData, width: 640, height: 640, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

               

            // 5

            context?.translateBy(x: 0, y: 640)

            context?.scaleBy(x: 1.0, y: -1.0)

            

            // 6

            UIGraphicsPushContext(context!)

            image.draw(in: CGRect(x: 0, y: 0, width: 640, height: 640))

            UIGraphicsPopContext()

            CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

                

            return pixelBuffer

        }

        

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}

            let ciImage = CIImage(cvPixelBuffer: imageBuffer)

            

            let context = CIContext()

            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }

            

            DispatchQueue.main.async {

                self.latestImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)

            }

        }

        

        func showStylized() {

            if let latestImage = latestImage {

                let styleArray = try? MLMultiArray(shape: [1] as [NSNumber], dataType: .double)

                styleArray?[0] = 1.0

                if let image = self.pixelBuffer(from: latestImage) {

                    do {

                        let predictionOutput = try self.model.prediction(image: image)

                        let ciImage = CIImage(cvPixelBuffer: predictionOutput.stylizedImage)

                        let tempContext = CIContext(options: nil)

                        let tempImage = tempContext.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width:

                            CVPixelBufferGetWidth(predictionOutput.stylizedImage), height: CVPixelBufferGetHeight(predictionOutput.stylizedImage)))

                        self.imageView.image = UIImage(cgImage: tempImage!)

                    } catch let error as NSError {

                        print("CoreML Model Error: \(error)")

                    }

                    }

                }

            Timer.scheduledTimer(withTimeInterval: 1.0 / 2000.0, repeats: false) { (_) in

                self.showStylized()

            }

        }

    }
