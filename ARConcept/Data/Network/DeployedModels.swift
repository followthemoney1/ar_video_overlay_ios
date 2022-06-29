//
//  DeployedModels.swift
//  ARConcept
//
//  Created by Dmitry Dyachenko on 12/11/20.
//

import Foundation

public struct DeployedModels: Codable {
    let dataset_id:String?
    let last_updated:Int?
    let model_name:String?
 
    enum CodingKeys: String, CodingKey {
        case dataset_id
        case last_updated
        case model_name
    }

}

