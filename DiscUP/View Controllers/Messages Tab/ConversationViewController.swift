//
//  ConversationViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 4/19/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseAuth
import FirebaseDatabase

class ConversationViewController: MessagesViewController {
    //  MARK: - OUTLETS
    
    //  MARK: - PROPERTIES
    var sender: Sender {
        var displayName = ""
        var senderID = ""
        
        if let user = Auth.auth().currentUser {
            displayName = user.displayName ?? ""
            senderID = user.uid
        }
        
        return Sender(photoURL: "", senderId: senderID, displayName: displayName)
    }
    
    var convoID: String?
    var messages: [MKmessage] = []
    var isNewConvo: Bool = false
    var item: MarketItem?
    
    //  MARK: - LIFECYLCES
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageCollectionView()
        configureMessageInputBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        listenForMessages()
    }
    
    //  MARK: - METHODS
    func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        showMessageTimestampOnSwipeLeft = true // default false
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .blue
        messageInputBar.sendButton.setTitleColor(.blue, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.blue.withAlphaComponent(0.3),
            for: .highlighted
        )
    }
    
    func listenForMessages() {
        guard let convoID = convoID else { return }
        
        let pathString = "\(convoID)/\(ConversationKeys.messages)"
        
        MessagingDB.shared.dbRef.child(pathString).observe(.value) { (snap) in
            guard let msgs = snap.value as? [String : [String : String]] else { return }
            
            let msgsSorted = msgs.sorted {
                return $0.key < $1.key
            }
            
            self.messages = []
            
            for msg in msgsSorted {
                let content = msg.value[MessageKeys.text] ?? "no content"
                let userID = msg.value[MessageKeys.senderID] ?? "no sender"
                let displayName = msg.value[MessageKeys.senderDisplayName] ?? "no name"
                
                guard let date = msg.key.stringToLocalDate(format: .MM_dd_yyyy_T_HH_mm_ss_SSS_Z) else { return }
                
                let sender = Sender(photoURL: "", senderId: userID, displayName: displayName)
                let message = MKmessage(text: content, user: sender, messageId: msg.key, date: date)
                
                self.messages.append(message)
                
                self.updateView()
            }
        }
    }
    
    func updateView() {
        self.messagesCollectionView.reloadDataAndKeepOffset()
        self.messagesCollectionView.scrollToLastItem()
    }

}   //  End of Class

// MARK: - Extensions
extension ConversationViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        
        print("Sending: \(text)")
        
        if isNewConvo {
            //  update buyer and seller user nodes and create convo node
            guard let item = item else { return }
            
            MessagingManager.createNewConversationWith(item: item, text: text) { convoID in
                DispatchQueue.main.async {
                    if convoID != "noConvoID" {
                        self.isNewConvo = false
                        self.convoID = convoID
                        self.listenForMessages()
                    } else {
                        //  present alert about not able to send message.
                        Alerts.presentAlertWith(title: "Uh-Oh!", message: "Your message could not be sent for an unknown reason.  Please try again.", sender: self)
                    }
                }
            }
        } else {
            if let convoID = self.convoID {
                MessagingManager.sendMessage(to: convoID, with: text) { success in
                    if success {
                        print("message successfully sent")
                    } else {
                        Alerts.presentAlertWith(title: "Uh-Oh!", message: "Your message could not be sent for an unknown reason.  Please try again.", sender: self)
                    }
                }
            }
        }
        
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        // Send button activity animation
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending..."
        // Resign first responder for iPad split view
        inputBar.inputTextView.resignFirstResponder()
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                inputBar.sendButton.stopAnimating()
                inputBar.inputTextView.placeholder = "Aa"
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
} // END OF EXTENSION

// MARK: - Messages DataSource & Delegates
extension ConversationViewController: MessagesDataSource, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return sender
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    
    
} // END OF EXTENSION

// MARK: - MessageCellDelegate
extension ConversationViewController: MessageCellDelegate {
}   //  End of Extension

// MARK: - MessagesLayoutDelegate
extension ConversationViewController: MessagesLayoutDelegate {
}   //  End of Extension
