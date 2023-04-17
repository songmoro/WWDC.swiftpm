//
//  ContentView.swift
//  WWDC
//
//  Created by 송재훈 on 2023/03/15.

import SwiftUI
import SpriteKit
import PencilKit

// TODO: 가로 대문자는 짤림
// TODO: 가이드 만들기
// TODO: 튜토리얼 만들기
// TODO: 스코프 만들기
// TODO: 지우개, 샌드 버튼 조정

struct PhysicsCategory {
    static let player: UInt32 = 0b0001
    static let alien: UInt32 = 0b0010
}

func StrokeCount(alphabet : String) -> Int {
    if alphabet == "" {
        return 0
    }
    let lowercaseStrokeCount = [1, 1, 1, 1, 1, 2, 1, 1, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 2, 1, 1]
    let uppercaseStrokeCount = [3, 2, 1, 2, 4, 3, 2, 3, 3, 2, 2, 1, 2, 2, 1, 2, 2, 2, 1, 2, 1, 1, 1, 2, 2, 1]
    
    let asciiValue = alphabet.first?.asciiValue
    let intValue = Int(asciiValue!)
    
    if intValue >= 97 && intValue <= 122 {
        return lowercaseStrokeCount[intValue - 97]
    } else if intValue >= 65 && intValue <= 90 {
        return uppercaseStrokeCount[intValue - 65]
    }
    
    return 0
}

enum GameState {
    case tutorial
    case ready
    case playing
    case end
}

enum TutorialState {
    case ready
    case touchAlien
    case drawingAlien
    case morePractice
    case tutorialEnd
}

var gameState = GameState.tutorial

var nextAlphabet : String = ""
var nextNumber : Int = 0

var isScore : Double = 0.0
var isRemove : Bool = false
var isStart : Bool = false

class GameScene: SKScene, SKPhysicsContactDelegate {
    let backgroundImage = SKSpriteNode(imageNamed: "backgroundImage")
    var descriptBanner = SKLabelNode(fontNamed: "Chalkduster")
    var scoreBanner = SKLabelNode(fontNamed: "Chalkduster")
    
    var tutorialState = TutorialState.ready
    var tutorialTitleBanner = SKLabelNode(fontNamed: "Chalkduster")
    var tutorialGuideBanner : [SKLabelNode] = [SKLabelNode(fontNamed: "Chalkduster"), SKLabelNode(fontNamed: "Chalkduster"), SKLabelNode(fontNamed: "Chalkduster"), SKLabelNode(fontNamed: "Chalkduster"), SKLabelNode(fontNamed: "Chalkduster")]
    var tutorialCount : Int = 3
    
    var alienTimer = Timer()
    var alienInterval: TimeInterval = 4.0
    var alienSpeed : CGFloat = 1.0
    var alienNumber : Int = 0
    
    var gameScore : Int = 0
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        gameState = .tutorial
        
        descriptBanner.text = "> Touch to start <"
        scoreBanner.text = "Portrait is recommended"
        
        playingSetting()
    }
    
    override func update(_ currentTime: TimeInterval) {
        switch gameState {
        case .tutorial:
            switch tutorialState {
            case .ready:
                break
            case .touchAlien:
                break
            case .drawingAlien:
                if nextAlphabet != "" {
                    if isRemove {
                        self.childNode(withName: "\(nextAlphabet)")?.removeFromParent()
                        self.childNode(withName: "alienScope")?.removeFromParent()
                        self.childNode(withName: "alienStroke")?.removeFromParent()
                        
                        nextAlphabet = ""
                        isRemove = false
                        
                        tutorialState = .morePractice
                        
                        tutorialGuideBanner[0].text = "1. Touch an alien"
                        tutorialGuideBanner[1].text = "2. Find the start point"
                        tutorialGuideBanner[2].text = "3. Draw an line"
                        tutorialGuideBanner[3].text = "4. Click a send"
                        tutorialGuideBanner[4].text = "(Optional). Click erase to reset draw"
                        
                        tutorialAddAlien()
                    }
                }
            case .morePractice:
                tutorialTitleBanner.text = "\(tutorialCount) times more!"
                
                if nextAlphabet != "" {
                    if isRemove {
                        self.childNode(withName: "\(nextAlphabet)")?.removeFromParent()
                        self.childNode(withName: "alienScope")?.removeFromParent()
                        self.childNode(withName: "alienStroke")?.removeFromParent()
                        
                        nextAlphabet = ""
                        isRemove = false
                        
                        tutorialCount -= 1
                        
                        if tutorialCount == 0 {
                            tutorialTitleBanner.text = "Finished tutorial!"
                            tutorialGuideBanner[0].text = "Touch here to start"
                            tutorialGuideBanner[1].text = "The main game"
                            tutorialGuideBanner[2].text = ""
                            tutorialGuideBanner[3].text = ""
                            tutorialGuideBanner[4].text = ""
                            tutorialState = .tutorialEnd
                        }
                        else {
                            tutorialAddAlien()
                        }
                    }
                }
            case .tutorialEnd:
                break
            }
        case .ready:
            descriptBanner.text = "> Touch to start <"
        case .playing:
            if nextAlphabet != "" {
                if isRemove {
                    self.childNode(withName: "\(nextAlphabet)")?.removeFromParent()
                    
                    nextAlphabet = ""
                    isRemove = false
                    
                    gameScore += 10
                }
            }
            else {
                descriptBanner.text = "Touch alien!"
            }
            scoreBanner.text = "Score : \(gameScore)"
        case .end:
            descriptBanner.text = "Game Over!"
        }
    }
    
    func tutorialAddAlien() {
        var alienAlphabet = ""
        
        switch tutorialState {
        case .ready:
            alienAlphabet = "A"
        case .touchAlien:
            break
        case .drawingAlien:
            break
        case .morePractice:
            let alienArray = ["D", "C", "B"]
            alienAlphabet = alienArray[tutorialCount - 1]
        case .tutorialEnd:
            break
        }
        
        let alien = SKSpriteNode(imageNamed: alienAlphabet)
        alien.size = CGSize(width: frame.size.width * 0.05, height: frame.size.height * 0.05)
        alien.position = CGPoint(x: frame.size.width * 0.05, y: frame.size.height * 0.9)
        alien.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        alien.speed = alienSpeed
        
        alien.name = "\(alienAlphabet)"
        
        alien.physicsBody = SKPhysicsBody(circleOfRadius: alien.size.height / 2)
        alien.physicsBody?.categoryBitMask = PhysicsCategory.alien
        alien.physicsBody?.affectedByGravity = false
        alien.physicsBody?.isDynamic = false
        alien.physicsBody?.contactTestBitMask = PhysicsCategory.player
        alien.physicsBody?.collisionBitMask = PhysicsCategory.player
        
        self.addChild(alien)
        
        let widthScale = frame.size.width * 0.1
        
        let moveRightAct = SKAction.moveBy(x: widthScale, y: 0, duration: 1)
        
        var moveArray : [SKAction] = []
        moveArray.append(moveRightAct)
        
        let sequence = SKAction.sequence(moveArray)
        
        alien.run(sequence)
    }
    
    func tutorialSetting() {
        addBackground()
        addPlayer()
        addTutorialBanner()
    }
    
    func addTutorialBanner(){
        tutorialTitleBanner.fontSize = 65
        tutorialTitleBanner.fontColor = SKColor.yellow
        tutorialTitleBanner.position = CGPoint(x: frame.midX, y: frame.midY)
        
        for index in 0...4 {
            tutorialGuideBanner[index].fontSize = 30
            tutorialGuideBanner[index].fontColor = SKColor.white
            tutorialGuideBanner[index].position = CGPoint(x: frame.midX, y: frame.midY - 65 - CGFloat(index * 40))
            addChild(tutorialGuideBanner[index])
        }
        addChild(tutorialTitleBanner)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameState {
        case .tutorial:
            switch tutorialState {
            case .ready:
                removeAllChildren()
                alienTimer.invalidate()
                
                tutorialSetting()
                
                tutorialTitleBanner.text = "Touch an Alien"
                tutorialGuideBanner[0].text = "See top of View"
                
                tutorialAddAlien()
                tutorialState = .touchAlien
            case .touchAlien:
                var location: CGPoint!
                
                if let touch = touches.first {
                    location = touch.location(in: self)
                }
                
                let frontTouchedNode = atPoint(location).name
                
                if frontTouchedNode != nil {
                    tutorialTitleBanner.text = "Draw an alphabet"
                    tutorialGuideBanner[0].text = "Color circle is start point"
                    tutorialGuideBanner[1].text = "And a dot will guide you how to draw a line"
                    tutorialGuideBanner[2].text = "when you finished, Click send button"
                    tutorialGuideBanner[4].text = "\"A\" have 3 lines"
                    
                    let alphabet = "\(frontTouchedNode!)"
                    let children = self.childNode(withName: alphabet)

                    var alienScopePath = CGMutablePath()
                    alienScopePath.addEllipse(in: CGRect(x: children!.position.x - frame.size.width * 0.02, y: children!.position.y - frame.size.width * 0.02, width: frame.size.width * 0.04, height: frame.size.width * 0.04))
                    alienScopePath.addRects([CGRect(x: children!.position.x - frame.size.width * 0.03, y: children!.position.y, width: frame.size.width * 0.06, height: 1), CGRect(x: children!.position.x, y: children!.position.y - frame.size.width * 0.03 , width: 1, height: frame.size.width * 0.06)])

                    let alienScope = SKShapeNode(path: alienScopePath)
                    alienScope.strokeColor = .red
                    alienScope.lineWidth = 2
                    alienScope.name = "alienScope"
                    
                    var alienStrokePath = CGMutablePath()
                    alienStrokePath.addLines(between: [CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.25), children!.position])

                    let alienStroke = SKShapeNode(path: alienStrokePath)
                    alienStroke.strokeColor = .red
                    alienStroke.lineWidth = 2
                    alienStroke.name = "alienStroke"
                    
                    addChild(alienScope)
                    addChild(alienStroke)
                    
                    nextAlphabet = "\(alphabet)"
                    
                    tutorialState = .drawingAlien
                }
            case .drawingAlien:
                break
            case .morePractice:
                var location: CGPoint!
                
                if let touch = touches.first {
                    location = touch.location(in: self)
                }
                
                let frontTouchedNode = atPoint(location).name
                
                if frontTouchedNode != nil {
                    let alphabet = "\(frontTouchedNode!)"
                    let children = self.childNode(withName: alphabet)

                    nextAlphabet = "\(alphabet)"
                }
            case .tutorialEnd:
                tutorialTitleBanner.text = ""
                tutorialGuideBanner[0].text = ""
                tutorialGuideBanner[1].text = ""
                tutorialGuideBanner[2].text = ""
                tutorialGuideBanner[3].text = ""
                tutorialGuideBanner[4].text = ""
                gameState = .ready
            }
        case .ready:
            gameState = .playing
            alienTimer.invalidate()
            removeAllChildren()
            addAlien()
            playingSetting()
            
            descriptBanner.text = "Touch alien!"
            alienSpeed = 1.0
            alienInterval = 4.0
            gameScore = 0
            alienNumber = 0
            alienTimer = setTimer(interval: alienInterval, function: self.addAlien)
        case .playing:
            var location: CGPoint!
            
            if let touch = touches.first {
                location = touch.location(in: self)
            }
            
            let frontTouchedNode = atPoint(location).name
            
            
            if frontTouchedNode != nil {
                let alphabet = "\(frontTouchedNode!)"
                
                descriptBanner.text = "Draw and Send!"
                nextAlphabet = alphabet
                
                let timeIndex = alphabet.index(alphabet.startIndex, offsetBy: 1)
                let i = alphabet[timeIndex...]
                
                nextNumber = Int(i)!
            }
        case .end:
            gameState = .ready
        }
    }
    
    func setTimer(interval: TimeInterval, function: @escaping () -> Void) -> Timer {
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            function()
        }
        timer.tolerance = interval * 0.2
        
        return timer
    }
    
    func randomAlphabet() -> String {
        let randomLower = Int.random(in: 0...1)
        let randomUnicode = Int.random(in: 65...90)
        let randomResult = "\(UnicodeScalar(randomUnicode + randomLower * 32)!)"
        
        return randomResult
    }
    
    func addBackground() {
        backgroundImage.zPosition = -1
        backgroundImage.size = CGSize(width: frame.size.width, height: frame.size.height)
        backgroundImage.anchorPoint = CGPoint(x: 0, y: 0)
        
        addChild(backgroundImage)
    }
    
    func addDescriptBanner() {
        descriptBanner.fontSize = 65
        descriptBanner.fontColor = SKColor.yellow
        descriptBanner.position = CGPoint(x: frame.midX, y: frame.midY)
        
        addChild(descriptBanner)
    }
    
    func addScoreBanner() {
        scoreBanner.fontSize = 40
        scoreBanner.fontColor = SKColor.white
        scoreBanner.position = CGPoint(x: frame.midX, y: frame.midY - 65)
        addChild(scoreBanner)
    }
    
    func addAlien() {
        let alienAlphabet = randomAlphabet()
        let alien = SKSpriteNode(imageNamed: alienAlphabet)
        alien.size = CGSize(width: frame.size.width * 0.05, height: frame.size.height * 0.05)
        alien.position = CGPoint(x: frame.size.width * 0.05, y: frame.size.height * 0.9)
        alien.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        alien.speed = alienSpeed
        
        alienSpeed *= 1.04
        alienInterval *= 0.98
        
        nextNumber = alienNumber
        
        alien.name = "\(alienAlphabet)\(alienNumber)"
        alienNumber += 1
        
        alien.physicsBody = SKPhysicsBody(circleOfRadius: alien.size.height / 2)
        alien.physicsBody?.categoryBitMask = PhysicsCategory.alien
        alien.physicsBody?.affectedByGravity = false
        alien.physicsBody?.isDynamic = false
        alien.physicsBody?.contactTestBitMask = PhysicsCategory.player
        alien.physicsBody?.collisionBitMask = PhysicsCategory.player
        
        self.addChild(alien)
        
        let widthScale = frame.size.width * 0.1
        let heightScale = frame.size.height * 0.1
        
        let moveLeftAct = SKAction.moveBy(x: -widthScale, y: 0, duration: 1)
        let moveRightAct = SKAction.moveBy(x: widthScale, y: 0, duration: 1)
        let moveDownAct = SKAction.moveBy(x: 0, y: -heightScale, duration: 0.1)
        let waitAct = SKAction.wait(forDuration: 1)
        
        var moveArray : [SKAction] = []
        
        for _ in 0...8 {
            moveArray.append(moveRightAct)
            moveArray.append(waitAct)
        }
        moveArray.append(moveDownAct)
        moveArray.append(waitAct)
        
        for _ in 0...8 {
            moveArray.append(moveLeftAct)
            moveArray.append(waitAct)
        }
        moveArray.append(moveDownAct)
        moveArray.append(waitAct)
        
        let sequence = SKAction.sequence(moveArray)
        
        alien.run(SKAction.repeatForever(sequence))
    }
    
    func addPlayer() {
        let player = SKSpriteNode(color: .clear, size: CGSize(width: frame.size.width * 2, height: frame.size.height * 0.5))
        
        player.color = .clear
        
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.size.width * 2, height: frame.size.height * 0.5))
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.collisionBitMask = PhysicsCategory.player
        
        self.addChild(player)
    }
    
    func playingSetting() {
        addBackground()
        addDescriptBanner()
        addScoreBanner()
        addPlayer()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.node?.physicsBody!.categoryBitMask == PhysicsCategory.player && secondBody.node?.physicsBody!.categoryBitMask == PhysicsCategory.alien {
            switch gameState {
            case .tutorial:
                break
            case .ready:
                self.removeAllChildren()
                playingSetting()
            case .playing:
                self.removeAllChildren()
                alienTimer.invalidate()
                playingSetting()
                
                nextAlphabet = ""
                gameState = .end
            case .end:
                nextAlphabet = ""
                nextNumber = 0
                addScoreBanner()
            }
        }
    }
}

struct ContentView: View {
    @State var canvasView = PKCanvasView()
    @State var backgroundView = PKCanvasView()
    @State var nowAlphabet : String = ""
    
    var scene: SKScene {
        let scene = GameScene()
        
        scene.size = CGSize(width: UIScreen.main.bounds.width, height : UIScreen.main.bounds.height)
        scene.scaleMode = .fill
        
        return scene
    }
    
    var body: some View {
        GeometryReader { geo in
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .frame(width: geo.size.width, height: geo.size.height)
            
            TextGeneratorView(backgroundCanvasView: $backgroundView, nowAlphabet: $nowAlphabet)
                .frame(width: geo.size.width, height: geo.size.height * 0.25)
                .frame(maxHeight: .infinity, alignment: .bottom)
            
            AnimationView(backgroundCanvasView: $backgroundView, nowAlphabet: $nowAlphabet)
                .frame(width: geo.size.width, height: geo.size.height * 0.25)
                .frame(maxHeight: .infinity, alignment: .bottom)
            
            CanvasView(canvasView: $canvasView)
                .frame(width: geo.size.width, height: geo.size.height * 0.25)
                .frame(maxHeight: .infinity, alignment: .bottom)
            
            HStack() {
                Button {
                    let button = ButtonActionView()
                    
                    button.Reseting(canvasView: canvasView, backgroundCanvasView: backgroundView)
                } label: {
                    VStack(alignment: .center) {
                        Image(systemName: "eraser")
                            .resizable()
                            .foregroundColor(.white)
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.1)
                            .padding(.leading, geo.size.width * 0.1)
                        Text("Erase")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .bold()
                            .padding(.leading, geo.size.width * 0.1)
                    }
                }
                
                Spacer()
                
                Button {
                    let button = ButtonActionView()
                    
                    isScore = button.Scoring(canvasView: canvasView, backgroundCanvasView: backgroundView)
                    
                    if isScore >= 90 {
                        button.Reseting(canvasView: canvasView, backgroundCanvasView: backgroundView)
                        isScore = 0
                        isRemove = true
                    }
                    
                } label: {
                    VStack() {
                        Image(systemName: "paperplane")
                            .resizable()
                            .foregroundColor(.white)
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.1)
                            .padding(.trailing, geo.size.width * 0.1)
                        Text("Send")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .bold()
                            .padding(.trailing, geo.size.width * 0.1)
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height * 0.25)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}

struct TextGeneratorView: UIViewRepresentable {
    @Binding var backgroundCanvasView: PKCanvasView
    @Binding var nowAlphabet : String
    
    @State var textTimer = Timer()
    
    func setTimer(interval: TimeInterval, function: @escaping () -> Void) -> Timer {
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            function()
        }
        timer.tolerance = interval * 0.2
        
        return timer
    }
    
    func generateText() {
        let textGenerator = TextGenerator()
        
        backgroundCanvasView.drawing = textGenerator.synthesizeTextDrawing(text: nextAlphabet)
        // MARK: ABCDEFGHIJKLMNOPQRSTUVWXYZ
        // MARK: abcdefghijklmnopqrstuvwxyz
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        textTimer = setTimer(interval: 0.1, function: generateText)
        backgroundCanvasView.backgroundColor = .clear
        backgroundCanvasView.layer.opacity = 0.3
        
        return backgroundCanvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
    }
}

struct AnimationView: UIViewRepresentable {
    @Binding var backgroundCanvasView : PKCanvasView
    @Binding var nowAlphabet : String
    
    @State var animationParametricValue : [CGFloat] = [0.0, 0.0, 0.0, 0.0]
    @State var animationMarkerLayer : [CALayer] = [CALayer(), CALayer(), CALayer(), CALayer()]
    @State var animationStartMarkerLayer : [CALayer] = [CALayer(), CALayer(), CALayer(), CALayer()]
    @State var animationTimer : Timer = Timer()
    @State var animatingStroke : PKStroke?
    
    @State var strokeCount : Int = 0
    @State var backgroundStrokeCount : Int = 0
    @State var strokeTimer : [Bool] = [false, false, false, false]
    
    let viewRoot: UIView = UIView()
    
    func setTimer(interval: TimeInterval, function: @escaping () -> Void) -> Timer {
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            function()
        }
        timer.tolerance = interval * 0.2
        
        return timer
    }
    
    func animateStart() {
        for index in 0...3 {
            animationStartMarkerLayer[index].opacity = 0.0
            animationMarkerLayer[index].opacity = 0.0
        }
        
        if nextAlphabet == "" {
            return
        }
        
        strokeCount = StrokeCount(alphabet: nextAlphabet)
        backgroundStrokeCount = backgroundCanvasView.drawing.strokes.count
        
        if strokeCount != backgroundStrokeCount {
            return
        }
        
        for index in 0..<strokeCount {
            let strokeToAnimate = backgroundCanvasView.drawing.strokes[index]
            animatingStroke = strokeToAnimate
            
            animationStartMarkerLayer[index].position = strokeToAnimate.path.interpolatedLocation(at: 0)
                .applying(strokeToAnimate.transform)
            animationStartMarkerLayer[index].opacity = 1.0
            
            animateStep(strokeIndex: index)
        }
    }
    
    func animateStep(strokeIndex : Int) {
        if nextAlphabet == "" {
            return
        }
        
        let strokeToAnimate = backgroundCanvasView.drawing.strokes[strokeIndex]
        
        
        if strokeTimer[strokeIndex] {
            if animationParametricValue[strokeIndex] <= CGFloat(1.0) {
                strokeTimer[strokeIndex] = false
            }
        
            return
        }
        else {
            if animationParametricValue[strokeIndex] > CGFloat(Double(strokeToAnimate.path.count) - 0.5) {
                strokeTimer[strokeIndex] = true
                animationMarkerLayer[strokeIndex].opacity = 0.0
                animationParametricValue[strokeIndex] = 0.0
            }
        
            animationMarkerLayer[strokeIndex].position = strokeToAnimate.path.interpolatedLocation(at: animationParametricValue[strokeIndex]).applying(strokeToAnimate.transform)
            animationMarkerLayer[strokeIndex].opacity = 1.0
            animationParametricValue[strokeIndex] += 0.5
        }
    }
    
    func makeUIView(context: Context) -> UIView {
        viewSetting()
        animationTimer = setTimer(interval: 0.1, function: animateStart)
        
        return viewRoot
    }
    
    
    
    func viewSetting() {
        animationStartMarkerLayer[0].borderColor = UIColor.red.cgColor
        animationMarkerLayer[0].backgroundColor = UIColor.red.cgColor
        
        animationStartMarkerLayer[1].borderColor = UIColor.blue.cgColor
        animationMarkerLayer[1].backgroundColor = UIColor.blue.cgColor
        
        animationStartMarkerLayer[2].borderColor = UIColor.green.cgColor
        animationMarkerLayer[2].backgroundColor = UIColor.green.cgColor
        
        animationStartMarkerLayer[3].borderColor = UIColor.magenta.cgColor
        animationMarkerLayer[3].backgroundColor = UIColor.magenta.cgColor
        
        for index in 0...3 {
            animationStartMarkerLayer[index].frame = CGRect(x: 0, y: 0, width: 10 + 5 * index, height: 10 + 5 * index)
            animationStartMarkerLayer[index].borderWidth = 2
            animationStartMarkerLayer[index].cornerRadius = 8
            
            animationMarkerLayer[index].frame = CGRect(x: 0, y: 0, width: 10, height: 10)
            animationMarkerLayer[index].cornerRadius = 5
            
            animationMarkerLayer[index].opacity = 0.0
            animationStartMarkerLayer[index].opacity = 0.0
            
            viewRoot.layer.addSublayer(animationStartMarkerLayer[index])
            viewRoot.layer.addSublayer(animationMarkerLayer[index])
        }
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

struct ButtonActionView {
    static var incorrectStrokeCount : Int = 0
    static var score : Double = 0
    
    func Scoring(canvasView: PKCanvasView, backgroundCanvasView: PKCanvasView) -> Double {
        let canvasCount = canvasView.drawing.strokes.count
        let backgroundCount = backgroundCanvasView.drawing.strokes.count
        
        let difficulty: CGFloat = 10.0
        let practiceScale: CGFloat = 2.0
        
        if backgroundCount == 0 {
            ButtonActionView.score = 0
            return ButtonActionView.score
        }
        if canvasCount > backgroundCount {
            canvasView.drawing.strokes.removeAll()
            ButtonActionView.score = 0
            return ButtonActionView.score
        }
        
        for nowIndex in 0..<canvasCount {
            let backDrawing = backgroundCanvasView.drawing
            let nowStroke = canvasView.drawing.strokes[nowIndex]
            
            let threshold: CGFloat = difficulty * practiceScale
            
            var minDistance = 10000.0
            
            for minCacul in 0..<backgroundCount {
                let cacul = nowStroke.discreteFrechetDistance(to: backDrawing.strokes[minCacul], maxThreshold: threshold)
                minDistance = minDistance < cacul ? minDistance : cacul
            }
            
            if minDistance < threshold {
                canvasView.drawing.strokes[nowIndex].ink.color = .green
            }
            else {
                canvasView.drawing.strokes[nowIndex].ink.color = .red
                ButtonActionView.incorrectStrokeCount += 1
            }
            
            ButtonActionView.score = {
                let correctStrokeCount = canvasView.drawing.strokes.count
                return (1.0 / (1.0 + Double(ButtonActionView.incorrectStrokeCount) / Double(1 + correctStrokeCount))) * 100
            }()
        }
        return ButtonActionView.score
    }
    
    func Reseting(canvasView: PKCanvasView, backgroundCanvasView: PKCanvasView) {
        ButtonActionView.score = 0
        canvasView.drawing.strokes.removeAll()
        ButtonActionView.incorrectStrokeCount = 0
    }
}

struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    
    var ink: PKInkingTool {
        PKInkingTool(.pen, color: .yellow, width: 10)
    }
     
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.tool = ink
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
