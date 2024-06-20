import SwiftUI

struct ContentView: View {
    @State private var navigateToLogin = false
    @State private var navigateToHome = false // State to control navigation to HomeView
    
    var body: some View {
        NavigationView {
            VStack {
                Image("book")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                    .padding(.top, 50)
                    .padding()
                
                NavigationLink(destination: LoginView(), isActive: $navigateToLogin) {
                    EmptyView()
                }
                
                NavigationLink(destination: HomeView(), isActive: $navigateToHome) {
                    EmptyView()
                }
            }
            .padding()
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    navigateToLogin = true
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
