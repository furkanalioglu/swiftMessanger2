//
//  MessagesCell.swift
//  swiftMessanger
//
//  Created by Furkan Alioglu on 4.08.2023.
//

import UIKit

class MessagesCell: UITableViewCell {
    
    var message : MessagesCellItem? {
        didSet{
            configureUI()
        }
    }

    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var messageSenderLabel: UILabel!
    @IBOutlet weak var messageContentLabel: UILabel!
    @IBOutlet weak var messageSentTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    private func configureUI() {
        guard let message = message else { return }
        messageImageView.image = UIImage(named: "prsn")
        messageSenderLabel.text = message.username
        messageContentLabel.text = message.lastMsg
        messageSenderLabel.textColor = message.isSeen ?? false ? .gray : .green
//        messageSentTimeLabel.text = message.sendTime
    }
    
}
