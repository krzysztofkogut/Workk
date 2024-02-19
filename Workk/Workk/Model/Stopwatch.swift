//
//  Stopwatch.swift
//  Workk
//
//  Created by Krzysztof Kogut on 02/01/2024.
//

import Combine
import SwiftUI

class Stopwatch: ObservableObject {
    private var startTime: Date?
    private var accumulatedTime: TimeInterval = 0
    private var timer: Cancellable?
    
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published var hours: Int = 0
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0
    @Published var isPaused: Bool = false
    
    @Published var isRunning = false {
        didSet {
            if isRunning {
                start()
            } else {
                stop()
            }
        }
    }
    
    private func start() -> Void {
        timer?.cancel()
        timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self else {
                return
            }
            
            self.elapsedTime = self.getElapsedTime()
            self.hours = elapsedTime.hours
            self.minutes = elapsedTime.minutes
            self.seconds = elapsedTime.seconds
        }
        startTime = Date()
        isPaused = false
    }
    
    private func stop() -> Void {
        timer?.cancel()
        timer = nil
        accumulatedTime = getElapsedTime()
        startTime = nil
        isPaused = true
    }
    
    func reset() -> Void {
        accumulatedTime = 0
        elapsedTime = 0
        hours = elapsedTime.hours
        minutes = elapsedTime.minutes
        seconds = elapsedTime.seconds
        startTime = nil
        isRunning = false
        isPaused = false
    }
    
    private func getElapsedTime() -> TimeInterval {
        return -(startTime?.timeIntervalSinceNow ?? 0) + accumulatedTime
    }
}
