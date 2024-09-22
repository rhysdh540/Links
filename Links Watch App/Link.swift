//
//  Link.swift
//  Links Watch App
//
//  Created by Rhys de Haan on 9/22/24.
//

import Foundation

struct Link: Identifiable, Codable {
    init(id: UUID, title: String, url: URL) {
        self.id = id
        self.title = title
        self.url = url
    }
    
    init(title: String, url: URL) {
        self.init(id: UUID(), title: title, url: url)
    }
    
    let id: UUID
    var title: String
    var url: URL
}
