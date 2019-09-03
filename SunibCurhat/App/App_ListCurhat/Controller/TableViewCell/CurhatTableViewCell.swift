//
//  CurhatTableViewCell.swift
//  SunibCurhat
//
//  Created by Rangga Leo on 04/08/19.
//  Copyright © 2019 Rangga Leo. All rights reserved.
//

import Foundation
import UIKit

class CurhatTableViewCell: UITableViewCell {
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_curhat: UILabel!
    @IBOutlet weak var lbl_count_likes: UILabel!
    @IBOutlet weak var lbl_count_comments: UILabel!
    @IBOutlet weak var lbl_count_shares: UILabel!
    @IBOutlet weak var lbl_time: UILabel!
    @IBOutlet weak var btn_likes: UIButton!
    
    var btn_likes_clicked: ((UIButton) -> Void)?
    var btn_comments_clicked: ((UIButton) -> Void)?
    var btn_shares_clicked: ((UIButton) -> Void)?
    var btn_more_clicked: ((UIButton) -> Void)?
    
    var timeline: TimelineItems? {
        didSet {
            self.updateUI()
        }
    }
    
    var isLiked: Bool = false {
        didSet {
            if isLiked {
                DispatchQueue.main.async {
                    self.btn_likes.setImage(UIImage(named: "btn_like_active"), for: .normal)
                }
            
            } else {
                DispatchQueue.main.async {
                    self.btn_likes.setImage(UIImage(named: "btn_like"), for: .normal)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            self.lbl_name.text          = self.timeline?.name
            self.lbl_curhat.text        = self.timeline?.text_content
            self.lbl_time.text          = self.timeline?.timed.toDate(format: "yyyy-MM-dd HH:mm:ss")?.timeAgo(numericDates: true)
            self.isLiked                = self.timeline?.is_liked ?? false
            
            let likes = self.timeline?.total_likes > 0 ? "\(self.timeline?.total_likes ?? 0)" : ""
            self.lbl_count_likes.text       = likes + " likes"
            
            let comments = self.timeline?.total_comments > 0 ? "\(self.timeline?.total_comments ?? 0)" : ""
            self.lbl_count_comments.text    = comments + " comments"
            
            let shares = self.timeline?.total_shares > 0 ? "\(self.timeline?.total_shares ?? 0)" : ""
            self.lbl_count_shares.text      = shares + " shares"
        }
    }
    
    @IBAction private func actionLike(_ sender: UIButton) {
        btn_likes_clicked?(sender)
    }
    
    @IBAction private func actionComment(_ sender: UIButton) {
        btn_comments_clicked?(sender)
    }
    
    @IBAction private func actionShare(_ sender: UIButton) {
        btn_shares_clicked?(sender)
    }
    
    @IBAction private func actionMore(_ sender: UIButton) {
        btn_more_clicked?(sender)
    }
    
}