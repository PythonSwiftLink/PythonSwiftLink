//
//  DB_Items.swift
//  KivySwiftLink
//
//  Created by MusicMaker on 08/12/2021.
//

import Foundation
import RealmSwift


class KslProject: Object {
    @Persisted var name: String
    @Persisted var path: String
    
    
    var url: URL { URL(fileURLWithPath: path) }
    
    var wrapper_src: URL { url.appendingPathComponent("wrapper_sources", isDirectory: true) }
    
    var headers: URL { url.appendingPathComponent("wrapper_headers", isDirectory: true) }
    
    var c_headers: URL { headers.appendingPathComponent("c", isDirectory: true) }
    
    var swift_headers: URL { headers.appendingPathComponent("swift", isDirectory: true)}
    
    var python_lib: URL { url.appendingPathComponent("lib", isDirectory: true)}
}

class GlobalSettings: Object {
    @objc dynamic var _id: String = ""
    @objc dynamic var root_path: String = ""
    @objc dynamic var site_path: String = ""
    @objc dynamic var current: KslProject?
    @objc dynamic var python_path: String = ""
    @objc dynamic var xcode_path: String = "/Applications/Xcode.app"
    let python_version = List<Int>()

    override static func primaryKey() -> String? {
        return "_id"
    }
}
//class GlobalSettings: Object {
//    @Persisted var _id: String = ""
//    @Persisted var root_path: String
//    @Persisted var site_path: String
//    @Persisted var current: KslProject!
//    let projects = List<KslProject>()
//    //python info
//    @Persisted var python_path: String = "/usr/local/bin/python3"
//    let python_version = List<Int>()
//
//    override static func primaryKey() -> String? {
//            return "_id"
//        }
//}

func load_global(realm: Realm) -> GlobalSettings {
    if let global = realm.objects(GlobalSettings.self).first {
        return global
    }
    let global = GlobalSettings()
    //try! realm.write({
        
    global.root_path = KSLPaths.shared.ROOT_URL.path
    global.site_path = KSLPaths.shared.VENV_SITE_PACKAGES.path
    //global.python_path = "/usr/local/bin/python3"
    global.python_version.append(objectsIn: [3,9,9])
    RealmService.shared.create(in: realm, object: global)
    //})
    
    return global
}

class ProjectHandler {
    
    static let shared = ProjectHandler()
    
    let realm: Realm
    let service = RealmService.shared
    var global: GlobalSettings
    //init(db_path: String!) {
    init() {
        let url = KSLPaths.shared.SYSTEM_FILES.appendingPathComponent("db.realm")
        //var url: URL
//        if let path = db_path {
//            url = URL(fileURLWithPath: path).appendingPathComponent("system_files/db.realm")
//        } else {
//            url = URL(fileURLWithPath: root_path).appendingPathComponent("system_files/db.realm")
//        }
        print(url.path)
        realm = (service.newRealm(url: url, types: [KslProject.self,GlobalSettings.self]))!
        global = load_global(realm: realm)
    }
    
    var current_project: KslProject! {
        set {
            print("current_project",newValue.name)
            try! realm.write {
                global.current = newValue
            }
        }
        
        get {return global.current}
    }
    
    var current_python_path: String {
        set {
            print("current python path:", newValue)
            try! realm.write { global.python_path = newValue }
        }
        
        get { return global.python_path }
    }
    
    var current_python_version: [Int] {
        get {Array(global.python_version)}
        
        set {
            print("setting current_python_version", newValue)
            try! realm.write {
                global.python_version.removeAll()
                global.python_version.append(objectsIn: newValue)
            }
        }
    }
    
    var xcode_path: String {
        get {global.xcode_path}
        set {
            try! realm.write {
                global.xcode_path = newValue
            }
        }
    }
    var python_major_version: String {
        current_python_version[0...1].map{"\($0)"}.joined(separator: ".")
    }
    
    func add_project(name: String, path: String) -> KslProject {
        let project = KslProject()
        project.name = name
        project.path = path
        service.create(in: realm, object: project)
        return project
    }
    
    func get_project(name: String) -> KslProject! {
        realm.objects(KslProject.self).first { (project) -> Bool in
            project.name == name
        }
    }
    
    func set_current_project(project: KslProject) {
        global.current = project
    }
    
    func save(){
        print("saving")
        service.update(in: realm, object: global)
    }
}
