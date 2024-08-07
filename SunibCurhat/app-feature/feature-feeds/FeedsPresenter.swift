//
//  FeedsPresenter.swift
//  SunibCurhat
//
//  Created by Rangga Leo on 27/11/20.
//  Copyright © 2020 Rangga Leo. All rights reserved.
//

import Foundation

class FeedsPresenter: FeedsViewToPresenter {
    weak var view: FeedsPresenterToView?
    var interactor: FeedsPresenterToInteractor?
    var router: FeedsPresenterToRouter?
    
    private var timelines: [TimelineItems] = []
    private var next_page: Int = 1
    private var getTimelineMore: Bool = false
    private var user: User? = UDHelpers.shared.getObject(type: User.self, forKey: .user)
    
    func didLoad() {
        view?.setupViews()
        requestGetTimeline(resetData: false)
    }
    
    func didAppear() {
//        view?.startInstructions()
    }
    
    func didPrepareDisappear() {
        view?.stopInstructions()
    }
    
    func shouldHandleOverlayCoachMarksTap() {
        view?.stopInstructions()
    }
    
    func didEndInstructions() {
        UDHelpers.shared.set(value: true, key: .is_show_instructions)
    }
    
    func getUser() -> User? {
        return user
    }
    
    func didClickNewPost() {
        router?.navigateToNewPost(from: view)
    }
    
    func didClickPrivacy() {
        let preferences = UDHelpers.shared.getObject(type: Preferences.self, forKey: .preferences_key)
        router?.navigateToPrivacy(from: view, url: preferences?.urls?.privacy_policy)
    }
    
    func didClickAgreement() {
        let preferences = UDHelpers.shared.getObject(type: Preferences.self, forKey: .preferences_key)
        router?.navigateToAgreement(from: view, url: preferences?.urls?.user_agreement)
    }
    
    func didClickSignOut() {
        interactor?.signOut()
    }
    
    func didClickSendChat(to: User) {
        guard let user = user else { return }
        let conversation = Conversation(
            conversation_id: "\(user.user_id).\(to.user_id)",
            users: [user, to],
            chats: [],
            last_chat: nil,
            last_chat_timestamp: Date().unixTimestampMilliseconds()
        )
        interactor?.createConversationRoom(conversation: conversation)
    }
    
    func didClickProfile() {
        router?.navigateToProfile(from: view)
    }
    
    func requestGetTimeline(resetData: Bool) {
        guard !getTimelineMore else {
            return
        }
        getTimelineMore = true
        
        if resetData {
            next_page = 1
            timelines.removeAll()
            view?.reloadTableView()
        }
        
        if next_page == 999 {
            self.getTimelineMore = false
            return
        }
        
        if let user = UDHelpers.shared.getObject(type: User.self, forKey: .user) {
            interactor?.getTimelines(user_id: user.user_id, page: "\(next_page)", itemPerPage: "10")
        }
    }
    
    func numberOfRowsInSection() -> Int {
        return timelines.count
    }
    
    func cellForRowAt(indexPath: IndexPath) -> TimelineItems? {
        return timelines.item(at: indexPath.row)
    }
    
    func didSelectRowAt(indexPath: IndexPath) {
        let timeline = timelines.item(at: indexPath.row)
        router?.navigateToComment(timeline: timeline, view: view)
    }
    
    func scrollViewDidScroll() {
        if !getTimelineMore {
            requestGetTimeline(resetData: false)
        }
    }
    
    func getTimelineItem(indexPath: IndexPath) -> TimelineItems? {
        return timelines.item(at: indexPath.row)
    }
    
    func requestDeleteTimeline(indexPath: IndexPath) {
        if let timelineId = timelines.item(at: indexPath.row)?.timeline_id {
            timelines.remove(at: indexPath.row)
            view?.removeCell(index: [indexPath])
            interactor?.deleteTimelime(user_id: user?.user_id ?? "", timelineID: timelineId)
        }
    }
    
    func requestReport(indexPath: IndexPath) {
        let timeline = timelines.item(at: indexPath.row)
        router?.navigateToReport(timeline: timeline, view: view)
    }

    func requestComment(indexPath: IndexPath) {
        let timeline = timelines.item(at: indexPath.row)
        router?.navigateToComment(timeline: timeline, view: view)
    }
    
    func requestLike(indexPath: IndexPath, isLiked: Bool) {
        if let timelineId = timelines.item(at: indexPath.row)?.timeline_id {
            if isLiked {
                interactor?.unlikeTimeline(user_id: user?.user_id ?? "", timelineID: timelineId)
            } else {
                interactor?.likeTimeline(user_id: user?.user_id ?? "", timelineID: timelineId)
            }
        }
    }
    
    func requestShare(indexPath: IndexPath) {
        if let timeline_id = timelines.item(at: indexPath.row)?.timeline_id {
            
            var shareText = timelines.item(at: indexPath.row)?.text_content ?? ""
            shareText += " - "
            shareText += timelines.item(at: indexPath.row)?.user?.name ?? ""
            
            view?.showShareController(items: [shareText], completion: { [weak self] in
                self?.interactor?.shareTimeline(user_id: self?.user?.user_id ?? "", timelineID: timeline_id)
            })
        }
    }
}

extension FeedsPresenter: FeedsInteractorToPresenter {
    func didGetTimelines(timelines: [TimelineItems], next_page: Int) {
        getTimelineMore = false
        self.next_page = next_page
        self.timelines.append(timelines)
        view?.reloadTableView()
        view?.finishRefershControl()
        let isShowInstructions = UDHelpers.shared.getBool(key: .is_show_instructions)
        if !isShowInstructions {
            view?.startInstructions()
        }
    }
    
    func failedGetTimelines(title: String, message: String) {
        getTimelineMore = false
        view?.showAlert(title: title, message: message)
    }
    
    func didLikeTimeline(id: Int) {
        if let timeline = timelines.filter({$0.timeline_id == id}).first {
            if let index = timelines.firstIndex(of: timeline) {
                let indexPath = IndexPath(row: index, section: 0)
                timelines[index].is_liked = true
                timelines[index].total_likes += 1
                view?.updateLikeCell(indexPath: indexPath)
            }
        }
    }
    
    func didUnlikeTimeline(id: Int) {
        if let timeline = timelines.filter({$0.timeline_id == id}).first {
            if let index = timelines.firstIndex(of: timeline) {
                let indexPath = IndexPath(row: index, section: 0)
                timelines[index].is_liked = false
                timelines[index].total_likes -= 1
                view?.updateLikeCell(indexPath: indexPath)
            }
        }
    }
    
    func didSignOut() {
        UDHelpers.shared.remove(key: .user)
        UDHelpers.shared.remove(key: .access_token)
        UDHelpers.shared.remove(key: .refresh_token)        
        router?.navigateToLogin(from: view)
    }
    
    func didCreateConversationRoom(conversation: Conversation) {
        router?.navigateToChat(from: view, conversation: conversation)
    }
    
    func failCreateConversationRoom(title: String, message: String) {
        view?.showAlert(title: title, message: message)
    }
}
