// 
//  ChatProtocols.swift
//  SunibCurhat
//
//  Created by Developer on 20/03/21.
//  Copyright © 2021 Rangga Leo. All rights reserved.
//

import UIKit

// MARK: View -
protocol ChatPresenterToView: AnyObject {
    var presenter: ChatViewToPresenter? { get set }
    
    func setupViews(title: String)
    func reloadCollectionView(isLastMessage: Bool)
    func scrollToBottom()
    func showLoaderIndicator()
    func dismissLoaderIndicator()
    func showAlertConfirm(title: String, message: String, okCompletion: VoidClosure?, cancelCompletion: VoidClosure?)
}

// MARK: Interactor -
protocol ChatPresenterToInteractor: AnyObject {
    var presenter: ChatInteractorToPresenter?  { get set }
    
    func listenMessage(chatID: String)
    func saveMessage(message: Message)
    func sendNotif(token: String, title: String, body: String)
    func uploadImage(message: Message, imageData: Data, chatID: String, isSendingImage: Bool)
}

// MARK: Router -
protocol ChatPresenterToRouter: AnyObject {
    static func createChatModule(chat: Chat) -> UIViewController
    func navigateToPreviousPage(from: ChatPresenterToView?)
}

// MARK: Presenter -
protocol ChatViewToPresenter: AnyObject {
    var view: ChatPresenterToView? {get set}
    var interactor: ChatPresenterToInteractor? {get set}
    var router: ChatPresenterToRouter? {get set}
    
    func didLoad()
    func getCurrentSender() -> (id: String, name: String)
    func messageForItem(at indexPath: IndexPath) -> Message
    func numberOfSections() -> Int
    func didGetPhoto(message: Message, imageData: Data)
    func didPressSendButtonWith(text: String)
}

protocol ChatInteractorToPresenter: AnyObject {
    func didSaveMessage(message: Message)
    func failSaveMessage(title: String, message: String)
    func didListenMessage(message: Message)
    func didUploadImage(message: Message)
}
