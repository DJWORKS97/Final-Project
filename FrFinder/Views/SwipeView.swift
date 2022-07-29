//
//  SwipeView.swift
//  FrFinder
//
//  Created by David Jones on 25/07/2022.
//

import Foundation
import SwiftUI

struct SwipeView: View {
    @EnvironmentObject var viewModel: AppViewModel
    var body: some View {
        VStack {
            Text("Friend Finder").font(.title)
            Divider().foregroundColor(Color.black)
            
            // Swipe section (look at other users and add them as friends
            // Can just say with more implementation it would involve a chat...
            // Needs to read documents from firestore, find users with the same loc value.
            // Then display the user
            Spacer()
        }
    }
}
