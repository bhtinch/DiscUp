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
import AVFoundation
import Photos

class ConversationViewController: MessagesViewController {
    //  MARK: - OUTLETS
    @IBOutlet weak var itemHighlightView: UIView!
    
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
    var senderAvatarImage: UIImage?
    var receiverAvatarImage: UIImage?
    var mediaMessageProtos: [MKmessageProto] = []
    
    lazy var attachmentManager: AttachmentManager = { [unowned self] in
        let manager = AttachmentManager()
        return manager
    }()
    
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
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        let blockAction = UIAlertAction(title: "Block This User", style: .default) { _ in
            self.presentBlockUserAlert()
            alert.dismiss(animated: true, completion: nil)
        }
        
        let viewItemAction = UIAlertAction(title: "View Listing", style: .default) { _ in
            
            self.performSegue(withIdentifier: "toItemDetailVC", sender: self)
            
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(viewItemAction)
        
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
        let messageInputBar = CameraInputBarAccessoryView()
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .blue
        messageInputBar.sendButton.setTitleColor(.blue, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.blue.withAlphaComponent(0.3),
            for: .highlighted
        )
        
        let camera = makeButton(named: "ic_camera")
        camera.tintColor = .darkGray
        camera.onTouchUpInside { (item) in
            print("camera tapped.")
            self.presentImageAlert()
        }
        
        messageInputBar.setLeftStackViewWidthConstant(to: 35, animated: true)
        messageInputBar.setStackViewItems([camera], forStack: .left, animated: false)
        attachmentManager.delegate = messageInputBar
        messageInputBar.inputPlugins = [attachmentManager]
        
        self.messageInputBar = messageInputBar
    }
    
    func fetchBlockedUsers() {
        MessagingManager.fetchBlockedUsers { blockedUserIDs in
            DispatchQueue.main.async {
                self.blockedUserIDs = blockedUserIDs
                self.fetchSenderAvatar()
            }
        }
    }
    
    func fetchSenderAvatar() {
        guard let _ = basicConvo else { return }
        
        MarketManager.fetchImageWith(imageID: sender.senderId) { result in
            switch result {
            
            case .success(let image):
                self.senderAvatarImage = image
                self.fetchReceiverAvatar()
            case .failure(let error):
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchReceiverAvatar() {
        guard let basicConvo = basicConvo else { return }
        
        var imageID = ""
        
        if basicConvo.buyerID == sender.senderId {
            imageID = basicConvo.sellerID
        } else {
            imageID = basicConvo.buyerID
        }
        
        MarketManager.fetchImageWith(imageID: imageID) { result in
            switch result {
            
            case .success(let image):
                self.receiverAvatarImage = image
                self.listenForMessages()
            case .failure(let error):
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
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
            self.mediaMessageProtos = []
            
            for i in 0..<msgsSorted.count {
                let msg = msgsSorted[i]
                
                let content = msg.value[MessageKeys.text] ?? "no content"
                let userID = msg.value[MessageKeys.senderID] ?? "no sender"
                let displayName = msg.value[MessageKeys.senderDisplayName] ?? "no name"
                let imageID: String? = msg.value[MessageKeys.imageID]
                
                guard let date = msg.key.stringToLocalDate(format: .MM_dd_yyyy_T_HH_mm_ss_SSS_Z) else { return }
                
                let sender = Sender(photoURL: "", senderId: userID, displayName: displayName)
                
                if self.blockedUserIDs.contains(sender.senderId)  { continue }
                                
                if let imageID = imageID {
                    let proto = MKmessageProto(sender: sender, sentDate: date, messageID: msg.key, convoIndex: i, imageID: imageID)
                    self.mediaMessageProtos.append(proto)
                } else {
                    let message = MKmessage(text: content, user: sender, messageId: msg.key, date: date)
                    self.messages.append(message)
                    self.updateView()
                }
                
                if i == msgsSorted.count - 1 {
                    self.appendMediaMessages()
                }
            }
        }
    }
    
    func appendMediaMessages() {
        
        for proto in mediaMessageProtos {
            MarketManager.fetchImageWith(imageID: proto.imageID) { result in
                DispatchQueue.main.async {
                    switch result {
                    
                    case .success(let image):
                        let message = MKmessage(text: "", mediaItem: image.asMediaItem(), user: proto.sender, messageId: proto.messageID, date: proto.sentDate)
                        
                        if proto.convoIndex >= self.messages.count {
                            self.messages.append(message)
                        } else {
                            self.messages.insert(message, at: proto.convoIndex)
                        }
                        	
                        self.updateView()
                        
                    case .failure(let error):
                        print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    }
                }
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
    
    func presentBlockUserAlert() {
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
    
    //  MARK: - NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toItemDetailVC" {
            guard let destination = segue.destination as? MarketItemDetailViewController,
                  let itemID = basicConvo?.itemID else { return }
            
            destination.itemID = itemID
        }
    }
    
}   //  End of Class

// MARK: - Extensions
extension ConversationViewController: CameraInputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment]) {
        guard let attachment = attachments.first,
              let convoID = basicConvo?.id else { return }
        
        switch attachment {
        case .image(let image):
            image.accessibilityIdentifier = "\(convoID)_\(UUID().uuidString)"
            
            StorageManager.uploadImagesWith(images: [image]) { result in
                switch result {
                case .success(_):
                    print("Image successfully uploaded to Firebase.")
                    print("Sending media message with imageID: \(String(describing: image.accessibilityIdentifier))")
                    self.sendMessage(text: nil, imageID: image.accessibilityIdentifier)
                    
                case .failure(let error):
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    return
                }
            }
        default:
            return
        }
    }
    
    func inputBar(_ inputBarView: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if attachmentManager.attachments.count > 0 {
            inputBar(messageInputBar, didPressSendButtonWith: attachmentManager.attachments)
        }
        
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else { return resetInputBar()}
        
        print("Sending: \(text)")
        sendMessage(text: text, imageID: nil)
    }
    
    func sendMessage(text: String?, imageID: String?) {
        if isNewConvo {
            guard let item = item else { return }
            
            MessagingManager.createNewConversationWith(item: item, text: text, imageID: imageID) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let basicConvo):
                        self.isNewConvo = false
                        self.basicConvo = basicConvo
                        self.listenForMessages()
                        self.resetInputBar()
                    case .failure(let error):
                        print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                        Alerts.presentAlertWith(title: "Uh-Oh!", message: "Your message could not be sent for an unknown reason.  Please try again.", sender: self)
                        self.resetInputBar()
                    }
                }
            }
        } else {
            if let convoID = self.basicConvo?.id {
                MessagingManager.sendMessage(to: convoID, with: text, imageID: imageID) { success in
                    if success {
                        print("message successfully sent")
                        self.resetInputBar()
                    } else {
                        Alerts.presentAlertWith(title: "Uh-Oh!", message: "Your message could not be sent for an unknown reason.  Please try again.", sender: self)
                        self.resetInputBar()
                    }
                }
            }
        }
    }
    
    func resetInputBar() {
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()
        // Send button activity animation
        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
        // Resign first responder for iPad split view
        messageInputBar.inputTextView.resignFirstResponder()
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                self?.messageInputBar.sendButton.stopAnimating()
                self?.messageInputBar.inputTextView.placeholder = "Aa"
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
    
    func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                
                if #available(iOS 13.0, *) {
                    $0.image = UIImage(systemName: "camera.fill")?.withRenderingMode(.alwaysTemplate)
                } else {
                    $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                }
                
                $0.setSize(CGSize(width: 30, height: 30), animated: false)
            }.onSelected {
                $0.tintColor = .systemBlue
            }.onDeselected {
                $0.tintColor = UIColor.lightGray
            }.onTouchUpInside { _ in
                print("Item Tapped")
            }
    }
    
} // END OF EXTENSION

// MARK: - Messages DataSource & Delegates
extension ConversationViewController: MessagesDataSource, MessagesDisplayDelegate {
    var currentSender: MessageKit.SenderType {
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
        var image = receiverAvatarImage
        var avatar = Avatar(image: image, initials: initials.description)
        
        if message.sender.senderId == Auth.auth().currentUser?.uid {
            avatarView.backgroundColor = #colorLiteral(red: 0.3236978054, green: 0.1063579395, blue: 0.574860394, alpha: 1)
            image = senderAvatarImage
            avatar = Avatar(image: image, initials: initials.description)
        }
        
        avatarView.set(avatar: avatar)
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if case MessageKind.photo(let media) = message.kind, let image = media.image {
            imageView.image = image
        } else {
            imageView.image = UIImage(systemName: "questionmark")
        }
        
        imageView.contentMode = .scaleAspectFit
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .pointedEdge)
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
        
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = self.messagesCollectionView.indexPath(for: cell) else { return }
        let message = messageForItem(at: indexPath, in: self.messagesCollectionView)
        let kind = message.kind
        
        let vc = ImageDetailViewController()
        
        switch kind {
        case .photo(let mediaItem):
            vc.imageView.image = mediaItem.image
        default:
            return
        }
                        
        self.navigationController?.pushViewController(vc, animated: true)
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

//  MARK: - IMAGE PICKER
extension ConversationViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func presentCamera() {
        let camera = UIImagePickerController()
        camera.sourceType = .camera
        camera.delegate = self
        camera.allowsEditing = true
        present(camera, animated: true, completion: nil)
    }
    
    func presentPhotoPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    //  MARK: - PHOTO PICKER METHODS
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        
        messageInputBar.inputPlugins.forEach { _ = $0.handleInput(of: image)}
        inputAccessoryView?.isHidden = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //  MARK: - ALERTS
    func presentImageAlert() {
        let alert = UIAlertController(title: "Take a photo or choose an image.", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
            
            switch MediaPermissions.checkCameraPermission() {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        if granted {
                            self.presentCamera()
                            alert.dismiss(animated: true, completion: nil)
                        } else {
                            alert.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                
            case .restricted:
                self.presentAlertWith(title: "Your permission settings for this app does not allow taking pictures", message: "Please update the app permissions in order to take photos.")
                alert.dismiss(animated: true, completion: nil)
                
            case .denied:
                self.presentAlertWith(title: "Your permission settings for this app does not allow taking pictures", message: "Please update the app permissions in order to take photos.")
                alert.dismiss(animated: true, completion: nil)
                
            case .authorized:
                self.presentCamera()
                alert.dismiss(animated: true, completion: nil)
                
            @unknown default:
                self.presentAlertWith(title: "Your permission settings for this app does not allow taking pictures", message: "Please update the app permissions in order to take photos.")
                alert.dismiss(animated: true, completion: nil)
            }
        }
        
        let choosePhotoAction = UIAlertAction(title: "Choose from Gallery", style: .default) { _ in
            
            switch MediaPermissions.checkMediaLibraryPermission() {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { status in
                    DispatchQueue.main.async {
                        switch status {
                        case .authorized:
                            self.presentPhotoPicker()
                            alert.dismiss(animated: true, completion: nil)
                            
                        default:
                            alert.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                
            case .authorized:
                self.presentPhotoPicker()
                alert.dismiss(animated: true, completion: nil)
                
            default:
                self.presentAlertWith(title: "Your permission settings for this app does not allow taking pictures", message: "Please update the app permissions in order to take photos.")
                alert.dismiss(animated: true, completion: nil)
            }
        }
        
        alert.addAction(takePhotoAction)
        alert.addAction(choosePhotoAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func presentAlertWith(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
}   //  End of Extension
