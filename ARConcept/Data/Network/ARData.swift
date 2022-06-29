//
//  ARData.swift
//  ARConcept
//
//  Created by Dmitry Dyachenko on 11/13/20.
//

import Foundation

struct ARData:Codable,Hashable{
    var img: String!
    var isYoutubeVideo: Bool!
    var directYoutubeUrl: String?
    var directVideoUrl: String?
    var name:String!
    var downloadVideoUrl: URL?
    var keyName: String?
    var downloadUrlFile: String?
    //MARK:additional
    var created_at: Int?
    var facebook: String?
    var group: String?
    var instagram: String?
    var labelName: String?
    var phone: String?
    var role: String?
    var website: String?
}
