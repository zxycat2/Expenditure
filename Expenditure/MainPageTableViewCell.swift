//
//  MainPageTableViewCell.swift
//  Expenditure
//
//  Created by 周熙岩 on 2019/1/22.
//  Copyright © 2019 DoDo. All rights reserved.
//

import UIKit

class MainPageTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBOutlet weak var detailStringLabel: UILabel!
    
    @IBOutlet weak var expenceNumberLabel: UILabel!
    
    @IBOutlet weak var categoryLabel: UILabel!
}
