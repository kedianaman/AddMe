//
//  ContactCardViewController.swift
//  AddMe
//
//  Created by Naman Kedia on 11/12/17.
//  Copyright © 2017 Naman Kedia. All rights reserved.
//

import UIKit
import Contacts

class ContactCardViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var phonenumberLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet var socialMediaProfiles: [UIButton]!
    
    var contactCard: CNContact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        contactCard = getMyContact()
        if let contactCard = contactCard {
            nameLabel.text = contactCard.givenName + " " + contactCard.familyName
            nicknameLabel.text = contactCard.nickname
            
            if let imageData = contactCard.imageData {
                let thumbnailImage = UIImage(data: imageData)
                thumbnailImageView.image = thumbnailImage
            } else {
                // set blank image
            }
            var phonenumberString = "";
            let phonenumbers = contactCard.phoneNumbers
            for i in 0..<phonenumbers.count {
                let number = phonenumbers[i]
                phonenumberString += number.value.stringValue + "\n"
            }
            phonenumberLabel.text = phonenumberString
            
            if let birthday = contactCard.birthday?.date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                birthdayLabel.text = dateFormatter.string(from: birthday)
            }
            
            var emailAddressString = "";
            let emailAddresses = contactCard.emailAddresses
            for i in 0..<emailAddresses.count {
                let emailAddress = emailAddresses[i]
                emailAddressString += (emailAddress.value as String) + "\n"
            }
            emailLabel.text = emailAddressString
            
            if let address = contactCard.postalAddresses.first?.value {
                addressLabel.text = address.city + ", " + address.country
            }
            
            let socialProfiles = contactCard.socialProfiles
            for i in 0..<5 {
                if (socialProfiles.count > i) {
                    let socialProfile = socialProfiles[i].value
                    socialMediaProfiles[i].setTitle(socialProfile.service, for: .normal)
                    socialMediaProfiles[i].tag = i
                }
            }
        }
    }
    
    
    @IBAction func socialMediaPressed(_ sender: UIButton) {
        
        let socialMedia = contactCard?.socialProfiles[sender.tag].value
        var link = socialMedia?.urlString
        print(socialMedia!.service)
        if (socialMedia!.service == "Snapchat ") {
            link = "https://www.snapchat.com/add/\(socialMedia!.username)"
        } else if (socialMedia!.service == "Instagram") {
             link = "https://www.instagram.com/\(socialMedia!.username)/"
        }
        if let url = URL(string: link!) {
            UIApplication.shared.open(url, options: [:], completionHandler: { (finished) in
                    print("opened url")
            })
        }

    }
    
    
    func getMyContact() -> CNContact? {
        let predicate: NSPredicate = CNContact.predicateForContacts(matchingName: "Naman Kedia")
        let keysToFetch = [CNContactVCardSerialization.descriptorForRequiredKeys()]
        let contacts = try? CNContactStore().unifiedContacts(matching: predicate, keysToFetch: keysToFetch as [CNKeyDescriptor])
        if let contacts = contacts {
            let contact = contacts.first
            return contact
        }
        return nil
    }
    
    

}
