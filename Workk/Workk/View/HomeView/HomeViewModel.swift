//
//  HomeViewModel.swift
//  Workk
//
//  Created by Krzysztof Kogut on 05/11/2023.
//

import Combine
import Foundation

protocol HomeViewModelProtocol where Self: ObservableObject {
    var selectedFilter: PeriodFilter { get set }
    var currentTime: Time { get set }
    var timeReciver: Publishers.Autoconnect<Timer.TimerPublisher> { get set }
    var currentDateString: String { get }
    
    func updateCurrentTime()
}

final class HomeViewModel: HomeViewModelProtocol {
    @Published var selectedFilter: PeriodFilter = .day
    @Published var currentTime = Time(hour: 0, min: 0, sec: 0)
    @Published var timeReciver = Timer.publish(every: 1, on: .current, in: .default).autoconnect()
    @Published var stopwatch: Stopwatch = Stopwatch()
    
    private let router: HomeRouter
    
    private let fullFormatter = DateFormatter(dateFormat: "dd MMMM, yyyy", calendar: Calendar.current)
    private var workTimeInSeconds: Int = 0

    var currentDateString: String {
        fullFormatter.string(from: Date())
    }
    
    init(router: HomeRouter) {
        self.router = router
    }
    
    func updateCurrentTime() {
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: Date())
        let min = calendar.component(.minute, from: Date())
        let sec = calendar.component(.second, from: Date())
        
        currentTime = Time(hour: hour, min: min, sec: sec)
    }
    
    func showSubscriptionPlan() {
        router.showSubscriptionPlan()
    }
}
