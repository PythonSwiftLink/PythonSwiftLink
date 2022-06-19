//
//  ProjectsView.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 26/05/2022.
//

import SwiftUI
import RealmSwift
var project_count = 0

struct ProjectsView: View {
    //@EnvironmentObject var data: KSLDataModel
    //@ObservedObject var project_data: KSLProjects
    @EnvironmentObject var view_states: ViewStatesModel
    @ObservedRealmObject var folder_data: WorkingFolderData
    @State var last_project: KSLProjectData?
    //@State var selection: KSLProjectData = KSLProjectData(name: "", dummy: true)
    @State var create_project_active = false
    @State var delete_project_active = false
    
    
    
    var body: some View {
        ZStack {
            
            GeometryReader { geo in
                VStack {
                    Form {
                        UIList {
                            Section {
                                Picker("Current Project", selection: $folder_data.selected_project_id, content: {
                                    ForEach(folder_data.projects) {project in
                                        Text(project.name).tag(project.id)
                                    }
                                })
                                    .pickerStyle(.menu)
                                    .padding()
                                    //.frame(height: 120)
                                HStack {
                                    Spacer()
                                    
                                    
                                    Button(
                                        action: {
                                            openXC_Project(url: folder_data.last_project!.path_url)
                                        },
                                        label: {
                                            Text("Open")
                                            Image(systemName: "filemenu.and.cursorarrow")
                                        }
                                    )
                                        .disabled(folder_data.last_project == nil)
                                    
                                    Button(
                                        action: {
                                            create_project_active = true
                                        },
                                        label: {
                                            Text("Create")
                                            Image(systemName: "plus")
                                        }
                                    )
                                        
                                    
                                    Button {
                                        guard folder_data.last_project != nil else {return}
                                        //if data.setup_path_config_missing { return }
                                        delete_project_active.toggle()
                                    } label: {
                                        
                                        Text("Delete")
                                        Image(systemName: "trash")
                                            
                                    }.disabled(folder_data.last_project == nil)

                                    
                                }
                            } header: {
                                Text("Projects:")
                            }
                            Divider()
                            
                            Section {
                                if let selected = folder_data.last_project {
                                    ProjectInfoView(data: selected )
                                        .frame(height: 400)
                                }
//                                ProjectInfoView(data: project_data.current_project)
//                                    .frame(height: 400)
                            } header: {
                                Text("Project Info:")
                            }
                            
                            Section {
                                
                            }
                        }
                    }
                    
                    
                    ZStack {
                        Button("Update Project") {
                            //project_data.update_wrappers()
                            view_states.projectIsUpdating.toggle()
                            Task(priority: .background, operation: {
                                await folder_data.last_project?.updateProject()
                                view_states.projectIsUpdating.toggle()
                            })
                        }.padding()
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                
            }
            if view_states.projectCreateIsRunning {
                Color.init(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.75)
                ProgressView("Creating Project")
            }
            if view_states.projectIsUpdating {
                Color.init(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.75)
                ProgressView("Updating Project")
            }
        }
        
        
        
        .sheet(isPresented: $create_project_active) {
            NewProjectView(data: folder_data, active: $create_project_active)
                .frame(width: 640)
                //.environmentObject(<#T##object: ObservableObject##ObservableObject#>)
        }
        
        .sheet(isPresented: $delete_project_active) {
            
            if let last = folder_data.last_project {
                DeleteProjectView(path: last.name, active: $delete_project_active) {
                    if let current_project = realm_shared.objects(KSLProjectData.self).first(where: { $0.id == last.id}) {
                        print(current_project.path_url)
                        try? FM.removeItem(at: current_project.path_url)
                        try! realm_shared.write {
                            realm_shared.delete(current_project)
                        }
                    }
                }
                .frame(width: 480)
            }
            
        }
        
        .onChange(of: folder_data.selected_project_id) { newValue in
            print("onChange folder_data.selected_project_id")
            guard let project = folder_data.projects.first(where: {$0.id == newValue}) else { return }
            $folder_data.last_project.wrappedValue = project.thaw()
            project.monitorWrappers(state: true)
            //addAdmobKeysToProject(project: project)
            guard let last = last_project else { return }
            last.monitorWrappers(state: false)
            
        }
    }
    
    

}

struct ProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsView( folder_data: WorkingFolderData())
            .environmentObject(KSLDataModel(preview: true) )
            .environmentObject(ViewStatesModel.shared)
            .previewLayout(.fixed(width: 499, height: 680))
    }
}


let XCODEBUILD = URL(fileURLWithPath: "Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild")


@discardableResult
func openXC_Project(url: URL) -> Int32 {

    let task = Process()

    task.executableURL = ZSH
    task.currentDirectoryURL = url
    task.arguments = ["-c","xed ."]

    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}
