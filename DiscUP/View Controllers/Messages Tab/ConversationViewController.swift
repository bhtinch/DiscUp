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
    
    var basicConvo: ConversationBasic?
    var messages: [MKmessage] = []
    var isNewConvo: Bool = false
    var itemID: String?
    var item: MarketItem?
    var blockedUserIDs : [String] = []
    
    //  MARK: - LIFECYLCES
    override func viewDidLoad() {
        super.viewDidLoad()
                
        configureMessageCollectionView()
        configureMessageInputBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let basicConvo = basicConvo {
            self.title = basicConvo.itemHeadline
        }
        
        fetchBlockedUsers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        if let convoID = basicConvo?.id {
            MessagingManager.resetMessageCount(convoID: convoID)
        }
    }
    
    //  MARK: - ACTIONS
    @IBAction func moreButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Block This User?", message: "Any new messages from this user will no longer be shown.  The user will not be notified that you have blocked them, however.", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        let blockAction = UIAlertAction(title: "Yes, Block this User.", style: .destructive) { _ in
            self.blockUser()
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(blockAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //  MARK: - METHODS
    func fetchItem() {
        guard let itemID = basicConvo?.itemID else { return }
        
        MarketManager.fetchItemWith(itemID: itemID) { fetchedItem in
            DispatchQueue.main.async {
                if let item = fetchedItem {
                    self.item = item
                }
            }
        }
    }
    
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
    
    func fetchBlockedUsers() {
        MessagingManager.fetchBlockedUsers { blockedUserIDs in
            DispatchQueue.main.async {
                self.blockedUserIDs = blockedUserIDs
                self.listenForMessages()
            }
        }
    }
    
    func listenForMessages() {
        guard let convoID = basicConvo?.id else { return }
        
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
                
                if self.blockedUserIDs.contains(sender.senderId)  { continue }
                
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
    
    func blockUser() {
        guard let convoID = basicConvo?.id else { return }
        
        MessagingManager.blockUserFromConversationWith(convoID: convoID, blockedUsersList: blockedUserIDs) { success in
            DispatchQueue.main.async {
                if success {
                    Alerts.presentAlertWith(title: "This user is now blocked.", message: "You will no longer see new messages. You may unblock users at any time in the app settings.", sender: self)
                }
            }
        }
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
            
            MessagingManager.createNewConversationWith(item: item, text: text) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let basicConvo):
                        self.isNewConvo = false
                        self.basicConvo = basicConvo
                        self.listenForMessages()
                    case .failure(let error):
                        print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                        Alerts.presentAlertWith(title: "Uh-Oh!", message: "Your message could not be sent for an unknown reason.  Please try again.", sender: self)
                    }
                }
            }
        } else {
            if let convoID = self.basicConvo?.id {
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

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let initials = sender.displayName.first ?? "?"
        
        avatarView.backgroundColor = .link
        
        if message.sender.senderId == Auth.auth().currentUser?.uid {
            avatarView.backgroundColor = #colorLiteral(red: 0.3236978054, green: 0.1063579395, blue: 0.574860394, alpha: 1)
        }
        
        MarketManager.fetchImageWith(imageID: message.sender.senderId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    let avatar = Avatar(image: image, initials: initials.description)
                    avatarView.set(avatar: avatar)
                    
                case .failure(_):
                    let avatar = Avatar(image: nil, initials: initials.description)
                    avatarView.set(avatar: avatar)
                }
            }
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = message.sentDate.dateToString(format: .monthDayYearTimestamp)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
}   //  End of Extension

// MARK: - MessagesLayoutDelegate
extension ConversationViewController: MessagesLayoutDelegate {
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 30
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 17
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}   //  End of Extension

