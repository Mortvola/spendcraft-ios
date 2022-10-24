//
//  PlansView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import SwiftUI
import Framework

struct PlansView: View {
    @ObservedObject private var planStore = PlanStore.shared
    @ObservedObject private var categoriesStore = CategoriesStore.shared
    @State var selection: SpendCraft.Category?
    @State var planSelection: Response.PlanCategory?
    
    var body: some View {
        NavigationSplitView {
            VStack {
                if planStore.loaded {
                    List(selection: $selection) {
                        Section(header: Text("My Categories")) {
                            ForEach(categoriesStore.tree) { node in
                                switch node {
                                case .category(let category):
                                    PlanCategoryView(category: category, planCategory: planStore.planCategory(category))
                                case .group(let group):
                                    if (group.type != GroupType.system) {
                                        PlanGroupView(group: group)
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                    ProgressView()
                    Spacer()
                }
                HStack {
                    Text("Total")
                    Spacer()
                    SpendCraft.AmountView(amount: planStore.plan?.total ?? 0.0)
                }
                .padding([.leading, .trailing, .bottom])
            }
            .navigationTitle("Plans")
            .refreshable {
                planStore.load()
            }
            .onAppear {
                if !planStore.loaded {
                    planStore.load()
                }
            }
        } detail: {
            List {
                if let category = selection, let planCategory = planStore.planCategory(category) {
                    PlanItemView(category: category, planCategory: planCategory)
                }
            }
            .listStyle(.plain)
        }
    }
}

struct PlansView_Previews: PreviewProvider {
    static var previews: some View {
        PlansView()
    }
}
