import SwiftUI

struct RegisterView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isEmpty = false
    @State private var matchPassword = false
    @State private var registrationFailed = false
    @State private var registrationSuccess = false
    @State private var navigateToLogin = false
    
    var body: some View {
        NavigationView {
            VStack {
                Image("book")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                    .padding(.top, 50)
                
                VStack {
                    TextField("Name", text: $name)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                    
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                    
                    Button(action: {
                        if name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
                            isEmpty = true
                            return
                        }
                        
                        if password != confirmPassword {
                            matchPassword = true
                            return
                        }
                        
                        registerUser(name: name, email: email, password: password)
                    }) {
                        Text("Register")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 30)
                }
                .navigationBarBackButtonHidden(true)
                .padding(.top, 20)
                .alert(isPresented: $isEmpty) {
                    Alert(title: Text("Register Failed"), message: Text("All text fields are required."), dismissButton: .default(Text("OK")))
                }
                .alert(isPresented: $matchPassword) {
                    Alert(title: Text("Register Failed"), message: Text("Passwords do not match."), dismissButton: .default(Text("OK")))
                }
                .alert(isPresented: $registrationFailed) {
                    Alert(title: Text("Register Failed"), message: Text("Registration failed. Please try again."), dismissButton: .default(Text("OK")))
                }
                .alert(isPresented: $registrationSuccess) {
                    Alert(title: Text("Register Success"), message: Text("Registration successful!"), dismissButton: .default(Text("OK"), action: {
                        navigateToLogin = true
                    }))
                }
                
                NavigationLink(destination: LoginView(), isActive: $navigateToLogin) {
                    EmptyView()
                }
                
                Spacer()
            }
            .padding()
            .background(Color.white.edgesIgnoringSafeArea(.all))
        }
    }
    
    func registerUser(name: String, email: String, password: String) {
        guard let url = URL(string: "http://172.20.10.3:2005/users") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "name": name,
            "email": email,
            "password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                DispatchQueue.main.async {
                    registrationFailed = true
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    registrationFailed = true
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    registrationSuccess = true
                }
            } else {
                DispatchQueue.main.async {
                    registrationFailed = true
                }
            }
        }.resume()
    }
}

#Preview {
    RegisterView()
}
