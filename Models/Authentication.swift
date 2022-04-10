//
//  Authentication.swift
//  ocbc-ios-assessment
//
//  Created by Saiful.Afiq on 10/04/2022.
//

import Foundation

struct AuthenticationResponse: Decodable {
    var status: String
    var token: String
    var username: String?
    var accountNo: String?
}



