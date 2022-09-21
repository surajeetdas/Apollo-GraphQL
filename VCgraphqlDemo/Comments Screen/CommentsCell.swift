//
//  CommentsCell.swift
//  VCgraphqlDemo
//
//  Created by Vantage Circle on 16/09/22.
//

import UIKit

class CommentViewModel {
    
    private(set) var commentNode:GetCommentsQuery.Data.FeedsV2.Comment.Info.Edge
    private(set) var feedId:Int
    private(set) var didInitiateReply:((Int)->Void)?
    
    init(_ data:GetCommentsQuery.Data.FeedsV2.Comment.Info.Edge, feedId:Int, callBack:@escaping (Int)->Void) {
        self.commentNode = data
        self.feedId = feedId
        self.didInitiateReply = callBack
    }
    
    var likeButtonText:String? {
        if (commentNode.node.likes.count > 0) {
            return "\(commentNode.node.likes.count) Like"
        } else {
            return nil
        }
    }
    
}

class CommentsCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var allLikesBtn: UIButton!
    @IBOutlet weak var replyTable: UITableView!
    
    //using delegate
    weak var delegate : RouteToLikeViewControllerProtocol?
//    weak var commentIdDelegate : CommentsProtocol?
//    var selectedFeedId: Int = 0
    
    var replyInfo = [GetCommentsQuery.Data.FeedsV2.Comment.Info.Edge.Node.Reply.Info]()
    var commentId = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        replyTable.delegate = self
        replyTable.dataSource = self
        allLikesBtn.isHidden = true
        
        replyTable.isHidden = true
        
        replyTable.register(UINib.init(nibName: "ReplyCell", bundle: nil), forCellReuseIdentifier: "ReplyCell")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private var viewModel:CommentViewModel?
    
    func setData(viewModel:CommentViewModel){
        self.viewModel = viewModel
        self.nameLabel.text = viewModel.commentNode.node.user.name
        self.commentTextLabel.text = viewModel.commentNode.node.text
        self.commentId = viewModel.commentNode.node.commentId
//        self.selectedFeedId = viewModel.feedId
        self.allLikesBtn.setTitle(viewModel.likeButtonText, for: .normal)
        self.allLikesBtn.isHidden = viewModel.likeButtonText == nil
        if(viewModel.commentNode.node.replies.count > 0)
        {
            self.replyBtn.setTitle("\(viewModel.commentNode.node.replies.count) Reply", for: .normal)
        }
        if(viewModel.commentNode.node.likes.isLiked){
            self.likeBtn.isSelected = true
        }
        if(viewModel.commentNode.node.replies.count > 0){
            self.replyTable.isHidden = false
            self.replyInfo = viewModel.commentNode.node.replies.info
        }

    }
    
    @IBAction func allLikesBtnPressed(_ sender: UIButton) {
        guard let feedId = self.viewModel?.feedId, let delegate = self.delegate else { return }
        delegate.navigateToLikes(feedId)
    }
    
    @IBAction func likeBtnPressed(_ sender: UIButton) {
        likeBtn.isSelected = !(likeBtn.isSelected)
    }
    
    @IBAction func replyToCommentBtnPressed(_ sender : UIButton){
        self.viewModel?.didInitiateReply?(self.commentId)
    }
}

extension CommentsCell: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replyInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyCell", for: indexPath) as? ReplyCell
        
        //sending replies
        cell?.setData(replyInfo: replyInfo[indexPath.row])
        
        return cell ?? UITableViewCell()
    }
    
    
}
