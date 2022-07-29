//
//  codedumps.swift
//  
//
//  Created by David Jones on 23/07/2022.
//

import Foundation









struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        VStack {
            if viewModel.signedIn == true {
                let _ = print(viewModel.auth.currentUser?.isEmailVerified)
                if viewModel.auth.currentUser?.isEmailVerified == true {
                    VStack {
                        TabView() {
                            ProfileView()
                                .tabItem {
                                    Text("UProfile")
                                }
                            SwipeView()
                                .tabItem {
                                    Text("Swipe")
                                }
                        .navigationBarHidden(true)
                        }
                    }
                } else {
                    verifyView()
                }
            } else {
                SignInView()
            }
        }.onAppear {
            viewModel.signedIn = viewModel.isSignedIn
        }
    }
}

//if viewModel.auth.currentUser?.isEmailVerified != true {
    //let _ = print("User needs to verify their email")
    //viewModel.auth.currentUser?.sendEmailVerification()
//}
//let _ = print(viewModel.auth.currentUser?.email)

// Instalike tabs
VStack {
    TabView {
        // User Profile
        NavigationView() {
            VStack {
                Text("This is the Uprofile section")
                Button(action: {
                    viewModel.signOut()
                }, label: {
                    Text ("Sign Out")
                        .frame(width: 200, height: 50)
                        .background(Color.green)
                        .foregroundColor(Color.blue)
                        .padding()
                })
            }.navigationBarHidden(true)
                .background(Color.blue)
        }.tabItem {
            Text("UProfile")
        }
        
        // Swipe
        NavigationView {
            VStack {
                Text("This is the Swipe section")
            }.navigationBarHidden(true)
        }.tabItem {
            Text("Swipe")
        }
        
        // Local Events
        NavigationView {
            VStack {
                Text("This is the Local Events section")
            }.navigationBarHidden(true)
        }.tabItem {
            Text("Local Events")
        }
        
        // Impromptu
        NavigationView {
            VStack {
                Text("This is the Impromptu section")
            }.navigationBarHidden(true)
        }.tabItem {
            Text("Impromptu")
        }
        
        NavigationView {
            VStack {
                Text("This is the Chats section")
            }.navigationBarHidden(true)
        }.tabItem {
            Text("Chats")
        }
    }
}

// Sign out button
VStack {
    // User is signed in section
    Text("Signed In")
    Button(action: {
        viewModel.signOut()
    }, label: {
        Text ("Sign Out")
            .frame(width: 200, height: 50)
            .background(Color.green)
            .foregroundColor(Color.blue)
            .padding()
    })
}

// Setting background hex colors
extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
