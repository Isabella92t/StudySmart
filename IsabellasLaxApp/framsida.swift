//
//  framsida.swift
//  IsabellasLaxApp
//
//  Created by Isabella Heidari on 2026-01-21.
//

import SwiftUI

struct framsida: View {
    var body: some View {
        
       
        NavigationStack{
            
            
            Text("StudySmart")
                .font(.largeTitle)
                .padding()
            
                
            .padding()
             
            VStack{
                Text("Saved content")
                    .font(.largeTitle)
                    .padding(15)
                    .foregroundStyle(.black)
                    .background(Color.blue)
                .cornerRadius(30)            }
            
            
            
            VStack{  NavigationLink(destination: MakeYourOwnList()) {
                Text("Expand content")
                    .font(.largeTitle)
                    .padding(15)
                    .foregroundStyle(.black)
                    .background(Color.green)
                    .cornerRadius(30)
            }            }
        }
        }
    }


#Preview {
    framsida()
}

