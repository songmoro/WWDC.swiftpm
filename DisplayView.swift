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

struct PhysicsCategory {
    static let player: UInt32 = 0b0001
    static let alien: UInt32 = 0b0010
}

var nextAlphabet : String = ""
var nextNumber : Int = 0

var isScore : Double = 0.0
var isRemove : Bool = false
var isStart : Bool = false

class GameScene: SKScene, SKPhysicsContactDelegate {
    var winner = SKLabelNode(fontNamed: "Chalkduster")
    var banner = SKLabelNode(fontNamed: "Chalkduster")
    var alienTimer = Timer()
    var alienInterval: TimeInterval = 4.0
    
    var addNumber : Int = 0
    
    override func didMove(to view: SKView) {
        print("GameScene didMove")
        
        backgroundColor = UIColor(.white)
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        addPlayer()
        
        alienTimer = setTimer(interval: alienInterval, function: self.addAlien)
        
        winner.fontSize = 65
        winner.fontColor = SKColor.black
        winner.position = CGPoint(x: frame.midX, y: frame.midY)
        
        addChild(winner)
        
        banner.fontSize = 65
        banner.fontColor = SKColor.systemPink
        banner.position = CGPoint(x: frame.midX, y: frame.midY + 60)
        
        addChild(banner)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isStart {
            if isRemove {
                self.childNode(withName: "\(nextAlphabet)")?.removeFromParent()
                
                nextAlphabet = ""
                isRemove = false
            }
            //            winner.text = "\(isScore)"
            //            banner.text = "\(nextAlphabet)"
        }
        else {
            banner.text = "Click here to Start"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isStart {
            var location: CGPoint!
            
            if let touch = touches.first {
                location = touch.location(in: self)
            }
                        let touchedNodes = nodes(at: location)
    
            let frontTouchedNode = atPoint(location).name
            if frontTouchedNode != nil {
                let alphabet = "\(frontTouchedNode!)"
                winner.text = "\(alphabet)"
                nextAlphabet = alphabet
                
                let timeIndex = alphabet.index(alphabet.startIndex, offsetBy: 1)
                let i = alphabet[timeIndex...]
                nextNumber = Int(i)!
                
//                self.childNode(withName: alphabet)?.speed *= 1.5
            }
            //            alienTimer.invalidate()
            //            self.childNode(withName: "alienA")?.removeFromParent()
        }
        else {
            isStart = true
            self.removeAllChildren()
            alienTimer.invalidate()
            
            addPlayer()
            addChild(winner)
            alienTimer = setTimer(interval: alienInterval, function: self.addAlien)
        }
    }
    
    func setTimer(interval: TimeInterval, function: @escaping () -> Void) -> Timer {
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            function()
        }
        timer.tolerance = interval * 0.2
        
        return timer
    }
    
    func addAlien() {
        let alien = SKSpriteNode(imageNamed: "aImage")
        
        alien.size = CGSize(width: frame.size.width * 0.05, height: frame.size.height * 0.05)
        alien.position = CGPoint(x: frame.size.width * 0.05, y: frame.size.height * 0.9)
        
        let isUpper = Int.random(in: 0...1)
        let isRandom = Int.random(in: 65...90)
        let isAlphabet = UnicodeScalar(isRandom + isUpper * 32)
        nextNumber = addNumber
        
//        addTuple.append((String(describing: isAlphabet!), addNumber))
        alien.name = "\(String(describing: isAlphabet!))\(addNumber)"
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
        
        //        let moveLeftAct = SKAction.moveBy(x: -alien.size.width - 10, y: 0, duration: 1)
        //        let moveRightAct = SKAction.moveBy(x: alien.size.width + 10, y: 0, duration: 1)
        //        let moveDownAct = SKAction.moveBy(x: 0, y: -alien.size.height - 10, duration: 1)
        let moveLeftAct = SKAction.moveBy(x: -widthScale, y: 0, duration: 1)
        let moveRightAct = SKAction.moveBy(x: widthScale, y: 0, duration: 1)
        let moveDownAct = SKAction.moveBy(x: 0, y: -heightScale, duration: 0.1)
        
        let waitAct = SKAction.wait(forDuration: 1)
        //        let removeAct = SKAction.removeFromParent()
        
        var arrayAct : [SKAction] = []
        
        for _ in 0...8 {
            arrayAct.append(moveRightAct)
            arrayAct.append(waitAct)
        }
        arrayAct.append(moveDownAct)
        arrayAct.append(waitAct)
        
        for _ in 0...8 {
            arrayAct.append(moveLeftAct)
            arrayAct.append(waitAct)
        }
        arrayAct.append(moveDownAct)
        arrayAct.append(waitAct)
        
        //        let sequence = SKAction.sequence([moveAct, waitAct])
        let seq = SKAction.sequence(arrayAct)
        //        alien.run(seq)
        alien.run(SKAction.repeatForever(seq))
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
//        if firstBody.node?.name == "player" && secondBody.node?.name == "*" {
//            secondBody.node?.removeFromParent()
//        }

        if firstBody.node?.physicsBody!.categoryBitMask == PhysicsCategory.player && secondBody.node?.physicsBody!.categoryBitMask == PhysicsCategory.alien {
//            secondBody.node?.removeFromParent()
            self.removeAllChildren()
            isStart = false
        }
    }
}

// MARK: ABCDEFGHIJKLMNOPQRSTUVWXYZ
// MARK: abcdefghijklmnopqrstuvwxyz

struct DisplayView: View {
    @State var canvasView = PKCanvasView()
    @State var backgroundView = PKCanvasView()
    @State var nowAlphabet : String = ""
    //    @State var currentHP : Double = 0
    
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
                .border(.pink)
                .frame(maxHeight: .infinity, alignment: .bottom)
            
            
            // MARK: 작게 조정해서 안 뜨는 듯
//            AnimateView(canvasView: $canvasView, backgroundCanvasView: $backgroundView)
//                .frame(width: geo.size.width, height: geo.size.height * 0.25)
//                .border(.pink)
//                .frame(maxHeight: .infinity, alignment: .bottom)
            
            CanvasView(canvasView: $canvasView)
                .border(.pink)
                .frame(width: geo.size.width, height: geo.size.height * 0.25)
                .frame(maxHeight: .infinity, alignment: .bottom)
            
            //            HPView(currentHP: $currentHP)
            
            //            ButtonActionView(score: $isInt.isInt, canvasView: $canvasView, backgroundCanvasView: $backgroundView)
            //                .offset(y: geo.size.height * 0.06)
            
            HStack() {
                Button {
                    
                    let button = ButtonActionVie()
                    
                    button.Reseting(canvasView: canvasView, backgroundCanvasView: backgroundView)
                } label: {
                    Image(systemName: "eraser")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.15)
                        .padding(.leading, geo.size.width * 0.1)
                }

                Spacer()
                
                Button {
                    let button = ButtonActionVie()
                    
                    isScore = button.Scoring(canvasView: canvasView, backgroundCanvasView: backgroundView)
                    //                    currentHP = isScore
                    
                    if isScore >= 100 {
                        button.Reseting(canvasView: canvasView, backgroundCanvasView: backgroundView)
                        isScore = 0
                        isRemove = true
                    }
                    
//                    nowAlphabet = nextAlphabet.description
//                    nowAlphabet = nextAlphabet
                } label: {
                    Image(systemName: "paperplane")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.15)
                        .padding(.trailing, geo.size.width * 0.1)
                    
                }
            }
                .frame(width: geo.size.width, height: geo.size.height * 0.25)
                .border(.pink)
                .frame(maxHeight: .infinity, alignment: .bottom)
            
            VStack() {
                Text("nowAlphabet \(nowAlphabet)")
                Text("nextAlphabet \(nextAlphabet)")
                Text("nextNumber \(nextNumber)")
                Text("isRemove \(isRemove.description)")
            }
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
        
        generateText()
        backgroundCanvasView.backgroundColor = .clear
        
        return backgroundCanvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        generateText()
    }
}

struct ButtonActionVie {
    static var incorrectStrokeCount : Int = 0
    static var score : Double = 0
    
    func Scoring(canvasView: PKCanvasView, backgroundCanvasView: PKCanvasView) -> Double {
        let lastIndex = canvasView.drawing.strokes.count
        let strokesCount = backgroundCanvasView.drawing.strokes.count
        
        var difficulty: CGFloat = 5.0
        var practiceScale: CGFloat = 2.0
        
        if strokesCount == 0 {
            ButtonActionVie.score = 0
            return ButtonActionVie.score
        }
        if lastIndex > strokesCount {
            let strokesIndex = canvasView.drawing.strokes.endIndex
            
            for nowIndex in 0..<strokesIndex {
                canvasView.drawing.strokes[nowIndex].ink.color = .red
            }

            ButtonActionVie.score = 0
            return ButtonActionVie.score
        }
        //        guard let lastStroke = canvasView.drawing.strokes.last else { return }
        //        guard strokeIndex < testDrawing.strokes.count else { return }
        
        for nowIndex in 0..<lastIndex {
            let backDrawing = backgroundCanvasView.drawing
            let nowStroke = canvasView.drawing.strokes[nowIndex]
            
            let threshold: CGFloat = difficulty * practiceScale
            let distance = nowStroke.discreteFrechetDistance(to: backDrawing.strokes[nowIndex], maxThreshold: threshold)
            
            if distance < threshold {
               canvasView.drawing.strokes[nowIndex].ink.color = .green
           }
           else {
//               canvasView.drawing.strokes.remove(at: nowIndex)
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
