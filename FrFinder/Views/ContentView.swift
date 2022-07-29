//
//  ContentView.swift
//  FrFinder
//
//  Created by David Jones on 22/07/2022.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class AppViewModel: ObservableObject {
    let auth = Auth.auth()
    let firestore = Firestore.firestore()
    let storage = Storage.storage()
    
    @Published var signedIn = false
    @Published var age = ""
    @Published var nick = ""
    @Published var bio = ""
    @Published var interests = [String]()
    
    
    private var authUser : User? {
        return Auth.auth().currentUser
    }
    
    var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email,
                    password: password) { [weak self] result, error in
            guard result != nil, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                // Success
                self?.signedIn = true
            }
        }
    }
    
    func storeUserInfo(age: String) {
        guard let uid = auth.currentUser?.uid else {
            return
        }
        let userData = ["dob" : age, "email" : auth.currentUser?.email]
        firestore.collection("users").document(uid).setData(userData as [String : Any]) { err in
            if let err = err {
                print(err)
            }
        }
    }
    
    func storeNickname( nick : String) {
        guard let uid = auth.currentUser?.uid else {
            return
        }
        let userData = ["nick": nick]
        firestore.collection("users").document(uid).updateData(userData as [String : Any]) { err in
            if let err = err {
                print(err)
            }
        }
    }
    
    func storeBio( bio : String) {
        guard let uid = auth.currentUser?.uid else {
            return
        }
        let userData = ["bio": bio]
        firestore.collection("users").document(uid).updateData(userData as [String : Any]) { err in
            if let err = err {
                print(err)
            }
        }
    }
    
    func storeLoc( loc : String) {
        guard let uid = auth.currentUser?.uid else {
            return
        }
        let userData = ["loc":loc]
        firestore.collection("users").document(uid).updateData(userData as [String : Any]) { err in
            if let err = err {
                print(err)
            }
        }
    }
    
    func storeInterest( interest : String) {
        guard let uid = auth.currentUser?.uid else {
            return
        }
        firestore.collection("users").document(uid)
            .updateData([ "interests" : FieldValue.arrayUnion([interest]) ]) { error in
                if error == nil {
                    self.interests.append(interest)
                }
            }
    }
        
        func sendVerificationMail() {
            if self.authUser != nil && !self.authUser!.isEmailVerified {
                self.authUser!.sendEmailVerification(completion: { (error) in
                    // Notify the user that the mail has sent or couldn't because of an error.
                })
            }
        }
        
        func signUp(email: String, password: String) {
            auth.createUser(withEmail: email, password: password) { [weak self] result, error in
                guard result != nil, error == nil else {
                    return
                }
                
                self?.sendVerificationMail()
                
                DispatchQueue.main.async {
                    // Success
                    self?.signedIn = true
                }
            }
        }
        
        func signOut() {
            try? auth.signOut()
            
            self.signedIn = false
        }
    }
    
    func isValidPass(testStr:String?) -> Bool {
        guard testStr != nil else { return false}
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[$@$#!%*?&])(?=.*[0-9])(?=.*[a-z]).{8,}")
        return passwordTest.evaluate(with:testStr)
    }
    
    struct ContentView: View {
        @EnvironmentObject var viewModel: AppViewModel
        
        
        var body: some View {
            VStack {
                if viewModel.signedIn == true {
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
                        }.background(Color(.secondarySystemBackground))
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
    
    
    // Sign in View
    struct SignInView: View {
        @State var email = ""
        @State var pass = ""
        @State var pfeedback = ""
        
        @EnvironmentObject var viewModel: AppViewModel
        var body: some View {
            NavigationView {
                VStack {
                    Text("Friend Finder")
                        .font(.title).bold()
                    
                    Image("FriendsIMG")
                        .resizable()
                        .scaledToFit()
                    
                    VStack {
                        Text("Sign In")
                        
                        TextField("Email Address", text: $email)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                        
                        SecureField("Password", text: $pass )
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                        
                        
                        Text(pfeedback)
                            .foregroundColor(Color.red)
                        
                        
                        Button(action: {
                            guard !email.isEmpty, !pass.isEmpty else {
                                return
                            }
                            
                            viewModel.signIn(email: email, password:pass)
                            
                            let seconds = 0.8
                            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                if !viewModel.isSignedIn {
                                    pfeedback = "Incorrect username or password."
                                }
                            }
                            
                        }, label: {
                            Text("Enter")
                                .foregroundColor(Color.white)
                                .frame(width:200, height: 50)
                                .background(Color.blue)
                                .cornerRadius(3.0)
                        })
                        
                        
                        Spacer()
                        HStack{
                            Text("No account?")
                            NavigationLink("Register", destination: SignUpView())
                        }
                        .padding()
                        
                    }
                }
                .navigationBarHidden(true)
                .padding()
            }
        }
    }
    
    // Account Registration View
    struct SignUpView: View {
        @State var email = ""
        @State var pass = ""
        
        @State var efeedback = ""
        @State var feedback = ""
        @State var feedback2 = ""
        @State var feedback3 = ""
        @State var ageFeedback = ""
        @State var successmsg = ""
        @State var DOB = Date()
        @State var curYear = ""
        
        @EnvironmentObject var viewModel: AppViewModel
        var body: some View {
            VStack {
                Text(efeedback).foregroundColor(Color.red)
                Text(feedback).foregroundColor(Color.red)
                Text(feedback2).foregroundColor(Color.red)
                Text(feedback3).foregroundColor(Color.red)
                
                VStack {
                    TextField("Email Address", text: $email)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                    
                    SecureField("Password", text: $pass )
                        .onChange(of: pass) {
                            print($0)
                            if (pass.count < 8) {
                                feedback = "Password must be at least 8 characters."
                                feedback2 = ""
                            } else {
                                feedback = ""
                                if pass.range(of: "(?=.*[$@$#!%*?&])", options: .regularExpression) != nil {
                                    feedback2 = ""
                                } else { feedback2 = "A special character is required." }
                                if pass.range(of: "(?=.*[A-Z])", options: .regularExpression) != nil {
                                    feedback3 = ""
                                } else { feedback3 = "A capitalised letter is required." }
                            }
                        }
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                    
                    DatePicker("Date of Birth", selection: $DOB, in: ...Date(), displayedComponents:.date)
                    let DOBF = DOB.description.prefix(10)
                    let DOBC = DOB.description.prefix(4)
                    let today = Date().description.prefix(4)
                    let curYear = Int(today)
                    let DOBYear = Int(DOBC)
                    
                    
                    
                    Button(action: {
                        guard !email.isEmpty, !pass.isEmpty, !DOB.description.isEmpty else {
                            feedback = "Email or password field do not meet requirements"
                            return
                        }
                        if !email.contains("@") {
                            efeedback = "Email requires @ character"
                        } else { efeedback = "" }
                        
                        print(curYear!-DOBYear!)
                        if ((curYear!-DOBYear!) < 18 ) {
                            ageFeedback = "Age of 18+ Required"
                            return
                        }
                        
                        if isValidPass(testStr: pass) {
                            successmsg = "Account Created"
                            viewModel.age = String(DOBF)
                            let seconds = 0.5
                            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                viewModel.signUp(email: email, password: pass)
                            }
                        }
                        
                    }, label: {
                        Text("Create Account")
                            .foregroundColor(Color.white)
                            .frame(width:200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(3.0)
                    })
                    Text(successmsg)
                        .foregroundColor(Color.green)
                    Text(ageFeedback)
                        .foregroundColor(Color.red)
                }
                .padding()
                Spacer()
            }
            .navigationTitle("Register")
        }
    }
