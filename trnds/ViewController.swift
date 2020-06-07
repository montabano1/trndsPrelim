//
//  ViewController.swift
//  trnds
//
//  Created by michael montalbano on 6/5/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import Hex

class ViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var filterLabel: UILabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var signUpButton: UIButton!
    
    var filters = ["who have taken your exact class (Math)", "that have had over 10 sessions", "who cost less than $50/hr", "who cost greater than $50/hr"]
    
    // if app connected to database, could populate tutors in viewWillAppear
    var tutors = [
        ["Derek J.", 85, 4, ["English", "History"], "To be or not to be your tutor", "derekj", 1],
        ["Mike M.", 75, 100, ["Math", "Science", "Sports Trivia"], "Carnegie Mellon Undergrad, Columbia Grad School. Favorite Movie: Back to the Future", "mikem", 2],
        ["Alex R.", 45, 0, ["Math", "Social Studies"], "I am very good at teaching stuff to people", "alexr", 3],
        ["Roger F.", 100, 12, ["Math", "History", "Biology"], "If you think you can or you think you can't, your're right", "rogerf", 4],
        ["Bobby B.", 20, 15, ["English"], "I good and college", "bobbyb", 5],
        ["Steph C.", 35, 6, ["Political Science", "Calculus", "Gender Studies"], "Favorite sports team: Lakers", "stephc", 6],
        ["Peyton M.", 75, 7, ["Math", "Golf", "Tennis"], "I really love sabermetrics", "peytonm", 7],
        ["Bryson D.", 80, 30, ["Math"], "I can teach any math subject, give me a try!", "brysond", 8],
    ]
    
    var chats = [[Any]]()
    var filteredTutors = [[Any]]()
    
    var currentCenter = CGFloat()
    var scrollCenter = CGFloat()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        leftSwipe.direction = .left
        
        view.addGestureRecognizer(rightSwipe)
        view.addGestureRecognizer(leftSwipe)
        
        filterLabel.font = UIFont(name: "Avenir", size: 20)
        
        signUpButton.titleLabel?.font = UIFont(name: "Avenir-Roman", size: 16)
        
        scrollView.delegate = self
        
        showTutors()
        highlightTutor()
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            switch sender.direction {
            case .left:
                swipeText(1)
            default:
                swipeText(-1)
            }
        }
    }
    
    //swiping is really moving off screen, then moving to other side off screen, then moving back on screen
    func swipeText(_ value: Int) {
        let width = self.view.bounds.width
        if pageControl.currentPage < 3 && value == 1  {
            UIView.animate(withDuration: 0.2, animations: {
                self.filterLabel.center.x -= width
                self.scrollView.center.x -= width
            }) { (completion) in
                self.pageControl.currentPage += 1
                self.filterLabel.text = "Find tutors or students \(self.filters[self.pageControl.currentPage])"
                self.showTutors()
                self.highlightTutor()
                self.filterLabel.center.x += 2*width
                self.scrollView.center.x += 2*width
                UIView.animate(withDuration: 0.2, animations: {
                    self.filterLabel.center.x -= width
                    self.scrollView.center.x -= width
                })
            }
        } else if pageControl.currentPage > 0 && value == -1  {
            UIView.animate(withDuration: 0.2, animations: {
                self.filterLabel.center.x += width
                self.scrollView.center.x += width
            }) { (completion) in
                self.pageControl.currentPage -= 1
                self.filterLabel.text = "Find tutors or students \(self.filters[self.pageControl.currentPage])"
                self.showTutors()
                self.highlightTutor()
                self.filterLabel.center.x -= 2*width
                self.scrollView.center.x -= 2*width
                UIView.animate(withDuration: 0.2, animations: {
                    self.filterLabel.center.x += width
                    self.scrollView.center.x += width
                })
            }
        }
    }
    
    func filterTutors() {
        //filter by category and sort by that category
        switch pageControl.currentPage {
        case 0:
            filteredTutors = tutors.filter({ ($0[3] as! [String]).contains("Math")})
        case 1:
            filteredTutors = tutors.filter({ ($0[2] as! Int) > 10}).sorted(by: {($0[2] as! Int) > ($1[2] as! Int)})
        case 2:
            filteredTutors = tutors.filter({ ($0[1] as! Int) < 50 }).sorted(by: {($0[1] as! Int) < ($1[1] as! Int)})
        case 3:
            filteredTutors = tutors.filter({ ($0[1] as! Int) >= 50 }).sorted(by: {($0[1] as! Int) > ($1[1] as! Int)})
        default:
            filteredTutors = tutors
        }
    }
    
    func showTutors() {
        //start each filter by removing all tutors from the list
        scrollView.subviews.forEach { (tutor) in
            tutor.removeFromSuperview()
        }
        
        filterTutors()
        
        scrollView.contentOffset.y = 0
        var i = 0
        while i < filteredTutors.count {
            let tutor = filteredTutors[i]
            
            //tutView is the cell for each tutor
            let tutView = UIView()
            tutView.tag = i+1
            //height of each cell is 80, y value is i*90 to give 10 points of space
            tutView.frame = CGRect(x: 20, y: i*90 + 20, width: Int(view.bounds.width) - 40, height: 80)
            tutView.backgroundColor = UIColor(hex: "E7E7ED")
            tutView.layer.cornerRadius = 10
            tutView.layer.masksToBounds = true
            
            let avatar = UIImageView(frame: CGRect(x: 15, y: 20, width: 40, height: 40))
            avatar.layer.cornerRadius = 20
            avatar.image = UIImage(named: tutor[5] as! String)?.circleMasked
            tutView.addSubview(avatar)
            
            let nameLabel = UILabel()
            nameLabel.frame = CGRect(x: avatar.frame.maxX + 5, y: 0, width: 300, height: 20)
            nameLabel.font = UIFont(name: "Roboto-Regular", size: 17.0)
            nameLabel.center.y = avatar.frame.minY
            nameLabel.text = tutor[0] as! String
            tutView.addSubview(nameLabel)
            
            let rateLabel = UILabel()
            rateLabel.frame = CGRect(x: nameLabel.frame.minX, y: nameLabel.frame.maxY + 5, width: 75, height: 14)
            rateLabel.font = UIFont(name: "Roboto-Regular", size: 12.0)
            rateLabel.textColor = UIColor(hex: "E47C41")
            rateLabel.text = "Rate/Hr"
            tutView.addSubview(rateLabel)
            
            let rateAmount = UILabel()
            rateAmount.frame = CGRect(x: rateLabel.frame.minX, y: rateLabel.frame.maxY + 5, width: 75, height: 14)
            rateAmount.font = UIFont(name: "Roboto-Regular", size: 12.0)
            rateAmount.textColor = UIColor(hex: "979797")
            rateAmount.text = "$\(tutor[1])"
            tutView.addSubview(rateAmount)
            
            let sessionLabel = UILabel()
            sessionLabel.frame = CGRect(x: rateLabel.frame.maxX, y: nameLabel.frame.maxY + 5, width: 75, height: 14)
            sessionLabel.font = UIFont(name: "Roboto-Regular", size: 12.0)
            sessionLabel.textColor = UIColor(hex: "E47C41")
            sessionLabel.text = "Sessions"
            tutView.addSubview(sessionLabel)
            
            let sessionsAmount = UILabel()
            sessionsAmount.frame = CGRect(x: rateLabel.frame.maxX, y: rateLabel.frame.maxY + 5, width: 75, height: 14)
            sessionsAmount.font = UIFont(name: "Roboto-Regular", size: 12.0)
            sessionsAmount.textColor = UIColor(hex: "979797")
            sessionsAmount.text = "\(tutor[2])"
            tutView.addSubview(sessionsAmount)
            
            let chatButton = UIButton()
            chatButton.frame = CGRect(x: tutView.frame.width - 90, y: 0, width: 80, height: 30)
            chatButton.center.y = 40
            chatButton.setTitle("Chat", for: [])
            chatButton.backgroundColor = UIColor(hex: "7DDC72")
            chatButton.layer.cornerRadius = 15
            chatButton.titleLabel!.font = UIFont(name: "Avenir-Roman", size: 16.0)
            chatButton.addTarget(self, action: #selector(openChat), for: .touchUpInside)
            chatButton.tag = i+1
            tutView.addSubview(chatButton)
            
            //cancel button and chat button toggle being visible
            let cancelbutton = UIButton()
            cancelbutton.setImage(UIImage(named: "close"), for: [])
            cancelbutton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            cancelbutton.center = chatButton.center
            cancelbutton.alpha = 0
            cancelbutton.addTarget(self, action: #selector(closeChat), for: .touchUpInside)
            cancelbutton.tag = i + 1
            tutView.addSubview(cancelbutton)
            
            let classesTaughLabel = UILabel()
            classesTaughLabel.frame = CGRect(x: Int(avatar.frame.minX), y: Int(sessionsAmount.frame.maxY) + 20, width: Int(view.bounds.width) - 65, height: 40)
            classesTaughLabel.text = "Classes Taught: \((tutor[3] as! [String]).joined(separator: ", "))"
            classesTaughLabel.font = UIFont(name: "Roboto-Regular", size: 18.0)
            classesTaughLabel.numberOfLines = 0
            classesTaughLabel.sizeToFit()
            tutView.addSubview(classesTaughLabel)
            
            //could limit description length to not take up entire chat space
            let descriptionText = UILabel()
            descriptionText.frame = CGRect(x: Int(classesTaughLabel.frame.minX), y: Int(classesTaughLabel.frame.maxY) + 5, width: Int(view.bounds.width) - 65, height: 120)
            descriptionText.text = "Description: \(tutor[4])"
            descriptionText.font = UIFont(name: "Roboto-Regular", size: 18.0)
            descriptionText.numberOfLines = 0
            descriptionText.sizeToFit()
            tutView.addSubview(descriptionText)
            
            let sendMesssageField = UITextField()
            sendMesssageField.frame = CGRect(x: descriptionText.frame.minX, y: descriptionText.frame.maxY + 20, width: view.bounds.width - 65, height: 30)
            sendMesssageField.placeholder = "Send \(tutor[0]) a message"
            sendMesssageField.layer.borderWidth = 1
            sendMesssageField.layer.cornerRadius = 5
            sendMesssageField.setLeftPaddingPoints(10)
            sendMesssageField.tag = i + 2
            tutView.addSubview(sendMesssageField)
            
            let sendMessageButton = UIButton()
            sendMessageButton.frame = CGRect(x: 0, y: sendMesssageField.frame.maxY + 5, width: 60.0, height: 30.0)
            sendMessageButton.center.x = sendMesssageField.frame.maxX - 30
            sendMessageButton.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            sendMessageButton.setTitle("Send", for: [])
            sendMessageButton.setTitleColor(.white, for: [])
            sendMessageButton.layer.cornerRadius = 5
            sendMessageButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
            sendMessageButton.tag = i + 2
            tutView.addSubview(sendMessageButton)
            
            let chatViewLabel = UILabel()
            chatViewLabel.frame = CGRect(x: descriptionText.frame.minX, y: sendMessageButton.frame.maxY, width: 100, height: 20)
            chatViewLabel.text = "Chat"
            tutView.addSubview(chatViewLabel)
            
            let chatView = UIScrollView()
            chatView.frame = CGRect(x: chatViewLabel.frame.minX, y: chatViewLabel.frame.maxY + 1, width: view.bounds.width - 65, height: view.bounds.height - chatViewLabel.frame.maxY - 140)
            chatView.layer.borderWidth = 1
            chatView.layer.cornerRadius = 5
            chatView.tag = i+2
            tutView.addSubview(chatView)
            
            scrollView.addSubview(tutView)
            i += 1
        }
        scrollView.contentSize = CGSize(width: Int(scrollView.frame.width - 100), height: 90*i + 160)
    }
    
    @objc func sendMessage(_ sender: UIButton) {
        var message = ""
        let tag = sender.tag
        for tutor in view.subviews {
            //find which message to add, could have multiple chats going at once
            if tutor.tag == tag - 1 {
                for sub in tutor.subviews {
                    if let textfield = sub as? UITextField {
                        message = textfield.text!
                        textfield.text = ""
                        addMessage(message: message, tutorNumber: tag - 1, outgoing: true)
                        chats.append([message, filteredTutors[tag-2][6], true])
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            let starts = ["Idk but ", "Thats cool but ", "Sorry to interupt but "]
                            let responses = ["I think you should hire Michael Montalbano", "I hear Michael Montalbano goes above and beyond", "it's obvious Michael Montalbano is a very hard worker"]
                            let response = starts[Int.random(in: 0..<3)] + responses[Int.random(in: 0..<3)]
                            self.addMessage(message: response, tutorNumber: tag - 1, outgoing: false)
                            self.chats.append([response, self.filteredTutors[tag-2][6], false])
                        }
                    }
                }
            }
        }
    }
    
    func addMessage(message: String, tutorNumber: Int, outgoing: Bool) {
        let tag = tutorNumber
        for tutor in view.subviews {
            if tutor.tag == tag {
                for sub in tutor.subviews {
                    //find which chat to add to, could have multiple chats going at once
                    if let allmessages = sub as? UIScrollView {
                        var maxY = CGFloat(0)
                        for oldMessage in allmessages.subviews {
                            if let realMessage = oldMessage as? UILabel {
                                if realMessage.frame.maxY > maxY {
                                    maxY = oldMessage.frame.maxY
                                }
                            }
                        }
                        let newMessage = UILabel()
                        newMessage.text = "  \(message)"
                        newMessage.numberOfLines = 0
                        newMessage.layer.borderWidth = 1
                        newMessage.layer.cornerRadius = 5
                        newMessage.textAlignment = .center
                        if outgoing {
                            newMessage.layer.borderColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
                            newMessage.textColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
                            newMessage.frame = CGRect(x: 20, y: maxY + 10, width: 200, height: 60)
                            newMessage.sizeToFit()
                            newMessage.frame = CGRect(x: view.bounds.width - newMessage.frame.width - 100, y: maxY + 10, width: newMessage.frame.width + 20, height: newMessage.frame.height + 20)
                        } else {
                            newMessage.layer.borderColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                            newMessage.textColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                            newMessage.frame = CGRect(x: 20, y: maxY + 10, width: 200, height: 60)
                            newMessage.sizeToFit()
                            newMessage.frame = CGRect(x: 20, y: maxY + 10, width: newMessage.frame.width + 20, height: newMessage.frame.height + 20)
                        }
                        allmessages.addSubview(newMessage)
                        
                        //allow scrolling if messages get near bottom
                        allmessages.contentSize = CGSize(width: 1, height: newMessage.frame.maxY + 50)
                        
                        //scroll to last message
                        if (newMessage.frame.maxY > allmessages.frame.height) {
                            allmessages.contentOffset.y = newMessage.frame.maxY - allmessages.frame.height + 20
                        }
                        
                    }
                }
            }
        }
    }
    
    @objc func openChat(_ sender: UIButton) {
        let tag = sender.tag
        for tutor in scrollView.subviews {
            if tutor.tag == tag {
                //remember location in scrollview
                scrollCenter = tutor.center.y
                //remember location in total view so it starts there before popping
                currentCenter = scrollCenter + scrollView.frame.minY - scrollView.contentOffset.y
                view.addSubview(tutor)
                tutor.center.y = currentCenter
                tutor.center.x = view.center.x
                tutor.backgroundColor = .white
                
                UIView.animate(withDuration: 0.5) {
                    self.signUpButton.alpha = 0
                    for sub in tutor.subviews {
                        if sub.tag == tag {
                            if sub == sender {
                                sub.alpha = 0
                            }  else {
                                sub.alpha = 1
                            }
                        }
                        if sub.tag == tag + 1 {
                            if let allmessages = sub as? UIScrollView {
                                for message in allmessages.subviews {
                                    message.removeFromSuperview()
                                }
                                self.populateMessages(tutorId: self.filteredTutors[tag-1][6] as! Int, tag: tag)
                            }
                        }
                    }
                    tutor.frame = CGRect(x: 20, y: 40, width: self.view.bounds.width - 40, height: self.view.bounds.height - 100)
                }
            }
        }
    }
    
    @objc func closeChat(_ sender: UIButton) {
        for bigView in view.subviews {
            if bigView.tag == sender.tag {
                UIView.animate(withDuration: 0.5, animations: {
                    self.signUpButton.alpha = 1
                    //start in same position
                    bigView.frame = CGRect(x: 20, y: 20, width: Int(self.view.bounds.width) - 40, height: 80)
                    //end in remembered position
                    bigView.center.y = self.currentCenter
                    for button in bigView.subviews {
                        if button.tag == sender.tag {
                            if button == sender {
                                button.alpha = 0
                            }  else {
                                button.alpha = 1
                            }
                        }
                    }
                }) { (finished) in
                    //put back in scrollview
                    self.scrollView.addSubview(bigView)
                    bigView.center.y = self.scrollCenter
                    self.highlightTutor()
                }
            }
        }
    }
    
    //swiping removes all tutors and subviews so I kept track of chats
    func populateMessages(tutorId: Int, tag: Int) {
        let filteredChats = chats.filter({ $0[1] as! Int == tutorId})
        for message in filteredChats {
            addMessage(message: message[0] as! String, tutorNumber: tag, outgoing: message[2] as! Bool)
        }
    }
    
    func highlightTutor() {
        let focus = scrollView.contentOffset.y
        let tag = Int((focus+125)/80)
        for tutor in scrollView.subviews {
            if tutor.tag == tag {
                tutor.backgroundColor = .white
            } else {
                tutor.backgroundColor = UIColor(hex: "E7E7ED")
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        highlightTutor()
    }
    
    


}

extension UIImage {
    
    var isPortrait:  Bool    { return size.height > size.width }
    var isLandscape: Bool    { return size.width > size.height }
    var breadth:     CGFloat { return min(size.width, size.height) }
    var breadthSize: CGSize  { return CGSize(width: breadth, height: breadth) }
    var breadthRect: CGRect  { return CGRect(origin: .zero, size: breadthSize) }
    var circleMasked: UIImage? {
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}


