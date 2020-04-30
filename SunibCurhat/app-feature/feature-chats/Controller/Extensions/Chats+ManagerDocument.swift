//
//  Chats+ManagerDocument.swift
//  SunibCurhat
//
//  Created by Koinworks on 8/28/19.
//  Copyright © 2019 Rangga Leo. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

extension ChatsViewController {
    func handleDocumentChange(_ change: DocumentChange) {
        guard let chat = Chat(document: change.document) else {
            return
        }
        
        switch change.type {
        case .added:
            addChannelToTable(chat)
            
        case .modified:
            updateChannelInTable(chat)
            
        case .removed:
            removeChannelFromTable(chat)
            
        @unknown default:
            print("Unknown document change \(change)")
        }
    }
    
    private func addChannelToTable(_ chat: Chat) {
        guard !chats.contains(chat) else {
            return
        }
        
        chats.append(chat)
        chats.sort()
        
        guard let index = chats.firstIndex(of: chat) else {
            return
        }
        tableViewChats.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func updateChannelInTable(_ chat: Chat) {
        guard let index = chats.firstIndex(of: chat) else {
            return
        }
        
        chats[index] = chat
        tableViewChats.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func removeChannelFromTable(_ chat: Chat) {
        guard let index = chats.firstIndex(of: chat) else {
            return
        }
        
        chats.remove(at: index)
        tableViewChats.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
}