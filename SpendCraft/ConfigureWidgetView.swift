//
//  ConfigureWidgetView.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/10/22.
//

import SwiftUI
import WidgetKit
import Framework

struct Cat: Identifiable, Hashable {
    var uuid: UUID
    var id: Int?
    
    init(id: Int) {
        self.uuid = UUID()
        self.id = id
    }
}

class CatList: ObservableObject {
    @Published var categories: [Cat] = []
    
    init() {
        self.categories = []
    }
}

struct ConfigureWidgetView: View {
    @Binding var isConfiguringWidget: Bool
    @ObservedObject var categories: CatList
    @State var selection: Int? = nil
    let watchedFile = "watched.json"
    
    func save() {
        let cats: [Int] = categories.categories.compactMap {
            $0.id
        }

        if let data = try? JSONEncoder().encode(cats) {
            do {
                let archiveURL = FileManager.sharedContainerURL()
                    .appendingPathComponent(watchedFile)

                try data.write(to: archiveURL)
            } catch {
                print("Error: Can't write \(watchedFile)")
            }
        }
        
        WidgetCenter.shared.reloadTimelines(ofKind: "app.spendcraft")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                ControlGroup {
                    Text("Select up to four categories to view in the SpendCraft widget. \(categories.categories.count)")
                }
                List {
                    ForEach($categories.categories, id: \.uuid) { $cat in
                        CategoryPicker(selection: $cat.id)
                    }
                    .onDelete { indices in
                        categories.categories.remove(atOffsets: indices)
                    }
                    
                    if (categories.categories.count < 4) {
                        CategoryPicker(selection: $selection)
                            .onChange(of: selection) { s in
                                if let s = s {
                                    categories.categories.append(Cat(id: s))
                                    selection = nil
                                }
                            }
                    }
                }
            }
            .navigationTitle("Widget Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isConfiguringWidget = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isConfiguringWidget = false;
                        save()
                    }
                }
            }
        }
    }
}

struct ConfigureWidgetView_Previews: PreviewProvider {
    static let isConfiguringWidget = true
    static let categories = CatList()

    static var previews: some View {
        ConfigureWidgetView(isConfiguringWidget: .constant(isConfiguringWidget), categories: categories)
    }
}
