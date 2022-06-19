//
//  KSLDataModel+Setup.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 23/05/2022.
//

import Foundation
import AppKit


@discardableResult
func InstallOpenSSL_GUI(url: URL, file: String, _ logger: @escaping ((String)->Void)) -> Int32 {
    //return 1
    let path = url.path.replacingOccurrences(of: " ", with: "\\ ")
    let targs = ["-c", """
        BASEDIR=$(pwd)
        cd /tmp


        echo "path: $BASEDIR/\(file)"
        #cd \(path)
        tar -xf \(file).tgz
        rm \(file).tgz
        cd \(file)
        ./config --prefix=\(path)/openssl --openssldir=\(path)/openssl shared zlib
        #cd \(file)
        make -j4
        #make test
        make install
        rm -R -f /tmp/\(file)
        #cp -R $BASEDIR/openssl \(path)
        """]
    let task = Process()
    //task.launchPath = "/bin/zsh"
    task.currentDirectoryURL = url
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    
    let outputHandler = pipe.fileHandleForReading
    outputHandler.waitForDataInBackgroundAndNotify()
    var output = [String]()
    var dataObserver: NSObjectProtocol!
    let notificationCenter = NotificationCenter.default
    let dataNotificationName = NSNotification.Name.NSFileHandleDataAvailable
    dataObserver = notificationCenter.addObserver(forName: dataNotificationName, object: outputHandler, queue: nil) {  notification in
        let data = outputHandler.availableData
        guard data.count > 0 else {
            notificationCenter.removeObserver(dataObserver as Any)
            return
        }
        if let line = String(data: data, encoding: .utf8) { logger(line) }
        outputHandler.waitForDataInBackgroundAndNotify()
    }
    
    
    
    task.executableURL = ZSH
    task.arguments = targs

    task.launch()
    task.waitUntilExit()
    //return task.terminationStatus
    return task.terminationStatus
}

@discardableResult
func BuildPython_GUI(version: String, target_folder: InternalPythons, _ logger: @escaping ((String)->Void)) -> Int32 {
    
    let _path = KSLPaths.shared.APPLICATION_SUPPORT_FOLDER
    let path = _path.path.replacingOccurrences(of: " ", with: "\\ ")
    let python_folder = _path.appendingPathComponent(target_folder.rawValue).path.replacingOccurrences(of: " ", with: "\\ ")
    let file = "Python-\(version)"
    let task = Process()
    //task.launchPath = python
    let targs = ["-c", """
        BASEDIR=$(pwd)
        cd /tmp
        echo "path: \(path)/\(file)"
        #cd \(path)
        tar -xf \(file).tgz
        rm \(file).tgz
        cd \(file)
        ./configure -q --without-static-libpython --with-openssl=\(path)/openssl --prefix=\(path)/\(target_folder.rawValue)
        #make altinstall
        make -j$(nproc)
        make install
        rm -R -f /tmp/\(file)
        #cd $BASEDIR
        #cp -R /tmp/\(target_folder.rawValue) \(python_folder)
        """]
        //task.launchPath = "/bin/zsh"
    task.executableURL = ZSH
    task.arguments = targs
    task.currentDirectoryURL = _path
    
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    let outputHandler = pipe.fileHandleForReading
    outputHandler.waitForDataInBackgroundAndNotify()
    //var output = [String]()
    var dataObserver: NSObjectProtocol!
    let notificationCenter = NotificationCenter.default
    let dataNotificationName = NSNotification.Name.NSFileHandleDataAvailable
    dataObserver = notificationCenter.addObserver(forName: dataNotificationName, object: outputHandler, queue: nil) {  notification in
        let data = outputHandler.availableData
        guard data.count > 0 else {
            notificationCenter.removeObserver(dataObserver as Any)
            return
        }
        if let line = String(data: data, encoding: .utf8) { logger(line) }
        outputHandler.waitForDataInBackgroundAndNotify()
    }
    
    
    

    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
    //return ShellResults(output: output, status: task.terminationStatus)
}


@discardableResult
func runToolchain_GUI(command: ToolchainCommands, args: [String], _ logger: @escaping ((String)->Void)) -> Int32 {
    
    let targs = ["-c", """
        . venv/bin/activate
        toolchain \(command.rawValue) \(args.joined(separator: " "))
        """]
    let task = Process()
    task.currentDirectoryURL = KSLPaths.shared.ROOT_URL
    
    
    //task.launchPath = "/bin/zsh"
    
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    
    let outputHandler = pipe.fileHandleForReading
    outputHandler.waitForDataInBackgroundAndNotify()
    var output = [String]()
    var dataObserver: NSObjectProtocol!
    let notificationCenter = NotificationCenter.default
    let dataNotificationName = NSNotification.Name.NSFileHandleDataAvailable
    dataObserver = notificationCenter.addObserver(forName: dataNotificationName, object: outputHandler, queue: nil) {  notification in
        let data = outputHandler.availableData
        guard data.count > 0 else {
            notificationCenter.removeObserver(dataObserver as Any)
            return
        }
        if let line = String(data: data, encoding: .utf8) { logger(line) }
        outputHandler.waitForDataInBackgroundAndNotify()
    }
    
    
    
    task.executableURL = ZSH
    task.arguments = targs

    task.launch()
    task.waitUntilExit()
    //return task.terminationStatus
    return task.terminationStatus
}

extension KSLDataModel {
    
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
        
        let output_path = paths.SYSTEM_FILES.appendingPathComponent("test_log.log")
        let output_string = log_output.joined(separator: "\n")
        try! output_string.write(toFile: output_path.path, atomically: true, encoding: .utf8)
        initHostPythonSitePackages()
        
        
    }

    
    
    func InitWorkingFolder(python_path: String!, python_version: String!, extra_recipes: [String] = []) {
        //var py_path = "/usr/local/bin/python3"
        logInput.send("Init WorkingFolder")
        var py_version_major = "3.9"
        var py_version_full = "3.9.9"
        //if let ppath = python_path {py_path = ppath}
        if let pversion = python_version {
            py_version_full = pversion
            py_version_major = python_version.split(separator: ".")[0...1].joined(separator: ".")
        }
        let paths = KSLPaths.shared

        let support_path = paths.SYSTEM_FILES.appendingPathComponent("project_support_files").path
        let KivySwiftSupportFiles = paths.KIVY_SUPPORT_FILES.path

        logInput.send("creating working venv")
        create_venv(python: "")
        //https://github.com/kivy/kivy-ios
        //https://github.com/meow464/kivy-ios.git@custom_recipes
        //return
        for pip in ["wheel","cython", "kivy", "git+https://github.com/kivy/kivy-ios.git"] {
            pip_install(arg: pip)
        }
 
        logInput.send("handling project_support_files")
        copyItem(from: "\(KivySwiftSupportFiles)/project_support_files", to: support_path, force: true)
        
        
        copyItem(from: "\(KivySwiftSupportFiles)/swift_types.pyi", to: paths.VENV_SITE_PACKAGES.appendingPathComponent("swift_types.pyi").path, force: true)

        createFolder(name: paths.WRAPPER_BUILDS.path) //wrapper_builds

        logInput.send("Toolchain - Building <Python3>")
        setup_log.debug("Toolchain - Building <Python3>")

        runToolchain_GUI(command: .build, args: ["python3"]) {[unowned self] log in
            setup_log.debug(log)
        }
        logInput.send("Toolchain - Building <Kivy>")
        setup_log.debug("Toolchain - Building <Kivy>")

        runToolchain_GUI(command: .build, args: ["kivy"]) {[unowned self] log in
            setup_log.debug(log)
        }
        let sel_recipes = extra_recipes
        let sel_count = extra_recipes.count
        for (i, recipe) in sel_recipes.enumerated() {
            let begin_string = "Toolchain - Building extras (\(i + 1)/\(sel_count) <\(recipe)>"
            logInput.send(begin_string)
            setup_log.debug(begin_string)
            let result = runToolchain_GUI(command: .build, args: [recipe]) {[unowned self] log in
                setup_log.debug(log)
            }
            let end_string = "\t\(result==0 ? "passed" : "failed")..."
            logInput.send(end_string)
            setup_log.debug(end_string)
            
        }
        
        do {
            try moveLibToSystem_Files()
        } catch let err {
            logInput.send(err.localizedDescription)
            setup_log.debug(err.localizedDescription)
        }
        
//        let proj_settings = ProjectHandler.shared
//        proj_settings.current_python_path = paths.VENVPYTHON_EXE.path//py_path
//        proj_settings.current_python_version = py_version_full.split(separator: ".").map{Int($0)!}
//        proj_settings.save()
//        //print("Setup done")
//        logInput.send("Setup done")
    }
    
}

struct ShellResult {

    let output: String
    let status: Int32

}

struct ShellResults {

    let output: [String]
    let status: Int32

}

@discardableResult
func shell_external(url: URL, file: String) -> ShellResult {
    let task = Process()
    let path = url.path
    let targs = ["-c", """
            echo "path: \(path)/\(file)"
            cd \(path)
            tar -xf \(path)/\(file).tgz
            rm \(path)/\(file).tgz
            cd \(file)
            ./config --prefix=\(path)/openssl --openssldir=\(path)/openssl shared zlib
            make -j$(nproc)
            #make test
            make install
            #rm -R -f \(path)/\(file)
            """]
    
    task.executableURL = ZSH
    task.arguments = targs
    let pipe = Pipe()
    task.standardOutput = pipe
    let outputHandler = pipe.fileHandleForReading
    outputHandler.waitForDataInBackgroundAndNotify()
    var line_count = 0
    var output = ""
    var dataObserver: NSObjectProtocol!
    let notificationCenter = NotificationCenter.default
    let dataNotificationName = NSNotification.Name.NSFileHandleDataAvailable
    dataObserver = notificationCenter.addObserver(forName: dataNotificationName, object: outputHandler, queue: nil) {  notification in
        let data = outputHandler.availableData
        guard data.count > 0 else {
            notificationCenter.removeObserver(dataObserver)
            return
        }
        if let line = String(data: data, encoding: .utf8) {
            print(line)
//            DispatchQueue.main.async {
//                KSLDataModel.shared.logData.logLines.append(Line(id: line_count, text: line))
//                line_count += 1
//            }
//            DispatchQueue.main.async {
//                KSLDataModel.shared.logInput.send(line)
//            }
            
//            if isVerbose {
//                print(line)
//            }
            output = output + line + "\n"
        }
        outputHandler.waitForDataInBackgroundAndNotify()
    }

    task.launch()
    task.waitUntilExit()
    return ShellResult(output: output, status: task.terminationStatus)
}
