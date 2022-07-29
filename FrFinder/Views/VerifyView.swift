//
//  VerifyView.swift
//  FrFinder
//
//  Created by David Jones on 25/07/2022.
//

import Foundation
import SwiftUI

struct verifyView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State var efeedback = ""
    
    var body: some View {
        VStack {
            //let _ = print(viewModel.auth.currentUser?.uid)
            //let _ = print(viewModel.age)


            Text("Your email requires verification")
            if viewModel.isSignedIn {
                Text("Email used: " + (viewModel.auth.currentUser?.email)!)
            }
            Button(action: {
                viewModel.sendVerificationMail()
            }, label: {
                Text ("Re-send email")
                    .frame(width: 200, height: 50)
                    .background(Color.green)
                    .foregroundColor(Color.blue)
                    .padding()
            })
            
            Button(action: {
                viewModel.auth.currentUser?.reload()
                if viewModel.auth.currentUser?.isEmailVerified == false {
                    efeedback = "Your email still requires verification."
                } else {
                    efeedback = "Your email has been verified, please sign in again to continue."
                    let seconds = 0.5
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                        viewModel.signOut()
                    }
                }
            }, label: {
                Text ("Refresh Status")
                    .frame(width: 200, height: 50)
                    .background(Color.green)
                    .foregroundColor(Color.blue)
                    .padding()
            })
            
            Text (efeedback).foregroundColor(Color.red)
            
            Text ("Your verification email was most likely sent to your 'Spam' folder")
                .foregroundColor(Color.blue)
            
            Spacer()
            Button(action: {
                viewModel.signOut()
            }, label: {
                Text ("Sign Out")
                    .frame(width: 200, height: 50)
                    .background(Color.green)
                    .foregroundColor(Color.blue)
                    .padding()
            })
        }.onAppear { viewModel.storeUserInfo(age: viewModel.age) }
    }
}
