//
//  HomeViewModel.swift
//  WibuApp
//
//  Created by Agung Dwi Saputra on 13/02/24.
//

import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    
    @Published private var waifuData:[WaifuDomainModel] = []
    @Published private (set) var errorMessage: String = ""
    @Published private (set) var loadingData: Bool = true
    
    @Published var searchText: String = ""
    
    @Published var imageToShare: UIImage?
    
    @Published var shareOptionsIsPresent: Bool = false
    
    @Published var isShowConfirmationDialog: Bool = false
    
    private (set) var characterToDelete: WaifuDomainModel?
    
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
    
    func getWaifuAsync() {
        loadingData = true
        Task {
            do {
                let waifu = try await service.getWaifuDataAsyncAWait()
                switch waifu {
                case .success(let data):
                    self.loadingData.toggle()
                    self.waifuData = data.map({ data in
                        data.toDomainModel()
                    })
                case .failure(let failure):
                    self.loadingData.toggle()
                    self.errorMessage = failure.localizedDescription
                }
            }catch {
                self.errorMessage = error.localizedDescription
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
    
    func deleteWaifu() {
        guard let data = self.characterToDelete else {
            return
        }
        print("data deleted = \(self.characterToDelete)")
        let index = waifuData.firstIndex { $0.id == data.id}
        guard let index = index else {
            return
        }
        waifuData.remove(at: index)
    }
    
    func showConfirmDialog() {
        self.isShowConfirmationDialog = true
    }
    
    func presentShareSheet() {
        self.shareOptionsIsPresent = true
    }
    
    func setDeletedCharacter(data: WaifuDomainModel) {
        self.characterToDelete = data
    }
    
}
