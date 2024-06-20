import SwiftUI
import JWTDecode

struct DiaryDetail: Codable {
    var idDiary: Int
    var userID: Int
    var title: String
    var diaryUser: String
    var createAt: String
    var updateAt: String
    
    enum CodingKeys: String, CodingKey {
        case idDiary = "id_diary"
        case userID = "user_id"
        case title
        case diaryUser = "diary_user"
        case createAt = "create_at"
        case updateAt = "update_at"
    }
}

struct DetailDiaryView: View {
    let token = UserDefaults.standard.string(forKey: "token") ?? ""
    let idDiary: Int
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
                        Text("Update Diary")
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
                fetchDiaryDetails()
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
    
    func fetchDiaryDetails() {
        guard let url = URL(string: "http://172.20.10.3:2005/diary/detail/\(idDiary)") else {
            showAlert(message: "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                showAlert(message: "No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let diary = try decoder.decode([DiaryDetail].self, from: data)
                
                if let firstDiary = diary.first {
                    DispatchQueue.main.async {
                        self.title = firstDiary.title
                        self.diaryUser = firstDiary.diaryUser
                    }
                } else {
                    showAlert(message: "No diary details found.")
                }
            } catch {
                showAlert(message: "Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func createDiary(title: String, diaryUser: String) {
        guard let url = URL(string: "http://172.20.10.3:2005/diary/update/\(idDiary)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "id_diary":idDiary,
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
                    self.registrationFailed = true
                    self.showAlert = true
                    self.alertMessage = "Failed to create diary. Please try again."
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    self.registrationFailed = true
                    self.showAlert = true
                    self.alertMessage = "Failed to create diary. Please try again."
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        self.registrationSuccess = true
                        self.showAlert = true
                        self.alertMessage = "Diary updated successfully!"
                        self.navigateToLogin = true // Trigger navigation to HomeView
                    }
                } else {
                    print("Failed to create diary. HTTP Response Code: \(httpResponse.statusCode)")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response Data: \(responseString)")
                    }
                    DispatchQueue.main.async {
                        self.registrationFailed = true
                        self.showAlert = true
                        self.alertMessage = "Failed to create diary. Please try again."
                    }
                }
            }
        }.resume()
    }
    
    private func showAlert(message: String) {
        self.alertMessage = message
        self.showAlert = true
    }
}

struct DetailDiaryView_Previews: PreviewProvider {
    static var previews: some View {
        DetailDiaryView(idDiary: 3)
    }
}
