//
//  File.swift
//  Stepik
//
//  Created by Denis Karpenko on 13.05.17.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import Foundation



struct Course{
    let title: String
    let cover: String
    let description: String
    init(title:String,cover:String,description:String){
        self.title = title
        self.cover = cover
        self.description = description
    }
}
