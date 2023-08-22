//
//  UserConatiner.swift
//  swiftMessanger
//
//  Created by Furkan Alioglu on 22.08.2023.
//

import UIKit

class UserConatiner: UIView {
    
    var leadingConstraing : NSLayoutConstraint?
    var videoResourceName: String
    var userId = 0
    var itemCount = 0
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let itemCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var userCircle: UserCircle = {
        let circle = UserCircle()
        circle.backgroundColor = .red
        circle.fileName = self.videoResourceName
        return circle
    }()
    
    init(frame: CGRect, videoResourceName: String) {
        self.videoResourceName = videoResourceName
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(usernameLabel)
        addSubview(itemCountLabel)
        addSubview(userCircle)
        
        
        userCircle.setWidth(100)
        userCircle.setHeight(30)
        
        usernameLabel.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor)
        itemCountLabel.anchor(top: usernameLabel.bottomAnchor, left: leftAnchor, right: rightAnchor)
        userCircle.anchor(top: itemCountLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,paddingBottom: 10)
        layoutIfNeeded()
    }
    
    func configure(user: GroupEventModel) {
        userId = user.userId
        itemCount = user.itemCount
        usernameLabel.text = String(user.userId)
        itemCountLabel.text = String(user.itemCount)
        userCircle.configure(withUser: user)
    }
    
    func updateItemCount(user: GroupEventModel) {
        itemCount = user.itemCount
        itemCountLabel.text = String(user.itemCount)
    }
}
