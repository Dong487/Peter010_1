//
//  HomeView.swift
//  Peter010_1
//
//  Created by DONG SHENG on 2022/7/1.
//

import SwiftUI
import AVKit

// 棒: sound1、Image1
// 老虎: sound2、Image2
// 雞: sound3、Image3
// 蟲: sound4、Image4

// 問號: Image6
// V.S.圖片: Image7

// 機器人: Image8
// 玩家圖片: Image9

// Win: Image10
// Lose: Image11
// 平手: Image12

class SoundManager{
    
    static let instance = SoundManager()
    
    var player: AVAudioPlayer?
    
    enum SoundOption: String{
        case sound1 // 木棒聲
        case sound2 // 老虎聲
        case sound3 // 雞叫聲
        case sound4 // 蟲蟲聲
    }
    
    // 按鈕點下的聲音
    func playSound(sound: SoundOption){
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: ".mp3") else { return }
        do{
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print("播放音效發生錯誤: \(error.localizedDescription)")
        }
    }
}

class HomeViewModel: ObservableObject{
    
    @Published var centerImage: String = "Image7" // 中央所顯示的 Image (顯示 V.S.、Lose、Win)
    @Published var computer: String = "Image6" // 電腦所選的
    @Published var player: String = "Image6" // 玩家選擇的
    
    @Published var computerScore: Int = 0
    @Published var playerScore: Int = 0
    
    @Published var fourButton: Bool = false // 空窗期按鈕禁止點擊
    @Published var buttonGO: Bool = true // Go按鈕能否點擊
    @Published var gameIsOver:Bool = false
    @Published var gameOverImage: String = "Image10"
    
    
    let random: [String] = [
        "Image1" , "Image2" , "Image3" , "Image4"
    ]
    
    // 圖片更換、聲音播放
    func selectedButton(selected: String ,sound: SoundManager.SoundOption){
        self.player = selected
        SoundManager.instance.playSound(sound: sound)
        self.buttonGO = false // 是否能點擊Go按鈕
    }
    
    // 按鈕GO 點擊後動作
    func goAction(){
        self.computer = random.randomElement() ?? "Image6"  // 電腦隨機選擇  棒、虎、雞、蟲 來做PK
        self.buttonGO = true
        self.fourButton = true
        
        // 轉換的過程 使用抓出最後一個字(剛好為數字) 如果數字在中間必須 在newCompter上做調整 (ex: contains、filter)
        // 電腦的轉換
        let computer1 = computer.map({ String($0)})
        let newComputer = Int(computer1[computer1.endIndex - 1]) ?? 0// Array從 [0] 開始所以 -1
        
        // 玩家的轉換
        let player1 = player.map { String($0) } // String -> [String]
        let newplayer = Int(player1[player1.endIndex - 1]) ?? 0

        // 利用數字來做判斷(以玩家角度)   平手 -> 比大小 -> 例外條件 (if 都是範圍多的放前面)
        // 平手 -> 4項
        guard newplayer != newComputer else {
            
            self.centerImage = "Image12"

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.computer = "Image6"
                self.player = "Image6"
                self.centerImage = "Image7"
                self.fourButton = false
            }
            return
        }
        // 這邊總共 12 項 (總16-平手4)
        if newplayer < newComputer {
            // 6項
            if newplayer + 3 != newComputer {
                win() // 5 項
            } else {
                lose() // 1 項
            }
        } else {
            if newplayer - 3 != newComputer{
                lose() // 5 項
            } else {
                win() // 1 項
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.computer = "Image6"
            self.player = "Image6"
            self.centerImage = "Image7"
            self.fourButton = false
        }
    }
    
    func win(){
        self.playerScore += 1
        guard playerScore != 5 else { gameOver("player") ; return }
        self.centerImage = "Image10"
    }
    
    func lose(){
        self.computerScore += 1
        guard computerScore != 5 else { gameOver("computer") ; return }
        self.centerImage = "Image11"
    }
    
    // 某一方達到 五勝
    func gameOver(_ winner: String){
        self.gameIsOver = true
        guard winner == "player" else {
            self.gameOverImage = "Image11"
            return
        }
        self.gameOverImage = "Image10"
    }
}

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        
        ZStack {
            
            Image("Background1")
    
            ImagePKView
            
            InformationView
            
            if viewModel.gameIsOver{
                OverView
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}


extension HomeView{
    
    // 最上層: 標題 ＋ 顯示分數的組件
    private var InformationView: some View{
        VStack(spacing: 0){
            Text("棒打老虎雞吃蟲🎭")
                .font(.largeTitle)
                .padding(.top ,20)
            
            HStack {
                VStack {
                    Image("Image8")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90, alignment: .leading)
                    
                    Text("\(viewModel.computerScore)")
                        .font(.largeTitle.bold())
                        .foregroundColor(.pink)
                        .padding()
                        .background(.gray.opacity(0.15))
                        .cornerRadius(8)
                    
                    Spacer()
                }
                
                Spacer()
                
                VStack {
                    Spacer()
                    
                    Text("\(viewModel.playerScore)")
                        .font(.largeTitle.bold())
                        .foregroundColor(.pink)
                        .padding()
                        .background(.gray.opacity(0.15))
                        .cornerRadius(8)
                    
                    Image("Image9")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90, alignment: .leading)
                }
                .padding(.bottom ,180)
            }
        }
        .frame(width: UIScreen.main.bounds.width - 20 ,height: UIScreen.main.bounds.height - 20)
        .padding(.top ,10)
    }
    
    // 中間層:
    private var ImagePKView: some View{
        VStack{
            Image(viewModel.computer)
                .resizable()
                .scaledToFit()
                .opacity(0.35)
                .frame(width: UIScreen.main.bounds.width - 100 ,height: UIScreen.main.bounds.height / 2 - 200)
                
            Image(viewModel.centerImage)
                .resizable()
                .scaledToFit()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.gray)
                        .frame(width: UIScreen.main.bounds.width - 50, height: 1)
                )
                .frame(width: 500, height: 100)
                
            
            Image(viewModel.player)
                .resizable()
                .scaledToFit()
                .opacity(0.35)
                .frame(width: UIScreen.main.bounds.width - 100 ,height: UIScreen.main.bounds.height / 2 - 200)
            
            ButtonView
        }
        .frame(width: UIScreen.main.bounds.width - 20 ,height: UIScreen.main.bounds.height - 20)
        .padding(.top ,75)
    }
    
    // 底部 總共 五個按鈕的 View
    private var ButtonView: some View{
        VStack(spacing: 0){
            HStack(spacing: 12){
                
                Button {
                    viewModel.selectedButton(selected: "Image1", sound: .sound1)
                } label: {
                    Image("Image1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width / 5, height: 60)
                        .shadow(color: .black.opacity(0.75), radius: 1, x: 1, y: 1)
                        .shadow(color: .black.opacity(0.65), radius: 1.5, x: 1.5, y: 1)
                        .shadow(color: .black.opacity(0.55), radius: 2, x: 2, y: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.gray)
                                .frame(width: UIScreen.main.bounds.width / 6 + 20, height: 45)
                                .offset(y: 20)
                                .shadow(color: .black.opacity(0.75), radius: 1, x: 1, y: 1)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.brown)
                                        .frame(width: UIScreen.main.bounds.width / 6 + 20, height: 45)
                                        .offset(y: 15)
                                        .shadow(color: .black.opacity(0.75), radius: 1, x: 1, y: 1)
                                )
                        )
                }
                .disabled(viewModel.fourButton)
                
                Button {
                    viewModel.selectedButton(selected: "Image2", sound: .sound2)
                } label: {
                    Image("Image2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width / 5, height: 100)
                        .shadow(color: .black.opacity(0.75), radius: 1, x: 1, y: 1)
                        .shadow(color: .black.opacity(0.65), radius: 1.5, x: 1.5, y: 1)
                        .shadow(color: .black.opacity(0.55), radius: 2, x: 2, y: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.gray)
                                .frame(width: UIScreen.main.bounds.width / 6 + 20, height: 45)
                                .offset(y: 20)
                                .shadow(color: .black.opacity(0.75), radius: 1, x: 1, y: 1)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.brown)
                                        .frame(width: UIScreen.main.bounds.width / 6 + 20, height: 45)
                                        .offset(y: 15)
                                        .shadow(color: .black.opacity(0.75), radius: 1, x: 1, y: 1)
                                )
                        )
                }
                .disabled(viewModel.fourButton)
                
                Button {
                    viewModel.selectedButton(selected: "Image3", sound: .sound3)
                } label: {
                    Image("Image3")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width / 5, height: 60)
                        .shadow(color: .black.opacity(0.75), radius: 1, x: 1, y: 1)
                        .shadow(color: .black.opacity(0.65), radius: 1.5, x: 1.5, y: 1)
                        .shadow(color: .black.opacity(0.55), radius: 2, x: 2, y: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.gray)
                                .frame(width: UIScreen.main.bounds.width / 6 + 20, height: 45)
                                .offset(y: 20)
                                .shadow(color: .black.opacity(0.75), radius: 1, x: 1, y: 1)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.brown)
                                        .frame(width: UIScreen.main.bounds.width / 6 + 20, height: 45)
                                        .offset(y: 15)
                                        .shadow(color: .black.opacity(0.75), radius: 1, x: 1, y: 1)
                                )
                        )
                }
                .disabled(viewModel.fourButton)
                
                Button {
                    viewModel.selectedButton(selected: "Image4", sound: .sound4)
                } label: {
                    Image("Image4")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width / 5, height: 100)
                        .shadow(color: .black.opacity(0.75), radius: 1, x: 1, y: 1)
                        .shadow(color: .black.opacity(0.65), radius: 1.5, x: 1.5, y: 1)
                        .shadow(color: .black.opacity(0.55), radius: 2, x: 2, y: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.gray)
                                .frame(width: UIScreen.main.bounds.width / 6 + 20, height: 45)
                                .offset(y: 20)
                                .shadow(color: .black.opacity(0.75), radius: 1, x: 1, y: 1)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.brown)
                                        .frame(width: UIScreen.main.bounds.width / 6 + 20, height: 45)
                                        .offset(y: 15)
                                        .shadow(color: .black.opacity(0.75), radius: 1, x: 1, y: 1)
                                )
                        )
                }
                .disabled(viewModel.fourButton)
            }
            
            Button {
                viewModel.goAction()
            } label: {
                Text("   GO   ")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 50, height: 60)
                    .shadow(color: .black.opacity(0.75), radius: 1, x: 1, y: 1)
                    .shadow(color: .black.opacity(0.65), radius: 1.5, x: 1.5, y: 1)
                    .shadow(color: .black.opacity(0.55), radius: 2, x: 2, y: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white)
                            .frame(width: UIScreen.main.bounds.width - 50, height: 45)
                            .offset(y: 3)
                            .shadow(color: .black.opacity(0.75), radius: 1, x: 1, y: 1)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(viewModel.buttonGO == false ?
                                           Color(red: 50 / 255, green: 78 / 255, blue: 99 / 255) : .gray.opacity(0.75))
                                    .frame(width: UIScreen.main.bounds.width - 50, height: 45)
                                    
                                    .shadow(color: .black.opacity(0.75), radius: 1, x: 1, y: 1)
                            )
                    )
            }
            .disabled(viewModel.buttonGO) // 防止沒選
        }
    }
    
    private var OverView: some View{
        ZStack{
            Image("Background2")
                .resizable()
                .frame(width: UIScreen.main.bounds.width - 50, height: 400)
            
            VStack(spacing: 0){
                Text("You Win")
                    .font(.largeTitle.bold())
                    .kerning(10)
                    .foregroundColor(.white)
                    
                Image(viewModel.gameOverImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                
                Button {
                    viewModel.gameIsOver.toggle()
                    self.viewModel.playerScore = 0
                    self.viewModel.computerScore = 0
                    
                } label: {
                    Image("Image13")
                        .resizable()
                        .scaleEffect()
                        .frame(width: 120, height: 70)
                }

            }
            .frame(width: UIScreen.main.bounds.width - 50, height: 400)
            
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(.black.opacity(0.35))
        .transition(AnyTransition.opacity.animation(.easeInOut))

    }
}
