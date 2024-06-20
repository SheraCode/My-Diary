import SwiftUI
import JWTDecode

struct Diary: Codable {
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

struct HomeView: View {
    let token = UserDefaults.standard.string(forKey: "token") ?? ""
    @State private var userName: String = ""
    @State private var diaryEntries: [Diary] = []
    @State private var navigateToCreateDiary = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    VStack {
                        HStack {
                            Text("Welcome, \(userName)")
                                .font(.title)
                                .padding()
                            Spacer()
                        }
                        Spacer()
                    }
                    .frame(height: UIScreen.main.bounds.height / 6)
                    .background(Color.white)
                    .navigationBarBackButtonHidden(true)
                    
                    ScrollView {
                        VStack {
                            ForEach(diaryEntries, id: \.idDiary) { diary in
                                CardView(diary: diary, onDelete: deleteDiary)
                                    .padding(.horizontal)
                                    .padding(.top, 10)
                            }
                            Spacer()
                        }
                        .background(Color.green)
                        .edgesIgnoringSafeArea(.all)
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: CreateDiaryView(), isActive: $navigateToCreateDiary) {
                            Button(action: {
                                self.navigateToCreateDiary = true
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.system(size: 24))
                                    .frame(width: 56, height: 56)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .shadow(color: .gray, radius: 6, x: 0, y: 2)
                            }
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                decodeToken()
                fetchDiaryEntries()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showSuccessAlert) {
            Alert(title: Text("Success"), message: Text("Diary entry deleted successfully"), dismissButton: .default(Text("OK")))
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func decodeToken() {
        do {
            let jwt = try decode(jwt: token)
            let name = jwt.claim(name: "name").string ?? ""
            self.userName = name
        } catch {
            showAlert(message: "Error decoding JWT token: \(error.localizedDescription)")
        }
    }
    
    func fetchDiaryEntries() {
        guard let url = URL(string: "http://172.20.10.3:2005/diary/\(getUserIdFromToken())") else {
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
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Adjust according to your API response format
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let diaryEntries = try decoder.decode([Diary].self, from: data)
                
                DispatchQueue.main.async {
                    self.diaryEntries = diaryEntries
                }
            } catch {
                showAlert(message: "Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }

    func getUserIdFromToken() -> Int {
        do {
            let jwt = try decode(jwt: token)
            return jwt.claim(name: "id_user").integer ?? 0
        } catch {
            showAlert(message: "Error decoding JWT token: \(error.localizedDescription)")
            return 0
        }
    }
    
    func deleteDiary(idDiary: Int) {
        guard let url = URL(string: "http://172.20.10.3:2005/diary/delete/\(idDiary)") else {
            showAlert(message: "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                showAlert(message: "Error deleting diary: \(error.localizedDescription)")
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                DispatchQueue.main.async {
                    self.diaryEntries.removeAll { $0.idDiary == idDiary }
                    self.showSuccessAlert = true
                }
            } else {
                showAlert(message: "Failed to delete diary. Please try again.")
            }
        }.resume()
    }

    private func showAlert(message: String) {
        self.alertMessage = message
        self.showAlert = true
    }
}

struct CardView: View {
    let diary: Diary
    var onDelete: (Int) -> Void
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .frame(height: 100)
            .overlay(
                VStack {
                    HStack {
                        Text(diary.title)
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding([.top, .leading])
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: DetailDiaryView(idDiary: diary.idDiary)) {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                                .padding([.bottom, .trailing], 8)
                        }
                        Button(action: {
                            onDelete(diary.idDiary)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .padding([.bottom, .trailing], 8)
                        }
                    }
                }
            )
            .shadow(radius: 5)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
