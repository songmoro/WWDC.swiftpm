//
//  DisplayView.swift
//  WWDC
//
//  Created by 송재훈 on 2023/03/15.

import SwiftUI
import SpriteKit
import PencilKit

class StateViewModel: ObservableObject {
    @Published var isInt : Double = 100.0
}

var isin : Double = 100.0

struct PhysicsCategory {
    static let player: UInt32 = 0b0001
    static let alien: UInt32 = 0b0010
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var winner = SKLabelNode(fontNamed: "Chalkduster")
    var alienTimer = Timer()
    var alienInterval: TimeInterval = 10.0
    
    @StateObject var stateViewModel = StateViewModel()
    
    var score : Double = 100.0 {
        didSet {
            stateViewModel.isInt -= 10
        }
    }
    
//    @StateObject var isInt = StateViewModel()
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(.white)
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        addPlayer()
        
        alienTimer = setTimer(interval: alienInterval, function: self.addAlien)
        
        winner.fontSize = 65
        winner.fontColor = SKColor.black
        winner.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(winner)
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var location: CGPoint!
        
        if let touch = touches.first {
            location = touch.location(in: self)
        }
        
        let touchedNodes = nodes(at: location)
        let frontTouchedNode = atPoint(location).name
        let frontTouches = atPoint(location).physicsBody?.categoryBitMask
        
        if frontTouches == nil {
            score -= 1
        }
        else {
        }
        winner.text = "\(score)"
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
        alien.position = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.9)
        alien.name = "alien"
        
        alien.physicsBody = SKPhysicsBody(circleOfRadius: alien.size.height / 2)
        alien.physicsBody?.categoryBitMask = PhysicsCategory.alien
        alien.physicsBody?.affectedByGravity = false
        alien.physicsBody?.isDynamic = false
        alien.physicsBody?.contactTestBitMask = PhysicsCategory.player
        alien.physicsBody?.collisionBitMask = PhysicsCategory.player
        
        self.addChild(alien)
        
        let moveAct = SKAction.moveBy(x: 0, y: -alien.size.height, duration: 0.1)
        let waitAct = SKAction.wait(forDuration: 5)
        
        let sequence = SKAction.sequence([moveAct, waitAct])
        alien.run(SKAction.repeatForever(sequence))
    }
    
    func addPlayer() {
        let player = SKSpriteNode(color: .clear, size: CGSize(width: frame.size.width * 2, height: frame.size.height * 0.5))
        
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.size.width * 2, height: frame.size.height * 0.5))
        
        player.physicsBody?.affectedByGravity = false
        
        player.name = "player"
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.collisionBitMask = PhysicsCategory.player
        
        self.addChild(player)
    }
    
    func addCanvasView() {
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
    
        if firstBody.node?.name == "player" && secondBody.node?.name == "alien" {
            secondBody.node?.removeFromParent()
        }
    }
}

// MARK: ABCDEFGHIJKLMNOPQRSTUVWXYZ
// MARK: abcdefghijklmnopqrstuvwxyz

struct DisplayView: View {
    @State var canvasView = PKCanvasView()
    @State var backgroundView = PKCanvasView()
    @State var nowAlphabet : String = "Z"
    
    @State var currentHP : Double = 100
    
    @StateObject var isInt = StateViewModel()
    
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
            
            AnimateView(canvasView: $canvasView, backgroundCanvasView: $backgroundView)
                .frame(width: geo.size.width, height: geo.size.height * 0.25)
                .border(.pink)
                .frame(maxHeight: .infinity, alignment: .bottom)

            CanvasView(canvasView: $canvasView)
                .border(.pink)
                .frame(width: geo.size.width, height: geo.size.height * 0.25)
                .frame(maxHeight: .infinity, alignment: .bottom)
                
            HPView(currentHP: $isInt.isInt)

            ButtonActionView(score: $isInt.isInt, canvasView: $canvasView, backgroundCanvasView: $backgroundView)
                .offset(y: geo.size.height * 0.06)

        }
    }
}

struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayView()
    }
}
