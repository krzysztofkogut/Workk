//
//  HomeView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 22/10/2023.
//

import Resolver
import SwiftUI

struct HomeView: View {
    @State var progressValue: CGFloat = 0
    @State private var timeReciver = Timer.publish(every: 1, on: .current, in: .default).autoconnect()
    @State private var showSubscriptionPlan = false
    @State private var countWorkTime = false
    @State private var pauseTimer = false
    @State private var toggleDynamicIsland: Bool = true
    @State var selection: String? = nil
    @ObservedObject private var appRouter: AppRouter = Resolver.resolve()
    @ObservedObject private var viewModel: HomeViewModel = Resolver.resolve()
    
    var body: some View {
        NavigationStack(path: $appRouter.path) {
            VStack(spacing: 0) {
                HStack {
                    DropDownPicker(selection: $selection, hint: "Select", options: ["DAZN"])
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .zIndex(1000)
                
                headerActionsView
                    .padding(.top, 16)
                                
                Spacer()
                
                detailsView
                    .ignoresSafeArea()
            }
            .onAppear(perform: {
                withAnimation(.linear(duration: 0.01)) {
                    self.viewModel.updateCurrentTime()
                    if countWorkTime, !pauseTimer {
                        self.viewModel.incrementWorkTimeInSeconds()
                    }
                }
                
                self.progressValue = 0.9
            })
            .onReceive(timeReciver) { _ in
                withAnimation(Animation.linear(duration: 0.01)) {
                    self.viewModel.updateCurrentTime()
                    if countWorkTime, !pauseTimer {
                        self.viewModel.incrementWorkTimeInSeconds()
                    }
                }
            }
            .withHomeRoutes()
            .fullScreenCover(isPresented: $showSubscriptionPlan) {
                SubscriptionPlanView()
            }
        }
    }
}

extension HomeView {
    var headerActionsView: some View {
        VStack(alignment: .center) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(countWorkTime ? viewModel.workTime.hourMinString : viewModel.currentTime.hourMinString)
                    .font(.latoBold(size: 56))
                    .padding(.leading, 24)
                Text(countWorkTime ? viewModel.workTime.secString : viewModel.currentTime.secString)
                    .font(.latoLight(size: 16))
            }
            .transition(.opacity)
            
            Text(viewModel.currentDateString)
                .font(.latoRegular(size: 16))
                .padding(.bottom, 16)
            
            addWorkTimeButtons
            
            //            periodCircleFilterBar
        }
        .background(.white)
        .padding(.bottom, 16)
    }
    
    var addWorkTimeButtons: some View {
        HStack {
            Button {
                if countWorkTime {
                    pauseTimer.toggle()
                } else {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        countWorkTime.toggle()
                    }
                }
            } label: {
                Text(countWorkTime ? (pauseTimer ? "Start" : "Stop") : "Start timer")
                    .frame(width: countWorkTime ? 80 : 120, height: 44)
            }
            .modifier(FilledButton())
            .background(.black)
            .cornerRadius(6)
            
            if countWorkTime {
                Button {
                    UIApplication.shared.inAppNotification(adaptForDynamicIsland: toggleDynamicIsland, timeout: 4, swipeToClose: true) { isDynamicIslandEnabled in
                        HStack {
                            VStack(alignment: .leading, spacing: 2, content: {
                                Text("Saved your work time")
                                    .font(.latoBold(size: 18))
                                    .foregroundStyle(.white)
                                
                                Text(viewModel.currentDateString)
                                    .font(.latoRegular(size: 14))
                                    .foregroundStyle(.gray)
                            })
                            .padding(.top, isDynamicIslandEnabled ? 20 : 0)
                            
                            Spacer(minLength: 0)
                            
                            Text(viewModel.workTime.timeString)
                                .font(.latoBold(size: 22))
                                .foregroundStyle(.gray)
                                .padding(.top, isDynamicIslandEnabled ? 20 : 0)
                        }
                        .padding(.horizontal, 36)
                        .padding(.vertical, 16)
                        .background {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.black)
                        }
                    }
                    
                    withAnimation(.easeInOut(duration: 0.6)) {
                        viewModel.resetWorkTimeInSeconds()
                        countWorkTime = false
                        pauseTimer = false
                    }
                } label : {
                    Text("Save")
                        .frame(width: 80, height: 44)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(.cranberry, lineWidth: 4)
                }
                .modifier(BorderedRoundedButton())
                .cornerRadius(6)
            }
            
            Button {
                if countWorkTime {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        viewModel.resetWorkTimeInSeconds()
                        countWorkTime = false
                        pauseTimer = false
                    }
                } else {
                    showSubscriptionPlan.toggle()
                }
            } label: {
                Text(countWorkTime ? "Reset" : "Save time")
                    .frame(width: countWorkTime ? 80 : 120, height: 44)
            }
            .modifier(BorderedRoundedButton())
            .overlay {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.persianBlue, lineWidth: 4)
            }
            .cornerRadius(6)
        }
    }
    
    var periodCircleFilterBar: some View {
        HStack(spacing: 16) {
            ForEach(PeriodFilter.allCases, id: \.rawValue) { item in
                VStack {
                    Text(item.title)
                        .font(FontManager.smallBodyBold)
                        .foregroundColor(viewModel.selectedFilter == item ? .white : .black)
                        .padding(.horizontal, 12)
                        .background (
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(viewModel.selectedFilter == item ? .cranberry : .white)
                                .frame(height: 24)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.selectedFilter == item ? .clear : .black, lineWidth: 1)
                                .frame(height: 24)
                        }
                }
                .onTapGesture {
                    withAnimation(.easeOut) {
                        self.viewModel.selectedFilter = item
                    }
                }
            }
        }
        .padding(.top, 24)
    }
    
    var detailsView: some View {
        VStack(spacing: 0) {
            periodFilterBar
            
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.selectedFilter.statsTitle + " you earned")
                            .font(.latoBold(size: 16))
                        
                        Text("23 November, 2023")
                            .font(.latoRegular(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(16)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Paid")
                            .font(.nunitoSemiBold(size: 16))
                        Spacer()
                        Text("120 PLN")
                            .font(.latoBold(size: 18))
                    }
                    
                    HStack {
                        Text("Unpaid")
                            .font(.nunitoSemiBold(size: 16))
                        Spacer()
                        Text("250 PLN")
                            .font(.latoBold(size: 18))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(.white)
            .cornerRadius(12)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            
            VStack {
                HStack {
                    Text(viewModel.selectedFilter.statsTitle + " you worked")
                        .font(.latoBold(size: 16))
                    Spacer()
                    Text("36h / 40h")
                        .font(.latoRegular(size: 16))
                }
                .padding(16)
                
                ProgressBar(percent: $progressValue)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                
                HStack(spacing: 6) {
                    Text("Plan done in:")
                        .font(.latoRegular(size: 16))
                        .foregroundColor(.gray)
                    Text(String(format: "%0.f", self.progressValue * 100) + "%")
                        .font(.nunitoSemiBold(size: 16))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 2)
                
                HStack(spacing: 6) {
                    Text("Left to be done:")
                        .font(.latoRegular(size: 16))
                        .foregroundColor(.gray)
                    Text("4h")
                        .font(.nunitoSemiBold(size: 16))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(.white)
            .cornerRadius(12)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            
            Spacer()
        }
        .background(.wildSand)
        .clipShape(RoundedShape(corners: [.topLeft, .topRight]))
    }
    
    var periodFilterBar: some View {
        HStack {
            ForEach(PeriodFilter.allCases, id: \.rawValue) { item in
                VStack {
                    Text(item.title)
                        .font(viewModel.selectedFilter == item ? .latoBold(size: 16) : .latoRegular(size: 16))
                        .foregroundColor(viewModel.selectedFilter == item ? .black : .gray)
                    
                    if viewModel.selectedFilter == item {
                        Rectangle()
                            .frame(height: 2)
                            .cornerRadius(3)
                            .foregroundColor(.persianBlue)
                    } else {
                        Rectangle()
                            .frame(height: 2)
                            .cornerRadius(3)
                            .foregroundColor(.clear)
                    }
                }
                .padding()
                .onTapGesture {
                    withAnimation(.easeOut) {
                        self.viewModel.selectedFilter = item
                    }
                }
            }
        }
        .padding(.top, 8)
        .padding(.horizontal, 8)
    }
}

#Preview {
    HomeView()
}
