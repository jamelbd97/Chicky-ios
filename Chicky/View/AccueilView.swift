//
//  Accueil.swift
//  Chicky
//
//  Created by Mac2021 on 15/11/2021.
//

import UIKit
import AVKit
import AVFoundation

class AccueilView: UIViewController  {
    
    var player : AVPlayer?
    var playerLayer : AVPlayerLayer?
    
    // VAR
    var moviePlayer: AVPlayerViewController?
    
    var liked = false
    var publications : [Publication] = []
    var publicationCounter = 0
    var isInitialized = false
    
    var previousPublication : Publication?
    var currentPublication : Publication?
    var nextPublication : Publication?
    
    var previousPublicationView = UIView()
    var currentPublicationView = UIView()
    var nextPublicationView = UIView()
    
    // WIDGET
    @IBOutlet weak var swipeAreaView: UIView!
    @IBOutlet weak var noContentLabel: UILabel!
    
    // PROTOCOLS
    
    // LIFECYCLE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commentairesSegue" {
            let destination = segue.destination as! CommentairesView
            destination.publication = currentPublication
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        publicationCounter = 0
        currentPublication = nil
        
        previousPublicationView.frame = CGRect(x: 0, y: -1500, width: swipeAreaView.frame.width, height: swipeAreaView.frame.height)
        currentPublicationView.frame = CGRect(x: 0, y: 0, width: swipeAreaView.frame.width, height: swipeAreaView.frame.height)
        nextPublicationView.frame = CGRect(x: 0, y: 1500, width: swipeAreaView.frame.width, height: swipeAreaView.frame.height)
        
        swipeAreaView.addSubview(previousPublicationView)
        swipeAreaView.addSubview(currentPublicationView)
        swipeAreaView.addSubview(nextPublicationView)
        
        PublicationViewModel().recupererToutPublication { [self] success, results in
            if success {
                publications = []
                self.publications.append(contentsOf: results!)
                
                if publications.count > 0 {
                    noContentLabel.isHidden = true
                    setupPublications()
                    isInitialized = true
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if player != nil {
            player?.pause()
        }
    }
    
    // METHODS
    func setupPublications(){
        
        print("Counter is :" + String(publicationCounter))
        print("-----------")
        if publicationCounter > 0  {
            print("making previousPub")
            previousPublication = publications[publicationCounter - 1]
            /*makePublicationCard(card: previousPublicationView, elementIndex: -1, publication: previousPublication!)*/
        } else {
            previousPublication = nil
        }
        
        if publications.count >= publicationCounter {
            print("making currentPub")
            currentPublication = publications[publicationCounter]
            makePublicationCard(card: currentPublicationView, elementIndex: 0, publication: currentPublication!)
        }
        
        if publications.count > publicationCounter + 1  {
            print("making nextPub")
            nextPublication = publications[publicationCounter + 1]
            /*makePublicationCard(card: nextPublicationView, elementIndex: 1, publication: nextPublication!)*/
        } else {
            nextPublication = nil
        }
        print("-----------")
    }
    
    func makePublicationCard(card: UIView, elementIndex: Int, publication: Publication) {
        
        card.layer.sublayers?.removeAll()
        
        //CARD
        card.backgroundColor = UIColor.darkGray
        card.layer.cornerRadius = ROUNDED_RADIUS
        card.layer.shadowOffset = CGSize(width: 0,height: 0)
        card.layer.shadowRadius = ROUNDED_RADIUS
        card.layer.shadowOpacity = 0.4
        
        // GRADIENT
        let gradientView = GradientView()
        gradientView.secondColor = UIColor.black
        gradientView.frame = CGRect(x: 0, y: card.frame.height/2 , width: card.frame.width, height: card.frame.height/2)
        gradientView.layer.cornerRadius = ROUNDED_RADIUS
        
        // VIDEO
        let videoURL = URL(string: VIDEO_URL + publication.idPhoto!)
        
        if player != nil {
            print("Player is playing .. pausing")
            player?.pause()
        }
        
        print("Starting new player")
        player = AVPlayer(url: videoURL!)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill;
        playerLayer!.frame = card.bounds
        playerLayer!.cornerRadius = ROUNDED_RADIUS
        playerLayer!.masksToBounds = true
        
        self.view.layer.addSublayer(playerLayer!)
        player!.play()
        
        // DESCRIPTION
        let descriptionLabel = UILabel()
        descriptionLabel.tag = 2
        descriptionLabel.text = publication.description
        descriptionLabel.textColor = UIColor.white
        descriptionLabel.frame = CGRect(x: 30, y: card.frame.height - 100, width: card.frame.width, height: 50)
        
        // STARS
        let star1 = UIImageView(image: UIImage(named: "icon-star-filled"))
        star1.heightAnchor.constraint(equalToConstant: 25).isActive = true
        star1.widthAnchor.constraint(equalToConstant: 25).isActive = true
        let star2 = UIImageView(image: UIImage(named: "icon-star-filled"))
        star2.heightAnchor.constraint(equalToConstant: 25).isActive = true
        star2.widthAnchor.constraint(equalToConstant: 25).isActive = true
        let star3 = UIImageView(image: UIImage(named: "icon-star-filled"))
        star3.heightAnchor.constraint(equalToConstant: 25).isActive = true
        star3.widthAnchor.constraint(equalToConstant: 25).isActive = true
        let star4 = UIImageView(image: UIImage(named: "icon-star-filled"))
        star4.heightAnchor.constraint(equalToConstant: 25).isActive = true
        star4.widthAnchor.constraint(equalToConstant: 25).isActive = true
        let star5 = UIImageView(image: UIImage(named: "icon-star-empty"))
        star5.heightAnchor.constraint(equalToConstant: 25).isActive = true
        star5.widthAnchor.constraint(equalToConstant: 25).isActive = true
        
        // RATING STACK VIEW
        let ratingStackView = UIStackView()
        ratingStackView.frame = CGRect(x: 30, y: card.frame.height - 60, width: 125, height: 25)
        ratingStackView.addArrangedSubview(star1)
        ratingStackView.addArrangedSubview(star2)
        ratingStackView.addArrangedSubview(star3)
        ratingStackView.addArrangedSubview(star4)
        ratingStackView.addArrangedSubview(star5)
        
        ratingStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AccueilView.showRatingAction)))
        
        // REPORT BUTTON
        let reportButton = UIButton()
        reportButton.setImage(UIImage(named: "icon-report-light"), for: .normal)
        reportButton.setTitleColor(UIColor.white, for: .normal)
        reportButton.frame = CGRect(x: card.frame.width - 40, y: 15, width: 30, height: 30)
        reportButton.addTarget(self, action: #selector(AccueilView.reportPost), for: .touchUpInside)
        
        // COMMENT BUTTON
        let commentButton = UIButton()
        commentButton.setImage(UIImage(named: "icon-comment"), for: .normal)
        commentButton.setTitleColor(UIColor.white, for: .normal)
        commentButton.frame = CGRect(x: 160, y: card.frame.height - 60, width: 30, height: 30)
        commentButton.addTarget(self, action: #selector(AccueilView.showCommentsAction), for: .touchUpInside)
        
        // CARD SUBVIEWS
        card.layer.addSublayer(playerLayer!)
        card.addSubview(reportButton)
        card.addSubview(gradientView)
        card.addSubview(descriptionLabel)
        card.addSubview(ratingStackView)
        card.addSubview(commentButton)
    }
    
    func navigateToNextPublication() {
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            // put here the code you would like to animate
            self.previousPublicationView.frame.origin.y -= 1500
            self.currentPublicationView.frame.origin.y -= 1500
            self.nextPublicationView.frame.origin.y -= 1500
        }, completion: { [self](finished:Bool) in
            
            setupPublications()
            
            previousPublicationView.frame = CGRect(x: 0, y: -1500, width: swipeAreaView.frame.width, height: swipeAreaView.frame.height)
            previousPublicationView.backgroundColor = UIColor.darkGray
            previousPublicationView.layer.cornerRadius = ROUNDED_RADIUS
            previousPublicationView.layer.shadowOffset = CGSize(width: 0,height: 0)
            previousPublicationView.layer.shadowRadius = ROUNDED_RADIUS
            previousPublicationView.layer.shadowOpacity = 0.4
            
            
            currentPublicationView.frame = CGRect(x: 0, y: 0, width: swipeAreaView.frame.width, height: swipeAreaView.frame.height)
            currentPublicationView.backgroundColor = UIColor.darkGray
            currentPublicationView.layer.cornerRadius = ROUNDED_RADIUS
            currentPublicationView.layer.shadowOffset = CGSize(width: 0,height: 0)
            currentPublicationView.layer.shadowRadius = ROUNDED_RADIUS
            currentPublicationView.layer.shadowOpacity = 0.4
            
            
            nextPublicationView.frame = CGRect(x: 0, y: 1500, width: swipeAreaView.frame.width, height: swipeAreaView.frame.height)
            nextPublicationView.backgroundColor = UIColor.darkGray
            nextPublicationView.layer.cornerRadius = ROUNDED_RADIUS
            nextPublicationView.layer.shadowOffset = CGSize(width: 0,height: 0)
            nextPublicationView.layer.shadowRadius = ROUNDED_RADIUS
            nextPublicationView.layer.shadowOpacity = 0.4
            
        })
    }
    
    func navigateToPreviousPublication() {
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            // put here the code you would like to animate
            self.previousPublicationView.frame.origin.y += 1500
            self.currentPublicationView.frame.origin.y += 1500
            self.nextPublicationView.frame.origin.y += 1500
        }, completion: { [self](finished:Bool) in
            
            setupPublications()
            
            previousPublicationView.frame = CGRect(x: 0, y: -1500, width: swipeAreaView.frame.width, height: swipeAreaView.frame.height)
            previousPublicationView.backgroundColor = UIColor.darkGray
            previousPublicationView.layer.cornerRadius = ROUNDED_RADIUS
            previousPublicationView.layer.shadowOffset = CGSize(width: 0,height: 0)
            previousPublicationView.layer.shadowRadius = ROUNDED_RADIUS
            previousPublicationView.layer.shadowOpacity = 0.4
            
            currentPublicationView.frame = CGRect(x: 0, y: 0, width: swipeAreaView.frame.width, height: swipeAreaView.frame.height)
            currentPublicationView.backgroundColor = UIColor.darkGray
            currentPublicationView.layer.cornerRadius = ROUNDED_RADIUS
            currentPublicationView.layer.shadowOffset = CGSize(width: 0,height: 0)
            currentPublicationView.layer.shadowRadius = ROUNDED_RADIUS
            currentPublicationView.layer.shadowOpacity = 0.4
            
            
            nextPublicationView.frame = CGRect(x: 0, y: 1500, width: swipeAreaView.frame.width, height: swipeAreaView.frame.height)
            nextPublicationView.backgroundColor = UIColor.darkGray
            nextPublicationView.layer.cornerRadius = ROUNDED_RADIUS
            nextPublicationView.layer.shadowOffset = CGSize(width: 0,height: 0)
            nextPublicationView.layer.shadowRadius = ROUNDED_RADIUS
            nextPublicationView.layer.shadowOpacity = 0.4
        })
    }
    
    var star1 : UIButton = UIButton()
    var star2 : UIButton = UIButton()
    var star3 : UIButton = UIButton()
    var star4 : UIButton = UIButton()
    var star5 : UIButton = UIButton()
    
    var noteAcutelle: Int?
    var noteChoisi: Int?
    
    @objc func showRatingAction(sender: UIButton) {
        let actionSheet = UIAlertController(title: "\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        
        initializeStarButton(starButton: star1, isEmpty: true)
        initializeStarButton(starButton: star2, isEmpty: true)
        initializeStarButton(starButton: star3, isEmpty: true)
        initializeStarButton(starButton: star4, isEmpty: true)
        initializeStarButton(starButton: star5, isEmpty: true)
        
        EvaluationViewModel().recupererEvaluationParUtilisateur(idPublication: currentPublication?._id) { [self] success, evaluationRep in
            if success {
                self.noteAcutelle = evaluationRep?.note
                
                var hasNote = false
                
                if noteAcutelle != 0 {
                    hasNote = true
                }
                
                print("noteAcutelle")
                print(noteAcutelle!)
                
                if hasNote {
                    initializeStarButton(starButton: star1, isEmpty: noteAcutelle! <= 0)
                    initializeStarButton(starButton: star2, isEmpty: noteAcutelle! <= 1)
                    initializeStarButton(starButton: star3, isEmpty: noteAcutelle! <= 2)
                    initializeStarButton(starButton: star4, isEmpty: noteAcutelle! <= 3)
                    initializeStarButton(starButton: star5, isEmpty: noteAcutelle! <= 4)
                }
                
                star1.addTarget(self, action: #selector(AccueilView.hoverStar1), for: .touchUpInside)
                star2.addTarget(self, action: #selector(AccueilView.hoverStar2), for: .touchUpInside)
                star3.addTarget(self, action: #selector(AccueilView.hoverStar3), for: .touchUpInside)
                star4.addTarget(self, action: #selector(AccueilView.hoverStar4), for: .touchUpInside)
                star5.addTarget(self, action: #selector(AccueilView.hoverStar5), for: .touchUpInside)
                
                let ratingStackView = UIStackView(frame: CGRect(x: 130, y: 20, width: 125, height: 25))
                ratingStackView.addArrangedSubview(star1)
                ratingStackView.addArrangedSubview(star2)
                ratingStackView.addArrangedSubview(star3)
                ratingStackView.addArrangedSubview(star4)
                ratingStackView.addArrangedSubview(star5)
                
                let addRatingLabel = UILabel(frame: CGRect(x: 8, y: 70, width: 380, height: 25))
                addRatingLabel.textColor = UIColor.gray
                addRatingLabel.text = "Please choose your rating"
                addRatingLabel.textAlignment = .center
                
                actionSheet.view.addSubview(ratingStackView)
                actionSheet.view.addSubview(addRatingLabel)
                
                if noteAcutelle != nil {
                    actionSheet.addAction(UIAlertAction(title: "Delete my rating", style: .destructive, handler: { act in
                        EvaluationViewModel().supprimerEvaluation(_id: "") { success in
                            if success {
                                self.dismiss(animated: true, completion: nil)
                            } else {
                                self.present(Alert.makeServerErrorAlert(),animated: true)
                            }
                        }
                    }))
                }
                
                actionSheet.addAction(UIAlertAction(title: "Save", style: .default, handler: { uication in
                    if hasNote {
                        if noteChoisi != nil {
                            EvaluationViewModel().modifierEvaluation(id: (evaluationRep?._id)!, note: noteChoisi!) { success in
                                if success {
                                    
                                } else {
                                    self.present(Alert.makeServerErrorAlert(),animated: true)
                                }
                            }
                        }
                    } else {
                        if noteChoisi != nil {
                            EvaluationViewModel().ajouterEvaluation(idPublication: (currentPublication?._id)!, note: noteChoisi!) { success in
                                if success {
                                    
                                } else {
                                    self.present(Alert.makeServerErrorAlert(),animated: true)
                                }
                            }
                        }
                    }
                }))
                actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(actionSheet, animated: true, completion: nil)
            } else {
                self.present(Alert.makeServerErrorAlert(),animated: true)
            }
        }
    }
    
    func initializeStarButton(starButton: UIButton, isEmpty: Bool) {
        var name: String
        
        if isEmpty {
            name = "icon-star-empty"
        } else {
            name = "icon-star-filled"
        }
        
        starButton.setImage(UIImage(named: name), for: .normal)
        starButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        starButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    @objc func hoverStar1(sender: UIButton) {
        star1.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star2.setImage(UIImage(named: "icon-star-empty"), for: .normal)
        star3.setImage(UIImage(named: "icon-star-empty"), for: .normal)
        star4.setImage(UIImage(named: "icon-star-empty"), for: .normal)
        star5.setImage(UIImage(named: "icon-star-empty"), for: .normal)
        
        noteChoisi = 1
    }
    
    @objc func hoverStar2(sender: UIButton) {
        star1.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star2.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star3.setImage(UIImage(named: "icon-star-empty"), for: .normal)
        star4.setImage(UIImage(named: "icon-star-empty"), for: .normal)
        star5.setImage(UIImage(named: "icon-star-empty"), for: .normal)
        
        noteChoisi = 2
    }
    
    @objc func hoverStar3(sender: UIButton) {
        star1.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star2.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star3.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star4.setImage(UIImage(named: "icon-star-empty"), for: .normal)
        star5.setImage(UIImage(named: "icon-star-empty"), for: .normal)
        
        noteChoisi = 3
    }
    
    @objc func hoverStar4(sender: UIButton) {
        star1.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star2.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star3.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star4.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star5.setImage(UIImage(named: "icon-star-empty"), for: .normal)
        
        noteChoisi = 4
    }
    
    @objc func hoverStar5(sender: UIButton) {
        star1.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star2.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star3.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star4.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        star5.setImage(UIImage(named: "icon-star-filled"), for: .normal)
        
        noteChoisi = 5
    }
    
    @objc func likeButtonAction(sender: UIButton) {
        
    }
    
    @objc func reportPost(sender: UIButton) {
        let alert = UIAlertController(title: "Report", message: "Please tell us why you are reporting this post", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Offensive", style: .default) { [self] UIAlertAction in
            sendReport(type: "Offensive")
        }
        let action2 = UIAlertAction(title: "Abusive", style: .default) { [self] UIAlertAction in
            sendReport(type: "Abusive")
        }
        let action3 = UIAlertAction(title: "Racism", style: .default) { [self] UIAlertAction in
            sendReport(type: "Racism")
        }
        let action4 = UIAlertAction(title: "Nudity", style: .default) { [self] UIAlertAction in
            sendReport(type: "Nudity")
        }
        let action5 = UIAlertAction(title: "Other", style: .default) { [self] UIAlertAction in
            sendReport(type: "Other")
        }
        let action6 = UIAlertAction(title: "Cancel", style: .cancel) { UIAlertAction in
     
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        alert.addAction(action4)
        alert.addAction(action5)
        alert.addAction(action6)
        
        self.present(alert,animated: true)
    }
    
    func sendReport(type: String) {
        PublicationViewModel.sharedInstance.report(_id: currentPublication?._id!, type: type) { success in
            if success {
                self.present(Alert.makeAlert(titre: "Success", message: "Your report has been sent for review"),animated: true)
            } else {
                self.present(Alert.makeServerErrorAlert(),animated: true)
            }
        }
    }
    
    @objc func showCommentsAction(sender: UIButton) {
        performSegue(withIdentifier: "commentairesSegue", sender: currentPublication)
    }
    
    @IBAction func topSwipeHandler(_ gestureRecognizer : UISwipeGestureRecognizer ) {
        if gestureRecognizer.state == .ended {
            if ((nextPublication) != nil){
                publicationCounter += 1
                
                navigateToNextPublication()
            } else {
                //nextPublicationView.removeFromSuperview()
                print("last one")
            }
        }
    }
    
    @IBAction func downSwipeHandler(_ gestureRecognizer : UISwipeGestureRecognizer ) {
        
        if gestureRecognizer.state == .ended {
            if ((previousPublication) != nil){
                publicationCounter -= 1
                
                navigateToPreviousPublication()
            } else {
                //previousPublicationView.removeFromSuperview()
                print("first one")
            }
        }
    }
}
