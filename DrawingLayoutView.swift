//
//  DrawingView.swift
//  WWDC
//
//  Created by 송재훈 on 2023/03/31.
//

import SwiftUI

struct DrawingLayoutView: View {
    var body: some View {
        GeometryReader {geo in
            RoundedRectangle(cornerRadius: 10)
                .stroke(.black)
            DrawingMergeView()
            
            VStack(){
                Divider()
                    .background(.blue)
                    .offset(y: geo.size.height * 0.5)
            }
            
            HStack(){
                Divider()
                    .background(.blue)
                    .offset(x: geo.size.width * 0.5)
            }
        }
    }
}

struct DrawingLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingLayoutView()
    }
}
