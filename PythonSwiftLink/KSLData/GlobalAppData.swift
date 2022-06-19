import Foundation
import Combine
import SwiftUI

import RealmSwift




//func initAppRealm() -> Realm {
//    var config = Realm.Configuration()
//    config.schemaVersion = 1000
//    config.objectTypes = [GlobalAppData.self, WorkingFolderData.self]
//    return try! Realm(configuration: config, queue: .main)
//}

//let app_realm = initAppRealm()

//class WorkingFolderData: Object, Identifiable {
//
//    let id = UUID()
//
//    @Persisted var path: String
//    var fileURL: URL { URL(fileURLWithPath: path)}
//
//
//    convenience init(path: String) {
//        self.init()
//        self.path = path
//    }
//
//
//    static func == (lhs: WorkingFolderData, rhs: WorkingFolderData) -> Bool {
//            lhs.path == rhs.path
//        }
//
//}

//class GlobalAppData: Object, Identifiable {
//    @Persisted var recent_folders: RealmSwift.List<WorkingFolderData>
//    @Persisted var last_folder: WorkingFolderData?
//
//
//
//}
