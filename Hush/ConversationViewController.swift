//
//  ConversationViewController.swift
//  Hush
//
//  Created by Luay Younus on 6/28/17.
//  Copyright © 2017 Luay Younus. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController
import Photos

class ConversationViewController: JSQMessagesViewController {

    @IBOutlet weak var VCTitle: UINavigationItem!
    var chatRoomRef: DatabaseReference?
    private var messages: [JSQMessage] = []
    
    private lazy var messageRef: DatabaseReference = self.chatRoomRef!.child("messages")
    private var newMessageRefHandle: DatabaseHandle?
    private var updatedMessageRefHandle: DatabaseHandle?

    private lazy var userIsTypingRef: DatabaseReference = self.chatRoomRef!.child("typingIndicator").child(self.senderId)
    private lazy var usersTypingQuery: DatabaseQuery = self.chatRoomRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    
    fileprivate lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://hush-bf81c.appspot.com")

    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    
    let imagePicker = UIImagePickerController()
    
    let dateFormatter = DateFormatter()
    var timeZoneInterval: TimeInterval = 0

    var chatRoom: ChatRoom? {
        didSet {
            self.VCTitle.title = chatRoom?.name
        }
    }
    
    private var localTyping = false
    
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
        self.senderId = Auth.auth().currentUser?.uid

        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        self.dateFormatter.timeZone = TimeZone.current

        if (dateFormatter.timeZone.isDaylightSavingTime()) {
            self.timeZoneInterval = dateFormatter.timeZone.daylightSavingTimeOffset()
        }
        observeMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        observeTyping()
    }
    
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
    }
    
   
    // MARK: Collection View data source (and related) methods
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.media != nil { return cell }
        
        if message.senderId == senderId {
            cell.textView.textColor = UIColor.white
            cell.textView.linkTextAttributes = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
            
        } else {
            cell.textView.textColor = UIColor.black
            cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.jsq_messageBubbleBlue(),
                                                NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        }
        
        var messageDate = messages[indexPath.item].date!
        messageDate.addTimeInterval(self.timeZoneInterval)
        dateFormatter.timeStyle = .short
        let displayDate = dateFormatter.string(from: messageDate)
        cell.timeStamp.text = displayDate
        cell.timeStamp.font = UIFont.systemFont(ofSize: 10)

        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        return 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        let message = messages[indexPath.item]
        switch message.senderId {
        case senderId:
            return nil
        default:
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
        }
    }
    
    //MARK: FireBase and related methods
    private func observeMessages() {
        let messageQuery = messageRef.queryLimited(toLast:25)
        
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!,
                let name = messageData["senderName"] as String!,
                let text = messageData["text"] as String!,
                let date = messageData["date"] as String!,
                text.characters.count > 0 {
                
                self.dateFormatter.dateFormat = "yyyy-mm-dd hh:mm:ss +zzzz"
                let dateFromString = self.dateFormatter.date(from: "\(date)")
                
                self.addMessage(withId: id, name: name, date: dateFromString!, text: text)
                self.finishReceivingMessage()
                
            } else if let id = messageData["senderId"] as String!,
                let name = messageData["senderName"] as String!,
                let photoURL = messageData["photoURL"] as String!,
                let date = messageData["date"] as String! {
                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                    
                    self.dateFormatter.dateFormat = "yyyy-mm-dd hh:mm:ss +zzzz"
                    let dateFromString = self.dateFormatter.date(from: date)
                    
                    self.addPhotoMessage(withId: id, name: name, key: snapshot.key, mediaItem: mediaItem, date: dateFromString!)

                    if photoURL.hasPrefix("gs://") {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: snapshot.key)
                    }
                }
            } else {
                print("Error! Could not decode message data")
            }
        })
        
        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, String>
            if let photoURL = messageData["photoURL"] as String! {
                if let mediaItem = self.photoMessageMap[key] {
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key)
                }
            }
        })
    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        let storageRef = Storage.storage().reference(forURL: photoURL)
        storageRef.getData(maxSize: INT64_MAX) { (data, error) in
            if let error = error {
                print("Error downloading image data: \(error.localizedDescription)")
                return
            }
            storageRef.getMetadata(completion: { (metadata, error) in
                if let error = error {
                    print("Error downloading metadata: \(error.localizedDescription)")
                    return
                }
                if (metadata?.contentType == "image") {
                    mediaItem.image = UIImage.init(data: data!)
                }
                
                self.collectionView.reloadData()
                
                guard key != nil else { return }
                
                self.photoMessageMap.removeValue(forKey: key!)
            })
        }
    }
    
    private func observeTyping() {
        let typingIndicatorRef = chatRoomRef!.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqual(toValue: true)

        usersTypingQuery.observe(.value) { (data: DataSnapshot) in
            
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            "date": "\(date!)"
            ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        isTyping = false
    }

    func sendPhotoMessage() -> String? {
        let itemRef = messageRef.childByAutoId()
        let imageURLNotSetKey = "NotSet"
        let currentDate = Date()

        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderId": senderId!,
            "senderName": senderDisplayName,
            "date": "\(currentDate)"
        ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        return itemRef.key
    }
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photoURL": url])
    }
    
    func presentImagePickerWith(sourceType: UIImagePickerControllerSourceType) {
        self.imagePicker.sourceType = sourceType
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        
        let actionSheetController = UIAlertController()
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.presentImagePickerWith(sourceType: .camera)
        }

        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.presentImagePickerWith(sourceType: .photoLibrary)
        }
        
        let originalCameraIcon = UIImage(named: "camIcon.png")
        let scaledCameraIcon = scaleDownIcon(for: originalCameraIcon!)
        cameraAction.setValue(scaledCameraIcon, forKey: "image")

        let photoLibraryIcon = UIImage(named: "photoLibIcon.png")
        let scaledPhotoLibraryIcon = scaleDownIcon(for: photoLibraryIcon!)
        photoLibraryAction.setValue(scaledPhotoLibraryIcon, forKey: "image")
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheetController.addAction(cameraAction)
        }
        
        actionSheetController.addAction(photoLibraryAction)
        actionSheetController.addAction(cancel)
        
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    // MARK: UI and User Interaction
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    private func addMessage(withId id: String, name: String, date: Date, text: String) {
        if let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, text: text) {
            self.messages.append(message)
        }
    }
    
    private func addPhotoMessage(withId id: String, name: String, key: String, mediaItem: JSQPhotoMediaItem, date: Date) {
        
        if let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, media: mediaItem) {
            messages.append(message)
            
            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }
            collectionView.reloadData()
        }
    }
    
    // MARK: UITextViewDelegate methods
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = textView.text != ""
    }
}

// MARK: Image Picker Delegate
extension ConversationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        //picking the image from the Photo Library
        guard let image: UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        
        let imageData = UIImageJPEGRepresentation(image, 0.5)!
        
        let metadata = StorageMetadata()
        metadata.contentType = "image"
        
        if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
            
            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options: nil)
            let asset = assets.firstObject
            
            if let key = sendPhotoMessage() {
                asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                    let imageNameFromURL = contentEditingInput?.fullSizeImageURL?.lastPathComponent
                    
                    let path = "\(Auth.auth().currentUser!.uid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))"
                    
                    self.storageRef.child(path).child("\(imageNameFromURL!)").putData(imageData, metadata: metadata, completion: { (metadata, err) in
                        if let error = err {
                            print("Error uploading photo: \(error.localizedDescription)")
                            return
                        }
                        self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                    })
                })
            }
        } else if let key = sendPhotoMessage() {
            
            var localId:String?
            let imageManager = PHPhotoLibrary.shared()
            
            imageManager.performChanges({ () -> Void in
                
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                localId = request.placeholderForCreatedAsset?.localIdentifier
                
            }, completionHandler: { (success, error) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    if let localId = localId {
                        
                        let result = PHAsset.fetchAssets(withLocalIdentifiers: [localId], options: nil)
                        result.firstObject?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                            let imageNameFromURL = contentEditingInput?.fullSizeImageURL?.lastPathComponent
                            let path = "\(Auth.auth().currentUser!.uid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))"
                            
                            self.storageRef.child(path).child("\(imageNameFromURL!)").putData(imageData, metadata: metadata, completion: { (metadata, err) in
                                if let error = err {
                                    print("Error uploading photo: \(error.localizedDescription)")
                                    return
                                }
                                self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                            })
                        })
                        self.view.snapshotView(afterScreenUpdates: true)
                    }
                })
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}
