//
//  ViewController.swift
//  Draft_Hypa_02
//
//  Created by mac on 11.07.16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate{
    var prelude: UIView!
    var answerTop: UIView!
    var answerBottom: UIView!
    var lastPanView: UIView = UIView()

    var defaultViewCenter: [CGPoint] = []
    
    var animator: UIDynamicAnimator!
    
    var preludePanGestureRecognizer: UIPanGestureRecognizer!
    var answerTopPanGestureRecognizer: UIPanGestureRecognizer!
    var answerBottomPanGestureRecognizer: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        createConstrants()
        
        animator = UIDynamicAnimator(referenceView: view)
        //animator.setValue(true, forKey: "debugEnabled")
        
        //Create UIPanGestureRecognizer
        preludePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(pan:)))
        answerTopPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(pan:)))
        answerBottomPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(pan:)))
        
        //Set delegate to UIPanGestureRecognizer
        preludePanGestureRecognizer.delegate = self
        answerTopPanGestureRecognizer.delegate = self
        answerBottomPanGestureRecognizer.delegate = self
        
        //Set UIPanGestureRecognizer to views
        prelude.addGestureRecognizer(preludePanGestureRecognizer)
        answerTop.addGestureRecognizer(answerTopPanGestureRecognizer)
        answerBottom.addGestureRecognizer(answerBottomPanGestureRecognizer)
        
        //MARK: Why we cant set isExclusiveTouch only for one view (in pan.view) and must setting for all views?
        //Turn off multi touch for views
        prelude.isExclusiveTouch = true
        answerTop.isExclusiveTouch = true
        answerBottom.isExclusiveTouch = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Set defaultViewCenter
        //FIXME: Not in the right place (viewDidAppear). And hardcode linking between array's index and view's tag
        defaultViewCenter.append(prelude.center)
        defaultViewCenter.append(answerTop.center)
        defaultViewCenter.append(answerBottom.center)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func pan(pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: self.view)
        guard let panView = pan.view else {
            print("Error with unwrap pan.view")
            return
        }
        
        switch pan.state {
            case .began:
                //Set previus touched view to init position if user starts touching view due snaping
                lastPanView.center = defaultViewCenter[lastPanView.tag]
                
                animator.removeAllBehaviors()
            
            case .changed:
                panView.center = CGPoint(x: panView.center.x + translation.x, y: panView.center.y)
                pan.setTranslation(CGPoint.zero, in: panView)
            
            case .cancelled, .ended:
                //Add UIDynamicItemBehavior to animator
                let dynamicItemBehavior = UIDynamicItemBehavior(items: [panView])
                dynamicItemBehavior.allowsRotation = false
                animator.addBehavior(dynamicItemBehavior)
                
                //Set UISnapBehavior to views
                let snapBehavior = UISnapBehavior(item: panView, snapTo: defaultViewCenter[panView.tag])
                snapBehavior.damping = 0.15
                animator.addBehavior(snapBehavior)
            
                lastPanView = panView
                lastPanView.tag = panView.tag
            
            default: ()
        }
    }
    
    func initViews() {
        //Init
        prelude = UIView()
        answerTop = UIView()
        answerBottom = UIView()
        
        //FIXME: Hardcoding view's tag
        //Set tag
        prelude.tag = 0
        answerTop.tag = 1
        answerBottom.tag = 2
        
        //Prepare Auto Layout
        prelude.translatesAutoresizingMaskIntoConstraints = false
        answerTop.translatesAutoresizingMaskIntoConstraints = false
        answerBottom.translatesAutoresizingMaskIntoConstraints = false
        
        //Set background color
        prelude.backgroundColor = UIColor.blue()
        answerTop.backgroundColor = UIColor.darkGray()
        answerBottom.backgroundColor = UIColor.lightGray()
        
        //Set view's corner radius
        answerTop.layer.cornerRadius = 4
        answerBottom.layer.cornerRadius = 4
        
        //Add to super view
        self.view.addSubview(prelude)
        self.view.addSubview(answerTop)
        self.view.addSubview(answerBottom)
    }
    
    func createConstrants() {
        //Create constrants preludeView
        let pinLeftPrelude = NSLayoutConstraint(item: prelude, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0)
        let pinTopPrelude = NSLayoutConstraint(item: prelude, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 24)
        let pinRightPrelude = NSLayoutConstraint(item: prelude, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0)
        let heightPrelude = NSLayoutConstraint(item: prelude, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.height, multiplier: 0.35, constant: 0)
        
        //Create constraints answerTopView
        let pinLeftAnswerTop = NSLayoutConstraint(item: answerTop, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 12)
        let pinRightAnswerTop = NSLayoutConstraint(item:answerTop, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: -12)
        let topMarginAnswerTopToPrelude = NSLayoutConstraint(item: answerTop, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: prelude, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 12)
        let heightAnswerTop = NSLayoutConstraint(item: answerTop, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.height, multiplier: 0.25, constant: 0)
        
        //Create constrants answerBottomView
        let pinLeftAnswerBottom = NSLayoutConstraint(item: answerBottom, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 12)
        let pinRightAnswerBottom = NSLayoutConstraint(item: answerBottom, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: -12)
        let topMarginAnswerBottomToAnswerTop = NSLayoutConstraint(item: answerBottom, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: answerTop, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 12)
        let heightAnswerBottom = NSLayoutConstraint(item: answerBottom, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.height, multiplier: 0.25, constant: 0)
        
        //Adding to super view
        self.view.addConstraints([pinLeftPrelude, pinTopPrelude, pinRightPrelude, heightPrelude, pinLeftAnswerTop, pinRightAnswerTop, heightAnswerTop, topMarginAnswerTopToPrelude, pinLeftAnswerBottom, pinRightAnswerBottom, topMarginAnswerBottomToAnswerTop, heightAnswerBottom])
    }
}

