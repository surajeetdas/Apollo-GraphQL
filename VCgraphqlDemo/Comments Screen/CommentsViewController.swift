//
//  CommentsViewController.swift
//  VCgraphqlDemo
//
//  Created by Vantage Circle on 16/09/22.
//

import UIKit

protocol CommentsProtocol : AnyObject{
    func setCommentId(_ commentId : Int)
}

class CommentsViewController: UIViewController {
    
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var commentsTable: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    init(_ feedID : Int) {
        self.selectedFeedID = feedID
        super.init(nibName: "CommentsViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var commentsForFeed : GetCommentsQuery.Data.FeedsV2.Comment?
    var allComments = [GetCommentsQuery.Data.FeedsV2.Comment.Info.Edge]()
    
    var selectedFeedID: Int = 0
    var commentId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentsTable.delegate = self
        commentsTable.dataSource = self
        
        commentsTable.register(UINib.init(nibName: "CommentsCell", bundle: nil), forCellReuseIdentifier: "CommentsCell")
        
        getAllComments()
    
    }
    
    func getAllComments(){
        Network.shared.getCommentsForParticularFeed(completion: { [weak self] (comments) in
              self!.commentsForFeed = comments
              self!.allComments = comments.info?.edges as! [GetCommentsQuery.Data.FeedsV2.Comment.Info.Edge]
              self!.commentsLabel.text = "\(comments.count) Comments"
              DispatchQueue.main.async {
                  self!.commentsTable.reloadData()
              }
          }, feedID: selectedFeedID)
    }
    
  
    
    func getFeedID(feedID: Int){
        print("get feed id called===")
        self.selectedFeedID = feedID
    }
    
    
    @IBAction func sendBtnPressed(_ sender: UIButton) {
        print("---")
        if let comment = textField.text{
            if ((!comment.isEmpty)&&(self.commentId == 0)){
                Network.shared.addComment(feedID: selectedFeedID, commentText: comment, isReply: false)
                getAllComments()
            }
            if((!comment.isEmpty)&&(self.commentId != 0)){
                Network.shared.addReplyToAComment(feedID: selectedFeedID, commentText: comment, parentId: self.commentId)
                self.commentId = 0
                getAllComments()
            }
            else{
                print("no text")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.popViewController(animated: true)
    }
    
    deinit{
        print("Deinit called")
    }
        
    
}

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath) as? CommentsCell
        let vm = CommentViewModel(allComments[indexPath.row], feedId: self.selectedFeedID) { commentId in
            self.commentId = commentId
        }
        cell?.setData(viewModel: vm)
        cell?.delegate = self
        return cell ?? UITableViewCell()
    }
    
}

//MARK: - custom extension

extension CommentsViewController: RouteToLikeViewControllerProtocol{
    func navigateToLikes(_ feedId : Int) {
        self.likeLabelTapped(feedId)
    }
    

    //MARK: functions -
    func likeLabelTapped(_ selectedFeedId : Int) {
        let likeVC = LikesScreenViewController()
        likeVC.getFeedID(feedID: selectedFeedId)
        self.present(likeVC, animated: false)
    }
    
    
}

extension CommentsViewController : CommentsProtocol{
    func setCommentId(_ commentId: Int) {
        self.commentId = commentId
        self.textField.becomeFirstResponder()
    }
    
    
}
