//
//  RealmDatabaseModel.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 08/06/2022.
//

import Foundation
import RealmSwift
import Combine


class KSLRealmDataModel: ObservableObject {
    
    
    private(set) var realm: Realm?
    
    //@Published var results: Results<KSLDataModelNew>?
    @Published var result: KSLDataModelNew?
    
    
    
    private var resultsToken: NotificationToken?
    
    private var currentFolderToken: NotificationToken?
    
    private var subscriptions = Set<AnyCancellable>()
    
    
    let inputFolderURL = PassthroughSubject<URL, Never>()
    
    var working_folders: [WorkingFolderData] {
        if let result = result {
            var output = [WorkingFolderData]()
            output.append(contentsOf: result.recentFolders)
            return output
        }
        return []
        
    }
    
    var pipManager = PipManagerData()
    private var pipToken: NotificationToken?
    private var pipListsToken: NotificationToken?
    init(realm_name: String) {
        
        inputFolderURL.sink { [unowned self] url in
            let folder = result?.recentFolders.first(where: {$0.path_url == url})
            guard let result = result?.thaw() else { return }
            if let realm = result.realm {
                try? realm.write {
                    result.current_url = url.path
                    if let folder = folder {
                        result.recentFolder_id = folder.id
                    } else {
                        result.no_config_alert = true
                        //result.recentFolder = nil
                    }
                    
                }
            }
        }.store(in: &subscriptions)
        
        $result.sink { [unowned self] new in
            currentFolderToken = new?.observe(keyPaths: ["recentFolder_id", "recentFolder"], { changes in
                switch changes {
                case .error(_):
                    break
                case .change(_, let new_changes):
                    guard let realm = realm else { return }
                    
                    for change in new_changes {
                        print(change.name, "changed")
                        if change.name == "recentFolder_id" {
                            let newValue = change.newValue as? ObjectId
                            //let oldValue = change.oldValue as? ObjectId
                            //print(newValue, oldValue)
                            //if newValue != oldValue {
                                if let new = new?.thaw() {
                                    guard let recent = new.recentFolders.first(where: { f in f.id == newValue }) else { return }
                                    guard let recent = recent.thaw() else { return }
                                    if realm.isInWriteTransaction {
                                        new.recentFolder = recent
                                    } else {
                                        try? realm.write {
                                            new.recentFolder = recent
                                        }
                                    }
                                }
                            //}
                        }
                        else if change.name == "recentFolder" {
                            guard let folder = change.newValue as? WorkingFolderData else { return }
                            KSLPaths.shared._root = folder.path_url
                            folder.handleObserver()
                            guard let old_folder = change.oldValue as? WorkingFolderData else { return }
                            old_folder.cancelObservers()
                        }
                        
                    }
                case .deleted:
                    break
                }
            })
        }.store(in: &subscriptions)
        
        
        
        initializeSchema(name: realm_name)
        setupObserver()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let this = self else { return }
            if this.result == nil {
                try? this.realm?.write {
                    this.realm?.add(KSLDataModelNew.init(file: nil))
                }
            }
        }
    }
    
    func setupObserver() {
        guard let realm = realm else {return}
        let observedResults = realm.objects(KSLDataModelNew.self)
        resultsToken = observedResults.observe { [weak self] new in
            //self?.results = observedResults
            
            guard let result = observedResults.first else { return }
            if self?.result == nil {
                self?.result = result
                if let recent_folder = result.recentFolder {
                    KSLPaths.shared._root = recent_folder.path_url
                    recent_folder.handleObserver()
                }
            }
 
        }
        let observedPipResults = realm.objects(PipData.self)
        pipToken = observedPipResults.observe { [weak self] new in
            self?.pipManager.pips = observedPipResults
        }
        
        let observedPipListResults = realm.objects(PipManagerList.self)
        pipListsToken = observedPipListResults.observe { [weak self] new in
            self?.pipManager.pip_lists = observedPipListResults
            
        }
        
    }
    
    
    func initializeSchema(name: String) {
        
        let config = Realm.Configuration(
            fileURL: KSLPaths.shared.APPLICATION_SUPPORT_FOLDER.appendingPathComponent("Database").appendingPathComponent("\(name).realm"),
            schemaVersion: UInt64(Bundle.main.buildVersionNumber) ?? 1000
        )
        Realm.Configuration.defaultConfiguration = config
        
        do {
            realm = try Realm()
            realm_shared = realm!
            pipManager.realm = realm
        } catch {
            print("Error opening default realm", error.localizedDescription)
        }
    }
    
}


func ResultsToArray<R>(results: Results<R>) -> [R] where R: Object {
    var arrayOfResults: [R] = []
    for result in results {
        arrayOfResults.append(result)
    }
    return arrayOfResults
}
