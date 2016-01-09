//
//  main.swift
//  recon
//
//  Created by Guillermo Baigorria on 1/8/16.
//  Copyright © 2016 bgn. All rights reserved.
//

import Foundation
import CoreWLAN
import SystemConfiguration

// site to fetch to test for connectivity
let reference_site = "http://www.google.com"
// this is the time in seconds to wait before trying to fetch the site again
let sleep_loop_sec:UInt32 = 1
// this is the time to wait before trying a new fetch after reconnection
let sleep_reconnect_sec:UInt32 = 10
// this is the timeout for the request in seconds
let request_timeout_sec:NSTimeInterval = 1


// we print to stderr so we can see the feedback in a bash console
public struct StderrOutputStream: OutputStreamType {
    public mutating func write(string: String) {
        fputs(string, stderr)}
}
public var errStream = StderrOutputStream()

// feedback char dictionary
enum feedbackChar: Character{
    case Unknown = "?"
    case Ping = "."
    case Reconnecting = "#"
    case ReconnectError = "!"
}

// prints feedback
func feedback(c:feedbackChar){
    print(c.rawValue, terminator:"", toStream: &errStream)
}

// disconnects and reconnects the wifi interface
func reconnect() throws{
    // get wifi interface
    let int = CWWiFiClient.sharedWiFiClient().interface()
    // turn down
    try int?.setPower(false)
    // back on
    try int?.setPower(true)
    // wait for reconnection to settle
    sleep(sleep_reconnect_sec)
}

// tries to fetch a reference site from the internet, if error or timeout calls reconnect()
func fetchPage() throws{
    // ephemeral, we don't need special feats like cookies
    let session_config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
    // set timeouts
    session_config.timeoutIntervalForRequest = request_timeout_sec
    session_config.timeoutIntervalForResource = request_timeout_sec
    // session
    let session = NSURLSession(configuration: session_config)
    // create a semaphore to wait for callbak
    let sem = dispatch_semaphore_create(0);
    let request = NSMutableURLRequest(URL: NSURL(string: reference_site)!)
    request.HTTPMethod = "GET"
    
    // create the tast for the request
    let task = session.dataTaskWithRequest(request,
        completionHandler: {
            data, response, error -> Void in
            
            if error != nil{
                feedback(feedbackChar.Reconnecting)
                do{
                    // reconnect if an error occurred
                    try reconnect()
                } catch {
                    feedback(feedbackChar.ReconnectError)
                }
            } else {
                feedback(feedbackChar.Ping)
            }
            
            // we can continue now
            dispatch_semaphore_signal(sem);
        }
    )
    
    // runs task
    task.resume()
    // wait for callback to be executed
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}


// main loop
while(true) {
    sleep(sleep_loop_sec)
    // fetch the page
    try fetchPage()
}
