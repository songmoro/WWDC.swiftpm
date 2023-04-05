//
//  DisplayView.swift
//  WWDC
//
//  Created by 송재훈 on 2023/03/15.


import SwiftUI
import SpriteKit

class GameScene: SKScene {
        var background = "Image"
//    var background = SKSpriteNode(imageNamed: "Image")
    
    override func didMove(to view: SKView) {
        
        let groundCircle = SKShapeNode(ellipseOf: CGSize(width: frame.size.width * 3, height: frame.size.height))
        
        groundCircle.strokeColor = .black
//        arc.fillColor = .green
        
        groundCircle.position = CGPoint(x: frame.size.width / 2, y: -frame.size.height / 4)
        addChild(groundCircle)
        
//        let path = CGMutablePath()
//        path.addArc(center: CGPoint.zero,
//                    radius: frame.size.width / 2,
//                    startAngle: .pi,
//                    endAngle: 0,
//                    clockwise: true)
//
//        let ball = SKShapeNode(path: path)
//
//        ball.lineWidth = 1
//        ball.fillColor = .blue
//        ball.strokeColor = .black
//        ball.glowWidth = 0.5
//        ball.position = CGPoint(x: 300, y: 300)
        
//        addChild(ball)
        
//        let grass = SKShapeNode(path: CGPath()
        
//        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        backgroundColor = UIColor(.white)
        
//        groundCircle.physicsBody = SKp
//
//        background.size = CGSize(width: frame.size.width, height: frame.size.height / 5)
//        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 6)
//        addChild(background)
        
//        moveBackground(image: background, y: -500, z: -5, duration: 10, needPhysics: false, size: self.size)
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        guard let touch = touches.first else { return }
//
//        let location = touch.location(in: self)
//
//        let box = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
//
//        box.position = location
//
//        box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
//
//        addChild(box)
//    }
    
    func moveBackground(image: String, y: CGFloat, z: CGFloat, duration: Double, needPhysics: Bool, size: CGSize){
        for i in 0...1{
            let background = SKSpriteNode(imageNamed: image)

            background.anchorPoint = .zero
            background.position = CGPoint(x: size.width * CGFloat(i), y: y)
            background.size = size
            background.zPosition = z

            if needPhysics {
                background.physicsBody = SKPhysicsBody(rectangleOf: background.size)
                background.physicsBody?.isDynamic = false
                background.physicsBody?.contactTestBitMask = 1
                background.name = "background"
            }

            let move = SKAction.moveBy(x: -background.size.width, y: 0, duration: duration)
            let back = SKAction.moveBy(x: background.size.width, y: 0, duration: 0)

            let sequence = SKAction.sequence([move,back])
            let repeatAction = SKAction.repeatForever(sequence)

            addChild(background)

            background.run(repeatAction)
        }
    }
}

struct DisplayView: View {
    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: 1000, height: 1200)
    
        scene.scaleMode = .fill
        return scene
    }
    
    var body: some View {
        
        ZStack(){
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .frame(width: 1000, height: 1200)
            DrawingHelperView()
                .frame(width: 300, height: 300)
                .offset(x:-300)
            
            VStack(){
                    Image("ufo")
                        .resizable()
                        .frame(width: 200, height: 200)
                    Image("aImage")
                        .resizable()
                        .frame(width: 200, height: 200)
            }
            .offset(x:400)
        }
    }
}

struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayView()
    }
}
