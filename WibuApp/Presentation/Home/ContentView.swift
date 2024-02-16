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
                            .contextMenu(menuItems: {
                                Button(action: {
                                    vm.setDeletedCharacter(data: nilai)
                                    vm.showConfirmDialog()
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
                            .confirmationDialog("Are you sure to delete this item?", isPresented: $vm.isShowConfirmationDialog, titleVisibility: .visible, actions: {
                                Button(role: .destructive) {
                                        vm.deleteWaifu()
                                    } label: {
                                        Text("Yes, Sure!")
                                    }

                            }, message: {
                                Text("This action cannot be undone!")
                            })

                        }
                    })
                }
            }
            
            .sheet(isPresented: $vm.shareOptionsIsPresent, content: {
                let defaultText = "Share something"
                Group {
                    if let image = vm.imageToShare {
                        ShareSheetView(activityItems: [defaultText,image])
                    }else {
                        ShareSheetView(activityItems: [defaultText])
                    }
                }
                .presentationDetents([.medium, .large])
                
            })
            .navigationTitle("Wibu App")
            .toolbarTitleDisplayMode(.large)
            .padding()
        }
        .searchable(text: $vm.searchText, prompt: "Looking for some waifu?")
        .onAppear {
            vm.getWaifuAsync()
        }
        .overlay {
            if !vm.searchText.isEmpty && vm.waifuResult.isEmpty {
                ContentUnavailableView.search(text: vm.searchText)
            }
        }
        .refreshable {
            vm.getWaifuAsync()
        }
      

    }
}

#Preview {
    ContentView(vm: HomeViewModel(service: WaifuService()))
}
