//
//  NetworkManager.swift
//  WibuApp
//
//  Created by Agung Dwi Saputra on 13/02/24.
//

import Foundation


class NetworkManager {
    
    private var baseURL = "https://waifu-generator.vercel.app/api/"
    
    private init() {}
    
    static let shared = NetworkManager()
    
    func fetchData(urlPath: WaifuAPI,
                   parameterQuery: [String: String] = [:],
                   type: ParameterType = .none,
                   param: String = "",
                   completion: @escaping(Result<Data?, APIError>) -> Void
    ) {
        var urlRequest: URLRequest?
        switch type {
            
        case .path:
            urlRequest = createRequestPath(urlPath: urlPath, param: param)
        case .query:
            urlRequest = createRequestQuery(urlPath: urlPath, parameterQuery: parameterQuery)
        case .none:
            urlRequest = createRequest(urlPath: urlPath)
        }
    
        
        guard let validReq = urlRequest else {
            return
        }
        
        let task = handleDataTask(urlRequest: validReq, completion: completion)
        
        task.resume()
        
    }
    
    func downloadImage(url: URL, completion: @escaping(Result<Data?, APIError>) -> Void) {
        
        let urlRequest = createRequest(customURL: url)
        
        guard let validReq = urlRequest else {
            return
        }
        
        let task = handleDataTask(urlRequest: validReq, completion: completion)
        
        task.resume()
    }
    
    
    func fetchDataAsyncAwait(
           urlPath: WaifuAPI,
           parameterQuery: [String: String] = [:],
           type: ParameterType = .none,
           param: String = ""
    ) async throws -> Result<Data, APIError> {
        var urlRequest: URLRequest?
        
        switch type {
            
        case .path:
            urlRequest = createRequestPath(urlPath: urlPath, param: param)
        case .query:
            urlRequest = createRequestQuery(urlPath: urlPath, parameterQuery: parameterQuery)
        case .none:
            urlRequest = createRequest(urlPath: urlPath)
        }
        
        guard let validReq = urlRequest else {
            return .failure(.unknownError("URL Request not valid"))
        }
        
        do {
            return try await handleTaskAsyncAwait(urlRequest: validReq)
        } catch {
            return .failure(.unknownError("failed to get data"))
        }
    }
    
}


extension NetworkManager {
    
    private func createURLSessionUtility() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        
        let urlSession = URLSession.init(configuration: .default, delegate: nil, delegateQueue: queue)
        
        return urlSession
    }
    
    private func createRequestPath(urlPath: WaifuAPI,param: String) -> URLRequest? {
        var urlComponent = URLComponents(string: baseURL)
        urlComponent?.path.append(urlPath.rawValue + "/" + param)
        guard let url = urlComponent?.url else {
            return nil
        }
        return URLRequest(url: url)
    }
    
    
    private func createRequest(urlPath: WaifuAPI) -> URLRequest? {
        var urlComponent = URLComponents(string: baseURL)
        urlComponent?.path.append(urlPath.rawValue)
        guard let url = urlComponent?.url  else {
            return nil
        }
        return URLRequest(url: url)
    }
    
    private func createRequest(customURL: URL) -> URLRequest? {
        var urlComponent = URLComponents(url: customURL, resolvingAgainstBaseURL: true)
        guard let url = urlComponent?.url  else {
            return nil
        }
        return URLRequest(url: url)
    }
    
    private func createRequestQuery(urlPath: WaifuAPI,parameterQuery: [String: String] = [:]) -> URLRequest? {
        var urlComponent = URLComponents(string: baseURL)
        urlComponent?.path = urlPath.rawValue
        urlComponent?.queryItems = parameterQuery.map({ key, value in
            URLQueryItem(name: key, value: value)
        })
        guard let url = urlComponent?.url else {
            return nil
        }
        return URLRequest(url: url)
    }
    
    private func handleDataTask(
        urlRequest: URLRequest,
        completion: @escaping(Result<Data?, APIError>) -> Void) -> URLSessionDataTask
    {
        let session = createURLSessionUtility()
        return session.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.other(error)))
                }
                
                guard let response = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                switch response.statusCode {
                case 200:
                    completion(.success(data))
                    return
                case 401:
                    completion(.failure(.unauthorize))
                    return
                case 500:
                    completion(.failure(.internalServer))
                    return
                default:
                    completion(.failure(.unknownError("Whoops, check your code API code buddy !!")))
                    return
                }
            }
        }
    }
    
    private func handleTaskAsyncAwait(
        urlRequest: URLRequest
    ) async throws -> Result<Data, APIError> {
        
        let session = createURLSessionUtility()
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            return mapResponseAsyncAwait(data: data, response: response)
        } catch {
            return .failure(.internalServer)
        }
        
    }
    
    private func mapResponseAsyncAwait(data: Data, response: URLResponse) -> Result<Data, APIError> {
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(.invalidResponse)
        }
        
        switch httpResponse.statusCode {
        case 200:
            return .success(data)
        case 401:
            return .failure(.unauthorize)
        case 500:
            return .failure(.internalServer)
        default:
            return .failure(.unknownError("Whoops, check your code buddy :p"))
        }
    }
    
}


enum APIError: Error {
    case invalidURL
    case decodeFailure
    case invalidResponse
    case unauthorize
    case netwokFailure
    case other(Error)
    case internalServer
    case unknownError(String)
}

enum WaifuAPI: String {
    case all = "v1"
}


enum ParameterType {
    case path
    case query
    case none
}
