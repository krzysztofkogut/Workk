//
//  MainTabView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 19/10/2023.
//

import SwiftUI

struct MainTabView: View {
    static let calendar = Calendar(identifier: .iso8601)
    @State var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(0)
                .tabItem {
                    if #available(iOS 17.0, *) {
                        Image(systemName: "house.fill")
                            .symbolEffect(.bounce.byLayer.down, value: selectedTab == 0)
                            .animation(.easeInOut, value: selectedTab)
                    } else {
                        Image(systemName: "house.fill")
                    }
                    Text("HOME".uppercased())
                }
            
            ScheduleView(calendar: MainTabView.calendar)
                .background(.wildSand)
                .tag(1)
                .tabItem {
                    Image(systemName: "chart.bar.doc.horizontal")
                    Text("SCHEDULE".uppercased())
                }
            
            StatsView()
                .background(.wildSand)
                .tag(2)
                .tabItem {
                    Image(systemName: "chart.bar.xaxis.ascending")
                    Text("STATS".uppercased())
                }
            
            DarkModeWrapper {
                MoreView()
            }
            .tag(3)
            .tabItem {
                Image(systemName: "ellipsis")
                Text("MORE".uppercased())
            }
        }
        .onAppear {
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
