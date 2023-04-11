//
//  HPView.swift
//  WWDC
//
//  Created by 송재훈 on 2023/04/08.
//

import SwiftUI

struct HPView: View {
    @Binding var currentHP : Double
    
    var body: some View {
        GeometryReader() { geo in
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(.black)
                .frame(width: geo.size.width * 1.0, height: geo.size.height * 0.05, alignment: .center)
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(.green)
                .frame(width: geo.size.width * currentHP * 0.01, height: geo.size.height * 0.05, alignment: .center)
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(.clear)
                .frame(width: geo.size.width * 1.0, height: geo.size.height * 0.05, alignment: .center)
                .overlay {
                    Text("\(Int(currentHP)) / 100")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: geo.size.width)
                }
            
            
        }
    }
}

struct HPView_Previews: PreviewProvider {
    static var previews: some View {
        HPView(currentHP: .constant(100))
    }
}
