//
//  DrawingHelper.swift
//  WWDC
//
//  Created by 송재훈 on 2023/04/03.
//

import SwiftUI

struct DrawingHelperView: View {
    var body: some View {
        
        ZStack(){
            
            DrawingLayoutView()
            DrawingMergeView()
            
        }
        
    }
}

struct DrawingHelperView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingHelperView()
    }
}
