//
//  AppDelegate.swift
//  EmitterKit
//
//  Created by Alec Stanford Larson on 9/8/14.
//  Copyright (c) 2014 Alec Larson. All rights reserved.
//

import UIKit
import EmitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var listeners = [Listener]()
  
  let myEvent = Event<Int>()

  let mySignal = Signal()

  let myView = UIView()
  
  func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
    
    myEvent.once {
      println("myEvent.once listener was called with: \($0)")
    }

    listeners += myEvent.on {
      println("myEvent.on listener was called with: \($0)")
    }

    listeners += myEvent.on(self) {
      println("myEvent.on(self) listener was called with: \($0)")
    }

    myEvent.emit(0)
    myEvent.emit(1)
    myEvent.emit(self, 2)


    ///////////////////////////////////////////////////////////////


    mySignal.once {
      println("mySignal.once listener was called")
    }

    listeners += mySignal.on {
      println("mySignal.on listener was called")
    }

    listeners += mySignal.on(self) {
      println("mySignal.on(self) listener was called")
    }

    mySignal.emit()
    mySignal.emit()
    mySignal.emit(self)


    ///////////////////////////////////////////////////////////////
    
    
    let willResignActive = Notification(UIApplicationWillResignActiveNotification)
    listeners += willResignActive.on(application) {
      println("willResignActive \($0)")
    }
    

    ///////////////////////////////////////////////////////////////


    listeners += myView.on("bounds") { (values: Change<NSValue>) in
      println("myView.bounds = (oldValue: \(values.oldValue), newValue: \(values.newValue))")
    }
    
    myView.bounds = CGRectMake(100, 100, 100, 100)
    myView.bounds.size = CGSizeMake(200, 200)
    
    myView.once("backgroundColor") { (values: Change<UIColor>) in
      println("myView.backgroundColor = (oldValue: \(values.oldValue), newValue: \(values.newValue))")
    }
    
    myView.backgroundColor = UIColor.blueColor()


    ///////////////////////////////////////////////////////////////
    
    
    class MyScrollView : UIScrollView, UIScrollViewDelegate {
      let didScroll = Event<CGPoint>()
      
      override init () {
        super.init()
        delegate = self
      }

      required init(coder aDecoder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
      
      func scrollViewDidScroll(scrollView: UIScrollView) {
        didScroll.emit(scrollView.contentOffset)
      }
    }
    
    
    // TODO: More tests
    
    
    return true
  }
}

