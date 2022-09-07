//
//  VideoPlayerView.swift
//
//  Created by Abdullah Kardas on 3.09.2022.
//

import SwiftUI
import VideoPlayer
import AVFoundation


struct VideoPlayerView: View {
    
    @State private var autoReplay: Bool = true
    @State private var mute: Bool = false
    @State private var play: Bool = true
    @State private var totalDuration:Double = 0
    @State private var currentDuration:Double = 0.0001
    @State private var time:CMTime = .zero
    
    @State private var showUI = false
    @State private var showLoading = false
    let url:String
    let width:CGFloat
    let height:CGFloat
    let radius:CGFloat
    @State private var orientation = UIDeviceOrientation.unknown
    @Binding var enableFullScreen:Bool
    

    
    var body: some View {
        //https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4
        GeometryReader { proxy in
            ZStack(alignment:.center) {
                Color(hex: "#36244f").ignoresSafeArea()
              
                
                VideoPlayer(url: URL(string: url)!, play: $play, time: $time)
                          .autoReplay(autoReplay)
                          .mute(mute)
                          
                          .onBufferChanged { progress in
                              // Network loading buffer progress changed
                             // print("****\(progress)")
                          }
                          .onPlayToEndTime {
                              showUI = true
                              // Play to the end time.
                          }
                          .onReplay {
                              // Replay after playing to the end.
                          }
                          .onStateChanged { state in
                              switch state {
                              case .loading:
                                  showLoading = true
                                  // Loading...
                                  print("Loading")
                              case .playing(let totDuration):
                                  showLoading = false
                                  totalDuration = totDuration
                                  currentDuration = time.seconds
                                  print("Playing \(totDuration)")
                                  // Playing...
                              case .paused(let playProgress, let bufferProgress):
                                  print("Paused \(playProgress)")
                                  showUI = true
                                  // Paused...
                              case .error(let error):
                                  print("Error")
                                  // Error...
                              }
                          }

                    
                    .overlay(
                        ZStack {
                           // Spacer()
                         
                            HStack{
                                Spacer()
                                HStack {
                                    Image(systemName: "gobackward.5")
                                        .font(.largeTitle)
                                        .scaleEffect(1).foregroundColor(.white)
                                        .onTapWithBounce {
                                            time = CMTimeMakeWithSeconds(min(totalDuration, time.seconds - 5), preferredTimescale: time.timescale)
                                    }
                                }
                                Spacer()
                                Image(systemName: play ? "pause.fill":"play.fill").font(.largeTitle).scaleEffect(1.7).foregroundColor(.white)
                                    .onTapGesture {
                                        play.toggle()
                                    }.animation(.default, value: play)
                                Spacer()
                                HStack {
                                    Image(systemName: "goforward.5")
                                        .font(.largeTitle)
                                        .scaleEffect(1).foregroundColor(.white)
                                        .onTapWithBounce {
                                            time = CMTimeMakeWithSeconds(min(totalDuration, time.seconds + 5), preferredTimescale: time.timescale)
                                    }
                                }
                                Spacer()
                            }.padding(.horizontal,32)
                            
                            
                           // Spacer()
                            HStack {
                                VStack(spacing:0) {
                                
                                    Slider(value: $currentDuration, in: 0...totalDuration, onEditingChanged: { val in
                                        if val {
                                            play = false
                                            self.time = CMTimeMakeWithSeconds(max(0, currentDuration), preferredTimescale: self.time.timescale)
                                        } else {
                                            // user is done sliding so play movie at point he/she slid to
                                            self.time = CMTimeMakeWithSeconds(max(0, currentDuration), preferredTimescale: self.time.timescale)
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                            play = true
                                            }
                                        }
                                    })
                                      
                                    
                                    HStack{
                                        Text(duration(seconds:time.seconds)).foregroundColor(.white)
                                        
                                        Spacer()
                                        Text(duration(seconds:totalDuration)).foregroundColor(.white)
                                        
                                    }
                                }
                                
                                
                            }.padding(6).padding(.horizontal,8).frame(maxHeight: .infinity,alignment: .bottom)
                        }.opacity(showUI ? 1 : 0).animation(.default, value: showUI)
                           
                            .background(content: {
                                if showUI {
                                    Color.black.opacity(0.3).cornerRadius(orientation.isLandscape ? 0 : radius)
                                }else {
                                    Color.clear
                                }
                        })


                    )
                   
                    .onChange(of: time.seconds) { newValue in
                        currentDuration = newValue
                    }
                   

                 
                if showLoading {
                    ProgressView().scaleEffect(2).tint(.white)
                }
                
            }.onTapGesture {
                showUI = true
            }
            .onChange(of: showUI) { UI in
                if UI {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        withAnimation {
                            showUI = false
                        }
                    })
                }
            }.cornerRadius(enableFullScreen ? 0:radius).ignoresSafeArea()
      
          
        }
        .onRotate { newOrientation in
            orientation = newOrientation
            enableFullScreen = newOrientation.isLandscape
            
        }
        .frame(maxWidth: enableFullScreen ? .infinity:width)
        .frame(maxHeight: enableFullScreen ? .infinity:height)
        
       // .ignoresSafeArea()
        
    
       
        
    }
    
    func duration(seconds:Double) -> String{
        let duration = seconds     // in seconds
        //print(duration)
        guard !(duration.isNaN || duration.isInfinite) else {
            return "illegal value" // or do some error handling
        }
        let ti = Int(duration)


        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        var tt:String
        if hours > 0 {
            tt = String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
        }else {
            tt = String(format: "%0.2d:%0.2d",minutes,seconds)
        }
        return tt
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView(url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", width: 400, height: 300, radius: 12, enableFullScreen: .constant(false)).previewInterfaceOrientation(.portrait)
            
    }
}

// Our custom view modifier to track rotation and
// call our action
struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

// A View wrapper to make the modifier easier to use
extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

//Bounce any view
struct bounce:ViewModifier {
    let onClick:() -> Void
    func body(content: Content) -> some View {
        Button {
            onClick()
        } label: {
            content
        }.buttonStyle(BounceStyle())
    }
}
struct BounceStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? CGFloat(0.85) : 1.0)
            .animation(Animation.spring(response: 0.4, dampingFraction: 0.45), value: configuration.isPressed)
    }
}

extension View {
    func onTapWithBounce(onClick:@escaping () -> Void) -> some View {
        modifier(bounce(onClick: onClick))
    }
}
