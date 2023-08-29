//
//  UserCircle.swift
//  swiftMessanger
//
//  Created by Furkan Alioglu on 17.08.2023.
//

import Foundation
import UIKit
import AVFoundation

class UserCircle: UIView {
    
    var userId: Int = 0
    var carId = 0
    var fileName = "framelights1"
    
    private var playerLooper: AVPlayerLooper?
    var playerLayer: AVPlayerLayer?
    private var queuePlayer : AVQueuePlayer?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        carId = 0
        setupView()
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(withUser user: GroupEventModel, withCarId carId:Int ) {
//         DispatchQueue.main.async { [weak self] in
//             self?.carId = user.carId
//             self?.userId = user.userId
//             self?.playAnimation()
//             self?.layoutIfNeeded()
//             self?.layoutSubviews()
//         }
        self.carId = user.carId
        self.userId = user.userId
        self.playAnimation()
     }
    
    private func setupView() {
        self.backgroundColor = .random
    }
    
    func playAnimation() {
        guard let localURL = AssetManager.shared.getUDAssetPath(for: .urlCAR, assetId: carId) else { return }
        print("AssetDEBUG: trying to play \(localURL)")
        DispatchQueue.main.async {
            GiftManager.shared.playSuperAnimation(view: self, videoURLString:localURL) {
                self.layoutIfNeeded()
                self.layoutSubviews()
            }
        }
    }
}

