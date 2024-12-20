//
//  MainTabView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 19/10/2023.
//

import SwiftUI

struct MainTabView: View {
    @State private var showSubscriptionPlanView: Bool = false
    
    @State var selectedTab: Int = 0
    static let calendar = Calendar(identifier: .iso8601)
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .background(.wildSand)
                .tag(0)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            ScheduleView(calendar: MainTabView.calendar)
                .background(.wildSand)
                .tag(1)
                .tabItem {
                    Image(systemName: "chart.bar.doc.horizontal")
                    Text("Schedule")
                }
            
            StatsView()
                .background(.wildSand)
                .tag(2)
                .tabItem {
                    Image(systemName: "chart.bar.xaxis.ascending")
                    Text("Stats")
                }
            
            DarkModeWrapper {
                MoreView()
            }
            .background(.wildSand)
            .tag(3)
            .tabItem {
                Image(systemName: "ellipsis")
                Text("More")
            }
        }
        .fullScreenCover(isPresented: $showSubscriptionPlanView, onDismiss: {
            UserDefaults.updateSubscriptionShownDate()
        }, content: {
            SubscriptionPlanView()
        })
        .onAppear {
            if UserDefaults.canShowSubscriptionPlan() {
                showSubscriptionPlanView = true
            }
            
            let standardAppearance = UITabBarAppearance()
            standardAppearance.backgroundColor = UIColor(.wildSand)
            standardAppearance.shadowColor = UIColor(.clear)
            
            let itemAppearance = UITabBarItemAppearance()
            itemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Lato-Black", size: 11)!]
            itemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Lato-Bold", size: 11)!]
            itemAppearance.normal.iconColor = UIColor(.aluminium)
            itemAppearance.selected.iconColor = UIColor(.blackTheme)
            standardAppearance.inlineLayoutAppearance = itemAppearance
            standardAppearance.stackedLayoutAppearance = itemAppearance
            standardAppearance.compactInlineLayoutAppearance = itemAppearance
            
            UITabBar.appearance().standardAppearance = standardAppearance
        }
        .accentColor(.blackTheme)
    }
}

#Preview {
    MainTabView()
}
