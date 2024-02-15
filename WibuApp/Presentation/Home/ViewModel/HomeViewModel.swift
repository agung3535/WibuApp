//
//  HomeViewModel.swift
//  WibuApp
//
//  Created by Agung Dwi Saputra on 13/02/24.
//

import SwiftUI


class HomeViewModel: ObservableObject {
    
    @Published private var waifuData:[WaifuDomainModel] = []
    @Published private (set) var errorMessage: String = ""
    @Published private (set) var loadingData: Bool = true
    
    @Published var searchText: String = ""
    
    @Published var imageToShare: UIImage?
    
    @Published var shareOptionsIsPresent: Bool = false
    
    private var service: WaifuServiceProtocol
    
    init(service: WaifuServiceProtocol) {
        self.service = service
    }
    
    
    var waifuResult: [WaifuDomainModel] {
        guard !searchText.isEmpty else {
            return waifuData
        }
        return waifuData.filter { data in
            data.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    func getWaifu() {
        loadingData = true
        service.getWaifuData { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let data):
                self.loadingData.toggle()
                self.waifuData = data.map({ data in
                    data.toDomainModel()
                })
            case .failure(let failure):
                self.loadingData.toggle()
                self.errorMessage = failure.localizedDescription
            }
        }
    }
    
    func downloadImage(url: URL) {
        service.downloadImage(url: url) { result in
            switch result {
            case .success(let data):
                self.imageToShare = UIImage(data: data)
                self.shareOptionsIsPresent = true
            case .failure(let err):
                print("Error image : \(err.localizedDescription) ")
            }
        }
    }
    
    func deleteWaifu(data: WaifuDomainModel) {
        let index = waifuData.firstIndex { $0.id == data.id}
        guard let index = index else {
            return
        }
        waifuData.remove(at: index)
    }
    
}