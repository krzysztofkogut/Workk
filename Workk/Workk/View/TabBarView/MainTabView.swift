//
//  MainTabView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 19/10/2023.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("Home")
                }
            
            ScheduleView(calendar: Calendar.current)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Schedule")
                }
            
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Stats")
                }
            
            DarkModeWrapper {
                MoreView()
            }
            .tabItem {
                Image(systemName: "ellipsis")
                Text("More")
            }
        }
        .onAppear() {
            let standardAppearance = UITabBarAppearance()
            standardAppearance.backgroundColor = UIColor(.wildSand)
            standardAppearance.shadowColor = UIColor(.clear)
            
            let itemAppearance = UITabBarItemAppearance()
            itemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Lato-Bold", size: 12)!]
            itemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Lato-Regular", size: 12)!]
            itemAppearance.normal.iconColor = UIColor(.gray)
            itemAppearance.selected.iconColor = UIColor(.black)
            standardAppearance.inlineLayoutAppearance = itemAppearance
            standardAppearance.stackedLayoutAppearance = itemAppearance
            standardAppearance.compactInlineLayoutAppearance = itemAppearance
            UITabBar.appearance().standardAppearance = standardAppearance
        }
        .accentColor(Color.black)
    }
}

#Preview {
    MainTabView()
}
