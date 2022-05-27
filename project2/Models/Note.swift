//
//  Note.swift
//  project2
//
//  Created by Дмитрий Войтович on 17.04.2022.
//

import Foundation

class Note {
    let id: String
    let title: String
    let text: String
    
    init(id: String, title: String, text: String) {
        self.id = id
        self.title = title
        self.text = text
    }
}
