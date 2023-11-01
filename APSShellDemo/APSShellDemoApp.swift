//
//  APSShellDemoApp.swift
//  APSShellDemo
//
//  Created by Li Chengxi on 2023/4/12.
//

import SwiftUI
import Foundation

class AppState: ObservableObject {
    @Published var strText: String
    @Published var clientId: String
    
    init(){
        self.strText = "Waiting"
        self.clientId = (ProcessInfo.processInfo.environment["APS_CLIENT_ID"] ?? "Missing Client ID in environment variables.\n Use 'launchctl setenv' to add to your environment") as String
    }
}


final class APPDelegate: NSObject, NSApplicationDelegate {
    
    var appState = AppState()
    
    
    lazy var callback: CFMessagePortCallBack = { messagePort, messageID, cfData, info in
        guard let pointer = info,
              let dataReceived = cfData as Data?,
              let string = String(data: dataReceived, encoding: .utf8  ) else {
            return nil
            }
        let appDelegate = Unmanaged<APPDelegate>.fromOpaque(pointer).takeUnretainedValue()
        appDelegate.appState.strText = string
        return nil
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        if urls.count > 0 {
            appState.strText = urls[0].absoluteString
        }
    }
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false;
        // We must add a port after our app group like below
        let port = "DAS.APSShellDemoPort.oAuth" as CFString
                
        let runningApp =
            NSWorkspace.shared.runningApplications
                .filter { item in item.bundleIdentifier == Bundle.main.bundleIdentifier }
                .first { item in item.processIdentifier != getpid() }
        if runningApp != nil {
            guard let messagePort = CFMessagePortCreateRemote(nil, port)
            else{
                let alert = NSAlert()
                alert.messageText = "error"
                alert.runModal()
                exit(1)
            }
            var unmanagedData: Unmanaged<CFData>? = nil;
            CFMessagePortSendRequest(messagePort, 0, Data(self.appState.strText.utf8) as CFData, 3.0, 3.0, CFRunLoopMode.defaultMode.rawValue, &unmanagedData)
            exit(0)
        }
        else{
            let info = Unmanaged.passUnretained(self).toOpaque()
            var context = CFMessagePortContext(version: 0, info: info, retain: nil, release: nil, copyDescription: nil)

            if let messagePort = CFMessagePortCreateLocal(nil, port, callback, &context, nil) ,
                let source = CFMessagePortCreateRunLoopSource(nil, messagePort, 0 ){
                    CFRunLoopAddSource(CFRunLoopGetMain(), source, .defaultMode)
                }
        }
    
    }
    
}

@main
struct APSShellDemoApp: App {
    
    @NSApplicationDelegateAdaptor(APPDelegate.self) var appDelegate
    
    var body: some Scene {
        Window("APSShellDemo", id: "main") {
            ContentView()
                .environmentObject(appDelegate.appState)
            
        }
    }
}
