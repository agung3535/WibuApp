//
//  ContentView.swift
//  WibuApp
//
//  Created by Agung Dwi Saputra on 13/02/24.
//

import SwiftUI

struct ContentView: View {
    var gridItemLayout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State var search: String = ""
    
    @ObservedObject var vm: HomeViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    LazyVGrid(columns: gridItemLayout, spacing: 10, content: {
                        ForEach(vm.waifuResult, id: \.id) { nilai in
                            CharacterCard(
                                size: CGSize(width: 100, height: 120),
                                data: nilai
                            )
                            .contentShape(RoundedRectangle(cornerRadius: 10))
                            .contextMenu(menuItems: {
                                Button(action: {
                                    vm.deleteWaifu(data: nilai)
                                }, label: {
                                    Label(
                                        title: { Text("Delete") },
                                        icon: { Image(systemName: "trash") }
                                    ).foregroundStyle(.black)
                                })
                                Button {
                                    vm.downloadImage(url: nilai.image)
                                } label: {
                                    Label(
                                        title: { Text("Share") },
                                        icon: { Image(systemName: "square.and.arrow.up") }
                                    ).foregroundStyle(.black)
                                }

                            })

                        }
                    })
                }
            }
            .sheet(isPresented: $vm.shareOptionsIsPresent, content: {
                if let image = vm.imageToShare {
                    ShareSheetView(activityItems: ["Share something",image])
                }else {
                    ShareSheetView(activityItems: ["Share something"])
                }
                
            })
            .navigationTitle("Wibu App")
            .toolbarTitleDisplayMode(.large)
            .padding()
        }
        .searchable(text: $vm.searchText, prompt: "Looking for some wifu?")
        .onAppear {
            vm.getWaifu()
        }

    }
}

#Preview {
    ContentView(vm: HomeViewModel(service: WaifuService()))
}
