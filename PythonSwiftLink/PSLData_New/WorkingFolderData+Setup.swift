//
//  KSLDataModelNew+Setup.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 31/05/2022.
//

import Foundation
import Combine
import RealmSwift
import SwiftyBeaver

let setup_log = SwiftyBeaver.self

extension WorkingFolderData {
    
    
    func createToolchainProject(name: String) {
        runToolchain_GUI(command: .create, args: [name, "py_src"]) { line in
            print(line)
        }
    }
    
    
    
    
    func run_setup() {
        let vsm = ViewStatesModel.shared
        vsm.log_mode = .setup
        vsm.setupLogData.reset()
        let paths = KSLPaths.shared
        paths._root = URL(fileURLWithPath: path)
        if !FM.fileExists(atPath: paths.SYSTEM_FILES.path) {
            do {
                try FM.createDirectory(at: paths.SYSTEM_FILES, withIntermediateDirectories: true)
            } catch let err {
                print(err.localizedDescription)
                
            }
        }
            print("running setup")
            new_log(name: "setup")
            let extra_recipes = selectedRecipes.map{$0.name}
            DispatchQueue.global().async { [self] in
                //BuildPythons()
                InitWorkingFolder(python_path: nil, python_version: nil, extra_recipes: extra_recipes)
                print("Adding extra recipe:")
                
    //            let selected_recipes = recipes.filter{$0.selected}
    //            for r in selected_recipes {
    //                print(r.name)where
    //            }
                DispatchQueue.main.async {
                    //setupIsRunning = false
                    
                    vsm.setupIsRunning = false
                    vsm.stopMonitoringDistLib()
                }
                
            }
            
            
            
            
        }
    
    func new_log(name: String) {
        setup_log.removeAllDestinations()
        let paths = KSLPaths.shared
        if !FM.fileExists(atPath: paths.SETUP_LOGS.path) {
            try! FM.createDirectory(at: paths.SETUP_LOGS, withIntermediateDirectories: true)
        }
        let date = Date().getFormattedDate(format: "MM_dd_yy_HH_mm_ss")
        let setup_file = FileDestination(logFileURL: paths.SETUP_LOGS.appendingPathComponent("setup-\(date).log"))
        setup_file.format = "$M"
        //let build_file = FileDestination(logFileURL: KSLPaths.shared.SYSTEM_FILES.appendingPathComponent("test_build.log"))
        setup_log.addDestination(setup_file)
    }
    
    
    func mainConfig() {
            BuildPythons()
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
        
        //var log_output = [String]()
        let logInput = ViewStatesModel.shared.logInput
        //&& !fm.fileExists(atPath: system.appendingPathComponent("openssl").path)
        
        if (!external_host_python || !external_venv_python ) && !fm.fileExists(atPath: system.appendingPathComponent("openssl").path) {
            print("building openssl")
            //logInput.send("downloading \(openssl.path)")
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
                    //setup_log.debug(log_text)
                    print(log_text)
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
        initHostPythonSitePackages()
        
        
    }

    
    
    func InitWorkingFolder(python_path: String!, python_version: String!, extra_recipes: [String] = []) {
        //var py_path = "/usr/local/bin/python3"
        let logInput = ViewStatesModel.shared.logInput
        logInput.send("Init WorkingFolder")
//        var py_version_major = "3.9"
//        var py_version_full = "3.9.9"
//        //if let ppath = python_path {py_path = ppath}
//        if let pversion = python_version {
//            py_version_full = pversion
//            py_version_major = python_version.split(separator: ".")[0...1].joined(separator: ".")
//        }
        let paths = KSLPaths.shared

        let system_lib = paths.SYSTEM_FILES.appendingPathComponent("lib")
        if !checkLibPath(
            target: system_lib,
            dst: paths.ROOT_LIB,
            onLink: { isTarget in
                if !isTarget {
                    try! FM.removeItem(at: paths.ROOT_LIB)
                    if FM.fileExists(atPath: system_lib.path) {
                        try! linkLibToBackToSystem()
                    }
                }
            },
            onDir: {
               //try? moveLibToSystem_Files()
            }
        ) {
            try? initLibToSystem_Files()
        }

        
        let support_path = paths.SYSTEM_FILES.appendingPathComponent("project_support_files").path
        let KivySwiftSupportFiles = paths.KIVY_SUPPORT_FILES.path

        logInput.send("creating working venv")
        create_venv(python: "")
        //https://github.com/kivy/kivy-ios
        //https://github.com/meow464/kivy-ios.git@custom_recipes
        //return
        logInput.send("pip installing into working venv")
        let new_pbxproj = "git+https://github.com/psychowasp/mod-pbxproj"
        for pip in ["wheel","cython", "kivy",new_pbxproj ,"git+https://github.com/kivy/kivy-ios.git"] {
            logInput.send("\t\(pip)")
            pip_install(arg: pip)
        }
 
        logInput.send("handling project_support_files")
        copyItem(from: "\(KivySwiftSupportFiles)/project_support_files", to: support_path, force: true)
        
        
        copyItem(from: "\(KivySwiftSupportFiles)/swift_types.pyi", to: paths.VENV_SITE_PACKAGES.appendingPathComponent("swift_types.pyi").path, force: true)

        createFolder(name: paths.WRAPPER_BUILDS.path) //wrapper_builds
        ViewStatesModel.shared.startMonitorDistLib()
        logInput.send("running setup")
        for main_recipe in ["libffi" , "openssl", "python3",
                            "freetype", "sdl2", "sdl2_image", "sdl2_mixer",
                            "sdl2_ttf","ios", "pyobjus", "kivy"] {
            
            logInput.send("Toolchain - Building <\(main_recipe)>")
            setup_log.debug("Toolchain - Building <\(main_recipe)>")
            
            runToolchain_GUI(command: .build, args: [main_recipe]) { log in
                setup_log.debug(log)
            }
        }

        let sel_recipes = extra_recipes
        let sel_count = extra_recipes.count
        for (i, recipe) in sel_recipes.enumerated() {
            let begin_string = "Toolchain - Building extras (\(i + 1)/\(sel_count)) <\(recipe)>"
            logInput.send(begin_string)
            setup_log.debug(begin_string)
            let result = runToolchain_GUI(command: .build, args: [recipe]) { log in
                setup_log.debug(log)
            }
            let end_string = "\t\(result==0 ? "passed" : "failed")..."
            logInput.send(end_string)
            setup_log.debug(end_string)
            
        }
        
        if let last = last_project {
            checkLibPath(
                target: system_lib,
                dst: paths.ROOT_LIB,
                onLink: { isTarget in
                    if !isTarget {
                        try? hardLinkProjectLib(ksl_proj: last)
                    }
                    print(system_lib.path, isTarget)
                },
                onDir: {
                    //try! moveLibToSystem_Files()
                }
            )
        }
//        print(dst.path, try? dst.checkResourceIsReachable())
        
//        do {
//            try moveLibToSystem_Files()
//        } catch let err {
//            logInput.send(err.localizedDescription)
//            setup_log.debug(err.localizedDescription)
//
//        }
        
//        let proj_settings = ProjectHandler.shared
//        proj_settings.current_python_path = paths.VENVPYTHON_EXE.path//py_path
//        proj_settings.current_python_version = py_version_full.split(separator: ".").map{Int($0)!}
//        proj_settings.save()
        //print("Setup done")
        logInput.send("Setup done")
    }
    
    @discardableResult
    func checkLibPath(
        target: URL,
        dst: URL,
        onLink: @escaping (Bool)->Void,
        onDir: @escaping ()->Void
    ) -> Bool {
        if let ok = try? dst.checkResourceIsReachable(), ok {
                   
            if let vals = try? dst.resourceValues(forKeys: [.isSymbolicLinkKey, .isDirectoryKey]) {
                if let islink = vals.isSymbolicLink, islink {
                    print("it's a symbolic link")
                    let link_dst = dst.resolvingSymlinksInPath()
                    onLink(target == link_dst)
                    return true
                }
                if let isDir = vals.isDirectory, isDir {
                    print("it's a Directory")
                    onDir()
                    return true
                }
            }
            return true
        }
        return false
    }
}
