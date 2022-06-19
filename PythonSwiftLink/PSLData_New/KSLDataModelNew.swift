//
//  KSLDataModelNew.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 30/05/2022.
//

import Foundation
import Combine
import RealmSwift
import Cocoa






class KSLDataModelNew: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var recentFolders: RealmList<WorkingFolderData>
    @Persisted var recentFolder: WorkingFolderData?
    @Persisted var recentFolder_id: ObjectId
    
    
    
    
    @Persisted var no_config_alert: Bool = false
    
    
    
    //@Published var logData = LogData()
    
    @Published var setupLogData = KSLViewLogger()
    
    @Published var setupIsRunning = false
    
    @Persisted var current_url: String
    
    
    
    let workingFolderInput = PassthroughSubject<URL,Never>()
    let logInput = PassthroughSubject<String, Never>()
    
    var subscriptions = Set<AnyCancellable>()
    
    convenience init(file: URL!) {
        self.init()
        //recentFolder = WorkingFolder_()
        
    }
    
    
    
    
}
