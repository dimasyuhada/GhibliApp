//
//  Ghibli.swift
//  GhibliApp
//
//  Created by macuser on 29/06/2021.
//

import Foundation

struct GhibliStats: Decodable {
    var title: String = ""
    var release_date: String = ""
    var director: String = ""
    var description: String = ""
    
    private enum getKeys: String, CodingKey{
        case title, release_date, director, description
    }
}

