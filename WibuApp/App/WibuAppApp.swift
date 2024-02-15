//
//  WibuAppApp.swift
//  WibuApp
//
//  Created by Agung Dwi Saputra on 13/02/24.
//

import SwiftUI

@main
struct WibuAppApp: App {

    
    var body: some Scene {
        
        WindowGroup {
            ContentView(vm: HomeViewModel(service: WaifuService()))
        }
    }
}
