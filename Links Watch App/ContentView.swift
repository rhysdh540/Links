//
//  ContentView.swift
//  Links Watch App
//
//  Created by Rhys de Haan on 9/22/24.
//

import SwiftUI
import AuthenticationServices

struct ContentView: View {
    var body: some View {
        // hardcoded links for now - duckduckgo.com and apple.com

        let links = [
            Link(title: "DuckDuckGo", url: URL(string: "https://duckduckgo.com")!),
            Link(title: "Apple", url: URL(string: "https://apple.com")!)
        ]

        List(links) { link in
            LinkView(link: link)
        }
                .navigationTitle("Links")
    }
}

struct LinkView: View {
    var link: Link

    var body: some View {
        Button(action: {
            let session = ASWebAuthenticationSession(url: link.url, callbackURLScheme: nil) { _, _ in}
            session.prefersEphemeralWebBrowserSession = true
            session.start()
        }) {
            Text(link.title)
        }
    }
}

#Preview {
    ContentView()
}
