import SwiftUI
import JWTDecode

struct CreateDiaryView: View {
    let token = UserDefaults.standard.string(forKey: "token") ?? ""
    @State private var title: String = ""
    @State private var idUser: Int = 0
    @State private var diaryUser: String = ""
    @State private var isEmpty = false
    @State private var registrationFailed = false
    @State private var registrationSuccess = false
    @State private var navigateToLogin = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Image("book")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                    .padding(.top, 50)
                    .padding()
                
                VStack {
                    TextField("Title", text: $title)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                    
                    TextField("Diary", text: $diaryUser)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                    
                    if isEmpty {
                        Text("Title and Diary fields cannot be empty.")
                            .foregroundColor(.red)
                    }
                    
                    Button(action: {
                        if title.isEmpty || diaryUser.isEmpty {
                            isEmpty = true
                            return
                        }
                        
                        createDiary(title: title, diaryUser: diaryUser)
                    }) {
                        Text("Create Diary")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 30)
                }
            }
            .padding(.top, 20)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Status"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"), action: {
                        // Optional: handle dismiss action if needed
                    })
                )
            }
            .onAppear {
                decodeToken()
            }
            .navigationBarBackButtonHidden(true)
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
        }
        .background(
            NavigationLink(destination: HomeView(), isActive: $navigateToLogin) {
                EmptyView()
            }
        )
        .padding()
    }
    
    func decodeToken() {
        do {
            let jwt = try decode(jwt: token)
            let userID = jwt.claim(name: "id_user").integer ?? 0
            self.idUser = userID
        } catch {
            print("Error decoding JWT token: \(error.localizedDescription)")
        }
    }
    
    func createDiary(title: String, diaryUser: String) {
        guard let url = URL(string: "http://172.20.10.3:2005/diary/create") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "user_id": idUser,
            "title": title,
            "diary_user": diaryUser
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    registrationFailed = true
                    showAlert = true
                    alertMessage = "Failed to create diary. Please try again."
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    registrationFailed = true
                    showAlert = true
                    alertMessage = "Failed to create diary. Please try again."
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        registrationSuccess = true
                        showAlert = true
                        alertMessage = "Diary created successfully!"
                        navigateToLogin = true // Trigger navigation to HomeView
                    }
                } else {
                    print("Failed to create diary. HTTP Response Code: \(httpResponse.statusCode)")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response Data: \(responseString)")
                    }
                    DispatchQueue.main.async {
                        registrationFailed = true
                        showAlert = true
                        alertMessage = "Failed to create diary. Please try again."
                    }
                }
            }
        }.resume()
    }
}

struct CreateDiaryView_Previews: PreviewProvider {
    static var previews: some View {
        CreateDiaryView()
    }
}
