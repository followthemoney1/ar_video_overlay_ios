//
//  FirebaseManager.swift
//  ARConcept
//
//  Created by Dmitry Dyachenko on 11/13/20.
//

import Foundation
import Firebase
import FirebaseAuth
import CodableFirebase
import Combine

class FirebaseManager{
    var ref: DatabaseReference?
    
    init() {
        ref = Database.database().reference()
    }
    
    func getDataForElement(withPath path:String, complete:@escaping(ARData?)->()){
        ref?.child(path).observeSingleEvent(of: .value, with: { (snapshot) in
            
            do {
                var data = try FirebaseDecoder().decode(ARData.self, from: snapshot.value!)
                //FirebaseManager.log(message:"get data for firebase success = \(data.name)")
//                if let youtubeUrl = data.isYoutubeVideo{
//                    if(youtubeUrl){
//                        XCDYouTubeClient.default().getVideoWithIdentifier(data.directYoutubeUrl?.youtubeID, completionHandler: { (video, error) in
//
//                            let streamURL = video?.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue] ??
//                                video?.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] ?? video?.streamURLs[XCDYouTubeVideoQuality.small240.rawValue]
//
//                            data.downloadVideoUrl = streamURL
//                            data.keyName = path
//                            //FirebaseManager.log(message:"loaded vide sucess youtube")
//                            //FirebaseManager.log(message:"video url = \( data.downloadVideoUrl)")
//                            complete(data)
//                        })
//                    }else{
                        data.downloadVideoUrl = URL(string: data.directVideoUrl!)
                        data.keyName = path
                        //FirebaseManager.log(message:"loaded vide sucess local")
                        //FirebaseManager.log(message:"video url = \( data.downloadVideoUrl)")
                        complete(data)
//                    }
               
            } catch let error {
                complete(nil)
                print(error)
            }
            return;
            
        })
    }
    
//    static func log(message:String){
//        let ref = Database.database().reference()
//        let time = getCurrentTime()
//        Auth.auth().signInAnonymously() { (authResult, error) in
//            guard let user = authResult?.user else { return }
//            let isAnonymous = user.isAnonymous  // true
//            let uid = user.uid
//            ref.child("logs").child(uid).child(time).childByAutoId().setValue([
//                "message":message,
//                "time":time
//            ])
//        };
//    }
    
    static func getCurrentTime()->String{
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        print("current time = date:d:\(day) m:\(month) time: \(hour):\(minutes)")
        return "time: \(hour):\(minutes) d:\(day) m:\(month)"
    }
}
