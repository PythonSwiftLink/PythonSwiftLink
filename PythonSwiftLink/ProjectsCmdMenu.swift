//
//  ProjectsCmdMenu.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 12/06/2022.
//

import Foundation
import SwiftUI
import RealmSwift

struct CurrentProjectMenuView: View {
    @ObservedRealmObject var project: KSLProjectData
    @ObservedObject var view_states: ViewStatesModel
    
    var body: some View {
        Text(project.name ?? "No Selected Project")
        
        Button("Update Project") {
            //guard let result = model.result else { return }
            //guard let folder = result.recentFolder else { return }
            //guard let project = folder.last_project else { return }
            view_states.projectIsUpdating = true
            Task {
                await project.updateProject(false)
                view_states.projectIsUpdating.toggle()
            }
        }.keyboardShortcut("u", modifiers: [.command ])
        
        Button("Update Project - Forced") {
            //guard let result = model.result else { return }
            //guard let folder = result.recentFolder else { return }
            //guard let project = folder.last_project else { return }
            view_states.projectIsUpdating = true
            Task {
                await project.updateProject(true)
                view_states.projectIsUpdating.toggle()
            }
            
            
        }.keyboardShortcut("u", modifiers: [.command, .shift])
    }
}


struct CurrentProjectMenu: View {
    @ObservedRealmObject var folder: WorkingFolderData
    @ObservedObject var view_states: ViewStatesModel
    
    var body: some View {
        
        if let project = folder.last_project {
            
            CurrentProjectMenuView(project: project, view_states: view_states)
        }
        
    }
}

struct ProjectsPicker: View {
    
    @ObservedRealmObject var folder: WorkingFolderData
    @ObservedObject var view_states: ViewStatesModel
    
    var body: some View {
        Picker("Projects", selection: $folder.selected_project_id) {
            ForEach(folder.projects) { p in
                Text(p.name).tag(p.id)
            }
        }
    }
}


struct ProjectsMenuView: View {
    @ObservedRealmObject var root: KSLDataModelNew
    @ObservedObject var view_states: ViewStatesModel
    
    var body: some View {
        if let folder = root.recentFolder {
            ProjectsPicker(folder: folder, view_states: view_states)
            Menu("Current Project") {
                CurrentProjectMenu(folder: folder, view_states: view_states)
            }
            
        }
    }
}

struct ProjectsMenu: View {
    @ObservedObject var model: KSLRealmDataModel
    @ObservedObject var view_states: ViewStatesModel
    
    var body: some View {
        if let result = model.result {
            
            ProjectsMenuView(root: result, view_states: view_states)
            
        }
        
    }
    


}
