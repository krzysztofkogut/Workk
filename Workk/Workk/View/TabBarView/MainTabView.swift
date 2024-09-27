//
//  MainTabView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 19/10/2023.
//

import SwiftUI

struct MainTabView: View {
    static let calendar = Calendar(identifier: .iso8601)
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("HOME".uppercased())
                }
            
            ScheduleView(calendar: MainTabView.calendar)
                .background(.wildSand)
                .tabItem {
                    Image(systemName: "chart.bar.doc.horizontal")
                    Text("SCHEDULE".uppercased())
                }
            
            StatsView()
                .background(.wildSand)
                .tabItem {
                    Image(systemName: "chart.bar.xaxis.ascending")
                    Text("STATS".uppercased())
                }
            
            DarkModeWrapper {
                MoreView()
            }
            .tabItem {
                Image(systemName: "ellipsis")
                Text("MORE".uppercased())
            }
        }
        .onAppear() {
            let standardAppearance = UITabBarAppearance()
            standardAppearance.backgroundColor = UIColor(.wildSand)
            standardAppearance.shadowColor = UIColor(.clear)
            
            let itemAppearance = UITabBarItemAppearance()
            itemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Lato-Black", size: 10)!]
            itemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Lato-Bold", size: 10)!]
            itemAppearance.normal.iconColor = UIColor(.aluminium)
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
