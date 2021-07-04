//
//  GhibliTableViewCell.swift
//  GhibliApp
//
//  Created by macuser on 29/06/2021.
//

import UIKit

class GhibliTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgMovie: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDirector: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    
    static let identifier = "GhibliTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "GhibliTableViewCell", bundle: nil)
    }
    
    func configure(with model: GhibliStats){
        self.lblTitle.text = model.title
        self.lblDirector.text = model.director
        self.lblYear.text = model.release_date
        self.imgMovie.image = UIImage(named: "poster_")
    }
    
    
    
}
