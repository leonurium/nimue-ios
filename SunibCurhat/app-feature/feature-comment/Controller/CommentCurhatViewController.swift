//
//  CommentCurhatViewController.swift
//  SunibCurhat
//
//  Created by Rangga Leo on 04/08/19.
//  Copyright © 2019 Rangga Leo. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class CommentCurhatViewController: UIViewController {
    @IBOutlet weak var tableViewComment: UITableView!
    @IBOutlet weak var scrollViewComment: UIScrollView!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_text_content: UILabel!
    @IBOutlet weak var lbl_time: UILabel!
    @IBOutlet weak var txt_comment: UITextView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    private lazy var refreshControl: UIRefreshControl = {
        let r = UIRefreshControl()
        r.tintColor = UIColor.custom.gray
        r.attributedTitle = NSAttributedString(string: "Fetching comments..", attributes: [NSAttributedString.Key.font: UIFont.custom.regular.size(of: 12)])
        return r
    }()
    
    var commentsApi: CommentResponse?
    var comments: [CommentItems] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableViewComment.reloadData()
            }
        }
    }
    var getMoreComment: Bool = false
    var timeline: TimelineItems?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegates()
        updateUI()
        configAdUI()
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            self.lbl_name.text = self.timeline?.name
            self.lbl_text_content.text = self.timeline?.text_content
            self.lbl_time.text = self.timeline?.timed.toDate(format: "yyyy-MM-dd HH:mm:ss")?.timeAgo(numericDates: true)
        }
    }
    
    private func configAdUI() {
        bannerView.isHidden = true
        MainService.shared.getAdBannerUnitID { (result) in
            switch result {
            case .failure(let e):
                print(e.localizedDescription)
            case .success(let s):
                if s.success {
                    if let ad_unit_id = s.data {
                        self.bannerView.delegate = self
                        self.bannerView.adUnitID = ad_unit_id
                        self.bannerView.rootViewController = self
                        self.bannerView.load(GADRequest())
                    }
                }
            }
        }
    }
    
    private func delegates() {
        self.title = "Comment"
        tableViewComment.delegate = self
        tableViewComment.dataSource = self
        txt_comment.delegate = self
        txt_comment.isScrollEnabled = false
        txt_comment.text = "Enter a comment?"
        txt_comment.textColor = UIColor.custom.gray
        textViewDidChange(txt_comment)
        self.endEditing()
        getComments()
        
        if #available(iOS 10.0, *) {
            tableViewComment.refreshControl = refreshControl
        } else {
            tableViewComment.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(getComments), for: .valueChanged)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @IBAction func actionSend(_ sender: UIButton) {
        addComment()
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        let userInfo      = notification.userInfo!
        var keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset:UIEdgeInsets = self.scrollViewComment.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollViewComment.contentInset = contentInset
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        let userInfo      = notification.userInfo!
        var keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset:UIEdgeInsets = self.scrollViewComment.contentInset
        contentInset.bottom = 0.0
        scrollViewComment.contentInset = contentInset
    }
    
    @objc func addComment() {
        guard txt_comment.textColor != UIColor.custom.gray_absolute && txt_comment.text.count > ConstGlobal.MINIMUM_TEXT else {
            self.showAlert(title: "Error", message: "Write your comment, at least \(ConstGlobal.MINIMUM_TEXT) character", OKcompletion: nil, CancelCompletion: nil)
            return
        }
        
        guard let timeline_id = timeline?.timeline_id else { return }
        
        self.showLoaderIndicator()
        CommentService.shared.addComment(timeline_id: timeline_id, text_content: txt_comment.text) { (result) in
            switch result {
            case .failure(let e):
                self.dismissLoaderIndicator()
                self.showAlert(title: "Error", message: e.localizedDescription + "\n Update Session?", OKcompletion: { (act) in
                    RepoMemory.token = nil
                    RepoMemory.pendingFunction = self.addComment.self
                }, CancelCompletion: nil)
                
            case .success(let s):
                self.dismissLoaderIndicator()
                if s.success {
                    self.txt_comment.text = ""
                    self.textViewDidChange(self.txt_comment)
                    self.getComments()
                } else {
                    self.showAlert(title: "Error", message: s.message + "\n Try Again?", OKcompletion: { (act) in
                        self.addComment()
                    }, CancelCompletion: nil)
                }
            }
        }
    }
    
    @objc func getComments() {
        guard
            !getMoreComment,
            let timeline_id = timeline?.timeline_id
            else {
                return
        }
        
        getMoreComment = true
        
        if refreshControl.isRefreshing {
            commentsApi = nil
            comments.removeAll()
        }
        
        let page = commentsApi?.next_page ?? 1
        if page == 999 {
            self.getMoreComment = false
            return
        }
        
        CommentService.shared.getComments(page: page, timeline_id: timeline_id) { (result) in
            switch result {
            case .failure(let e):
                self.refreshControl.endRefreshing()
                self.showAlert(title: "Error", message: e.localizedDescription + "\n Update Session?", OKcompletion: { (act) in
                    self.getMoreComment = false
                    RepoMemory.token = nil
                    RepoMemory.pendingFunction = self.getComments.self
                }, CancelCompletion: nil)
                
            case .success(let s):
                self.refreshControl.endRefreshing()
                if s.success {
                    if let data = s.data {
                        self.getMoreComment = false
                        self.comments.append(data.comments)
                        self.commentsApi = data
                    }
                
                } else {
                    self.getMoreComment = false
                    print(s.message)
                }
            }
        }
    }
}

extension CommentCurhatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: self.view.frame.width - 32, height: .infinity)
        let estimateSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (cs) in
            if cs.firstAttribute == .height {
                DispatchQueue.main.async {
                    cs.constant = estimateSize.height
                }
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.custom.gray {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter a comment?"
            textView.textColor = UIColor.custom.gray_absolute
        }
    }
}

extension CommentCurhatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let isLastItem = indexPath.row + 1 == comments.count
        
        if isLastItem && commentsApi?.next_page != 999 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingTableViewCell") as! LoadingTableViewCell
            cell.ActIndicatorLoading.startAnimating()
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as! CommentTableViewCell
        cell.comment = comments[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            if !getMoreComment {
                self.getComments()
            }
        }
    }
    
}

extension CommentCurhatViewController: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isHidden = false
        print_r(title: "ADMOB RECEIVE", message: nil)
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print_r(title: "ADMOB ERROR", message: error)
    }
    
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print_r(title: "ADMOB WILL PRESENT", message: nil)
    }
    
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print_r(title: "ADMOB WILL DISMISS", message: nil)
    }
    
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print_r(title: "ADMOB DID DISMISS", message: nil)
    }
    
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print_r(title: "ADMOB WILL LEAVE", message: nil)
    }
}