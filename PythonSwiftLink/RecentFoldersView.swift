//
//  RecentFoldersView.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 31/05/2022.
//

import SwiftUI
import RealmSwift

struct RecentFolderPicker: View {
    @ObservedRealmObject var model: KSLDataModelNew
    
    var body: some View {
        Picker(selection: $model.recentFolder_id , label: Text("Recent Folders")) {
                                    
            ForEach(model.recentFolders, id: \.path) { folder in
                Text(folder.path).tag(folder.id)
            }
                   
        }
    }
}


struct RecentFoldersView: View {
    @ObservedObject var model: KSLRealmDataModel
    //@ObservedRealmObject var model: KSLDataModelNew
    
    var body: some View {
        if let result = model.result {
            RecentFolderPicker(model: result)
        } else {
            Text("Recent Folders")
        }
//        .onChange(of: model.recentFolder_id) { id in
//            //guard let folder = model.recentFolders.first(where: {$0.id == id}) else { return }
//            print("onChange(of: model.recentFolder_id)",id)
//            guard let folder = model.recentFolders.first(where: {$0.id == id}) else { return }
//            //$model.recentFolder.wrappedValue = folder.thaw()
//
//            KSLPaths.shared._root = URL(fileURLWithPath: folder.path)
////
////            try? realm_shared.write {
////                model.thaw()?.recentFolder = folder
////            }
//
//        }
    }
}

struct RecentFoldersView_Previews: PreviewProvider {
    static var previews: some View {
        RecentFoldersView(model: KSLRealmDataModel.init(realm_name: "sample"))
    }
}
