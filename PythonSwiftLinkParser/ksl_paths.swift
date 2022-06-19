//
//  ksl_paths.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 22/05/2022.
//

import Foundation


let FM = FileManager.default

let ZSH = URL(fileURLWithPath: "/bin/zsh")

class KSLPaths {
    
    static let shared = KSLPaths()
    var _root: URL
    
    var external_venv: URL! = nil
    var external_host: URL! = nil
    
    var user_app_folder_url: URL
    
    init() {
        _root = FM.homeDirectoryForCurrentUser
        
        let fileManager = FileManager.default
        let appURL = fileManager.urls(for: .applicationDirectory, in: .userDomainMask).first!
        //  Create subdirectory
        user_app_folder_url = appURL.appendingPathComponent("PythonSwiftLink")
    }
    
    var ROOT_URL: URL {
        //URL(fileURLWithPath: FM.currentDirectoryPath, isDirectory: true)
        _root
    }
    
    
    var VENV_SITE_PACKAGES : URL { ROOT_URL.appendingPathComponent("venv/lib/python3.9/site-packages/", isDirectory: true) }
    //let site_path = ROOT_URL.path + "/venv/lib/python3.9/site-packages/"
    var SYSTEM_FILES: URL { ROOT_URL.appendingPathComponent("system_files", isDirectory: true) }
    var VENVPYTHON: URL {
        get {
            if let ext = external_venv {
                return ext
            }
            return SYSTEM_FILES.appendingPathComponent("venvpython", isDirectory: true)
        }
        set {
            external_venv = newValue
        }
    }
    
    var HOSTPYTHON: URL {
        get {
            if let ext = external_host {
                return ext
            }
            return SYSTEM_FILES.appendingPathComponent("hostpython", isDirectory: true)
        }
        set {
            external_host = newValue
        }
    }
    
    var APPLICATION_SUPPORT_FOLDER: URL { user_app_folder_url }
    
    var KIVY_SUPPORT_FILES: URL { user_app_folder_url.appendingPathComponent("KivySwiftSupportFiles") }
    
    var OPENSSL_APP: URL { APPLICATION_SUPPORT_FOLDER.appendingPathComponent("openssl") }
    
    var OPENSSL_APP_EXE: URL { OPENSSL_APP.appendingPathComponent("bin/openssl") }
    
    var HOSTPYTHON_APP: URL { APPLICATION_SUPPORT_FOLDER.appendingPathComponent("hostpython") }
    
    var HOSTPYTHON_APP_SITE_PACKAGES: URL { HOSTPYTHON_APP.appendingPathComponent("lib/python3.10/site-packages", isDirectory: true) }
    var HOSTPYTHON_APP_EXE: URL { HOSTPYTHON_APP.appendingPathComponent("bin/python3") }
    
    var VENVPYTHON_APP: URL { APPLICATION_SUPPORT_FOLDER.appendingPathComponent("venvpython") }
    
    var VENVPYTHON_APP_SITE_PACKAGES: URL { VENVPYTHON_APP.appendingPathComponent("lib/python3.10/site-packages", isDirectory: true) }
    var VENVPYTHON_APP_EXE: URL { VENVPYTHON_APP.appendingPathComponent("bin/python3") }
    
    var VENVPYTHON_SITE_PACKAGES: URL { SYSTEM_FILES.appendingPathComponent("lib/python3.9/site-packages", isDirectory: true) }
    var HOSTPYTHON_SITE_PACKAGES: URL { SYSTEM_FILES.appendingPathComponent("lib/python3.10/site-packages", isDirectory: true) }
    var VENVPYTHON_EXE: URL { VENVPYTHON.appendingPathComponent("bin/python3") }
    
    var HOSTPYTHON_EXE: URL { HOSTPYTHON.appendingPathComponent("bin/python3") }
    var WRAPPER_BUILDS: URL { ROOT_URL.appendingPathComponent("wrapper_builds", isDirectory: true) }
    var WRAPPER_SOURCES: URL { ROOT_URL.appendingPathComponent("wrapper_sources", isDirectory: true) }
    var WRAPPER_HEADERS: URL { ROOT_URL.appendingPathComponent("wrapper_headers", isDirectory: true) }
    var WRAPPER_HEADERS_C: URL { WRAPPER_HEADERS.appendingPathComponent("c", isDirectory: true) }
    var WRAPPER_HEADERS_SWIFT: URL { WRAPPER_HEADERS.appendingPathComponent("swift", isDirectory: true) }
    var TOOLCHAIN_URL: URL {
        if let ext = external_venv {
            return ext.appendingPathComponent("bin/toolchain")
        }
        return VENVPYTHON.appendingPathComponent("bin/toolchain")
    }
    
    var DIST_FOLDER: URL { ROOT_URL.appendingPathComponent("dist", isDirectory: true) }
    var DIST_LIB_FOLDER: URL { DIST_FOLDER.appendingPathComponent("lib", isDirectory: true) }
    var ROOTPYTHON: URL { DIST_FOLDER.appendingPathComponent("root", isDirectory: true) }
    var ROOTPYTHON_CHECK_PATH: URL { ROOTPYTHON.appendingPathComponent("python3", isDirectory: true) }
    var ROOT_LIB: URL { ROOTPYTHON.appendingPathComponent("python3/lib", isDirectory: true) }

    var LOGS_FOLDER: URL { ROOT_URL.appendingPathComponent("Logs", isDirectory: true) }
    var SETUP_LOGS: URL { LOGS_FOLDER.appendingPathComponent("Setup", isDirectory: true) }
    var BUILD_LOGS: URL { LOGS_FOLDER.appendingPathComponent("Builds", isDirectory: true) }
}
