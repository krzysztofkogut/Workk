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
                    Text(Date(timeInterval: Date().timeIntervalSinceNow, since: context.state.workTime), style: .timer)
                        .font(.latoRegular(size: 14))
                        .foregroundColor(.gray)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
//                DynamicIslandExpandedRegion(.bottom) {
//                    Text("Bottom \(context.state.emoji)")
//                    // more content
//                }
            } compactLeading: {
                Text(Date(timeInterval: Date().timeIntervalSinceNow, since: context.state.workTime), style: .timer)
                    .font(.latoRegular(size: 14))
                    .foregroundColor(.gray)
            } compactTrailing: {
                Text("Work time")
            } minimal: {
                Text(Date(timeInterval: Date().timeIntervalSinceNow, since: context.state.workTime), style: .timer)
                    .font(.latoRegular(size: 14))
                    .foregroundColor(.gray)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}
