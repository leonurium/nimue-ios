//
//  UINCButtonPrimaryRounded.swift
//  SunibCurhat
//
//  Created by Rangga Leo on 01/05/20.
//  Copyright © 2020 Rangga Leo. All rights reserved.
//

import UIKit

class UINCButtonPrimaryRounded: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                self.backgroundColor = UINCColor.primary
                self.setTitleColor(UINCColor.primary_foreground, for: .normal)
                
            } else {
                self.backgroundColor = UINCColor.tertiary
                self.setTitleColor(UINCColor.tertiary_foreground, for: .normal)
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.backgroundColor = UINCColor.primary400.get()
                self.setTitleColor(UINCColor.primary_foreground, for: .normal)
            }
        }
    }
    
    private func setupViews() {
        self.setTitleColor(.white, for: .normal)
        let size_font: CGFloat      = self.titleLabel?.font.pointSize ?? 20.0
        self.layer.cornerRadius     = self.bounds.size.height / 4.0
        self.layer.masksToBounds    = false
        self.titleLabel?.font       = UIFont.custom.bold.size(of: size_font)
        self.isEnabled              = true
    }
    
    func fullRounded() {
        self.layer.cornerRadius     = self.bounds.size.height / 2.0
    }
}
