//
//  WorkTimeStatusLiveActivity.swift
//  WorkTimeStatus
//
//  Created by Krzysztof Kogut on 11/12/2023.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct WorkTimeActivityView: View {
    let context: ActivityViewContext<WorkTimeStatusAttributes>
    
    var body: some View {
        VStack {
            Text(context.attributes.workName)
                .font(.latoBold(size: 18))
            
            Text(Date(timeInterval: Date().timeIntervalSinceNow, since: context.state.workTime), style: .timer)
                .font(.latoRegular(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
    }
}

struct WorkTimeStatusLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkTimeStatusAttributes.self) { context in
            // Lock screen/banner UI goes here
            WorkTimeActivityView(context: context)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                        Text("Work time")
                            .font(.caption)
                        
                        Text(Date(timeInterval: Date().timeIntervalSinceNow, since: context.state.workTime), style: .timer)
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 6)
                    .multilineTextAlignment(.leading)
                }
                DynamicIslandExpandedRegion(.center) {
                    // This App Don't Require Any Content on Center
                    // But You Can use it in your App
                    HStack {
                        Button {
                            print("test")
                        } label: {
                            Image(systemName: "pause.fill")
                                .frame(width: 24, height: 24)
                        }
                        
                        Button {
                            print("test")
                        } label: {
                            Image(systemName: "stop.fill")
                                .frame(width: 24, height: 24)
                        }
                    }
                    .foregroundColor(.gray)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Spacer()
                    Text(context.attributes.workName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                    Spacer()
                }
            } compactLeading: {
                Text(Date(timeInterval: Date().timeIntervalSinceNow, since: context.state.workTime), style: .timer)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: 50)
                    .minimumScaleFactor(0.7)
            } compactTrailing: {
                Text(context.attributes.workName)
                    .font(.subheadline)
                    .frame(maxWidth: 50)
                    .minimumScaleFactor(0.8)
            } minimal: {
                Text(Date(timeInterval: Date().timeIntervalSinceNow, since: context.state.workTime), style: .timer)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .keylineTint(Color.red)
        }
    }
}
