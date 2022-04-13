//
//  TransactionTableViewCell.swift
//  ocbc-ios-assessment
//
//  Created by Saiful.Afiq on 12/04/2022.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var transferTypeImageView: UIImageView!
    @IBOutlet weak var recipientNameLabel: UILabel!
    @IBOutlet weak var accountNoLabel: UILabel!
    @IBOutlet weak var transactionAmountLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupTransactionCell(transaction: Transaction) {
        recipientNameLabel.text = transaction.receipient?.accountHolder ?? "N/A"
        accountNoLabel.text = transaction.receipient?.accountNo ?? "N/A"
        
        if transaction.amount >= 0 {
            transactionAmountLabel.textColor = UIColor(red: 107/255, green: 203/255, blue: 119/255, alpha: 1)
        } else {
            transactionAmountLabel.textColor = .red
        }
        
        transactionAmountLabel.text = String(format: "%.2f", transaction.amount)
    }
    
}
