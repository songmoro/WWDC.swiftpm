//
//  CharacterView.swift
//  WWDC
//
//  Created by 송재훈 on 2023/03/21.
//

import SwiftUI

struct CharacterView: View {
    var body: some View {
        if #available(iOS 16.1, *) {
            VStack(){
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                //            .bold()
                    .shadow(color: .black, radius: 1, x: 0, y: 0)
                    .colorInvert()
                
                
                ZStack{
                    let width : CGFloat = 1
                    let text = "Hello, World!"
                    
                    Text(text).offset(x:  width, y:  width)
                    Text(text).offset(x: -width, y: -width)
                    Text(text).offset(x: -width, y:  width)
                    Text(text).offset(x:  width, y: -width)
                }
                
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

struct CharacterView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterView()
    }
}
