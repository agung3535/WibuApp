//
//  WaifuService.swift
//  WibuApp
//
//  Created by Agung Dwi Saputra on 13/02/24.
//

import Foundation


protocol WaifuServiceProtocol {
    func getWaifuData(completion: @escaping (Result<[WaifuModel], APIError>) -> Void)
    func downloadImage(url: URL, completion: @escaping (Result<Data, APIError>) -> Void)
    func getWaifuDataAsyncAWait() async throws -> Result<[WaifuModel], APIError>
}

class WaifuService: WaifuServiceProtocol {
    
    private var networkManager = NetworkManager.shared
    
    func getWaifuData(completion: @escaping (Result<[WaifuModel], APIError>) -> Void) {
        networkManager.fetchData(urlPath: .all) { [weak self] response in
            switch response {
            case .success(let success):
                guard let result = success else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                do {
                    let resoruce = try JSONDecoder().decode([WaifuModel].self, from: result)
                    completion(.success(resoruce))
                }catch {
                    completion(.failure(.decodeFailure))
                    return
                }
                
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    func downloadImage(url: URL, completion: @escaping (Result<Data, APIError>) -> Void) {
        networkManager.downloadImage(url: url) { response in
            switch response {
            case .success(let success):
                guard let result = success else{
                    completion(.failure(.invalidResponse))
                    return
                }
                
                completion(.success(result))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    func getWaifuDataAsyncAWait() async throws -> Result<[WaifuModel], APIError> {
        do {
            let data = try await networkManager.fetchDataAsyncAwait(urlPath: .all)
            switch data {
            case .success(let success):
                let decoder = JSONDecoder()
                do {
                    let json = try decoder.decode([WaifuModel].self, from: success)
                    return .success(json)
                } catch {
                    return .failure(.decodeFailure)
                }
            case .failure(let failure):
                return .failure(failure)
            }
        }catch {
            return .failure(.other(error))
        }
    }
    
}
