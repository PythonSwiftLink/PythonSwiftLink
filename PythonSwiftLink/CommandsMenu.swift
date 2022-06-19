//
//  CommandsMenu.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 08/06/2022.
//

import Foundation
import SwiftUI
import RealmSwift
import SwiftUIWindow



struct SortingCommands: Commands {
    @Binding var sorting: Int

    var body: some Commands {
        CommandMenu("Sort") {
            Picker(selection: $sorting, label: Text("Sorting")) {
                Text("Option 1").tag(0)
                Text("Option 2").tag(1)
                Text("Option 3").tag(2)
            }
        }
    }
}


struct MainCommands: Commands {
    @ObservedObject var model: KSLRealmDataModel
    @ObservedObject var view_states: ViewStatesModel

    var body: some Commands {
       
        CommandGroup(before: CommandGroupPlacement.newItem) {
            Button("Open Folder") {
                selectFolder { url in
                    model.inputFolderURL.send(url)
                }
            }.keyboardShortcut("o", modifiers: .command )
            RecentFoldersView(model: model)
            
        }
        CommandMenu("Projects") {
            ProjectsMenu(model: model, view_states: view_states)
        }
        
        CommandMenu("PIP Manager") {
            Button("Pips Manager") {
                SwiftUIWindow.open {_ in
                    GlobalPipManager(pip_man: model.pipManager)
                        
                }
            }
            Button("Lists Manager") {
                SwiftUIWindow.open {_ in 
                    PipListsManager(pip_man: model.pipManager)
                        
                }
            }
        }

    }
    


}




