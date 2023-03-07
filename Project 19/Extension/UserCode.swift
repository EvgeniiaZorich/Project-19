//
//  UserCode.swift
//  Extension
//
//  Created by Евгения Зорич on 07.03.2023.
//

import Foundation

class UserCode: Codable {
    var name: String
    var code: String
    
    init(name: String, code: String) {
        self.name = name
        self.code = code
    }
}
