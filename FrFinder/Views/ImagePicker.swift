//
//  ImagePicker.swift
//  FrFinder
//
//  Created by David Jones on 26/07/2022.
//

import Foundation
import SwiftUI


struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var selectedImage: UIImage?
    @Binding var isPickerShowing: Bool
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = context.coordinator
        // Obj that can receive uiimagepickercontroller events
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}

class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var parent: ImagePicker
    
    init(_ picker: ImagePicker) {
        self.parent = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any ] ) {
        // run code whge user has selected an image
        print("Image selected")
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            DispatchQueue.main.async {
                // Retrieved imag
                self.parent.selectedImage = image
            }
        }
        // Dismiss picker
        parent.isPickerShowing = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Code for when user cancelled picker UI
        print("Cancelled")
        parent.isPickerShowing = false
    }
}
