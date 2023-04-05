////
////  HandWritingView.swift
////  WWDC
////
////  Created by 송재훈 on 2023/03/15.
////
//
//import SwiftUI
//import PencilKit
//
//struct DrawingCanvasView: View {
//    @State var canvasView = PKCanvasView()
//    @State var color: Color = .black
//    @State var type: PKInkingTool.InkType = .pen
//    
//    var body: some View {
//        CanvasView(canvasView: $canvasView, type: $type, color: $color)
//    }
//}
//
//struct CanvasView: UIViewRepresentable {
//    // Todo 선 두께 조절
//    // Todo 글자 마스킹 이미지
//    
//    @Binding var canvasView: PKCanvasView
//    @Binding var type: PKInkingTool.InkType
//    @Binding var color: Color
////    @Binding var width: CGFloat
//    
//    var ink: PKInkingTool {
//        PKInkingTool(type, color: UIColor(color))
//    }
//     
//    
//    func makeUIView(context: Context) -> PKCanvasView {
////        canvasView.drawingPolicy = .pencilOnly
//        canvasView.drawingPolicy = .anyInput
//        canvasView.tool = ink
//        
//        return canvasView
//    }
//    
//    func updateUIView(_ uiView: PKCanvasView, context: Context) {
//        
//    }
//}
//
//struct DrawingCanvasView_Previews: PreviewProvider {
//    static var previews: some View {
//        DrawingCanvasView()
//    }
//}
//
