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
    @State var but : Int = 0
    @State var incorrectStrokeCount = 0
    @State var strokeCounter : Int = 0
    
    @State var isScoring : Bool = false
    @State var isReseting : Bool = false
    
    var practiceScale: CGFloat = 2.0
    var animationSpeed: CGFloat = 1.0
    var difficulty: CGFloat = 5.0
    
    func Scoring() {
        let testDrawing = backgroundCanvasView.drawing
        let strokeIndex = canvasView.drawing.strokes.count - 1

        // Score the last stroke.
        guard let lastStroke = canvasView.drawing.strokes.last else { return }
        guard strokeIndex < testDrawing.strokes.count else { return }

//                isUpdatingDrawing = true

        // Stroke matching.
        let threshold: CGFloat = difficulty * practiceScale
        let distance = lastStroke.discreteFrechetDistance(to: testDrawing.strokes[strokeIndex], maxThreshold: threshold)

        if distance < threshold {
            // Adjust the correct stroke to have a green ink.
            canvasView.drawing.strokes[strokeIndex].ink.color = .green

            // If the user has finished, show the final score.
            if strokeIndex + 1 >= testDrawing.strokes.count {
                //                performSegue(withIdentifier: "showScore", sender: self)
            }
        } else {
            //            // If the stroke drawn was bad, remove it so the user can try again.
            canvasView.drawing.strokes.removeLast()
            incorrectStrokeCount += 1
        }
        score = {
            let correctStrokeCount = canvasView.drawing.strokes.count
            return 1.0 / (1.0 + Double(incorrectStrokeCount) / Double(1 + correctStrokeCount))
        }()

        //        updateScore()
        //        startAnimation(afterDelay: PracticeViewController.nextStrokeAnimationTime)
//                isUpdatingDrawing = false
    }
    
    func Reseting() {
        canvasView.drawing.strokes.removeAll()
    }
    
    var body: some View {

        VStack(){
            HStack(){
                Button {
                    Reseting()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                Text("\(Int(score * 100))")
                Button {
                    Scoring()
                } label: {
                    Image(systemName: "return.right")
                }
            }
            
            ZStack(){
                TextGeneratorView(backgroundCanvasView: $backgroundCanvasView)

                AnimateView(canvasView: $canvasView, backgroundCanvasView: $backgroundCanvasView)
                CanvasView(canvasView: $canvasView, strokeCounter: $strokeCounter)
            }
        }
    }
}


struct TextGeneratorView: UIViewRepresentable {
    @Binding var backgroundCanvasView: PKCanvasView
    
    func generateText() {
        let textGenerator = TextGenerator()
        
        backgroundCanvasView.drawing = textGenerator.synthesizeTextDrawing(text: "A", practiceScale: CGFloat(5.0), lineWidth: 0)
        
        // ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz
    }

    func makeUIView(context: Context) -> PKCanvasView {
        generateText()
        
        backgroundCanvasView.backgroundColor = .clear

        return backgroundCanvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
    }
}

struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var strokeCounter: Int
    
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
    @State var animationLastFrameTime = Date()
    @State var animationSpeed: CGFloat = 1.0
    @State var animationMarkerLayer = CALayer()
    @State var animationStartMarkerLayer = CALayer()
    @State var animationTimer: Timer?
    
    @State var nextStrokeCount: Int = 0
    @State var nowStrokeCount: CGFloat = 0
    
    static let repeatStrokeAnimationTime: TimeInterval = 2
    static let nextStrokeAnimationTime: TimeInterval = 0.5
    
    let viewRoot: UIView = UIView()
    
    func animateStart() {
        let nextStrokeIndex = canvasView.drawing.strokes.count
        
        guard nextStrokeIndex < backgroundCanvasView.drawing.strokes.count else {
            // Hide the animation markers.
            animationMarkerLayer.opacity = 0.0
            animationStartMarkerLayer.opacity = 0.0
            return
        }

        let strokeToAnimate = backgroundCanvasView.drawing.strokes[nextStrokeIndex]
        AnimateView.animatingStroke = strokeToAnimate
        
        animationParametricValue = 0
        animationLastFrameTime = Date()
        animationTimer?.invalidate()
        
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 10, repeats: true) { _ in
            animationStep()
        }
        animationStartMarkerLayer.position = strokeToAnimate.path.interpolatedLocation(at: 0).applying(strokeToAnimate.transform)
        animationStartMarkerLayer.opacity = 1.0
    }
    
    func animationStep() {
        guard let animatingStroke = AnimateView.animatingStroke, animationParametricValue < CGFloat(animatingStroke.path.count - 1) else {
            
            _ = Timer.scheduledTimer(withTimeInterval: AnimateView.repeatStrokeAnimationTime, repeats: false) { _ in
                
                animationParametricValue = 0
                nowStrokeCount = 0
            }
            
            return
        }
        
        
        //        let currentTime = Date()
        //        let delta = currentTime.timeIntervalSince(animationLastFrameTime)
        //        animationParametricValue = animatingStroke.path.parametricValue(animationParametricValue,offsetBy: .time(delta))
        animationParametricValue = nowStrokeCount
        animationMarkerLayer.position = animatingStroke.path.interpolatedLocation(at: animationParametricValue)
            .applying(animatingStroke.transform)
        animationMarkerLayer.opacity = 1
        //        animationLastFrameTime = currentTime
        
        nowStrokeCount += 1
    }
    
    func makeUIView(context: Context) -> UIView {
        animationMarkerLayer.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        animationMarkerLayer.backgroundColor = UIColor.red.cgColor
        animationMarkerLayer.cornerRadius = 5
        viewRoot.layer.addSublayer(animationMarkerLayer)
        
        animationStartMarkerLayer.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        animationStartMarkerLayer.borderColor = UIColor.gray.cgColor
        animationStartMarkerLayer.borderWidth = 2
        animationStartMarkerLayer.cornerRadius = 8
        viewRoot.layer.addSublayer(animationStartMarkerLayer)
    
        animateStart()
        
        return viewRoot
    }
    
//    func animateNextStroke() {
//        let nextStrokeIndex = canvasView.drawing.strokes.count
//        guard nextStrokeIndex < backgroundCanvasView.drawing.strokes.count else {
//            // Hide the animation markers.
//            animationMarkerLayer.opacity = 0.0
//            animationStartMarkerLayer.opacity = 0.0
//            return
//        }
//
//        let strokeToAnimate = backgroundCanvasView.drawing.strokes[nextStrokeIndex]
//        AnimateView.animatingStroke = strokeToAnimate
//        animationParametricValue = 0
//        animationLastFrameTime = Date()
//        animationTimer?.invalidate()
//
//        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60, repeats: true) { _ in stepAnimation()}
//
//        // Setup the start marker layer.
//        animationStartMarkerLayer.position = strokeToAnimate.path.interpolatedLocation(at: 0).applying(strokeToAnimate.transform)
//        animationStartMarkerLayer.opacity = 1.0
//    }
//
//    func startAnimation(afterDelay delay: TimeInterval) {
//        // Animate the next stroke again after `delay`.
//        stopAnimation()
////        AnimateView.animatingStroke = nil
//
//        animationTimer = Timer.scheduledTimer(withTimeInterval: AnimateView.repeatStrokeAnimationTime, repeats: false) { _ in
//            // Only animate the next stroke if another animation has not already started.
//            if AnimateView.animatingStroke == nil {
//                animateNextStroke()
//
//            }
//        }
//    }
//
//    func stopAnimation() {
//        animationMarkerLayer.opacity = 0
//        AnimateView.animatingStroke = nil
//        animationTimer?.invalidate()
//    }
//
//    func stepAnimation() {
////        dump(AnimateView.animatingStroke)
//        guard let animatingStroke = AnimateView.animatingStroke, animationParametricValue < CGFloat(animatingStroke.path.count - 1) else {
//            ////             Animate the next stroke again, in `repeatStrokeAnimationTime` seconds.
//            startAnimation(afterDelay: AnimateView.repeatStrokeAnimationTime)
//
//            return
//        }
//        let currentTime = Date()
//        let delta = currentTime.timeIntervalSince(animationLastFrameTime)
//
//        animationParametricValue = animatingStroke.path.parametricValue(
//            animationParametricValue,
//            offsetBy: .time(delta * TimeInterval(animationSpeed)))
//
//        animationMarkerLayer.position = animatingStroke.path.interpolatedLocation(at: animationParametricValue)
//            .applying(animatingStroke.transform)
//        animationMarkerLayer.opacity = 1
//        animationLastFrameTime = currentTime
//
////        dump(animatingStroke.path.parametricValue(
////            animationParametricValue,
////            offsetBy: .time(delta * TimeInterval(animationSpeed))))
//    }
    
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

struct DrawingMergeView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingMergeView()
    }
}
