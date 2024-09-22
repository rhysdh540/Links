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

struct ContentView: View {
    @State private var links = [Link]()
    @State private var showLinkForm = false
    @State private var linkToEdit: Link? = nil
    @State private var linkFormMode: LinkFormMode = .add

    private let log = Logger(
        subsystem: "dev.rdh.Links-Watch-App",
        category: "ContentView"
    )

    var body: some View {
        NavigationView {
            List {
                ForEach(links) { link in
                    LinkItem(link: link)
                        .swipeActions {
                            Button(action: {
                                linkToEdit = link
                                linkFormMode = .edit
                                DispatchQueue.main.async {
                                    showLinkForm = true
                                }
                            }) {
                                Label("Edit", systemImage: "ellipsis")
                            }
                        }
                }
            }
            .navigationTitle("Links")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        linkFormMode = .add
                        linkToEdit = nil
                        showLinkForm = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showLinkForm) {
                LinkFormView(mode: linkFormMode, link: linkToEdit) { action in
                    handleLinkFormAction(action)
                }
            }
            .onAppear(perform: loadLinks)
        }
    }

    func handleLinkFormAction(_ action: LinkFormAction) {
        switch action {
        case .add(let newLink):
            links.append(newLink)
            log.info("Added link: \(newLink.title) - \(newLink.url)")
            saveLinks()
        case .update(let updatedLink):
            if let index = links.firstIndex(where: { $0.id == updatedLink.id }) {
                links[index] = updatedLink
                log.info("Updated link: \(updatedLink.title) - \(updatedLink.url)")
                saveLinks()
            }
        case .delete(let linkToDelete):
            if let index = links.firstIndex(where: { $0.id == linkToDelete.id }) {
                links.remove(at: index)
                log.info("Deleted link: \(linkToDelete.title) - \(linkToDelete.url)")
                saveLinks()
            }
        case .cancel:
            break
        }
        linkToEdit = nil
        showLinkForm = false
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

struct LinkItem: View {
    var link: Link

    var body: some View {
        Button(action: {
            let session = ASWebAuthenticationSession(url: link.url, callbackURLScheme: nil) { _, _ in }
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
