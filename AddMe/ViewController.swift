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
        contactToVCard(contact: contact)
    }
    
    func saveContact(contact: CNMutableContact) {
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier:nil)
        try! contactStore.execute(saveRequest)
    }
    
    func fetchContacts() {
        let predicate: NSPredicate = CNContact.predicateForContacts(matchingName: "Shubham Kedia")
        let keysToFetch = [CNContactVCardSerialization.descriptorForRequiredKeys()]
        let contacts = try? contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as [CNKeyDescriptor])
        if let contacts = contacts {
            let contact = contacts.first
//            contactToVCard(contact: contact!)
        }
    }
    
    func contactToVCard(contact: CNContact) {
        do {
            let data = try CNContactVCardSerialization.data(with: [contact])
            print(data.description)
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

