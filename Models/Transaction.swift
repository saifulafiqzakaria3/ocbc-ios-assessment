//
//  Transaction.swift
//  ocbc-ios-assessment
//
//  Created by Saiful.Afiq on 12/04/2022.
//

import Foundation

struct TransactionResponse: Decodable {
    let status: String?
    let data: [Transaction]?
}

struct Transaction: Decodable {
    var transactionId: String
    var amount: Double
    var transactionDate: String?
    var description: String?
    var transactionType: String?
    var receipient: Account?
}

struct Account: Decodable {
    var accountNo: String?
    var accountHolder: String?
}

struct Balance: Decodable {
    var status: String?
    var accountNo: String?
    var balance: Double?
}

struct PayeeResponse: Decodable {
    let status: String?
    let data: [Payee]?
}

struct Payee: Decodable {
    var id: String
    var name: String?
    var accountNo: String?
}




