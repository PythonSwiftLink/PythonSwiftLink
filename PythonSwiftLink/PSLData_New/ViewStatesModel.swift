//
//  ViewStatesModel.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 01/06/2022.
//

import Foundation


import Foundation
import Combine
import RealmSwift
import SwiftyBeaver
//import DirectoryWatcher
import PythonKit

enum LogMode {
    case app_setup
    case setup
    case wrapper_build
}

class ViewStatesModel: ObservableObject {
    
    static let shared = ViewStatesModel()
    
    
    
    //@Published var logData = LogData()
    @Published var appSetupLogData = KSLViewLogger()
    
    @Published var appSetupIsRunning = false
    
    @Published var setupLogData = KSLViewLogger()
        
    @Published var setupIsRunning = false
    @Published var projectCreateIsRunning = false
    @Published var projectIsUpdating = false
    @Published var wrapperFileExistAlert = false
    
    var log_mode: LogMode = .app_setup
    
    let logInput = PassthroughSubject<String, Never>()
    let appSetupIsRunningInput = PassthroughSubject<Bool, Never>()
        
    var subscriptions = Set<AnyCancellable>()
    
    var dist_lib_monitor: DirectoryWatcher?
    //private lazy var folderMonitor = FolderMonitor
    
    
    var external_host_python = false
    var external_venv_python = false
    
    
    
    let app_files_checker = AppFilesChecker()
    
    init() {
        var log_count = 0
        
        appSetupIsRunningInput
            .receive(on: DispatchQueue.main)
            .assign(to: &$appSetupIsRunning)
        
        logInput
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] log_text in
                print(log_text)
                
                switch log_mode {
                case .app_setup:
                    appSetupLogData.current_logs.append(LogLine(id: log_count, text: log_text))
                case .setup:
                    setupLogData.current_logs.append(LogLine(id: log_count, text: log_text))
                case .wrapper_build:
                    break
                }
                
                
                //log.debug(log_text)
                log_count += 1
            }.store(in: &subscriptions)
        
        
        app_files_checker.logInput = logInput
        app_files_checker.logger = { log in
            print(log)
        }
        app_files_checker.pythons_missing = { state in
            if state {
                self.appSetupIsRunningInput.send(true)
//                DispatchQueue.main.async {
//                    self.appSetupIsRunning = true
//                }
            } else {
                //DispatchQueue.main.async {
                    if self.appSetupIsRunning {
                        self.appSetupIsRunningInput.send(false)
                    }
                //}
            }
        }
        //DispatchQueue.global().async {
        Task(priority: .high) {
            var app_files_ok = false
            while app_files_ok == false {
                app_files_ok = await self.app_files_checker.CheckAppFiles()
            }
            //DispatchQueue.main.async {
            
                await reload_pbxproj()
            //}
        }
            
        
        
    }
    
    
    func startMonitorDistLib() {
        let path = KSLPaths.shared.DIST_FOLDER.appendingPathComponent("lib")
        
    
        if !FM.fileExists(atPath: path.path) {
            try! FM.createDirectory(at: path, withIntermediateDirectories: true)
        }
        dist_lib_monitor = DirectoryWatcher(watchedUrl: path)
        dist_lib_monitor?.onNewFiles = { [unowned self] files in
            for f in files {
                logInput.send("\tbuilded \(f.lastPathComponent)")
            }
        }
        dist_lib_monitor?.startWatching()
    }
    
    
    func stopMonitoringDistLib() {
        dist_lib_monitor?.stopWatching()
        dist_lib_monitor = nil
    }
    
    func checkAppFilesExist() async {
        let app_dir = KSLPaths.shared.APPLICATION_SUPPORT_FOLDER
                            
        for check in ["openssl","hostpython","venvpython","KivySwiftSupportFiles"].map({app_dir.appendingPathComponent($0)}) {
            if !FM.fileExists(atPath: check.path) {
                
                await mainConfig()
                break
            }
        }
    }
    
    func mainConfig() async {
        
        log_mode = .app_setup
        appSetupIsRunning.toggle()
        
        //DispatchQueue.global().async { [weak self] in
            self.BuildPythons()
            let paths = KSLPaths.shared
            
            let KivySwiftSupportFiles = paths.KIVY_SUPPORT_FILES.path
            
            
            do {
                let branch = AppVersion.release_state == .release ? "main" : "testing"
                try Process().clone(repo: ["--branch", branch, "https://github.com/psychowasp/KivySwiftSupportFiles.git"], path: KivySwiftSupportFiles)
            } catch let err {
                print(err.localizedDescription)
                return
            }
             
            copyItem(from: "\(KivySwiftSupportFiles)/pythoncall_builder.py", to: paths.HOSTPYTHON_APP_SITE_PACKAGES.appendingPathComponent("pythoncall_builder.py").path, force: true)
            
            //DispatchQueue.main.async {
             await MainActor.run {
                self.log_mode = .setup
                self.appSetupIsRunning.toggle()
                
            }
        await reload_pbxproj()
        //}
    }
    
    func BuildPythons() {
        let fm = FileManager()
        var system: URL
        let paths = KSLPaths.shared
        //system = paths.SYSTEM_FILES
        let new_path = paths.APPLICATION_SUPPORT_FOLDER
        if FM.fileExists(atPath: new_path.path) {
            system = new_path
        } else {
            system = new_path
            //system = createFolderFullPath(root: paths.ROOT_URL, foldername: "system_files")
            try! FM.createDirectory(at: new_path, withIntermediateDirectories: true)
        }
        let openssl = URL(string: "http://www.openssl.org/source/openssl-1.1.1l.tar.gz")!
        let py39 = URL(string: "https://www.python.org/ftp/python/3.9.9/Python-3.9.9.tgz")!
        let py310 = URL(string: "https://www.python.org/ftp/python/3.10.2/Python-3.10.2.tgz")!
        //exit(0)
        
        var log_output = [String]()
        
        //&& !fm.fileExists(atPath: system.appendingPathComponent("openssl").path)
        
        if (!external_host_python || !external_venv_python ) && !fm.fileExists(atPath: system.appendingPathComponent("openssl").path) {
            print("building openssl")
            logInput.send("downloading \(openssl.path)")
            FileDownloader.loadFileSyncTemp(url: openssl) { [unowned self] url, err in
                let dst = system.appendingPathComponent("openssl-1.1.1l.tgz")
                let tmp = URL(fileURLWithPath: "/tmp/openssl-1.1.1l.tgz")
                do {
                    try? fm.moveItem(at: url! , to: tmp)
                }
    //                InstallOpenSSL(url: paths.SYSTEM_FILES, file: "openssl-1.1.1l")
                logInput.send("building openssl-1.1.1l")
                let result = InstallOpenSSL_GUI(url: system, file: "openssl-1.1.1l", { logger in
                    //setup_log.debug(logger)
                    print(logger)
                })
                //let path = paths.SYSTEM_FILES.appendingPathComponent("test_log.log")
                if result == 0 {
                    logInput.send("\tpassed...")
                } else {
                    logInput.send("\tfailed...")
                }
                //print("result status",result.status)
                //log_output.append(contentsOf: result.output)
                
            }
        }
        //return
        if !external_host_python &&  !fm.fileExists(atPath: system.appendingPathComponent("hostpython").path) {
            print("downloading \(py310.path)")
            //logInput.send("downloading \(py310.path)")
            FileDownloader.loadFileSyncTemp(url: py310) { [unowned self] url, err in
                let dst = system.appendingPathComponent("Python-3.10.2.tgz")
                let tmp = URL(fileURLWithPath: "tmp/Python-3.10.2.tgz")
                try? fm.moveItem(at: url! , to: tmp)
                logInput.send("building Python-3.10.2")
                //build_root_python(path: system.path, file: "Python-3.10.2", target_folder: "hostpython")
                let result = BuildPython_GUI(version: "3.10.2", target_folder: .host, { log_text in
                    //setup_log.debug(log_text)
                    print(log_text)
                })
                //log_output.append(contentsOf: result.output)
                if result == 0 {
                    logInput.send("\tpassed...")
                } else {
                    logInput.send("\tfailed...")
                }
                InstallPythonCert(target_folder: .host)
                
            }
        }
        //return
        if !external_venv_python && !fm.fileExists(atPath: system.appendingPathComponent("venvpython").path) {
            print("downloading \(py39.path)")
            FileDownloader.loadFileSyncTemp(url: py39) { [unowned self] url, err in
                let dst = system.appendingPathComponent("Python-3.9.9.tgz")
                let tmp = URL(fileURLWithPath: "/tmp/Python-3.9.9.tgz")
                try! fm.moveItem(at: url! , to: tmp)
                logInput.send("building Python-3.9.9")
                //build_root_python(path: system.path, file: "Python-3.9.9", target_folder: "venvpython")
                let result = BuildPython_GUI(version: "3.9.9", target_folder: .venv, { log_text in
                    setup_log.debug(log_text)
                })
                //log_output.append(contentsOf: result.output)
                
                if result == 0 {
                    logInput.send("\tpassed...")
                } else {
                    logInput.send("\tfailed...")
                }
                
                InstallPythonCert(target_folder: .venv)
            }
        }
        
//        let output_path = paths.SYSTEM_FILES.appendingPathComponent("test_log.log")
//        let output_string = log_output.joined(separator: "\n")
//        try! output_string.write(toFile: output_path.path, atomically: true, encoding: .utf8)
        
        
        
    }
    
//    func CheckAppFiles() {
//        let paths = KSLPaths.shared
//        //paths.HOSTPYTHON_APP_EXE
//        //print(paths.HOSTPYTHON_APP_EXE)
//        //let app_dir = KSLPaths.shared.APPLICATION_SUPPORT_FOLDER
//        
//        let hostpython = paths.HOSTPYTHON_APP_EXE
//        let hostpython_path = hostpython.path
//        if FM.fileExists(atPath: hostpython_path) {
//            let result = CheckPython(python: hostpython)
//            
//            switch result {
//            case 0:
//                print("hostpython ran")
//            case 1:
//                print("hostpython failed")
//                
//            default:
//                print("hostpython - some other result = \(result)")
//            }
//        } else {
//            print(fatalError("\(hostpython_path) missing"))
//        }
//        
//        let venvpython = paths.VENVPYTHON_APP_EXE
//        let venvpython_path = venvpython.path
//        
//        if FM.fileExists(atPath: venvpython_path) {
//            let result = CheckPython(python: venvpython)
//            
//            switch result {
//            case 0:
//                print("venvpython ran")
//            case 1:
//                print("venvpython failed")
//                
//            default:
//                print("venvpython - some other result = \(result)")
//            }
//        } else {
//            print(fatalError("\(venvpython_path) missing"))
//        }
//        
//        
//    }
//
//    
}

extension ViewStatesModel: DirectoryMonitorDelegate {
    func didChange(directoryMonitor: DirectoryMonitor, added: Set<URL>, removed: Set<URL>) {
        print()
        print(added)
    }
    
    
}

@MainActor
func reload_pbxproj() async {
        
        let host_path = KSLPaths.shared.APPLICATION_SUPPORT_FOLDER.appendingPathComponent("hostpython").path
        guard FM.fileExists(atPath: host_path) else { return }
        loadHostPythonLibrary_GUI()
        pbxproj = Python.import("pbxproj")
        XcodeProject_cls = pbxproj.XcodeProject
    }
