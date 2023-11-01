//
//  ContentView.swift
//  APSShellDemo
//
//  Created by Li Chengxi on 2023/4/12.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    var body: some View {
        VStack {
            Text($appState.strText.wrappedValue)
            Text($appState.clientId.wrappedValue)
            Button("Authenticate!", action: {
                let str = "https://developer.api.autodesk.com/authentication/v1/authorize?response_type=code&client_id=\(appState.clientId)&redirect_uri=apsshelldemo://oauth&scope=data:read%20data:create%20data:write"
                if let url = URL(string:str){
                    NSWorkspace.shared.open(url)
                }
            })
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
