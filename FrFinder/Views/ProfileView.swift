//
//  ProfileView.swift
//  FrFinder
//
//  Created by David Jones on 25/07/2022.
//

/*
 Need to add user settings (maybe in another view)
 - Where users can say what info they want to be displayed or not
 - Or how specific the info is
 - Or Whether only friends can see what info or not
 Picture adding - (filter detector?)
 Add info
 - Location detector - e.g. Allow location use - detects and puts to closest town
 - Gender
 - Interests (general) etc - film, sports, food,
 - Interests - (specific) etc - rock climbing, 'this tv show' etc...
 - Bio - 250 space charfield
 */

import Foundation
import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import CoreLocation
import CoreLocationUI


struct ProfileView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @ObservedObject var locationManager = LocationManager.shared
    
    @State var isPickerShowing = false
    @State var selectedImage: UIImage?
    @State var retrievedImages = [UIImage]()
    @State var nickNameS = ""
    @State var bioS = ""
    @State var interestSubmit = ""
    @State var isInterestFieldShowing = false
    @State var retrievedInterests = [String]()
    
    var body: some View {
        Group {
            VStack {
                Text("Friend Finder").font(.title)
                Divider().foregroundColor(Color.black)
                ScrollView{
                    
                    VStack {
                        Text("Your photos")
                        ScrollView(.horizontal) {
                            HStack {
                                // Retrieve Images section
                                ForEach(retrievedImages, id: \.self) {image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                }
                            }
                        }
                        Button {
                            // Show image picker
                            isPickerShowing = true
                        } label: {
                            Text("Upload a photo")
                        }
                        
                        if selectedImage != nil {
                            Image(uiImage: selectedImage!)
                                .resizable()
                                .frame(width: 200, height:200)
                        }
                        
                        // Upload button
                        if selectedImage != nil {
                            Button {
                                // Upload image
                                uploadPhoto()
                            } label: {
                                Text("Upload photo")
                            }
                        }
                        
                        Divider().foregroundColor(Color.black)
                        
                        
                    }
                    
                    
                    VStack {
                        if viewModel.nick != "" {
                            Text("Nickname")
                            Text(viewModel.nick).foregroundColor(Color.green)
                            Button(action: {
                                DispatchQueue.main.async {
                                    viewModel.nick = ""
                                }
                            }, label: {
                                Text ("Change nickname?")
                                    .foregroundColor(Color.blue)
                            })
                        } else {
                            TextField("Nickname", text: $nickNameS)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                            Button(action: {
                                viewModel.storeNickname(nick: nickNameS)
                                viewModel.nick = nickNameS
                            }, label: {
                                Text ("Submit")
                                    .frame(width: 100, height: 30)
                                    .background(Color.green)
                                    .foregroundColor(Color.blue)
                                    .padding()
                            })
                        }
                        
                        
                        VStack {
                            Divider().foregroundColor(Color.black)
                            Text("Age: \(viewModel.age)")
                            Divider().foregroundColor(Color.black)
                            
                            // Location Section
                            Text("Location")
                            // Location section
                            if locationManager.userLocation == nil {
                                ZStack {
                                    VStack {
                                        Image(systemName: "paperplane.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.blue)
                                        
                                        VStack {
                                            Button {
                                                DispatchQueue.main.async {
                                                    LocationManager.shared.requestLocation()
                                                    viewModel.storeLoc(loc: locationManager.locality)
                                                }
                                            } label: {
                                                Text("Update location")
                                            }
                                        }
                                    }
                                }
                            } else {
                                Text("\(locationManager.locality)").foregroundColor(Color.green)
                                let _ = viewModel.storeLoc(loc: locationManager.locality)
                                Button {
                                    DispatchQueue.main.async {
                                        LocationManager.shared.requestLocation()
                                        viewModel.storeLoc(loc: locationManager.locality)
                                    }
                                } label: {
                                    Text("Update location")
                                }
                            }
                            Divider().foregroundColor(Color.black)
                        }
                        
                        // Interests Section
                        Text("Interests")
                        if !retrievedInterests.isEmpty {
                            let interests = retrievedInterests
                            ScrollView(.horizontal) {
                                HStack {
                                    Divider().foregroundColor(Color.black)
                                    ForEach(interests, id: \.self) { interest in
                                        Text(interest).foregroundColor(Color.green)
                                        Divider().foregroundColor(Color.black)
                                    }
                                }
                            }
                        }
                        if isInterestFieldShowing == true {
                            HStack {
                                TextField("Add interest", text: $interestSubmit)
                                    .background(Color(.secondarySystemBackground))
                                Button(action: {
                                    
                                    DispatchQueue.main.async {
                                        viewModel.storeInterest(interest: interestSubmit)
                                        retrievedInterests.append(interestSubmit)
                                    }
                                    let seconds = 0.5
                                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                        isInterestFieldShowing = false
                                    }
                                    
                                }, label: {
                                    Text ("/")
                                        .foregroundColor(Color.blue)
                                })
                            }.padding()
                            
                        }
                        Button(action: {
                            isInterestFieldShowing = true
                        }, label: {
                            Text ("Add an interest?")
                                .foregroundColor(Color.blue)
                        })
                        
                        // Bio section
                        Divider().foregroundColor(Color.black)
                        VStack {
                            Text("Bio")
                            if viewModel.bio != "" {
                                Text(viewModel.bio)
                                    .foregroundColor(Color.green)
                                    .multilineTextAlignment(.center)
                                Button(action: {
                                    DispatchQueue.main.async {
                                        viewModel.bio = ""
                                    }
                                }, label: {
                                    Text ("Change bio?")
                                        .foregroundColor(Color.blue)
                                })
                            } else {
                                ZStack {
                                    TextEditor(text: $bioS)
                                    Text(bioS).opacity(0).padding(.all, 8)
                                }.shadow(radius: 1)
                                Button(action: {
                                    viewModel.storeBio(bio: bioS)
                                    viewModel.bio = bioS
                                }, label: {
                                    Text ("Submit")
                                        .frame(width: 100, height: 30)
                                        .background(Color.green)
                                        .foregroundColor(Color.blue)
                                        .padding()
                                })
                                
                            }
                        }.padding()
                    }
                    
                    
                    
                    Spacer()
                    Button(action: {
                        DispatchQueue.main.async {
                            viewModel.signOut()
                        }
                    }, label: {
                        Text ("Sign Out")
                            .frame(width: 200, height: 50)
                            .background(Color.green)
                            .foregroundColor(Color.blue)
                            .padding()
                    })
                }
                
            }.sheet(isPresented: $isPickerShowing, onDismiss: nil) {
                // Image picker
                ImagePicker(selectedImage: $selectedImage, isPickerShowing: $isPickerShowing)
            }
            .onAppear {
                if retrievedInterests.isEmpty && retrievedImages.isEmpty {
                    DispatchQueue.main.async {
                        retrieveInfo()
                    }
                }
            }
        }
    }
    
    func uploadPhoto() {
        // Ensure selected image property isn't nil
        guard selectedImage != nil else {
            return
        }
        
        // Create storageRef
        let storageRef = viewModel.storage.reference()
        
        // turn image into data
        let imageData = selectedImage!.jpegData(compressionQuality: 0.8)
        
        guard imageData != nil else {
            return
        }
        
        // Specify file path and name
        let path = "images/\(UUID().uuidString).jpg"
        let fileRef = storageRef.child(path)
        
        // upload data
        let uploadTask = fileRef.putData(imageData!, metadata: nil) {
            metadata, error in
            if error == nil && metadata != nil {
                
                // Save a reference to the file in firestore DB
                /*
                 Associate upload with particular user
                 Image reference gets sent to user collection in firestore.
                 */
                
                viewModel.firestore.collection("users").document(viewModel.auth.currentUser!.uid)
                    .updateData([ "imgURLs" : FieldValue.arrayUnion([path]) ]) { error in
                        
                        // if no errors display new image
                        if error == nil {
                            DispatchQueue.main.async {
                                // Add uploaded image to the list of images for display
                                self.retrievedImages.append(self.selectedImage!)
                                self.selectedImage = nil
                            }
                        }
                    }
            }
        }
    }
    
    func retrieveInfo() {
        // Get data from DB
        viewModel.firestore.collection("users").getDocuments { snapshot, error in
            if error == nil && snapshot != nil {
                var imgPaths = [String]()
                var intPaths = [String]()
                
                // Loop through returned documents
                for doc in snapshot!.documents {
                    if doc.documentID == viewModel.auth.currentUser!.uid {
                        // Extract file path
                        // Extract path and add to array
                        if doc["imgURLs"] != nil {
                            imgPaths.append(contentsOf: doc["imgURLs"] as! [String])
                        }
                        if doc["nick"] != nil {
                            viewModel.nick = doc["nick"] as! String
                        }
                        
                        if doc["bio"] != nil {
                            viewModel.bio = doc["bio"] as! String
                        }
                        
                        if doc["interests"] != nil {
                            intPaths.append(contentsOf: doc["interests"] as! [String])
                        }
                        
                        if doc["dob"] != nil {
                            let dob = doc["dob"] as! String
                            let dobf = dob.description.prefix(4)
                            let today = Date().description.prefix(4)
                            let curYear = Int(today)
                            let DOBYear = Int(dobf)
                            let age = curYear!-DOBYear!
                            viewModel.age = String(age)
                            
                        }
                    }
                }
                
                // Loop through each file path and fetch data from storage
                for path in imgPaths {
                    // Get a ref to storage
                    let storageRef = viewModel.storage.reference()
                    
                    // Specify path
                    let fileRef = storageRef.child(path)
                    
                    // Retrieve Data
                    fileRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                        if error == nil && data != nil{
                            // Create a UIImage and put it into our array for display
                            if let image = UIImage(data: data!) {
                                // Need to check whether what is being appended is already in the UI array or not.
                                DispatchQueue.main.async {
                                    retrievedImages.append(image)
                                }
                            }
                        }
                    }
                }
                
                for path2 in intPaths {
                    // Need to check whether what is being appended is already in the UI array or not.
                    //let _ = print(path2)
                    //let _ = print(retrievedInterests)
                    DispatchQueue.main.async {
                        retrievedInterests.append(path2)
                    }
                }
            }
        }
    }
}

