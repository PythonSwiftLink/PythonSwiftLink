//
//  KSLProjectData.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 26/05/2022.
//

import Foundation
import Combine
import RealmSwift
import PythonKit
//import DirectoryWatcher


let BRIDGE_STRING = """
#import "runMain.h"
#include "Python.h"
#include "PyImports.h"
//#Wrappers Start
//#Wrappers End
//Insert Other OBJ-C Headers Here:
"""



var pbxproj: PythonObject!
var XcodeProject_cls: PythonObject!



class KSLProjectData: Object, ObjectKeyIdentifiable {
    private let ksl_paths = KSLPaths.shared
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var name: String
    @Persisted var path: String
    @Persisted var python_folder: String
    @Persisted(originProperty: "projects") var working_folder: LinkingObjects<WorkingFolderData>
    var path_url: URL {
        get { URL(fileURLWithPath: path) }
        set { path = newValue.path }
    }
    
    @Persisted var wrapper_builds: List<KSLWrapperData>
    //var wrapper_builds_array: [KSLWrapperData] { Array(wrapper_builds) }
    @Persisted var pips: PipManagerList?
    @Persisted var installed_pips: List<PipData>
    
    @Persisted var bridge_header: String
    var bridge_header_url: URL {
        get { URL(fileURLWithPath: bridge_header) }
        set { bridge_header = newValue.path }
    }
    
    @Persisted var addons: List<ProjectAddon>
    
    var XCProject: PythonObject!
    
    private var _url: URL? = nil
    
    var url: URL {
        if let _url = _url {
            return _url
        }
        _url = URL(fileURLWithPath: path)
        return _url!
    }

    var wrapper_src: URL { url.appendingPathComponent("wrapper_sources", isDirectory: true) }

    var headers: URL { url.appendingPathComponent("wrapper_headers", isDirectory: true) }

    var c_headers: URL { headers.appendingPathComponent("c", isDirectory: true) }

    var swift_headers: URL { headers.appendingPathComponent("swift", isDirectory: true)}

    var python_lib: URL { url.appendingPathComponent("lib", isDirectory: true)}
    
    var dummy: Bool = false
    
    var subscriptions = Set<AnyCancellable>()
    
    
    var wrapper_sources_monitor: DirectoryWatcher?
    
    convenience init(name: String, dummy: Bool = false) {
        self.init()
        self.name = name
        self.dummy = dummy
        
        path_url = ksl_paths.ROOT_URL.appendingPathComponent("\(name)-ios")
        
        bridge_header_url = path_url.appendingPathComponent("\(name)-Bridging-Header.h")
        
        print(path_url)
        if !dummy {
            
        }
//        bridge_header = project_dir.appendingPathComponent("\(project_title)-Bridging-Header.h")
//
//        wrapper_builds.collectionPublisher.sink { err in
//
//        } receiveValue: { wrappers in
//            print(wrappers)
//        }.store(in: &subscriptions)

    }
    
    
    convenience init(create project_name: String, python_folder: URL, working_folder: URL, addons: [([String:String], KSLProjectAddonType)], pip_list: PipManagerList?) {
        self.init()
        self.name = project_name
        self.python_folder = python_folder.path
        self.pips = pip_list
        let proj_url = working_folder.appendingPathComponent("\(project_name)-ios")
        path_url = proj_url
        
        bridge_header_url = proj_url.appendingPathComponent("\(project_name)-Bridging-Header.h")
        //var _addons = addons
        //_addons.append(("NSCameraUsageDescription", .custom))
        handleAddons(addons: addons)
        
        createXCodeProject()
        //print(addons)
        
        //print(self.addons)
        updateAddons()
        //addAdmobKeysToProject(project: self)
    }
    
    func handleAddons(addons: [([String:String], KSLProjectAddonType)]) {
        for (k, addon) in addons {
            
            switch addon {
            case .admob:
                for (_, value) in k {
                    self.addons.append(ProjectAddon(admob: value))
                }
                
            case .custom:
                for (key, value) in k {
                    self.addons.append(ProjectAddon(info_key: key, value: value))
                }
                
            default: break
            }
        }
        
    }
    
    func updateAddons() {
        let add_dict: PythonObject = [:]
        
        for a in addons {
            //print(a.type, KSLProjectAddonType(rawValue: a.type))
            switch KSLProjectAddonType(rawValue: a.type) {
                
            case .none: continue
            case .admob:
                let x = a.plist_items[0]
                add_dict[x.key] = x.value.pythonObject
                let y = a.plist_items[1]
                //add_dict[y.key] = ploads(y.value.stringValue.pythonObject.encode(),fmt: fmt_xml)
                add_dict[y.key] = ploads(y.value.pythonBytes_utf8, fmt: fmt_xml)
                
            case .custom:
                let x = a.plist_items[0]
                add_dict[x.key] = x.value.pythonObject
                //add_plist(keys: add_dict)
            default: continue
            
            }
            
        }
        add_plist(keys: add_dict)
    }
    
}

extension KSLProjectData {
    
    func importWrapper(file: URL) {
        

        let dst = wrapper_src.appendingPathComponent(file.lastPathComponent)
        copyItem(from: file.path, to: dst.path, force: true)
        //realmImportWrapper(project: self, fileurl: dst)
        let filename = file.deletingPathExtension().lastPathComponent
        
        if wrapper_builds.contains(where: {$0.name == filename}) { return }
        
        let wrapper = KSLWrapperData(file: filename, code_url: dst)
        guard let wrapper_builds = wrapper_builds.thaw() else { return }
        try! realm_shared.write({
            wrapper_builds.append(wrapper)
        })
    }
    
    func newWrapper(name: String, cls_name: String, code: String? = nil) {
        let dst = wrapper_src.appendingPathComponent("\(name).py")
        if FM.fileExists(atPath: dst.path) {
            ViewStatesModel.shared.wrapperFileExistAlert = true
            return
        }
        var wrapper_code = ""
        if let code = code {
            wrapper_code = code
        } else {
            wrapper_code = newWrapperTemplate0(cls_name: name)
        }
        
        try? wrapper_code.write(to: dst, atomically: true, encoding: .utf8)
        let wrapper = KSLWrapperData(file: name, code_url: dst)
        guard let wrapper_builds = wrapper_builds.thaw() else { return }
        try? realm_shared.write({
            wrapper_builds.append(wrapper)
        })
    }
    
    func deleteWrapper(name: String) {
        if let file = wrapper_builds.first(where: {$0.name == name}) {
            
            let cmds = WrapperCommandQueue.shared
            
            let task = KSL_WrapperQueueItem.item(remove: name, project: self)
            cmds.Task(add: task)
            cmds.handleQueue()
            for code in file.code_files {
                if FM.fileExists(atPath: code.path) {
                    try? FM.removeItem(atPath: code.path)
                }
            }
            if let file = file.thaw() {
                try? realm_shared.write {
                    realm_shared.delete(file.code_files)
                    realm_shared.delete(file)
                }
            }
        }
    }
    
    func checkForWrapperBuildUpdates() {
        
    }
        
        
    func createXCodeProject() {
        runToolchain_GUI(command: .create, args: [name, python_folder]) { line in
            print(line)
        }
        let project_path = path_url.appendingPathComponent("\(name).xcodeproj", isDirectory: true).appendingPathComponent("project.pbxproj")
        print(project_path)
        if FM.fileExists(atPath: project_path.path) {
            XCProject = XcodeProject_cls.load(project_path.path)
        } else {
            print("xc proj not found",project_path.path)
            return
        }
        onNewProject()
    }
        
    func onNewProject() {
        
        let admob_mode = self.addons.contains(where: {$0.type == "admob"})
            guard let xc_proj = XCProject else {
                print("onNewProject xc proj object not found")
                return
            }
            
            if !FM.fileExists(atPath: bridge_header) {
                let bridge_string = BRIDGE_STRING
                try! bridge_string.write(to: bridge_header_url, atomically: true, encoding: .utf8)
            }
            
            
            let project_dir = path_url
            
            for x in 14...16 {
                for i in 0...9 {
                    xc_proj.remove_framework_search_paths([
                    "\(XCODE_PATH)/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator\(x).\(i).sdk/System/Library/Frameworks"])
                    xc_proj.remove_library_search_paths(["\(XCODE_PATH)/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator\(x).\(i).sdk/usr/lib"])
            }}
            let sources = xc_proj.get_or_create_group("Sources")
            for src in sources.children {
                let ID = src
                let file = String(src._get_comment())!
                if file.contains("main.m") {
                    xc_proj.remove_file_by_id(ID)
                }
            }
            let resources = xc_proj.get_or_create_group("Resources")
            for res in resources.children {
                let ID = res
                let file = String(res._get_comment())!
                if file.contains("lib") {
                    xc_proj.remove_file_by_id(ID)
                    
                    
                }
            }
            
            copySystemLibToProject(proj: project_dir)
            
            //xc_proj.add_file(project_dir.appendingPathComponent("lib", isDirectory: true).path, parent: resources)
            xc_proj.remove_group_by_name("Classes")
            
            let classes = xc_proj.get_or_create_group("Objc-Classes")
            
            let main_m = try! String(contentsOfFile: project_dir.appendingPathComponent("main.m").path)
            let run_main_path = project_dir.appendingPathComponent("runMain.m")
            
            do { try main_m.replacingOccurrences(of: "int main(int argc, char *argv[]) {", with: "int run_main(int argc, char *argv[]) {").write(to: run_main_path, atomically: true, encoding: .utf8) } catch { print(error.localizedDescription)}
            do { try "int run_main(int argc, char *argv[]);".write(to: project_dir.appendingPathComponent("runMain.h"), atomically: true, encoding: .utf8) } catch  { print(error.localizedDescription) }
            
            for item in ["runMain.h","runMain.m"] {
                xc_proj.add_file(project_dir.appendingPathComponent(item).path, parent: classes)
            }
            let support_files = KSLPaths.shared.SYSTEM_FILES.appendingPathComponent("project_support_files")
            let pythonobjectsupport = support_files.appendingPathComponent("PythonObjectSupport", isDirectory: true)
            for item in ["PyImports.h","PyImports.c"] {
                xc_proj.add_file(pythonobjectsupport.appendingPathComponent(item).path, parent: classes)
            }
            
            
            let python_support = xc_proj.get_or_create_group("PythonSupport")
            try! extract_folder_to_xcode_group(project: xc_proj, group: python_support, url: pythonobjectsupport)
            
            for item in try! FM.contentsOfDirectory(atPath: support_files.path) {
                let item_url = support_files.appendingPathComponent(item)
                if !["old_PythonSupport.swift","JsonSupport.swift", "PythonSupport.swift", "PythonMain.swift"].contains(item) && !item_url.isDirectory {
                    if item != ".DS_Store" && item.lowercased().contains(".swift") {
                        copyItem(from: item_url.path, to: project_dir.appendingPathComponent(item).path, force: true)
                        xc_proj.add_file(project_dir.appendingPathComponent(item).path, parent: sources)
                    }
                }
            }
        let python_main_url = project_dir.appendingPathComponent("PythonMain.swift")
        try! newPythonMainFile(project: self).write(to: python_main_url, atomically: true, encoding: .utf8)
            //copyItem(from: support_files.appendingPathComponent(item).path, to: project_dir.appendingPathComponent(item).path, force: true)
        xc_proj.add_file(python_main_url.path, parent: sources)
        
        if admob_mode {
            let admob_file_url = support_files.appendingPathComponent("examples/admob/Admob_handler.swift")
            let admob_target_url = project_dir.appendingPathComponent("Admob_handler.swift")
            print(admob_file_url)
            print(admob_target_url)
            copyItem(from: admob_file_url.path, to: admob_target_url.path, force: true)
            xc_proj.add_file(admob_target_url.path, parent: sources)
        }
        
        
        
        
            try! FM.createDirectory(at: project_dir.appendingPathComponent("wrapper_headers/c", isDirectory: true), withIntermediateDirectories: true, attributes: nil)
            try! FM.createDirectory(at: project_dir.appendingPathComponent("wrapper_headers/swift", isDirectory: true), withIntermediateDirectories: true, attributes: nil)
            try! FM.createDirectory(at: project_dir.appendingPathComponent("wrapper_sources", isDirectory: true), withIntermediateDirectories: true, attributes: nil)
            
            //todo
            xc_proj.set_flags("SWIFT_OBJC_BRIDGING_HEADER",bridge_header)
            xc_proj.set_flags("SWIFT_VERSION","5.0")
            xc_proj.set_flags("IPHONEOS_DEPLOYMENT_TARGET","11.0")
            //todo
            xc_proj.add_file(bridge_header, parent: classes, force: false)
            xc_proj.add_header_search_paths(project_dir.appendingPathComponent("wrapper_headers/c").path, false)
            
//        xc_proj.add_package(
//            "https://github.com/googleads/swift-package-manager-google-mobile-ads.git",
//            "master",
//            ["GoogleMobileAds"],
//            name
//        )
//        xc_proj.add_package(
//            "https://github.com/googleads/swift-package-manager-google-mobile-ads.git",
//            [
//                "kind": "upToNextMajorVersion",
//                "minimumVersion": "9.0.0"
//            ],
//            ["GoogleMobileAds"],
//            name
//
//        )
        //var packs = [SwiftPackageItem]()
        for addon in self.addons {
            for pack in addon.swift_packages {
                xc_proj.add_package(
                    pack.url,
                    [
                        "kind": "upToNextMajorVersion",
                        "minimumVersion": pack.minimumVersion
                    ],
                    Array(pack.packages),
                    name
                )
            }
        }
        
        
            
            xc_proj.backup()
            xc_proj.save()
        }
    
    
    
    func extract_folder_to_xcode_group(project: PythonObject ,group: PythonObject, url: URL) throws {
                let files = try FM.contentsOfDirectory(atPath: url.path)
                for f in files {
                    let _file_ = url.appendingPathComponent(f)
                    
                    if _file_.isDirectory {
                        let sub_group = project.get_or_create_group(f, parent: group)
                        try extract_folder_to_xcode_group(project: project ,group: sub_group, url: _file_)
                    } else {
                        if f != ".DS_Store" && _file_.pathExtension == "swift" {
                            project.add_file(_file_.path , parent: group)
                        }
                        
                    }
                }
            }
    
    
    func monitorWrappers(state: Bool) {
        if state {
            let mon = DirectoryWatcher(watchedUrl: path_url.appendingPathComponent("wrapper_sources"))
            
            mon.onNewFiles = { f in
                print(f)
            }
            
            wrapper_sources_monitor = mon
            mon.startWatching()
        } else {
            wrapper_sources_monitor?.stopWatching()
            wrapper_sources_monitor = nil
        }
    }
    
    func updateProject(_ forced: Bool = false) async {
       
        let cmd_queue = WrapperCommandQueue.shared
        var lib_items_to_be_removed = [String]()
        
        for wrapper in wrapper_builds {
            guard let wrapper = wrapper.thaw() else { continue }
            
            if forced {
                if wrapper.status == .up2date {
                    try! realm_shared.write {
                        wrapper.status = .updated
                    }
                }
            } else {
                if wrapper.needsUpdate {
                    if wrapper.status == .up2date {
                        try! realm_shared.write {
                            wrapper.status = .updated
                        }
                    }
                } else {
                    if wrapper.status == .updated {
                        try! realm_shared.write {
                            wrapper.status = .up2date
                        }
                    }
                }
            }
            
            
            switch wrapper.status {
                
            case .created:
                cmd_queue.Task(
                    add: KSL_WrapperQueueItem.item(new: wrapper.name, project: self)
                )
            case .deleted:
                cmd_queue.Task(
                    add: KSL_WrapperQueueItem.item(remove: wrapper.name, project: self)
                )
                lib_items_to_be_removed.append(wrapper.name)
            case .updated:
                cmd_queue.Task(
                    add: KSL_WrapperQueueItem.item(update: wrapper.name, project: self)
                )
            case .up2date:
                print(wrapper.name, wrapper.status.rawValue)
            }
            
            
        }
        
        let queue_size = cmd_queue.handleQueue()
        
        if queue_size > 0 {
            
            
            let project_path = path_url.appendingPathComponent("\(name).xcodeproj", isDirectory: true).appendingPathComponent("project.pbxproj")
            if FM.fileExists(atPath: project_path.path) {
                XCProject = XcodeProject_cls.load(project_path.path)
            } else {
                print("xc proj not found",project_path.path)
                return
            }
            update_frameworks_lib_a(removed: lib_items_to_be_removed)
            for removed in lib_items_to_be_removed { deleteLibFile(recipe_name: removed) }
        }
        if let pips = pips {
            var args = ["install"]
            args.append(contentsOf: pips.pips.map{ $0.full_name })
            runToolchain_GUI(command: .pip, args: args) { log in
                print(log)
            }
        }
        
    }
    
    func deleteLibFile(recipe_name: String) {
        
        let url = ksl_paths.DIST_LIB_FOLDER.appendingPathComponent("lib\(name)_\(recipe_name).a")
        
        if FM.fileExists(atPath: url.path) {
            try? FM.removeItem(at: url)
        }
    }
    
    func update_frameworks_lib_a(removed: [String]) {
        //load_xcode_project()
        var updated = false
        let root_lib_path = ksl_paths.DIST_LIB_FOLDER
        
        let root_lib_files_a = try! FM.contentsOfDirectory(atPath: root_lib_path.path).filter{$0.contains(".a")}.filter{a in
            a.starts(with: "lib\(name)_")
        }
        
        let removed_lib_files = try! FM.contentsOfDirectory(atPath: root_lib_path.path).filter{$0.contains(".a")}
        
        if let project = self.XCProject {
            let frameworks = project.get_or_create_group("Frameworks")
            let libs = frameworks.children.map{String($0._get_comment())!}.filter{$0.contains(".a")}

            for lib in root_lib_files_a.find_missing_lib_a(compare_array: libs) {
                project.add_file(root_lib_path.appendingPathComponent(lib).path, parent: frameworks)
                if !updated { updated = true }
            }

            let frame_childrens = Array(frameworks.children)
            for todo in removed {
                if let file = frame_childrens.first(where: { obj in String(obj._get_comment()) == "lib\(name)_\(todo).a" }) {
                    if let first = project.get_files_by_name(file._get_comment(), parent: frameworks).first {
                        first.remove()
                        if !updated { updated = true }
                    }
                }
            }
            
            update_swift_wrapper_group(project: project, updated: &updated)
        if updated {
            project.backup()
            project.save()
            }
        } else {print("no project selected")}
        
        
    }
    
    
    func update_swift_wrapper_children(project: PythonObject ,group: PythonObject, root: URL, updated: inout Bool) {
        //let wrap_dir = cur_dir.appendingPathComponent("wrapper_headers/swift", isDirectory: true)
        let dir_files = try! FM.contentsOfDirectory(atPath: root.path).filter{$0 != ".DS_Store"}
        let group_children = group.children.map{String($0._get_comment())!}
        for missing in dir_files {
            
            let mis_url = root.appendingPathComponent(missing)
            if mis_url.isDirectory {
                let mis_group = project.get_or_create_group(missing,parent: group)
                update_swift_wrapper_children(project: project,group: mis_group, root: mis_url, updated: &updated)
            } else {
                if !group_children.contains(missing) {
                    if !updated { updated = true }
                    project.add_file(mis_url.path, parent: group)
                }
            }
            //if !updated { updated = true }
            //project.add_file(wrap_dir.appendingPathComponent(wrap).path, parent: swift_wrappers, force: true)
        }
    }
    
    func update_swift_wrapper_group(project: PythonObject, updated: inout Bool) {

        let wrap_dir = swift_headers
//        let wrap_dir = cur_dir.appendingPathComponent("wrapper_headers/swift/\(cur_proj)", isDirectory: true)
        let wrap_dir_files = try! FM.contentsOfDirectory(atPath: wrap_dir.path).filter{$0 != ".DS_Store"}
        
        //let sources = project.get_or_create_group("Sources")
        //let swift_wrappers = project.get_or_create_group("SwiftWrappers",parent: sources)
        let swift_wrappers = project.get_or_create_group("SwiftWrappers")
        let swift_wraps = swift_wrappers.children.map{String($0._get_comment())!}
        
//        for wrap in wrap_dir_files.find_missing(compare_array: swift_wraps) {
        for wrap in wrap_dir_files {
            
            let mis_url = wrap_dir.appendingPathComponent(wrap)
            if mis_url.isDirectory {
                let mis_group = project.get_or_create_group(wrap, parent: swift_wrappers)
                update_swift_wrapper_children(project: project, group: mis_group, root: mis_url, updated: &updated)
            } else {
                
                if !swift_wraps.contains(wrap) {
                    if !updated { updated = true }
                    project.add_file(mis_url.path, parent: swift_wrappers)
                }
            }
            
        }
        
    }
    
    
}


func realmImportWrapper(project: KSLProjectData, fileurl: URL) {
    let wrapper = KSLWrapperData()
    
    let filename = fileurl.deletingPathExtension().lastPathComponent
    
    let code = try! String(contentsOf: fileurl)
    
    let code_file = CodeFile(name: filename, path: fileurl.path, code: code)
    //guard let _project = realm_shared.objects(KSLProjectData.self).first(where: {$0.id == project.id}) else {fatalError()}
    try! realm_shared.write {
        
        //realm_shared.add(wrapper)
        //realm_shared.add(code_file)
        
        //code_file.code = code
        //code_file.name = filename

        wrapper.type = .file
        wrapper.name = filename
        wrapper.code_files.append(code_file)
        project.thaw()?.wrapper_builds.append(wrapper)
    }
    
    
}


extension Array where Element == String {
    func find_missing_lib_a(compare_array: [String]) -> [String]{
        return Array(Set(self).subtracting(compare_array))
    }
    
    func find_missing(compare_array: [String]) -> [String]{
        return Array(Set(self).subtracting(compare_array))
    }
}

