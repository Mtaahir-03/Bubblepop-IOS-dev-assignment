import SwiftUI

struct GameView: View {
    @StateObject private var gameManager = GameManager()
    @State private var showingSettings = false
    @State private var showingHighScores = false
    @State private var isGameStarted = false
    @State private var showCountdown = false
    @State private var countdownNumber = 3
    @State private var scoreAnimations: [ScoreAnimation] = []
    @State private var backgroundAnimation = 0.0


    let gradientColors = [Color(red: 0.1, green: 0.2, blue: 0.45), Color(red: 0.3, green: 0.4, blue: 0.9)]
    let accentColor = Color(red: 0.9, green: 0.5, blue: 0.1)
    let buttonGradient = LinearGradient(
        colors: [Color(red: 0.3, green: 0.6, blue: 0.9), Color(red: 0.2, green: 0.4, blue: 0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        GeometryReader { geometry in

            ZStack {
                // Animated background
                ZStack {
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .edgesIgnoringSafeArea(.all)
                    
                    // Floating bubble effects in background
                    ForEach(0..<20) { i in
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: CGFloat.random(in: 20...60))
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                            .offset(y: -backgroundAnimation + Double(i * 10))
                    }
                }
                .onAppear {
                    withAnimation(.linear(duration: 20).repeatForever()) {
                        backgroundAnimation = geometry.size.height
                    }
                }

                if !isGameStarted {
                    VStack(spacing: 30) {
                        Text("BubblePop")
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 5)
                            .padding(.top, 20)
                            .overlay(
                                Text("BubblePop")
                                    .font(.system(size: 50, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .offset(x: -2, y: -2)
                                    .opacity(0.7)
                            )
                        
                        Spacer().frame(height: 20)
                       
                        TextField("Enter your name", text: $gameManager.playerName)
                            .font(.system(size: 20, design: .rounded))
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .foregroundColor(.white)
                            .accentColor(.white)
                            .padding(.horizontal, 50)
                            .transition(.move(edge: .leading))
                        
                        // Start game button
                        Button(action: {
                            withAnimation {
                                isGameStarted = true
                                startCountdown()
                            }
 
                        }) {
                            Text("Start Game")

                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 30)
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                                .shadow(color: .blue.opacity(0.5), radius: 5, x: 0, y: 3)
                        }
                        .disabled(gameManager.playerName.isEmpty)
                        .opacity(gameManager.playerName.isEmpty ? 0.5 : 1)
                        .scaleEffect(gameManager.playerName.isEmpty ? 0.95 : 1)
                        .animation(.spring(), value: gameManager.playerName.isEmpty)                       
 
                        HStack(spacing: 20) {
                            
                            Button(action: {
                                showingSettings.toggle()
                            }) {
                                Text("Settings")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .background(Color.green)
                                    .cornerRadius(15)
                                    .shadow(color: .green.opacity(0.5), radius: 3, x: 0, y: 2)
                            }
                            
                            Button(action: {
                                showingHighScores.toggle()
                            }) {
                                Text("High Scores")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .background(Color.orange)
                                    .cornerRadius(10)
                                    .shadow(color: .orange.opacity(0.5), radius: 3, x: 0, y: 2)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
		    .transition(.opacity)

                } else if showCountdown {
                    
                    VStack {
                        Text("\(countdownNumber)")
                            .font(.system(size: 120, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: accentColor, radius: 20, x: 0, y: 0)
                            .scaleEffect(countdownNumber == 3 ? 0.5 : 1.2)
                            .opacity(countdownNumber == 3 ? 0.7 : 1)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.1), value: countdownNumber)
                    }
                    .transition(.opacity)
                } else if gameManager.gameActive {

                    ZStack {
                        VStack(spacing: 0) {
                            HStack {
                                Text("Score: \(gameManager.score)")
                                    .font(.headline)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(10)
                                
                                Spacer()
                                
                                if let highestScore = gameManager.highScores.first?.score, !gameManager.highScores.isEmpty {
                                    Text("Best: \(highestScore)")
                                        .font(.headline)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(Color.yellow.opacity(0.8))
                                        .cornerRadius(10)
                                }
                                
                                Spacer()
                                
                                Text("Time: \(gameManager.timeRemaining)")
                                    .font(.headline)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(10)
                            }
                            .padding()

                            // Combo indicator
                           /* if gameManager.comboMultiplier > 0 {
                                Text("Combo: x\(gameManager.comboMultiplier + 1)")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 5)
                                    .background(Color.purple.opacity(0.8))
                                    .cornerRadius(15)
                                    .transition(.scale)
                            }*/
                            
                            Spacer()
                        }
                       
                        // Bubbles with improved appearance
                        /*ForEach(gameManager.bubbles) { bubble in
                            ZStack {
                                // Bubble glow effect
                                Circle()
                                    .fill(bubble.bubbleColor.opacity(0.5))
                                    .blur(radius: 10)
                                    .frame(width: bubble.size + 10, height: bubble.size + 10)
                                
                                // Main bubble
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            gradient: Gradient(colors: [bubble.bubbleColor.opacity(0.8), bubble.bubbleColor]),
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: bubble.size/2
                                        )
                                    )
                                    .frame(width: bubble.size, height: bubble.size)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.6), lineWidth: 2)
                                    )
                                    .overlay(
                                        Circle()
                                            .fill(Color.white.opacity(0.3))
                                            .frame(width: bubble.size * 0.3, height: bubble.size * 0.3)
                                            .offset(x: -bubble.size * 0.2, y: -bubble.size * 0.2)
                                    )
                            }
                            .position(bubble.position)
                            .onTapGesture {
                                if let index = gameManager.bubbles.firstIndex(where: { $0.id == bubble.id }) {
                                    // Add score animation
                                    withAnimation {
                                        let points = gameManager.calculatePointsForBubble(bubble)
                                        addScoreAnimation(at: bubble.position, points: points, color: bubble.bubbleColor)
                                        gameManager.popBubble(at: index)
                                    }
                                }
                            }
                            .transition(.scale)
                        }*/

                        ForEach(gameManager.bubbles.indices, id: \.self) { index in
                            let bubble = gameManager.bubbles[index]
                            Circle()
                                .fill(bubble.bubbleColor)
                                .frame(width: bubble.size, height: bubble.size)
                                .position(bubble.position)
                                .onTapGesture {
                                    if let index = gameManager.bubbles.firstIndex(where: { $0.id == bubble.id }) {
                                        withAnimation {
                                            let points = gameManager.calculatePointsForBubble(bubble)
                                            addScoreAnimation(at: bubble.position, points: points, color: bubble.bubbleColor)
                                            gameManager.popBubble(at: index)
                                        }
                                    }
                                }
                                .transition(.scale)
                        }
                    
                        // Score animations
                        ForEach(scoreAnimations) { animation in
                            Text("+\(animation.points)")
                                /*.font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(animation.color)
                                .shadow(color: .black, radius: 2, x: 0, y: 0)
                                .position(animation.position)
                                .opacity(animation.opacity)
                                .offset(y: animation.offset)
                                .scaleEffect(animation.scale)*/

                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(animation.color)
                                .position(animation.position)
                                .opacity(animation.opacity)
                                .offset(y: animation.offset)
                        }
                    }
    
                    .transition(.opacity)
                } else {

                    VStack(spacing: 25) {


                        Text("Game Over!")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: accentColor, radius: 10, x: 0, y: 0)
                       
                        Text("Your Score: \(gameManager.score)")
                            .font(.system(size: 30, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue.opacity(0.3))
                            .cornerRadius(20) 
                        
                        Text("High Scores")
			    .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(gameManager.highScores.prefix(10)) { player in
                                    HStack {
                                        Text(player.name)
                                            .font(.headline)
                                        Spacer()
                                        Text("\(player.score)")
                                            .font(.headline)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.7))
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: geometry.size.height * 0.4)
                        
                        Button(action: {
                            withAnimation {
                                isGameStarted = false
                            }
                        }) {
                            Text("New Game")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .frame(maxHeight: geometry.size.width * 0.9)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                    .transition(.scale)
                }
            }
            .onAppear {
                gameManager.setScreenSize(geometry.size)
            }
            .onChange(of: geometry.size) { newSize in
                gameManager.setScreenSize(newSize)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(settings: $gameManager.settings, saveSettings: gameManager.saveSettings)
            }
            .sheet(isPresented: $showingHighScores) {
                HighScoresView(highScores: gameManager.highScores)
            }
        }
    }
    
    private func startCountdown() {
        showCountdown = true
        countdownNumber = 3
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 0.5)) {
                countdownNumber -= 1
            }
            if countdownNumber <= 0 {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    withAnimation {
                        showCountdown = false
                        gameManager.startGame()
                    }
                }
            }
        }
    }
    
    private func addScoreAnimation(at position: CGPoint, points: Int, color: Color) {
        let animation = ScoreAnimation(
            id: UUID(),
            position: position,
            points: points,
            color: color
        )
        scoreAnimations.append(animation)
        
        withAnimation(.easeOut(duration: 1.5)) {
            if let index = scoreAnimations.firstIndex(where: { $0.id == animation.id }) {
                scoreAnimations[index].opacity = 0
                scoreAnimations[index].offset = -50
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            scoreAnimations.removeAll(where: { $0.id == animation.id })
        }
    }
}

// Score animation model
struct ScoreAnimation: Identifiable {
    let id: UUID
    let position: CGPoint
    let points: Int
    let color: Color
    var opacity: Double = 1.0
    var offset: CGFloat = 0
}

// SettingsView
struct SettingsView: View {
    @Binding var settings: GameSettings
    var saveSettings: () -> Void
    @State private var tempGameDuration: Double = 60
    @State private var tempMaxBubbles: Double = 15
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Game Settings")) {
                    HStack {
                        Text("Game Duration (seconds)")
                        Spacer()
                        Text("\(Int(tempGameDuration)) seconds")
                            .frame(width: 100, alignment: .leading)
                        Slider(value: $tempGameDuration, in: 0...60, step: 1)
                            .accentColor(.blue)
                    }
                    HStack {
                        Text("Maximum Bubbles")
                        Spacer()
                        Text("\(Int(tempMaxBubbles)) bubbles")
                            .frame(width: 100, alignment: .leading)
                        Slider(value: $tempMaxBubbles, in: 0...15, step: 1)
                            .accentColor(.green)
                    }
                }
                
                Section {
                    Button("Save Settings") {
                        settings.gameDuration = Int(tempGameDuration)
                        settings.maxBubbles = Int(tempMaxBubbles)
                        saveSettings()
                    }
                }
                
                Section(header: Text("Information")) {
                    Text("Game duration must be between 1 and 60 seconds")
                    Text("Maximum bubbles must be between 0 and 15")
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                tempGameDuration = Double(settings.gameDuration)
                tempMaxBubbles = Double(settings.maxBubbles)
            }
        }
    }
}

// HighScoresView
struct HighScoresView: View {
    let highScores: [Player]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(highScores.indices, id: \.self) { index in
                    HStack {
                        Text("\(index + 1).")
                            .font(.headline)
                            .frame(width: 40, alignment: .leading)
                        
                        Text(highScores[index].name)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(highScores[index].score)")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("High Scores")
        }
    }
}

