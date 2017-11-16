//
//  ViewController.swift
//  AddMe
//
//  Created by Naman Kedia on 11/10/17.
//  Copyright © 2017 Naman Kedia. All rights reserved.
//

import UIKit
import Contacts

class ViewController: UIViewController {
    
    @IBOutlet weak var qrCodeImageView: UIImageView!
    var contactStore: CNContactStore!

    override func viewDidLoad() {
        super.viewDidLoad()
        contactStore = CNContactStore()
        fetchContacts()
        
        let contact = CNMutableContact()
        contact.imageData = Data() // The profile picture as a NSData object
        
        contact.givenName = "John"
        contact.familyName = "Appleseed"
        
        let homeEmail = CNLabeledValue(label:CNLabelHome, value:"john@example.com" as NSString)
        let workEmail = CNLabeledValue(label:CNLabelWork, value:"j.appleseed@icloud.com" as NSString)
        
        contact.emailAddresses = [homeEmail, workEmail]
        
        contact.phoneNumbers = [CNLabeledValue(
            label:CNLabelPhoneNumberiPhone,
            value:CNPhoneNumber(stringValue:"(408) 555-0126"))]
        
        let homeAddress = CNMutablePostalAddress()
        homeAddress.street = "1 Infinite Loop"
        homeAddress.city = "Cupertino"
        homeAddress.state = "CA"
        homeAddress.postalCode = "95014"
        contact.postalAddresses = [CNLabeledValue(label:CNLabelHome, value:homeAddress)]
        
        var birthday = DateComponents()
        birthday.day = 1
        birthday.month = 4
        birthday.year = 1988  // You can omit the year value for a yearless birthday
        contact.birthday = birthday
        let fb = CNSocialProfile(urlString: "https://www.facebook.com/naman.kedia.5", username: "naman.kedia5", userIdentifier: "", service: "Facebook")
        let facebookLabeledValue = CNLabeledValue(label: "Facebook", value: fb)
        let snapchat = CNSocialProfile(urlString: "https://www.snapchat.com/add/joditheunicorn", username: "joditheunicorn", userIdentifier: "", service: "Snapchat")
        let snapchatLabeledValue = CNLabeledValue(label: "Snapchat", value: snapchat)
        let instagram = CNSocialProfile(urlString: "https://www.instagram.com/faridaeldeftar/", username: "faridaeldeftar", userIdentifier: "", service: "Instagram")
        let instagramtLabeledValue = CNLabeledValue(label: "Instagram", value: instagram)
        contact.socialProfiles = [facebookLabeledValue, snapchatLabeledValue, instagramtLabeledValue]
//        contactToVCard(contact: contact)
    }
    
    func saveContact(contact: CNMutableContact) {
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier:nil)
        try! contactStore.execute(saveRequest)
    }
    
    func fetchContacts() {
        let predicate: NSPredicate = CNContact.predicateForContacts(matchingName: "Naman Kedia")
        let keysToFetch = [CNContactVCardSerialization.descriptorForRequiredKeys(), CNContactImageDataAvailableKey] as [Any]
        let contacts = try? contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
        if let contacts = contacts {
            let contact = contacts.first
            contactToVCard(contact: contact!)
        }
    }
    
    func contactToVCard(contact: CNContact) {
        do {
            
            let data = try CNContactVCardSerialization.data(with: [contact])
            print(data.description)
            let dataWithImage = try CNContactVCardSerialization.data(jpegPhotoContacts: [contact])
            
            let dataString = String(data: dataWithImage, encoding: String.Encoding.utf8)
            print(dataString)
            
            //https://stackoverflow.com/questions/39638149/how-to-get-vcf-data-with-contact-images-using-cncontactvcardserialization-datawi

            if let filter = CIFilter(name: "CIQRCodeGenerator") {
                filter.setValue(data, forKey: "inputMessage")
                let transform = CGAffineTransform(scaleX: 1, y: 1)
                if let output = filter.outputImage?.transformed(by: transform) {
                    let image =  UIImage(ciImage: output)
                    qrCodeImageView.image = image
                }
            }
            
            if let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                let fileURL = directoryURL.appendingPathComponent("john.appleseed").appendingPathExtension("vcf")
                do {
                    try data.write(to: fileURL)
                } catch {
                    print("error writing to file")
                }
            }
            
        } catch {
            print("error turning into Vcard")
        }
    }


}

import Foundation
import Contacts

extension CNContactVCardSerialization {
    internal class func vcardDataAppendingPhoto(vcard: Data, photoAsBase64String photo: String) -> Data? {
        let vcardAsString = String(data: vcard, encoding: .utf8)
        let vcardPhoto = "PHOTO;TYPE=JPEG;ENCODING=BASE64:".appending(photo)
        let vcardPhotoThenEnd = vcardPhoto.appending("\nEND:VCARD")
        if let vcardPhotoAppended = vcardAsString?.replacingOccurrences(of: "END:VCARD", with: vcardPhotoThenEnd) {
            return vcardPhotoAppended.data(using: .utf8)
        }
        return nil
        
    }
    class func data(jpegPhotoContacts: [CNContact]) throws -> Data {
        
        var overallData = Data()
        for contact in jpegPhotoContacts {
            let data = try CNContactVCardSerialization.data(with: [contact])
            if contact.imageDataAvailable {
                if let base64imageString = contact.imageData?.base64EncodedString(),
                    let updatedData = vcardDataAppendingPhoto(vcard: data, photoAsBase64String: base64imageString) {
                    overallData.append(updatedData)
                }
            } else {
                overallData.append(data)
            }
        }
        return overallData
    }
}

