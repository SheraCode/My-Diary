//
//  login.swift
//  first
//
//  Created by Johannes Bastian Jasa Sipayung on 12/06/24.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert = false // State to control alert visibility
    @State private var alertMessage = "" // Message to display in alert
    @State private var loggedIn = false // State to control navigation
    @State private var wrongCredentials = false
    @State private var isEmpty = false
    
    var body: some View {
        NavigationView {
            VStack {
                Image("book")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                    .padding(.top, 50)
                
                VStack {
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
                    
                    NavigationLink(destination: HomeView(), isActive: $loggedIn) {
                        EmptyView() // Placeholder for navigation
                    }
                    
                    NavigationLink(destination: RegisterView()) {
                        Text("Belum Punya Akun? Daftar Sekarang!")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.top, 20)
                    }
                    
                    Button(action: {
                                        // Action to perform login
                                        if email.isEmpty || password.isEmpty {
                                            isEmpty = true
                                            return
                                        }
                                        loginUser(email: email, password: password)
                                    }) {
                                        Text("Login")
                                            .font(.title)
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.blue)
                                            .cornerRadius(10)
                                    }
                                    .padding(.top, 30)
                                    
                                    NavigationLink(destination: HomeView(), isActive: $loggedIn) {
                                        EmptyView()
                                    }
                    .padding(.top, 30)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
            .background(Color.white.edgesIgnoringSafeArea(.all))
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Login"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $wrongCredentials) {
            Alert(title: Text("Login Failed"), message: Text("Email or password is incorrect."), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $isEmpty) {
            Alert(title: Text("Login Failed"), message: Text("Email or password is required."), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Login Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .navigationBarBackButtonHidden(true)
    }
    
    
    func loginUser(email: String, password: String) {
        guard let url = URL(string: "http://172.20.10.3:2005/users/login") else {
            print("Invalid URL")
            return
        }
        
        let body: [String: String] = ["email": email, "password": password]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Handle network errors
                    self.showAlert(message: "Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    self.showAlert(message: "No data in response")
                    return
                }
                
                do {
                    let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                    // Assuming TokenResponse is a simple struct to hold the token
                    let token = tokenResponse.token
                    
                    // Save token to UserDefaults
                    UserDefaults.standard.set(token, forKey: "token")
                    self.loggedIn = true // Navigate to HomeView
                } catch let decodingError {
                    // Handle JSON decoding error
                    self.showAlert(message: "Error decoding JSON: \(decodingError.localizedDescription)")
                }
            }
        }.resume()
    }


    struct TokenResponse: Codable {
        let token: String
    }


    func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }



}

struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let token: String?
}


#Preview {
    LoginView()
}
