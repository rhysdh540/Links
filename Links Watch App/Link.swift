//
//  Link.swift
//  Links Watch App
//
//  Created by Rhys de Haan on 9/22/24.
//

import Foundation

struct Link: Identifiable {
    var id = UUID()
    var title: String
    var url: URL
}