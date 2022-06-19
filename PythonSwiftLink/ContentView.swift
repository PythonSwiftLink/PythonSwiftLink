//
//  ContentView.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 22/05/2022.
//

import SwiftUI
//import ArgumentParser
import RealmSwift
var DEBUG_MODE = true





struct ContentView: View {
    
    @ObservedRealmObject var root_data: KSLDataModelNew
    @State var shown: Bool = true
    //@EnvironmentObject var data: KSLDataModel
    @EnvironmentObject var view_states: ViewStatesModel
    init(root_data: KSLDataModelNew) {
        print("ContentView")
        self.root_data = root_data
        //ViewStatesModel.shared.checkAppFilesExist()
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                UIList{
                    NavigationLink("Setup") {
                        if let recent = root_data.recentFolder {
                            SetupView(data: recent)
                        }
                        
                    }
                    NavigationLink("Projects") {
                        if let recent = root_data.recentFolder {
                            ProjectsView(folder_data: recent)
                        }
                    }
                    NavigationLink("Build") {
                        Text("Build")
                    }

                }.padding()
            }
            .disabled(root_data.no_config_alert)

            .navigationTitle(root_data.recentFolder?.path ?? "No Active Folder")
            //}
            .onChange(of: root_data.no_config_alert, perform: { newValue in
                print("root_data.no_config_alert", true)
                
            })
            
            if view_states.appSetupIsRunning {
                StatusTextViewer(data: view_states.appSetupLogData)
            }
        
        }
//        .onAppear {
//            view_states.checkAppFilesExist()
//        }
        .sheet(isPresented: $root_data.no_config_alert) {
            NoConfigView(
                path: root_data.current_url,
                active: $root_data.no_config_alert,
                completion: {
                    let folder = WorkingFolderData(filePath: URL(fileURLWithPath: root_data.current_url))
                    guard let root_data = root_data.thaw() else { return }
                    guard let _realm = root_data.realm else { return }
                    try? _realm.write({
                        root_data.recentFolders.append(folder)
                        //root_data.recentFolder = folder
                        root_data.recentFolder_id = folder.id
                    })
                    
                     //$root_data.recentFolder_id.wrappedValue = folder.id
                    
                     //$root_data.no_config_alert.wrappedValue.toggle()
                }
            )
                .frame(width: 480, height: 240)
        }
    }
        
    func newAlert(url: URL?) -> Alert {
        var path_string = "<No Path>"
        if let url = url {
            path_string = url.path
        }
        return Alert(
            title:
                Text("""
                \(path_string)
                Not found in the Database.
                Do you wish to
                """),
            primaryButton: .cancel(Text("No")),
            secondaryButton: .default(Text("Yes"), action: {
                //project_data.delete_project()
            })
        )
    }
        
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(root_data: KSLDataModelNew())
            .environmentObject(KSLDataModel(preview: true))
            .environmentObject(ViewStatesModel.shared)
    }
}
