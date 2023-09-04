import SDWebImage

class ChatCellWithImage: UITableViewCell {
    
    var message: MessageItem? {
        didSet {
            configureUI()
        }
    }

    @IBOutlet weak var leftStack: UIStackView!
    @IBOutlet weak var rightStack: UIStackView!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var sentImageView: UIImageView!
    @IBOutlet weak var messageBuble: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func configureUI() {
        guard let message = message else { return }
        guard let currentUserId = AppConfig.instance.currentUserId else { return }
        
        let isCurrentUserSender = message.senderId == Int(currentUserId)
        senderLabel.text = String(message.senderId)
        senderLabel.font = UIFont.systemFont(ofSize: 10)
        rightStack.isHidden = isCurrentUserSender
        messageBuble.backgroundColor = isCurrentUserSender ? .systemPurple : .systemPink
        leftStack.isHidden = !isCurrentUserSender
        
        if message.imageData != nil {
            sentImageView.image = UIImage(data: message.imageData!)
        }else{
            sentImageView.image = UIImage(systemName: "magnifyingglass")
        }
    }
}
