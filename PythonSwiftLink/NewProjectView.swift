//
//  NewProjectView.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 26/05/2022.
//

import SwiftUI
import RealmSwift


struct AdmobSettings: View {
    
    //@State var app_id: String = "ca-app-pub-3940256099942544~1458002511"
    @Binding var app_id: String
    @State var test_mode = false
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("app id:")
                    TextField("App id", text: $app_id)
                }
                
                
            } header: {
                Text("Admob Settings:")
                    .font(.bold(.subheadline)())
                    .foregroundColor(.gray)
                    
            }
            
        }
        .padding()
        .background(ZStack {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder()
        })
    }
}


struct NewProjectAddonsView: View {
    
    @Binding var Admob_used: Bool
    @Binding var admob_id: String
    
    var body: some View {
        Form {
            Section {
                if Admob_used {
                    Divider()
                    AdmobSettings(app_id: _admob_id)
                       
                }
            } header: {
                HStack {
                    Text("Admob")
                    Spacer()
                    Toggle("Enabled", isOn: _Admob_used)
             
                }
            }
        }
        .padding(.vertical, 16)
    }
    
    
}

struct NewProjectInfoKeysView: View {
    
    @Binding var project_name: String
//    @Binding var app_info_key_enabled: [Bool]
//    @Binding var app_info_key_values: [String]
    @Binding var app_info_dict: [String:String]
    
    var body: some View {
        Form {
            Section {
                
                ForEach(app_info_dict.keys.sorted(), id: \.self) { k in
                    newKeyInput(key: k)
                }
                
            } header: {
                Text("Plist keys")
            }
        }
        .padding()
        .background(ZStack{
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder()
        })
            
    }
    
    private func newKeyInput(key: String) -> some View {
        let converted_keys: [String:String] = [
            "CFBundleIdentifier": "App Bundle Identifier:",
            "NSCameraUsageDescription": "Camera key info:"
        ]
        
        return HStack {
            Text(converted_keys[key] ?? key)
            switch key {
            case "CFBundleIdentifier":
                TextField("org.kivy.\(project_name)", text: self.binding(for: key))
            default:
                TextField("org.kivy.\(project_name)", text: self.binding(for: key))
            }
        
        }

    }
    
    private func binding(for key: String) -> Binding<String> {
            return .init(
                get: { self.app_info_dict[key, default: ""] },
                set: { self.app_info_dict[key] = $0 })
        }
}


struct NewProjectPipListPicker: View {
    
    //@ObservedObject var pip_man: PipManagerData
    @ObservedRealmObject var folder: WorkingFolderData
    //@ObservedRealmObject var project: KSLProjectData
//    @Binding var selection: PipManagerList?
    @Binding var selection: ObjectId
    var body: some View {
        Picker("Pip list:", selection: $selection) {

            ForEach(folder.getPipLists(), id: \.self) { list in
                Text(list.name).tag(list.id)
                
            }
        }
    }
}

struct NewProjectView: View {
    //@ObservedObject var projects_data: KSLProjects
    @EnvironmentObject var model: KSLRealmDataModel
    @EnvironmentObject var view_states: ViewStatesModel
    @ObservedRealmObject var data: WorkingFolderData
    @Binding var active: Bool
    
    @State var inProgress = false
    @State var project_name: String = ""
    @State var python_folder: URL? = nil
    
    @State var admob_used = false
    @State var admob_id: String = "ca-app-pub-3940256099942544~1458002511"
    
    @State var pip_list_id = ObjectId()
    
    @State var app_info_dict: [String:String] = [
        "CFBundleIdentifier": "",
        "NSCameraUsageDescription": "$(PRODUCT_NAME) camera use"
    ]
    
    var body: some View {
        Form {
            Section {
                
                VStack {
                    TextField("input project name", text: $project_name)
                        .multilineTextAlignment(.center)
                    Text("Python Source Folder")
                        .font(.bold(.subheadline)())
                        .foregroundColor(.gray)
                    HStack {
                        Text(python_folder != nil ? python_folder!.path : "select folder" )
                            .padding(4)
                            .frame(maxWidth: .infinity)
                            
                            .background(ZStack{
                                Rectangle()
                                    .strokeBorder()
                                    
                            })
                        Spacer()
                        Button(
                            action: {
                                selectFolder { folder in
                                    python_folder = folder
                                }
                            },
                            label: {
                                Text("Open")
                            })
                    }
                    
                    NewProjectInfoKeysView(
                        project_name: $project_name,
//                        app_info_key_enabled: $app_info_key_enabled,
//                        app_info_key_values: $app_info_key_values,
                        app_info_dict: $app_info_dict
                    )
                    Divider()
                    NewProjectPipListPicker(folder: data, selection: $pip_list_id)
                    Divider()
                    NewProjectAddonsView(Admob_used: $admob_used, admob_id: $admob_id)
                }
                
                
            } header: {
                HStack {
                    Text("final project name:")
                        .font(.bold(.subheadline)())
                        .foregroundColor(.gray)
                        .padding()
                    Text("\(project_name)-ios")
                    
                }
            }
            
            
            HStack {
                Button("Create") {
                    //do {
                        //try! projects_data.create_project(name: project_name)
                    
                    createProject()
                        active.toggle()
                    //}
                    
                }
                .disabled(python_folder == nil || project_name.count == 0)
                Button("Cancel") {
                    active.toggle()
                }
            }
        }
        .padding()
        //.frame( maxWidth: .infinity, maxHeight: .infinity)
        
    }
    
    
    func createProject() {
        guard let py_src = python_folder else {return}
        var project_addons = [([String:String], KSLProjectAddonType)]()

        project_addons.append(
            contentsOf: app_info_dict.map{ ([$0.0:$0.1], .custom) }
        )
        if admob_used {
            project_addons.append(
                ([admob_id:""], .admob  )
            )
        }
        
        
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                view_states.projectCreateIsRunning.toggle()
                let project = KSLProjectData(
                    create: project_name,
                    python_folder: py_src,
                    working_folder: URL(fileURLWithPath: data.path),
                    addons: project_addons,
                    pip_list: data.getPipLists().first(where: { list in
                        list.id == pip_list_id
                    })
                )
                $data.projects.append(
                    project
                )
                $data.selected_project_id.wrappedValue = project.id
                if admob_used {
//                    project.importWrapper(file: URL(fileURLWithPath: "/Users/musicmaker/Downloads/ads_viewer.py"))
                    project.newWrapper(name: "admob_handler", cls_name: "AdmobHandler", code: AdmobHandlerCode)
                    Task {
                        await project.updateProject()
                        view_states.projectCreateIsRunning.toggle()
                    }
                } else {
                    view_states.projectCreateIsRunning.toggle()
                }
                
            }
        }
        
        //data.createToolchainProject(name: project_name)
        //$data.last_project.wrappedValue = project
    }
}

struct NewProjectView_Previews: PreviewProvider {
    static var previews: some View {
        NewProjectView(data: WorkingFolderData(), active: .constant(false), admob_used: true, admob_id: "ca-app-pub-3940256099942544~1458002511")
            .environmentObject(ViewStatesModel.shared)
            .previewLayout(.fixed(width: 640, height: 640))
    }
}
