import SwiftUI

struct ContentView: View {
    var body: some View {
        

        ZStack(){
            DrawingMergeView()
            
        }
    }
}

struct ContentView_Priview: PreviewProvider {
    static var previews: some View {
            ContentView()
        }
}
