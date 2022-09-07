//
//  VideoPlayerApp.swift
//  
//
//  Created by Abdullah Kardas on 25.06.2022.
//

import SwiftUI
import AVFoundation

@main
struct VideoPlayerApp: App {
    @State var isFullScreen:Bool = false
    
    var body: some Scene {
        WindowGroup {
            VideoPlayerView(url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                            width: 400,
                            height: 300,
                            radius: 12,
                            enableFullScreen: $isFullScreen)
            .padding(isFullScreen ? 0:16)
               
        }
    }
}
