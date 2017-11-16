//
//  QRCodeScannerViewController.swift
//  AddMe
//
//  Created by Naman Kedia on 11/13/17.
//  Copyright © 2017 Naman Kedia. All rights reserved.
//

import UIKit
import AVFoundation
import Contacts

class QRCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    //MARK: Properties
    
    var feedbackGenerator = UINotificationFeedbackGenerator()

    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?

    var contact: CNContact? {
        didSet {
            presentContactViewController(withContact: contact!)
        }
    
    }
    
    //MARK: IB Outlets
    @IBOutlet weak var backgroundView: UIView!


    override func viewDidLoad() {
        super.viewDidLoad()
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.insertSublayer(videoPreviewLayer!, at: 0)
            captureSession?.startRunning()
        } catch {
            print(error)
            return
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if (metadataObjects.count == 0) {
            return
        }
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            
            if metadataObj.stringValue != nil {
                // Check here if QR code is valid
                let contactStringData = metadataObj.stringValue
                print(contactStringData)
                if let data = contactStringData?.data(using: .utf8) {
                    do {
                        let contacts = try CNContactVCardSerialization.contacts(with: data)
                        if contact == nil {
                            feedbackGenerator.prepare()
                            feedbackGenerator.notificationOccurred(.success)
                            contact = contacts.first
                        }
//                        captureSession?.stopRunning()
                    } catch {
                        print("couldn't convert QR Code to VCard")
                    }
                }
            }
        }
    }
    
    func presentContactViewController(withContact contact: CNContact) {
        if let contactCardViewController = self.storyboard?.instantiateViewController(withIdentifier: "ContactViewControllerID") as? ContactCardViewController {
            contactCardViewController.contactCard = contact
            let width: CGFloat = self.view.bounds.width * 0.85
            let height: CGFloat = self.view.bounds.height * 0.68
            contactCardViewController.view.frame = CGRect(x: self.view.bounds.width/2 - width/2, y: self.view.bounds.height, width: width, height: height)
            self.view.addSubview(contactCardViewController.view)
            self.addChildViewController(contactCardViewController)
            contactCardViewController.view.layer.cornerRadius = 40
            contactCardViewController.view.layer.masksToBounds = true
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
                contactCardViewController.view.frame.origin.y = self.view.bounds.height/2 - height/2
                self.backgroundView.alpha = 0.8
            }, completion: { (complete) in
                contactCardViewController.didMove(toParentViewController: self)
            })
        }
       
    }
    
    func removeContactViewController() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "QRCodeToContactSegueID") {
            if let contactVC = segue.destination as? ContactCardViewController {
                contactVC.contactCard = contact
            }
        }
    }
}


