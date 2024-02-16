//
//  CharacterCard.swift
//  WibuApp
//
//  Created by Agung Dwi Saputra on 13/02/24.
//

import SwiftUI

struct CharacterCard: View {
    
    var size: CGSize = CGSize(width: 100, height: 100)
    var data: WaifuDomainModel
    
    var body: some View {
        VStack {            
            AsyncImage(url: data.image) { phase in
                switch phase {
                case .empty:
                    WaitView()
                        .frame(width: size.width, height: size.height)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.width, height: size.height)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 10)
                        )
                case .failure(let error):
                    VStack {
                        Image(systemName: "photo.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.width, height: size.height)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 10)
                            )
                    }
                @unknown default:
                    fatalError()
                }
            }
                
            Text(data.name + "\n")
                .font(.system(size: 16, weight: .bold))
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
                .padding(.horizontal, 5)
            Text(data.anime)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .padding(.horizontal, 5)
        }
        .contentShape(RoundedRectangle(cornerRadius: 10))
    }
}

@ViewBuilder
func WaitView() -> some View {
    VStack {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(.blue)
    }
}

//#Preview {
//    CharacterCard()
//}
