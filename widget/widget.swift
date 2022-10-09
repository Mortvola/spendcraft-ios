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

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), tree: SpendCraft.CategoryTree(), configuration: ConfigurationIntent())
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), tree: SpendCraft.CategoryTree(), configuration: configuration)
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let tree = readContents()
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let date = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: date, tree: tree, configuration: ConfigurationIntent())
//            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    func readContents() -> SpendCraft.CategoryTree {
        let tree = SpendCraft.CategoryTree()
        
        tree.read()
        
        return tree
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let tree: SpendCraft.CategoryTree
    let configuration: ConfigurationIntent
}

struct widgetEntryView : View {
    var entry: Provider.Entry

    func category(categoryId: Int) -> SpendCraft.Category? {
        entry.tree.getCategory(categoryId: categoryId)
    }

    var body: some View {
        if entry.tree.tree.count == 0 {
            Text("No Categories")
        }
        else {
            VStack {
                CategoryView(category: category(categoryId: 7))
                CategoryView(category: category(categoryId: 5))
            }
        }
    }
}

struct CategoryView: View {
    var category: SpendCraft.Category?
    
    var body: some View {
        if let category = category {
            HStack {
                Text("\(category.name):")
                SpendCraft.AmountView(amount: category.balance)
            }
        }
        else {
            Text("Category not found.")
        }
    }
}

@main
struct widget: Widget {
    let kind: String = "SpendCraft"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            widgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct widget_Previews: PreviewProvider {
    static var previews: some View {
        widgetEntryView(entry: SimpleEntry(date: Date(), tree: SpendCraft.CategoryTree(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
