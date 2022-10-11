//
//  widget.swift
//  widget
//
//  Created by Richard Shields on 10/8/22.
//

import WidgetKit
import SwiftUI
import Intents
import Framework

extension Data {
    func toString() -> String {
        self.map { String(format: "%c", $0) }.joined()
    }
}

let sampleTree = SpendCraft.CategoryTree([
    SpendCraft.TreeNode(SpendCraft.Group(id: 0, name: "Allowance", type: .regular, categories: [
            SpendCraft.Category(id: 4, groupId: 0, name: "Richard", balance: 100.0, type: .regular, monthlyExpenses: true)
        ])),
    SpendCraft.TreeNode(SpendCraft.Group(id: 1, name: "Food", type: .regular, categories: [
            SpendCraft.Category(id: 7, groupId: 1, name: "Groceries", balance: 385.34, type: .regular, monthlyExpenses: true)
        ])),
    SpendCraft.TreeNode(SpendCraft.Category(id: 11, groupId: -1, name: "Miscellaneous", balance: 787.30, type: .regular, monthlyExpenses: true)),
    SpendCraft.TreeNode(SpendCraft.Category(id: 40, groupId: -1, name: "Leisure", balance: 126.32, type: .regular, monthlyExpenses: true))
])

let sampleCatIds = [4, 7, 11, 40]

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), tree: SpendCraft.CategoryTree(), catIds: sampleCatIds, configuration: ConfigurationIntent())
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        if (context.isPreview) {
            let entry = SimpleEntry(date: Date(), tree: sampleTree, catIds: sampleCatIds, configuration: configuration)
            completion(entry)
        }
        else {
            let tree = readCategoryTree()
            let catIds = SpendCraft.readWatchList()

            let entry = SimpleEntry(date: Date(), tree: tree, catIds: catIds, configuration: configuration)
            completion(entry)
        }
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let tree = readCategoryTree()
        let catIds = SpendCraft.readWatchList()
        
        let currentDate = Date()
        let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let entry = SimpleEntry(date: currentDate, tree: tree, catIds: catIds, configuration: ConfigurationIntent())
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        
        completion(timeline)
    }
    
    func readCategoryTree() -> SpendCraft.CategoryTree {
        let tree = SpendCraft.CategoryTree()
        
        tree.read()
        
        return tree
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let tree: SpendCraft.CategoryTree
    let catIds: [Int]
    let configuration: ConfigurationIntent
}

struct widgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        BudgetView(tree: entry.tree, categories: entry.catIds)
    }
}

struct PlaceHolderView: View {
    var tree: SpendCraft.CategoryTree
    var categories: [Int]

    var body: some View {
        BudgetView(tree: tree, categories: categories)
            .redacted(reason: .placeholder)
    }
}

struct BudgetView: View {
    var tree: SpendCraft.CategoryTree
    let categories: [Int]

    func category(categoryId: Int) -> SpendCraft.Category? {
        tree.getCategory(categoryId: categoryId)
    }
    
    var body: some View {
        if tree.tree.count == 0 {
            Text("No Categories")
        }
        else {
            VStack(alignment: .leading) {
                ForEach(categories, id: \.self) { id in
                    CategoryView(category: category(categoryId: id))
                }
                Spacer()
                Link("Configure", destination: URL(string: "/widget/configure")!)
                    .foregroundColor(Color(uiColor: .link))
            }
            .padding()
        }
    }
}

struct CategoryView: View {
    var category: SpendCraft.Category?
    
    var body: some View {
        if let category = category {
            HStack {
                if let group = category.group {
                    Group {
                        Text("\(group.name)")
                            .padding(.trailing, 0)
                        Text(":")
                            .padding(.leading, 0)
                            .padding(.trailing, 0)
                    }
                }
                Text(category.name)
                Spacer()
                SpendCraft.AmountView(amount: category.balance)
                    .frame(maxWidth: 100, alignment: .trailing)
                    .padding(.trailing, 0)
            }
            .lineLimit(1)
        }
        else {
            Text("Category not found.")
        }
    }
}

@main
struct widget: Widget {
    let kind: String = "app.spendcraft"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            widgetEntryView(entry: entry)
        }
        .configurationDisplayName("SpendCraft")
        .description("Quickly view budget categories you care most about.")
        .supportedFamilies([.systemMedium])
    }
}

struct widget_Previews: PreviewProvider {
    @Environment(\.widgetFamily) var family
    
    static var previews: some View {
        Group {
            widgetEntryView(entry: SimpleEntry(date: Date(), tree: sampleTree, catIds: sampleCatIds, configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            PlaceHolderView(tree: sampleTree, categories: sampleCatIds)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
