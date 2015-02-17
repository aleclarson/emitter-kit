//
//  AppDelegate.swift
//  EmitterKit
//
//  Created by Alec Stanford Larson on 9/8/14.
//  Copyright (c) 2014 Alec Larson. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
  var window: UIWindow!

  let events = ListenerStorage()
  
  let myEvent = Event<Int>()

  let mySignal = Signal()
  
  let myNotif = Notification(UIApplicationWillResignActiveNotification)
  
  func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
    
    window = UIWindow()
    window?.rootViewController = UIViewController()

    ///////////////////////////////////////////////////////////////
    
    
    myEvent.once {
      println("myEvent.once listener was called with: \($0)")
    }

    events += myEvent.on {
      println("myEvent.on listener was called with: \($0)")
    }

    events += myEvent.on(window) {
      println("myEvent.on(window) listener was called with: \($0)")
    }

    myEvent.emit(0)
    myEvent.emit(1)
    myEvent.emit(window, 2)


    ///////////////////////////////////////////////////////////////


    mySignal.once {
      println("mySignal.once listener was called")
    }

    events += mySignal.on {
      println("mySignal.on listener was called")
    }

    events += mySignal.on(window) {
      println("mySignal.on(window) listener was called")
    }

    mySignal.emit()
    mySignal.emit()
    mySignal.emit(window)


    ///////////////////////////////////////////////////////////////
    
    
    // Use the simulator and press CMD+L to lock it. 
    // This closure should be called then.
    myNotif.once(application) { info in
      println("myNotif.once listener was called with: \(info)")
    }


    ///////////////////////////////////////////////////////////////

    
    println("myEvent.listeners BEFORE `myEvent.removeAllListeners`: \(myEvent.listenerCount)")

    myEvent.removeAllListeners()

    println("myEvent.listeners AFTER `myEvent.removeAllListeners`: \(myEvent.listenerCount)")


    ///////////////////////////////////////////////////////////////


    println("events.listeners BEFORE `events.removeAllListeners`: \(events.count)")

    events.removeAllListeners()

    println("events.listeners AFTER `events.removeAllListeners`: \(events.count)")


    ///////////////////////////////////////////////////////////////
    
    
    // TODO: More tests
    
    
    return true
  }

  func applicationWillResignActive(application: UIApplication!) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication!) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication!) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication!) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication!) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

}

