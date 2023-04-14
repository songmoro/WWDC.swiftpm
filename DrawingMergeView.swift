//
//  ContentView.swift
//  SwiftUIPlayground
//
//  Created by 송재훈 on 2023/03/26.
//
import SwiftUI
import PencilKit

// TODO: 백그라운드 추가
// TODO: 체력 게이지 추가
// TODO: 공격 방식 설정
// TODO: 스코어링 조정
// TODO: 리셋 버튼 구현
// TODO: 애니메이션 추가 구현

struct DrawingMergeView: View {
    @State var backgroundCanvasView = PKCanvasView()
    @State var canvasView = PKCanvasView()
    @State var score : Double = 0
    @State var strokeCounter : Int = 0
    @State var nowAlphabet : String = "A"
    @State var incorrectStrokeCount = 0
//    var animationSpeed: CGFloat = 1.0
    
    func Scoring() {
        let lastIndex = canvasView.drawing.strokes.count
        
        var difficulty: CGFloat = 5.0
        var practiceScale: CGFloat = 2.0
        
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
               incorrectStrokeCount += 1
           }
            
            score = {
                let correctStrokeCount = canvasView.drawing.strokes.count
                return 1.0 / (1.0 + Double(incorrectStrokeCount) / Double(1 + correctStrokeCount))
            }()
        }
    }
    
    func Reseting() {
        canvasView.drawing.strokes.removeAll()
        incorrectStrokeCount = 0
    }
    
    var body: some View {
        GeometryReader() { geo in
//            TextGeneratorView(backgroundCanvasView: $backgroundCanvasView, nowAlphabet: $nowAlphabet)

            AnimateView(canvasView: $canvasView, backgroundCanvasView: $backgroundCanvasView)

            CanvasView(canvasView: $canvasView)

        }
    }
}



struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    
    var ink: PKInkingTool {
        PKInkingTool(.pen, color: .systemBlue, width: 10)
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

struct AnimateView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var backgroundCanvasView: PKCanvasView
    
    static var animatingStroke: PKStroke?
    @State var animationParametricValue: CGFloat = 0
    @State var animationSpeed: CGFloat = 1.0
    @State var animationMarkerLayer = CALayer()
    @State var animationStartMarkerLayer = CALayer()
    @State var animationTimer: Timer?
    @State var nextStrokeCount: Int = 0
    @State var maxStrokeCount: Int = 0
    @State var nowStrokeCount: CGFloat = 0
    
    @State var isRepeat: Bool = true
    
    @State var ca = CALayer()
    
    static let repeatStrokeAnimationTime: TimeInterval = 2
    static let nextStrokeAnimationTime: TimeInterval = 0.5
    
    let viewRoot: UIView = UIView()
    
    // TODO: 백드로잉 말고 캔버스드로잉 수정
    func animateStart() {
        let nextStrokeIndex = canvasView.drawing.strokes.count
        
        guard nextStrokeIndex < backgroundCanvasView.drawing.strokes.count else {
            // Hide the animation markers.
//            animationMarkerLayer.opacity = 0.0
//            animationStartMarkerLayer.opacity = 0.0
            
            dump(nextStrokeIndex)
            dump(backgroundCanvasView.drawing.strokes.count)
            return
        }
        let strokeToAnimate = backgroundCanvasView.drawing.strokes[nextStrokeIndex]
        AnimateView.animatingStroke = strokeToAnimate
        
        animationParametricValue = 0
        
        animationStartMarkerLayer.position = strokeToAnimate.path.interpolatedLocation(at: 0).applying(strokeToAnimate.transform)
//        animationStartMarkerLayer.position = CGPoint(x: 600, y: 0)
        animationStartMarkerLayer.opacity = 1.0
        
        ca.position = CGPoint(x: 100, y: 100)
        
        animationTimer?.invalidate()
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 10, repeats: true){ _ in
                animationStep()
        }
    }

    func animationStep() {
        guard let animatingStroke = AnimateView.animatingStroke, animationParametricValue < CGFloat(Double(animatingStroke.path.count) - 0.5) else {
            
            animationTimer?.invalidate()
            
            _ = Timer.scheduledTimer(withTimeInterval: AnimateView.repeatStrokeAnimationTime, repeats: false) { _ in
            
                animationMarkerLayer.opacity = 0
                animationParametricValue = 0
//                animationTimer?.invalidate()
                
                animateStart()
            }
            
            return
        }
        
        animationMarkerLayer.position = animatingStroke.path.interpolatedLocation(at: animationParametricValue)
            .applying(animatingStroke.transform)
        animationMarkerLayer.opacity = 1
        animationParametricValue += 0.5
    }
    
    func makeLayer() {
        animationMarkerLayer.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        animationMarkerLayer.backgroundColor = UIColor.red.cgColor
        animationMarkerLayer.cornerRadius = 5
        viewRoot.layer.addSublayer(animationMarkerLayer)
        
        animationStartMarkerLayer.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        animationStartMarkerLayer.borderColor = UIColor.gray.cgColor
        animationStartMarkerLayer.borderWidth = 2
        animationStartMarkerLayer.cornerRadius = 8
        viewRoot.layer.addSublayer(animationStartMarkerLayer)
        
        
        ca.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        ca.backgroundColor = UIColor.red.cgColor
        viewRoot.layer.addSublayer(ca)
        
        maxStrokeCount = backgroundCanvasView.drawing.strokes.count
    }
    
    func makeUIView(context: Context) -> UIView {
        makeLayer()
        
        animateStart()
        
        return viewRoot
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

struct DrawingMergeView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingMergeView()
    }
}
