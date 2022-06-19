//
//  AppFilesChecker.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 04/06/2022.
//

import Foundation
import Combine

class AppFilesChecker {
    static let shared = AppFilesChecker()
    
    let paths = KSLPaths.shared
    var logger: ((String)->Void)?
    var pythons_missing: ((Bool) async ->Void)?
    var logInput: PassthroughSubject<String, Never>?
    
    init() {
        //self.logger = logger
        //self.pythons_missing = pythons_missing
    }
    
    func CheckAppFiles( ) async -> Bool {
        let paths = KSLPaths.shared
        //paths.HOSTPYTHON_APP_EXE
        //print(paths.HOSTPYTHON_APP_EXE)
        //let app_dir = KSLPaths.shared.APPLICATION_SUPPORT_FOLDER
        
        let openssl = paths.OPENSSL_APP_EXE
        let openssl_path = openssl.path
        if FM.fileExists(atPath: openssl_path) {
            let result = await CheckOpenSSL(openssl: openssl)
            
            switch result {
            case 0:
                print("openssl ran")
            case 1:
                print("openssl failed")
                await pythons_missing?(true)
                await cleanAppFiles()
                await buildOpenSSL()
            default:
                print("openssl - some other result = \(result)")
            }
        } else {
            print("\(openssl_path) missing")
            await pythons_missing?(true)
            await cleanAppFiles()
            await buildOpenSSL()
        }
        
        let hostpython = paths.HOSTPYTHON_APP_EXE
        let hostpython_path = hostpython.path
        if FM.fileExists(atPath: hostpython_path) {
            let result = CheckPython(python: hostpython)
            
            switch result {
            case 0:
                print("hostpython ran")
            case 1:
                print("hostpython failed")
                await pythons_missing?(true)
                await buildHostPython()
            default:
                print("hostpython - some other result = \(result)")
            }
        } else {
            print("\(hostpython_path) missing")
            await pythons_missing?(true)
            await buildHostPython()
        }
        
        let venvpython = paths.VENVPYTHON_APP_EXE
        let venvpython_path = venvpython.path
        
        if FM.fileExists(atPath: venvpython_path) {
            let result = CheckPython(python: venvpython)
            
            switch result {
            case 0:
                print("venvpython ran")
                
            case 1:
                print("venvpython failed")
                await pythons_missing?(true)
                await buildVenvPython()
                
            default:
                print("venvpython - some other result = \(result)")
            }
        } else {
            print("\(venvpython_path) missing")
            await pythons_missing?(true)
            await buildVenvPython()
        }
        
        //let support_files = paths.KIVY_SUPPORT_FILES
        
        if !FM.fileExists(atPath: paths.APPLICATION_SUPPORT_FOLDER.appendingPathComponent("Database").path) {
            try? FM.createDirectory(at: paths.APPLICATION_SUPPORT_FOLDER.appendingPathComponent("Database"), withIntermediateDirectories: true)
        }
        
        if !FM.fileExists(atPath: paths.KIVY_SUPPORT_FILES.path) {
            await pythons_missing?(true)
            await installKSLSupportFiles()
        } 
        
        let pycall_py = paths.HOSTPYTHON_APP_SITE_PACKAGES.appendingPathComponent("pythoncall_builder.py")
        if !FM.fileExists(atPath: pycall_py.path) {
            await pythons_missing?(true)
            await installKSLSupportFiles()
        } else {
            await pythons_missing?(false)
            return true
        }
        
        
        
        return false
    }
    
    func cleanAppFiles() async {
        let app_dir = paths.APPLICATION_SUPPORT_FOLDER
        if FM.fileExists(atPath: app_dir.path) {
            for dir in ["openssl", "venvpython", "hostpython","KivySwiftSupportFiles"] {
                try? FM.removeItem(at: app_dir.appendingPathComponent(dir))
            }
        }
    }
    
    func buildOpenSSL () async {
        let openssl = URL(string: "http://www.openssl.org/source/openssl-1.1.1l.tar.gz")!
        
        let system = paths.APPLICATION_SUPPORT_FOLDER
        
        
        logInput?.send("downloading \(openssl.path)")
        
        FileDownloader.loadFileSyncTemp(url: openssl) { [unowned self] url, err in
            
            let tmp = URL(fileURLWithPath: "/tmp/openssl-1.1.1l.tgz")
            do {
                try? FM.moveItem(at: url! , to: tmp)
            }
//                InstallOpenSSL(url: paths.SYSTEM_FILES, file: "openssl-1.1.1l")
            logInput?.send("building openssl-1.1.1l")
            let result = InstallOpenSSL_GUI(url: system, file: "openssl-1.1.1l", logger!)
            
            if result == 0 {
                logInput?.send("\tpassed...")
            } else {
                logInput?.send("\tfailed...")
            }
            
        }
    }
    
    func buildHostPython() async {
        let python = URL(string: "https://www.python.org/ftp/python/3.10.2/Python-3.10.2.tgz")!
        
        print("downloading \(python.path)")
        logInput?.send("downloading \(python.path)")
        FileDownloader.loadFileSyncTemp(url: python) { [unowned self] url, err in
            //let dst = system.appendingPathComponent("Python-3.10.2.tgz")
            let tmp = URL(fileURLWithPath: "tmp/Python-3.10.2.tgz")
            try? FM.moveItem(at: url! , to: tmp)
            logInput?.send("building Python-3.10.2")
            //build_root_python(path: system.path, file: "Python-3.10.2", target_folder: "hostpython")
            let result = BuildPython_GUI(version: "3.10.2", target_folder: .host, logger!)
            //log_output.append(contentsOf: result.output)
            if result == 0 {
                logInput?.send("\tpassed...")
                InstallPythonCert(target_folder: .host)
            } else {
                logInput?.send("\tfailed...")
            }
            
            
        }
    }
    
    func buildVenvPython() async {
        let python = URL(string: "https://www.python.org/ftp/python/3.9.9/Python-3.9.9.tgz")!
        
        print("downloading \(python.path)")
        logInput?.send("downloading \(python.path)")
        FileDownloader.loadFileSyncTemp(url: python) { [unowned self] url, err in
            //let dst = system.appendingPathComponent("Python-3.10.2.tgz")
            let tmp = URL(fileURLWithPath: "/tmp/Python-3.9.9.tgz")
            try? FM.moveItem(at: url! , to: tmp)
            logInput?.send("building Python-3.9.9")
            //build_root_python(path: system.path, file: "Python-3.10.2", target_folder: "hostpython")
            let result = BuildPython_GUI(version: "3.9.9", target_folder: .venv, logger!)
            //log_output.append(contentsOf: result.output)
            if result == 0 {
                logInput?.send("\tpassed...")
                InstallPythonCert(target_folder: .host)
                
            } else {
                logInput?.send("\tfailed...")
            }
            
            
        }
    }
    
    func installKSLSupportFiles() async {
        initHostPythonSitePackages()
        do {
            let KivySwiftSupportFiles = paths.KIVY_SUPPORT_FILES.path
            let branch = AppVersion.release_state == .release ? "main" : "testing"
            try Process().clone(repo: ["--branch", branch, "https://github.com/psychowasp/KivySwiftSupportFiles.git"], path: KivySwiftSupportFiles)
            copyItem(from: "\(KivySwiftSupportFiles)/pythoncall_builder.py", to: paths.HOSTPYTHON_APP_SITE_PACKAGES.appendingPathComponent("pythoncall_builder.py").path, force: true)
        } catch let err {
            print(err.localizedDescription)
            return
        }
        
    }
    
    
}




@discardableResult
private func CheckPython(python: URL) -> Int32 {

    let check_python_script = """
    import ssl
    print("python working")
    """

    let task = Process()
    let targs = ["-c", check_python_script]
    //let paths = KSLPaths.shared

    task.executableURL = python
    
    task.arguments = targs

    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

@discardableResult
private func CheckOpenSSL(openssl: URL) async -> Int32 {
    let task = Process()
    let targs = ["-c","\(openssl.path) help"]
    //let paths = KSLPaths.shared

    task.executableURL = ZSH
    
    task.arguments = targs

    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}
