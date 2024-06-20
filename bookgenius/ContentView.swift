import SwiftUI

struct ContentView: View {
    @State private var items: [ApifyItem] = []
    @State private var errorMessage: String?
    @State private var rawData: String?
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Fetching data...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding()
                } else if let rawData = rawData {
                    ScrollView {
                        Text(rawData)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .padding()
                    }
                } else {
                    if items.isEmpty {
                        Text("No data available. Please fetch data.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List(items, id: \.someField) { item in
                            Text(item.someField)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                
                Button(action: fetchData) {
                    Text("Fetch Data")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationBarTitle("BookGenius", displayMode: .inline)
            .padding()
        }
    }

    private func fetchData() {
        isLoading = true
        errorMessage = nil
        rawData = nil
        ApifyClient.shared.runApifyTask { result, rawData in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    self.items = response.items
                    self.errorMessage = nil
                case .failure(let error):
                    self.items = []
                    self.errorMessage = handleError(error)
                    self.rawData = rawData
                }
            }
        }
    }

    private func handleError(_ error: Error) -> String {
        // Add more detailed error handling based on error types
        if let urlError = error as? URLError {
            return "Network Error: \(urlError.localizedDescription)"
        } else if let decodingError = error as? DecodingError {
            return "Data Error: Unable to decode the data."
        } else {
            return "Unexpected Error: \(error.localizedDescription)"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
