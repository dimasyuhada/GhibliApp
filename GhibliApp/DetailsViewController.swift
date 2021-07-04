//
//  DetailsViewController.swift
//  GhibliApp
//
//  Created by macuser on 02/07/2021.
//

import UIKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var imgPoster: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblDirector: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    
    var detailGhibli: GhibliStats?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imgPoster.image = UIImage(named: "totoro_")
        
        lblTitle.text = detailGhibli?.title
        lblYear.text = detailGhibli?.release_date
        lblDirector.text = detailGhibli?.director
        lblDesc.text = detailGhibli?.description
        
    }
    

}
