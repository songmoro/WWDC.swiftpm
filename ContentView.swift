import SwiftUI

var isTrue: Double = 100.0

struct ContentView: View {
    var body: some View {
        VStack(){
            Text("\(isTrue)")
            
            Button(/*@START_MENU_TOKEN@*/"Button"/*@END_MENU_TOKEN@*/) {
                isTrue -= 10
            }
        }
    }
}

struct ContentView_Priview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
