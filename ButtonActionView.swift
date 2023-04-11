//
//  ButtonActionView.swift
//  WWDC
//
//  Created by 송재훈 on 2023/04/10.
//

import SwiftUI
import PencilKit

struct ButtonActionView: View {
    @State var incorrectStrokeCount = 0
    @Binding var score : Double
    @Binding var canvasView : PKCanvasView
    @Binding var backgroundCanvasView : PKCanvasView
    
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
                return (1.0 / (1.0 + Double(incorrectStrokeCount) / Double(1 + correctStrokeCount))) * 100
            }()
        }
    }
    
    func Reseting() {
        score = 100
        canvasView.drawing.strokes.removeAll()
        incorrectStrokeCount = 0
    }
    
    var body: some View{
        GeometryReader() { geo in
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: geo.size.width, height: geo.size.height * 0.04)
                .overlay {
                    HStack() {
                        Button {
                            Reseting()
                        } label: {
                            Image(systemName: "eraser")
                                .resizable()
                                .foregroundColor(.gray)
                                .scaledToFit()
                        }
                        
                        Button {
                            Scoring()
                        } label: {
                            Image(systemName: "paperplane")
                                .resizable()
                                .foregroundColor(.gray)
                                .scaledToFit()
                        }
                    }
                }
        }
    }
}

struct ButtonActionView_Previews: PreviewProvider {
    var canvasView = PKCanvasView()
    var backgroundCanvasView = PKCanvasView()
    static var previews: some View {
        ButtonActionView(score: .constant(100), canvasView: .constant(PKCanvasView()), backgroundCanvasView: .constant(PKCanvasView()))
    }
}
