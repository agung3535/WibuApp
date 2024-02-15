//
//  WaifuModel.swift
//  WibuApp
//
//  Created by Agung Dwi Saputra on 13/02/24.
//

import Foundation


struct WaifuModel: Codable, Identifiable {
    let id: UUID = UUID()
    let image: String
    let anime, name: String
}

extension WaifuModel {
    
    func toDomainModel() -> WaifuDomainModel {
        let url = URL(string: image)!
        return WaifuDomainModel(image: url, anime: anime, name: name)
    }
    
}

struct WaifuDomainModel: Codable, Identifiable {
    let id: UUID = UUID()
    let image: URL
    let anime, name: String
}
