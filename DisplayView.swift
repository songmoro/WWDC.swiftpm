//
//  DisplayView.swift
//  WWDC
//
//  Created by 송재훈 on 2023/03/15.

import SwiftUI
import SpriteKit
import PencilKit

// TODO: Scoring 조정하기
// TODO: UFO, ABCD... 프로크리에이트
// TODO: animation 조정
// TODO: 공격 func 만들기
// TODO: 터치한 node에 대한 TextGenerator 수정
// MARK: TextGenerator에는 영어만 표기됨
// TODO: scoring 고치기
// TODO: alien 선택 시 그리라고 하기, 선택 해제 시 선택하라고 하기

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
    
    var asciiValue = alphabet.first?.asciiValue
    let intValue = Int(asciiValue!)
    
    if intValue >= 97 && intValue <= 122 {
        return lowercaseStrokeCount[intValue - 97]
    } else if intValue >= 65 && intValue <= 90 {
        return uppercaseStrokeCount[intValue - 65]
    }
    
    return 0
}

enum GameState {
    case ready
    case playing
    case end
}

var gameState = GameState.ready

var nextAlphabet : String = ""
var nextNumber : Int = 0

var isScore : Double = 0.0
var isRemove : Bool = false
var isStart : Bool = false

class GameScene: SKScene, SKPhysicsContactDelegate {
    var descriptBanner = SKLabelNode(fontNamed: "Chalkduster")
    let backgroundImage = SKSpriteNode(imageNamed: "backgroundImage")
    
    var alienTimer = Timer()
    var alienInterval: TimeInterval = 4.0
    var alienSpeed : CGFloat = 1.0
    var addNumber : Int = 0
    
    var Banner = SKLabelNode(fontNamed: "Chalkduster")
    var animate = SKSpriteNode(color: .blue, size: CGSize(width: 20, height: 20))
    var backgroundCanvasView = PKCanvasView()
    var textGenerator = TextGenerator()
    var animatingStroke : PKStroke?
    var animationParametricValue : CGFloat = 0
    
    var animateTimer = Timer()
    
    var gameScore : Int = 0
    
    override func didMove(to view: SKView) {
        print("GameScene didMove")
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        descriptBanner.fontSize = 65
        descriptBanner.fontColor = SKColor.white
        descriptBanner.position = CGPoint(x: frame.midX, y: frame.midY)
        descriptBanner.text = "Click here to start"
        
        backgroundImage.zPosition = -1
        backgroundImage.size = CGSize(width: frame.size.width, height: frame.size.height)
        backgroundImage.anchorPoint = CGPoint(x: 0, y: 0)
        
        alienTimer = setTimer(interval: alienInterval, function: self.addAlien)
        
        playingSetting()
    }
    
    override func update(_ currentTime: TimeInterval) {
        switch gameState {
        case .ready:
            break
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
                descriptBanner.text = "Click any alien"
            }
        case .end:
            descriptBanner.text = "Game Over!"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameState {
        case .ready:
            gameState = .playing
            alienTimer.invalidate()
            
            removeAllChildren()
            
            playingSetting()
            
            descriptBanner.text = "Click any alien"
            alienSpeed = 1.0
            gameScore = 0
            addNumber = 0
            alienTimer = setTimer(interval: alienInterval, function: self.addAlien)
        
        case .playing:
            var location: CGPoint!
            
            if let touch = touches.first {
                location = touch.location(in: self)
            }
//            let touchedNodes = nodes(at: location)
            
            let frontTouchedNode = atPoint(location).name
            
            if frontTouchedNode != nil {
                let alphabet = "\(frontTouchedNode!)"
//                descriptBanner.text = "\(alphabet)"
                descriptBanner.text = "Draw and Send!"
                nextAlphabet = alphabet
                
                let timeIndex = alphabet.index(alphabet.startIndex, offsetBy: 1)
                let i = alphabet[timeIndex...]
                
                nextNumber = Int(i)!
            }
        case .end:
            descriptBanner.text = "Game Over!"
        }
    }
    
    func addBackground() {
        addChild(backgroundImage)
    }
    
    func addDescriptBanner() {
        addChild(descriptBanner)
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
    
    func addAlien() {
        let alienAlphabet = randomAlphabet()
        let alien = SKSpriteNode(imageNamed: alienAlphabet)
        alien.size = CGSize(width: frame.size.width * 0.05, height: frame.size.height * 0.05)
        alien.position = CGPoint(x: frame.size.width * 0.05, y: frame.size.height * 0.9)
        alien.speed = alienSpeed
        
        alienSpeed *= 1.02
        nextNumber = addNumber
        
        alien.name = "\(alienAlphabet)\(addNumber)"
        addNumber += 1
        
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
        
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.size.width * 2, height: frame.size.height * 0.5))
        
        player.physicsBody?.affectedByGravity = false
        
        player.name = "player"
        player.color = .clear
        
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.collisionBitMask = PhysicsCategory.player
        
        self.addChild(player)
    }
    
//    func addAnimate() {
//        Banner.fontSize = 65
//        Banner.fontColor = SKColor.white
//        Banner.position = CGPoint(x: frame.midX, y: frame.midY - 100)
//
//        backgroundCanvasView.drawing = textGenerator.synthesizeTextDrawing(text: "G")
//
//        var pathtest = CGMutablePath()
//
//        for index2 in 0..<backgroundCanvasView.drawing.strokes.count {
//            var strokeToAnimate = backgroundCanvasView.drawing.strokes[index2]
//            var pathArray : [CGPoint] = []
//
//            let path = strokeToAnimate.path
//
//            animationParametricValue = 0
//
//            while(Int(animationParametricValue) < path.count - 1) {
//                pathArray.append(strokeToAnimate.path.interpolatedLocation(at: animationParametricValue))
//                animationParametricValue += 0.5
//            }
//            pathtest.addLines(between: pathArray)
//        }
//
//        var pathtestnode = SKShapeNode(path: pathtest)
//        pathtestnode.lineWidth = 3
//
//        pathtestnode.yScale = -4
//        pathtestnode.xScale = 4
//        // MARK: 300씩
////        pathtestnode.position = CGPoint(x: frame.midX - 1450, y: frame.midY + 100)
//        pathtestnode.position = CGPoint(x: frame.midX - 300 * 7, y: frame.midY)
//
//        addChild(pathtestnode)
//        addChild(animate)
//        addChild(Banner)
//    }
    
    func playingSetting() {
        addBackground()
        addDescriptBanner()
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
            case .ready:
                self.removeAllChildren()
                playingSetting()
                
            case .playing:
                self.removeAllChildren()
                alienTimer.invalidate()
                playingSetting()
                gameState = .end
                
            case .end:
                break
            }
        }
    }
}

// MARK: ABCDEFGHIJKLMNOPQRSTUVWXYZ
// MARK: abcdefghijklmnopqrstuvwxyz

struct DisplayView: View {
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
            
            animationView(backgroundCanvasView: $backgroundView, nowAlphabet: $nowAlphabet)
                .frame(width: geo.size.width, height: geo.size.height * 0.25)
                .frame(maxHeight: .infinity, alignment: .bottom)
            
            CanvasView(canvasView: $canvasView)
                .frame(width: geo.size.width, height: geo.size.height * 0.25)
                .frame(maxHeight: .infinity, alignment: .bottom)

            HStack() {
                Button {
                    let button = ButtonActionVie()
                    
                    button.Reseting(canvasView: canvasView, backgroundCanvasView: backgroundView)
                } label: {
                    Image(systemName: "eraser")
                        .resizable()
                        .foregroundColor(.white)
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.15)
                        .padding(.leading, geo.size.width * 0.1)
                }
                
                Spacer()
                
                Button {
                    let button = ButtonActionVie()
                    
                    isScore = button.Scoring(canvasView: canvasView, backgroundCanvasView: backgroundView)
                    
                    if isScore >= 100 {
                        button.Reseting(canvasView: canvasView, backgroundCanvasView: backgroundView)
                        isScore = 0
                        isRemove = true
                    }
                    
                } label: {
                    Image(systemName: "paperplane")
                        .resizable()
                        .foregroundColor(.white)
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.15)
                        .padding(.trailing, geo.size.width * 0.1)
                    
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
        
        return backgroundCanvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        generateText()
    }
}

struct animationView: UIViewRepresentable {
    @Binding var backgroundCanvasView: PKCanvasView
    @Binding var nowAlphabet : String
    
    
//    @State var animationParametricValue: CGFloat = 0
//    @State var animationSpeed: CGFloat = 1.0
    @State var animationMarkerLayer : [CALayer] = [CALayer(), CALayer(), CALayer(), CALayer()]
    @State var animationStartMarkerLayer : [CALayer] = [CALayer(), CALayer(), CALayer(), CALayer()]
    @State var animationTimer = Timer()
    @State var animatingStroke : PKStroke?
    
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
        }
        
        if nextAlphabet == "" {
            return
        }
        
        var strokeCount = StrokeCount(alphabet: nextAlphabet)
        var backgroundCanvasCount = backgroundCanvasView.drawing.strokes.count
        
        if strokeCount != backgroundCanvasCount {
            return
        }
        
        for index in 0..<strokeCount {
            
            let strokeToAnimate = backgroundCanvasView.drawing.strokes[index]
            
            animatingStroke = strokeToAnimate

            animationStartMarkerLayer[index].position = strokeToAnimate.path.interpolatedLocation(at: 0)
                .applying(strokeToAnimate.transform)
            animationStartMarkerLayer[index].opacity = 1.0
        }
    }
    
    func animateStep() {
    //        guard let animatingStroke = AnimateView.animatingStroke, animationParametricValue < CGFloat(Double(animatingStroke.path.count) - 0.5) else {
    //
    ////            animationTimer.invalidate()
    //
    ////            _ = Timer.scheduledTimer(withTimeInterval: AnimateView.repeatStrokeAnimationTime, repeats: false) { _ in
    ////
    ////                animationMarkerLayer.opacity = 0
    ////                animationParametricValue = 0
    //////                animationTimer?.invalidate()
    ////
    ////                animateStart()
    ////            }
    //
    //            return
    //        }
            
    //        animationMarkerLayer.position = animatingStroke.path.interpolatedLocation(at: animationParametricValue)
    //            .applying(animatingStroke.transform)
    //        animationMarkerLayer.opacity = 1
    //        animationParametricValue += 0.5
    }

    func makeUIView(context: Context) -> UIView {
//        animationMarkerLayer.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
//        animationMarkerLayer.backgroundColor = UIColor.red.cgColor
//        animationMarkerLayer.cornerRadius = 5
//        viewRoot.layer.addSublayer(animationMarkerLayer)
        
//        animationStartMarkerLayer.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
//        animationStartMarkerLayer.borderColor = UIColor.gray.cgColor
//        animationStartMarkerLayer.borderWidth = 2
//        animationStartMarkerLayer.cornerRadius = 8
//        viewRoot.layer.addSublayer(animationStartMarkerLayer)

        animationStartMarkerLayer[0].frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        animationStartMarkerLayer[0].borderColor = UIColor.red.cgColor
        animationStartMarkerLayer[0].borderWidth = 2
        animationStartMarkerLayer[0].cornerRadius = 8
        viewRoot.layer.addSublayer(animationStartMarkerLayer[0])
        
        animationStartMarkerLayer[1].frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        animationStartMarkerLayer[1].borderColor = UIColor.blue.cgColor
        animationStartMarkerLayer[1].borderWidth = 2
        animationStartMarkerLayer[1].cornerRadius = 8
        viewRoot.layer.addSublayer(animationStartMarkerLayer[1])
        
        animationStartMarkerLayer[2].frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        animationStartMarkerLayer[2].borderColor = UIColor.green.cgColor
        animationStartMarkerLayer[2].borderWidth = 2
        animationStartMarkerLayer[2].cornerRadius = 8
        viewRoot.layer.addSublayer(animationStartMarkerLayer[2])
        
        animationStartMarkerLayer[3].frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        animationStartMarkerLayer[3].borderColor = UIColor.purple.cgColor
        animationStartMarkerLayer[3].borderWidth = 2
        animationStartMarkerLayer[3].cornerRadius = 8
        viewRoot.layer.addSublayer(animationStartMarkerLayer[3])
        
        animationTimer = setTimer(interval: 0.1, function: animateStart)
        
        return viewRoot
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        animateStart()
    }
}

struct ButtonActionVie {
    static var incorrectStrokeCount : Int = 0
    static var score : Double = 0
    
    func Scoring(canvasView: PKCanvasView, backgroundCanvasView: PKCanvasView) -> Double {
        let lastIndex = canvasView.drawing.strokes.count
        let strokesCount = backgroundCanvasView.drawing.strokes.count
        
//        let difficulty: CGFloat = 10.0
        let difficulty: CGFloat = 10.0
        let practiceScale: CGFloat = 3.0
        
//        let strokeCount = StrokeCount(alphabet: nextAlphabet) // 알파벳 카운트 로딩
        
        if strokesCount == 0 {
            ButtonActionVie.score = 0
            return ButtonActionVie.score
        }
        if lastIndex > strokesCount {
            let strokesIndex = canvasView.drawing.strokes.endIndex
            
//            for nowIndex in 0..<strokesIndex {
//                canvasView.drawing.strokes[nowIndex].ink.color = .red
//            }

            canvasView.drawing.strokes.removeAll()
            ButtonActionVie.score = 0
            return ButtonActionVie.score
        }
        
        for nowIndex in 0..<lastIndex {
            let backDrawing = backgroundCanvasView.drawing
            let nowStroke = canvasView.drawing.strokes[nowIndex]
            
            let threshold: CGFloat = difficulty * practiceScale
            
            var minDistance = 10000.0
            
            for minCacul in 0..<strokesCount {
                let cacul = nowStroke.discreteFrechetDistance(to: backDrawing.strokes[minCacul], maxThreshold: threshold)
                minDistance = minDistance < cacul ? minDistance : cacul
            }
            
//            let distance = nowStroke.discreteFrechetDistance(to: backDrawing.strokes[nowIndex], maxThreshold: threshold)
            
//            if distance < threshold {
//               canvasView.drawing.strokes[nowIndex].ink.color = .green
//           }
//           else {
//               canvasView.drawing.strokes[nowIndex].ink.color = .red
//               ButtonActionVie.incorrectStrokeCount += 1
//           }
            
            if minDistance < threshold {
               canvasView.drawing.strokes[nowIndex].ink.color = .green
           }
           else {
               canvasView.drawing.strokes[nowIndex].ink.color = .red
               ButtonActionVie.incorrectStrokeCount += 1
           }
            
            ButtonActionVie.score = {
                let correctStrokeCount = canvasView.drawing.strokes.count
               return (1.0 / (1.0 + Double(ButtonActionVie.incorrectStrokeCount) / Double(1 + correctStrokeCount))) * 100
            }()
        }
        
        return ButtonActionVie.score
    }
    
    func Reseting(canvasView: PKCanvasView, backgroundCanvasView: PKCanvasView) {
        ButtonActionVie.score = 0
        canvasView.drawing.strokes.removeAll()
        ButtonActionVie.incorrectStrokeCount = 0
    }
}


struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayView()
    }
}
