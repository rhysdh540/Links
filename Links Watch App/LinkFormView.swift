//
//  LinkFormView.swift
//  Links Watch App
//
//  Created by rdh on 9/22/24.
//

import SwiftUI

enum LinkFormMode {
    case add
    case edit
}

enum LinkFormAction {
    case add(Link)
    case update(Link)
    case delete(Link)
    case cancel
}


struct LinkFormView: View {
    @State var title: String
    @State var url: String
    @State private var errorMessage = ""
    @State private var showErrorMessage = false

    let mode: LinkFormMode
    let originalLink: Link?
    let onComplete: (LinkFormAction) -> Void

    init(mode: LinkFormMode, link: Link? = nil, onComplete: @escaping (LinkFormAction) -> Void) {
        self.mode = mode
        self.originalLink = link
        _title = State(initialValue: link?.title ?? "")
        _url = State(initialValue: link?.url.absoluteString ?? "")
        self.onComplete = onComplete
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                TextField("URL", text: $url)

                if mode == .edit {
                    Section {
                        Button(action: deleteLink) {
                            Text("Delete")
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button(action: save) {
                                if mode == .add {
                                    Image(systemName: "plus")
                                } else {
                                    Image(systemName: "pencil")
                                }
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button(action: { onComplete(.cancel) }) {
                                Text("Cancel")
                            }
                        }
                    }
                    .alert(isPresented: $showErrorMessage) {
                        Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                    }
        }
    }

    func save() {
        if url.isEmpty {
            errorMessage = "URL is required"
            showErrorMessage = true
            return
        }

        var formattedURL = url.trimmingCharacters(in: .whitespaces).lowercased()
        if !formattedURL.hasPrefix("http://") && !formattedURL.hasPrefix("https://") {
            formattedURL = "https://\(formattedURL)"
        }

        guard let validURL = URL(string: formattedURL) else {
            errorMessage = "Invalid URL: \(formattedURL)"
            showErrorMessage = true
            return
        }

        let finalTitle: String
        if title.isEmpty {
            if let host = validURL.host {
                var titleComponents = [host]
                if !validURL.path.isEmpty, validURL.path != "/" {
                    titleComponents.append(validURL.path)
                }
                finalTitle = titleComponents.joined()
            } else {
                finalTitle = validURL.absoluteString.replacingOccurrences(of: "\(validURL.scheme!)://", with: "")
            }
        } else {
            finalTitle = title
        }

        if mode == .add {
            let newLink = Link(title: finalTitle, url: validURL)
            onComplete(.add(newLink))
        } else if mode == .edit, let originalLink = originalLink {
            let updatedLink = Link(id: originalLink.id, title: finalTitle, url: validURL)
            onComplete(.update(updatedLink))
        }
    }

    func deleteLink() {
        if let originalLink = originalLink {
            onComplete(.delete(originalLink))
        } else {
            onComplete(.cancel)
        }
    }
}

