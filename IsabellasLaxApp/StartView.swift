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
            VStack {
                Text("StudySmart")
                    .font(.largeTitle)
                    .padding(.top)

                Text("Make it easier for your projects")

                Spacer(minLength: 0)

                NavigationLink(destination: MakeYourOwnList()) {
                    Text("Start here")
                        .font(.largeTitle)
                        .padding(40)
                        .foregroundStyle(.black)
                        .background(Color.green)
                        .cornerRadius(60)
                }
                .padding(.bottom, 24)

                Spacer()
            }
            .padding(.top, 100)
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}

