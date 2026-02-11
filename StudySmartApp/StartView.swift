//
//  StartView.swift
//  IsabellasLaxApp
//
//  Created by Isabella Heidari on 2026-01-21.
//

import SwiftUI

struct StartView: View {

    var body: some View {
        NavigationStack {
            ZStack {
               AppBackground()
                
                VStack {
                    
                    HStack {Text("StudySmart")
                            .font(.largeTitle)
                        Image(systemName: "bird")
                            .font(.largeTitle)
                
                    }
                    .padding(.top, 120)

                    Text("Gör det enklare")
                  
                    
                    Spacer(minLength: 0)

                    NavigationLink(destination: FolderCreateView()) {
                        Text("Start here")
                            .font(.largeTitle)
                            .padding(40)
                            .foregroundStyle(.black)
                            .background(Color.green)
                            .cornerRadius(60)
                    }
                    .padding(.bottom, 10)

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}

import SwiftUI

struct AppBackground: View {
    var body: some View {
        Color(red: 227/255, green: 244/255, blue: 220/255)
            .ignoresSafeArea()
    }
}
