//
//  NetworkGateway.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import NetworkExtension

internal final class NetworkGateway {
    
    enum NetworkError: Error {
        case noService
        case noData
        case badResponse
        case parsing(Error)
        case httpError(Int)
    }
    
    // MARK: - Private properties
    
    private let _keychain: KeychainGateway
    private let _decoder = JSONDecoder()
    private let _baseURL: URL
    private let _clientID: String
    private let _clientSecret: String
    
    // MARK: - Initialization
    
    init(baseURL: URL, clientID: String, clientSecret: String, keychain: KeychainGateway) {
        _baseURL = baseURL
        _keychain = keychain
        _clientID = clientID
        _clientSecret = clientSecret
    }
    
    // MARK: - Internal methods
    
    internal func isAuthorized() -> Bool {
        return (try? _keychain.readPassword()) != nil
    }
    
    internal func authorize(with code: String, completion: @escaping ((Result<Void, Error>) -> ())) {
        var urlComponents = URLComponents(string: "https://github.com/login/oauth/access_token")!
        urlComponents.queryItems = [
            .init(name: "client_id", value: _clientID),
            .init(name: "client_secret", value: _clientSecret),
            .init(name: "code", value: code),
        ]
        
        var postRequest = URLRequest(url: urlComponents.url!)
        postRequest.httpMethod = "POST"
        postRequest.allHTTPHeaderFields = ["Accept": "application/json"]
        
        URLSession.shared.dataTask(with: postRequest) { [weak self] (data, response, error) -> Void in
            if let error = error {
                completion(.failure(error))
                return
            } else if let data = data {
                guard let httpURLResponse = response as? HTTPURLResponse else {
                    completion(.failure(NetworkError.badResponse))
                    return
                }
                
                guard let `self` = self else {
                    completion(.failure(NetworkError.noService))
                    return
                }
                
                switch httpURLResponse.statusCode {
                case 200...300:
                    do {
                        let decodedData = try self._decoder.decode([String: String].self, from: data)
                        
                        guard let accessToken = decodedData["access_token"] else {
                            completion(.failure(NetworkError.noData))
                            return
                        }
                        
                        DispatchQueue.main.async(execute: {
                            try? self._keychain.savePassword(accessToken)
                            
                            completion(.success(()))
                            return
                        })
                    } catch {
                        DispatchQueue.main.async(execute: {
                            completion(.failure(NetworkError.parsing(error)))
                            return
                        })
                    }
                default:
                    completion(.failure(NetworkError.httpError(httpURLResponse.statusCode)))
                    return
                }
            }
            return
        }.resume()
    }
    
    internal func requestRepos(for user: String, completion: @escaping ((Result<[Repo], Error>) -> ())) {
        let url = _baseURL.appendingPathComponent("user/repos")
        var getRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 5)
        if let accessToken = try? _keychain.readPassword() {
            getRequest.allHTTPHeaderFields = ["Authorization": "token \(accessToken)"]
        }
        
        URLSession.shared.dataTask(with: getRequest) { [weak self] (data, response, error) -> Void in
            if let error = error {
                completion(.failure(error))
                return
            } else if let data = data {
                guard let httpURLResponse = response as? HTTPURLResponse else {
                    completion(.failure(NetworkError.badResponse))
                    return
                }
                
                guard let `self` = self else {
                    completion(.failure(NetworkError.noService))
                    return
                }
                
                switch httpURLResponse.statusCode {
                case 200...300:
                    do {
                        let decodedData = try self._decoder.decode([Repo].self, from: data)
                        
                        DispatchQueue.main.async(execute: {
                            completion(.success(decodedData))
                            return
                        })
                    } catch {
                        DispatchQueue.main.async(execute: {
                            completion(.failure(NetworkError.parsing(error)))
                            return
                        })
                    }
                default:
                    completion(.failure(NetworkError.httpError(httpURLResponse.statusCode)))
                    return
                }
            }
            return
        }.resume()
    }
    
    internal func authURL() -> URL {
        var urlComponents = URLComponents(string: "https://github.com/login/oauth/authorize")!
        urlComponents.queryItems = [.init(name: "client_id", value: _clientID)]
        return urlComponents.url!
    }
}
