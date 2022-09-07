# VideoPlayer
This repository shows Videoplayer with custom UI

## Requirements

* Add packacge Dependency https://github.com/wxxsw/VideoPlayer  

* Copy and paste VideoPlayerView to your project

## Usage
Portrait<img src="https://user-images.githubusercontent.com/28716129/188855794-1e6a54c9-640f-413a-bd0b-9836f5e30586.gif" width="20%" >
Landscape<img src="https://user-images.githubusercontent.com/28716129/188857893-bd7c574a-e9f1-4515-a4c5-7fe92c9f77a8.gif" width="70%" >



* initilize `VideoPlayerView`


```Swift
VideoPlayerView(url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                            width: 400,
                            height: 300,
                            radius: 12,
                            enableFullScreen: $isFullScreen)
            .padding(isFullScreen ? 0:16)
```

