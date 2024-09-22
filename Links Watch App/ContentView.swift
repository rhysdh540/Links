//
//  ContentView.swift
//  Links Watch App
//
//  Created by Rhys de Haan on 9/22/24.
//

import Foundation
import SwiftUI
import AuthenticationServices
import os.log

struct Link: Identifiable, Codable {
    init(title: String, url: URL) {
        self.id = UUID()
        self.title = title
        self.url = url
    }
    
    let id: UUID
    var title: String
    var url: URL
}

struct ContentView: View {
    @State private var links = [Link]()
    @State private var showAddPopup = false

    private let log = Logger(
        subsystem: "dev.rdh.Links-Watch-App",
        category: "ContentView"
    )

    var body: some View {
        NavigationView {
            List {
                ForEach(links) { link in
                    LinkItem(link: link)
                }
            }
            .navigationTitle("Links")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { showAddPopup = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddPopup) {
                AddLinkView { title, url in
                    let newLink = Link(title: title, url: url)
                    links.append(newLink)
                    showAddPopup = false
                    log.info("Added link: \(title) - \(url)")
                    saveLinks()
                }
            }
            .onAppear(perform: loadLinks)
        }
    }

    func saveLinks() {
        do {
            let data = try JSONEncoder().encode(links)
            UserDefaults.group.set(data, forKey: "links")
            log.info("Saved \(links.count) links")
        } catch {
            log.error("Failed to save links: \(error)")
        }
    }

    func loadLinks() {
        if let data = UserDefaults.group.data(forKey: "links") {
            do {
                links = try JSONDecoder().decode([Link].self, from: data)
                log.info("Loaded \(links.count) links")
            } catch {
                log.error("Failed to load links: \(error)")
            }
        }
    }
}

struct AddLinkView: View {
    @State private var title = ""
    @State private var url = ""
    @State private var errorMessage = ""
    @State private var showErrorMessage = false
    let onAdd: (String, URL) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                TextField("URL", text: $url)
            }
            .navigationTitle("Add Link")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: go) {
                        Image(systemName: "plus")
                    }
                }
            }.alert(isPresented: $showErrorMessage) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    func go() {
        if url.isEmpty {
            errorMessage = "URL is required"
            showErrorMessage = true
        } else {
            // Use URL as title if title is empty
            // Do this before adding http:// or https:// to the URL
            if title.isEmpty {
                title = url
            }

            if !url.hasPrefix("http://") && !url.hasPrefix("https://") {
                url = "https://\(url)"
            }

            if let url = URL(string: url) {
                onAdd(title, url)
            } else {
                errorMessage = "Invalid URL: \(url)"
                showErrorMessage = true
            }
        }
    }
}

struct LinkItem: View {
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
