//
//  SetupView.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 22/05/2022.
//

import SwiftUI
//import ArgumentParser
import SwiftUIWindow
import RealmSwift
//import xLogViewer
 
let SetupSectionBDColor = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))

struct SetupView: View {
    @EnvironmentObject var view_states: ViewStatesModel
    
    @ObservedRealmObject var data: WorkingFolderData
    
    //@EnvironmentObject var data: KSLDataModel
    //@EnvironmentObject var log_data: LogData
    
    @State var sel: String = ""
    //@State var showLog = false
   // @State var setupRunning = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Form {
                    UIList {
                        
                        Spacer()
                        //.frame(maxWidth: .infinity)
//                        Section {
//                            PythonVenvRow()
//                        } header: {
//                            Text("Use External Python")
//                        }
                        Section {
                            Toggle("Enabled", isOn: $data.python_lib_each_project)
                        } header: {
                            Text("Unique Python/Lib each Project")
                        }.disabled(data.plep_locked)
                        Spacer()
                        Section {
                            UIList {
                                ForEach(data.recipes, id: \.sha) { recipe in
                                    RecipeRowView(recipe_data: recipe)
                                }
                            }.padding(.horizontal, 28)
                
                            .frame(height: 360)
                        } header: {
                            Text("Select extra Recipes")
                        }
                        
                        
                    }
                    Button("Run") {
                        
                        data.run_setup()
                        view_states.setupIsRunning.toggle()
                        SwiftUIWindow.open {_ in
                            StatusTextViewer(data: view_states.setupLogData)
                                    .frame(width: 640, height: 480)
                            }

                        if !data.plep_locked {
                            $data.plep_locked.wrappedValue.toggle()
                        }
                    }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                }
                .disabled(view_states.setupIsRunning)
                if view_states.setupIsRunning {
                    Color.init(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.75)
                    ProgressView("Running Setup")
                }
            }
                
            
        }
        
        .onAppear {
//            if data.setup_path_config_missing {
//                data.no_config_alert = true
//            }
        }
    }
}

struct SetupView_Previews: PreviewProvider {
    
    var sel: String = ""
    
    static var previews: some View {
        SetupView(data: WorkingFolderData())
            .environmentObject(KSLDataModel(preview: true) )
            .environmentObject(ViewStatesModel())
            .previewLayout(.fixed(width: 499, height: 480)  )
    }
}
