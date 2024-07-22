import SwiftUI
import MediaPlayer

struct ContentView: View {
    @StateObject private var nowPlayingManager = NowPlayingManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Now Playing")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(nowPlayingManager.currentSong)
                .font(.title2)
            
            Text(nowPlayingManager.currentArtist)
                .font(.title3)
                .foregroundColor(.secondary)
            
            Button("Refresh Now Playing") {
                nowPlayingManager.updateNowPlaying()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .onAppear {
            nowPlayingManager.startMonitoring()
        }
    }
}

class NowPlayingManager: ObservableObject {
    @Published var currentSong: String = "No song playing"
    @Published var currentArtist: String = ""
    
    private var timer: Timer?
    
    func startMonitoring() {
        updateNowPlaying()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateNowPlaying), userInfo: nil, repeats: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNowPlaying), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateNowPlaying), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
        
        // Start MPMusicPlayerController notifications
        let player = MPMusicPlayerController.systemMusicPlayer
        player.beginGeneratingPlaybackNotifications()
    }
    
    @objc func updateNowPlaying() {
        let nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        
        DispatchQueue.main.async {
            self.currentSong = nowPlayingInfo?[MPMediaItemPropertyTitle] as? String ?? "No song playing"
            self.currentArtist = nowPlayingInfo?[MPMediaItemPropertyArtist] as? String ?? ""
            print("Now playing: \(self.currentSong) by \(self.currentArtist)")
        }
    }
    
    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
        
        // Stop MPMusicPlayerController notifications
        let player = MPMusicPlayerController.systemMusicPlayer
        player.endGeneratingPlaybackNotifications()
    }
}
