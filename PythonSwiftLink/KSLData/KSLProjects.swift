//
//  KSLProjects.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 27/05/2022.
//

import Foundation
import Combine
import RealmSwift
import PythonKit

let XCODE_PATH = "/Applications/Xcode.app"
class KSLProjects: ObservableObject {
    
    @Published var projects: [KSLProjectData]
    //@ObservedRealmObject var projects
    //@ObservedRealmResult var
    @ObservedResults(KSLProjectData.self) var project_results
    @Published var current_project = KSLProjectData(name: "", dummy: true)
    
    let last_projectInput = PassthroughSubject<String, Never>()
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var pbxproj: PythonObject!
    private var XcodeProject_cls: PythonObject!
    
    init() {
        projects = []
        
        last_projectInput.sink { [unowned self] proj in
            print("last_projectInput", proj)
            if let first = projects.first(where: { $0.name == proj }) {
                current_project = first
                
            }
            
        }.store(in: &subscriptions)
        
        $current_project.sink {[unowned self] project in
            if !project.dummy {
                
//                loadHostPythonLibrary_GUI()
//                pbxproj = Python.import("pbxproj")
//                XcodeProject_cls = pbxproj.XcodeProject
                
                let project_path = project.path_url.appendingPathComponent("\(project.name).xcodeproj", isDirectory: true).appendingPathComponent("project.pbxproj")
                
                
//                if FM.fileExists(atPath: project_path.path) {
//                    current_project.XCProject = XcodeProject_cls.load(project_path.path)
//                } else {
//                    print("xc proj not found",project_path.path)
//                }
                
            }
        }.store(in: &subscriptions)
    }
    
    func reload_pbxproj() {
        loadHostPythonLibrary_GUI()
        pbxproj = Python.import("pbxproj")
        XcodeProject_cls = pbxproj.XcodeProject
    }
    
    func sync() {
        guard let _realm = _realm else { return }
        projects.removeAll()
        projects.append(contentsOf: _realm.objects(KSLProjectData.self))
        
    }
    
    func create_project(name: String, python_folder: URL) throws  {
        let project = KSLProjectData(name: name, dummy: false)
        guard let _realm = _realm else { return }
        try _realm.write {
            //project.name = name
            //project.path_url
            _realm.add(project)
        }
        
        runToolchain_GUI(command: .create, args: [name, python_folder.path]) { line in
            print(line)
        }
        
        
        
        projects.append( project)
        print(project.name, project.path)
        let project_path = project.path_url.appendingPathComponent("\(project.name).xcodeproj", isDirectory: true).appendingPathComponent("project.pbxproj")
        
        if FM.fileExists(atPath: project_path.path) {
            project.XCProject = XcodeProject_cls.load(project_path.path)
        } else {
            print("xc proj not found",project_path.path)
        }
        
        onNewProject(project: project)
        
        current_project = project
    }
    func delete_project() {
        
        if FM.fileExists(atPath: current_project.path) {
            
            try? FM.removeItem(at: current_project.path_url)
        }
        
        guard let _realm = _realm else { return }
        
        //if projects.contains(current_project) {
            projects.removeAll { p in
                p == current_project
            }
            
            try? _realm.write {
                _realm.delete(current_project)
            }
            
            
            //sync()
            //current_project = nil
       // }
        
    }
    
    
    
    func onNewProject(project: KSLProjectData) {
        guard let xc_proj = project.XCProject else {
            print("onNewProject xc proj object not found")
            return
        }
        
        if !FM.fileExists(atPath: project.bridge_header) {
            let bridge_string = BRIDGE_STRING
            try! bridge_string.write(to: project.bridge_header_url, atomically: true, encoding: .utf8)
        }
        
        
        let project_dir = project.path_url
        
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
        
        xc_proj.add_file(project_dir.appendingPathComponent("lib", isDirectory: true).path, parent: resources)
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
            if !["old_PythonSupport.swift","JsonSupport.swift", "PythonSupport.swift"].contains(item) {
                if item != ".DS_Store" && item.lowercased().contains(".swift") {
                    copyItem(from: support_files.appendingPathComponent(item).path, to: project_dir.appendingPathComponent(item).path)
                    xc_proj.add_file(project_dir.appendingPathComponent(item).path, parent: sources)
                }
            }
        }
        
        
        try! FM.createDirectory(at: project_dir.appendingPathComponent("wrapper_headers/c", isDirectory: true), withIntermediateDirectories: true, attributes: nil)
        try! FM.createDirectory(at: project_dir.appendingPathComponent("wrapper_headers/swift", isDirectory: true), withIntermediateDirectories: true, attributes: nil)
        try! FM.createDirectory(at: project_dir.appendingPathComponent("wrapper_sources", isDirectory: true), withIntermediateDirectories: true, attributes: nil)
        
        //todo
        xc_proj.set_flags("SWIFT_OBJC_BRIDGING_HEADER",project.bridge_header)
        xc_proj.set_flags("SWIFT_VERSION","5.0")
        xc_proj.set_flags("IPHONEOS_DEPLOYMENT_TARGET","11.0")
        //todo
        xc_proj.add_file(project.bridge_header, parent: classes)
        xc_proj.add_header_search_paths(project_dir.appendingPathComponent("wrapper_headers/c").path, false)
        
        
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
    
    
    func update_wrappers() {
        let cmd_queue = WrapperCommandQueue.shared
        for name in [
            "ads_viewer"
            //,"inapp_example"
        ] {
            cmd_queue.Task(add: KSL_WrapperQueueItem.item(update: name, project: current_project))
        }
        cmd_queue.handleQueue()
    }
}
