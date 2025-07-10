//
//  UserAPI.swift
//  CallingSampleAppv5
//
//  Created by Suryansh on 11/06/25.
//

import Foundation

class UserAPI {
    static let shared = UserAPI()

    private let baseURL = "https://appid.api-us.cometchat.io/v3/users"
    
    // Function to create a user
    func createUser(uid: String, name: String, avatar: String, completion: @escaping (Result<Data, Error>) -> Void) {
        
        // Create the URL object
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        // Create the JSON payload
        let payload: [String: Any] = [
            "uid": uid,
            "name": name,
            "avatar": avatar,
            "withAuthToken": true,
        ]
        
        // Convert the payload to JSON data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
            
            // Create a URLRequest object
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = jsonData
            
            // Perform the API call
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                } else if let data = data {
                    completion(.success(data))
                }
            }
            task.resume()
            
        } catch {
            completion(.failure(error))
        }
    }
}
