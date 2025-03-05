//
//  MainTabView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 19/10/2023.
//

import Resolver
import SwiftUI

struct MainTabView: View {
    @AppStorage("hasShownGoalsView") private var hasShownGoalsView: Bool = false
    
    @State private var showGoalsView: Bool = false
    @State private var showSubscriptionPlanView: Bool = false
    @State var selectedTab: Int = 0
    
    @StateObject private var adManager: InterstitialAdManager = Resolver.resolve()
    @StateObject private var userSubscriptionViewModel: UserSubscriptionViewModel = Resolver.resolve()
    
    @FetchRequest(
        entity: Work.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Work.startDate, ascending: true)]
    ) private var works: FetchedResults<Work>
    
    static let calendar = Calendar(identifier: .iso8601)
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .background(.wildSand)
                .tag(0)
                .tabItem {
                    Image(systemName: "timer.circle.fill")
                    Text("home_tab_title".localized)
                }
            
            ScheduleView(calendar: MainTabView.calendar)
                .background(.wildSand)
                .tag(1)
                .tabItem {
                    Image(systemName: "chart.bar.doc.horizontal")
                    Text("schedule_tab_title".localized)
                }
            
            StatsView()
                .background(.wildSand)
                .tag(2)
                .tabItem {
                    Image(systemName: "chart.bar.xaxis.ascending")
                    Text("stats_tab_title".localized)
                }
            
            MoreView()
                .background(.wildSand)
                .tag(3)
                .tabItem {
                    Image(systemName: "ellipsis")
                    Text("more_tab_title".localized)
                }
        }
        .fullScreenCover(isPresented: $showGoalsView, onDismiss: {
            hasShownGoalsView = true
            if UserDefaults.canShowSubscriptionPlan(), !userSubscriptionViewModel.subscriptionActive {
                showSubscriptionPlanView = true
            }
        }, content: {
            GoalsView()
        })
        .fullScreenCover(isPresented: $showSubscriptionPlanView, onDismiss: {
            UserDefaults.updateSubscriptionShownDate()
        }, content: {
            SubscriptionPlanView()
        })
        .onAppear {
            if !userSubscriptionViewModel.subscriptionActive {
                Task {
                    await adManager.loadAd()
                }
            }
            
            showGoalsView = !hasShownGoalsView
            
            if UserDefaults.canShowSubscriptionPlan(), !userSubscriptionViewModel.subscriptionActive, hasShownGoalsView {
                showSubscriptionPlanView = true
            }
            
            let standardAppearance = UITabBarAppearance()
            standardAppearance.backgroundColor = UIColor(.wildSand)
            standardAppearance.shadowColor = UIColor(.clear)
            
            let itemAppearance = UITabBarItemAppearance()
            itemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Lato-Black", size: 11)!]
            itemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Lato-Bold", size: 11)!]
            itemAppearance.normal.iconColor = UIColor(.gray)
            itemAppearance.selected.iconColor = UIColor(.blackWhite)
            standardAppearance.inlineLayoutAppearance = itemAppearance
            standardAppearance.stackedLayoutAppearance = itemAppearance
            standardAppearance.compactInlineLayoutAppearance = itemAppearance
            
            UITabBar.appearance().standardAppearance = standardAppearance
        }
        .onChange(of: selectedTab) { 
            if UserDefaults.canShowFullScreenAd(), !userSubscriptionViewModel.subscriptionActive {
                showAd()
            }
        }
        .accentColor(.blackWhite)
    }
}

extension MainTabView {
    private func showAd() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let topViewController = UIApplication.shared.getTopViewController() else {
                print("Unable to get top view controller.")
                return
            }
            
            adManager.showAd(from: topViewController)
            UserDefaults.updateFullScreenAdShownDate()
        }
    }
}
