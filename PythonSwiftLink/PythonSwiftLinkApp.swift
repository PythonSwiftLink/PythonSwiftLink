//
//  KivySwiftLink_GUIApp.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 22/05/2022.
//

import SwiftUI
import Cocoa
import AppKit
import RealmSwift
import PythonKit


func checkAppFolderExist() {
    let url = KSLPaths.shared.APPLICATION_SUPPORT_FOLDER.appendingPathComponent("database")
    if !FM.fileExists(atPath: url.path) {
        try? FM.createDirectory(at: url, withIntermediateDirectories: true)
    }
}


extension Bundle {

    var releaseVersionNumber: String? {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildVersionNumber: String {
        return self.infoDictionary?["CFBundleVersion"] as! String
    }

}


typealias RealmList = RealmSwift.List

typealias UIList = SwiftUI.List



var realm_shared = try! Realm()

@objc class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationWillTerminate(_ notification: Notification) {
        print("KSL will quit")
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        print("KSL will Launch")
    }
    

}


@main
struct PythonSwiftLinkApp: SwiftUI.App {
    
    @StateObject var app_model = KSLRealmDataModel(realm_name: "db")
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var view_states = ViewStatesModel.shared
    //@StateObject var data: KSLDataModel = KSLDataModel.shared
    //@ObservedResults(KSLDataModelNew.self) var data_model
    
    //@ObservedResults(KivyRecipeData.self) var recipes
    //@ObservedResults(GlobalAppData.self) var groups
    
    //@StateObject var log_data: LogData = LogData()
    //@State var recentFolder_index: WorkingFolder = WorkingFolder(path: "")
    //@State var recentFolder_index_: WorkingFolderData = WorkingFolderData()
    
    @State var recentFolder_UUID = ""
    //@State private var no_setup_alert = false
    
    init() {

        checkAppFolderExist()
        
        
    }
    
    var body: some Scene {
        
        
        WindowGroup {
            
            if let first = app_model.result {
                ContentView(root_data: first)
                    .frame(minWidth: 840,maxWidth: 840, minHeight: 720, maxHeight: 720)
                    .environmentObject(view_states)
                    
                
            } else {
                Text("No Data")
            }
        }
        
        
        
        
        
        .commands(content: {
            
        })
        .commands {
            
            MainCommands(model: app_model, view_states: view_states)
                
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                            Button("Custom app info") {
                                // show custom app info
                            }
                        }
            //SortingCommands(sorting: $sorting)
            
        }
    }
    
    
}



