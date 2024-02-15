//
//  ShareSheetView.swift
//  WibuApp
//
//  Created by Agung Dwi Saputra on 15/02/24.
//

import SwiftUI


struct ShareSheetView: UIViewControllerRepresentable {
    
    let activityItems: [Any]
    
    let appActivity: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: appActivity)
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        //do what?
    }
    
}
