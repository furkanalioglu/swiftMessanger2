//
//  GroupEventModel.swift
//  swiftMessanger
//
//  Created by Furkan Alioglu on 15.08.2023.
//

import Foundation

struct GroupEventModel : Codable, Equatable {
    let userId : Int
    var itemCount : Int
    let groupId: Int
}

extension GroupEventModel{
    static func == (lhs: GroupEventModel, rhs: GroupEventModel) -> Bool {
        return lhs.userId == rhs.userId
    }
}