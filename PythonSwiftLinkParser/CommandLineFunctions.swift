
import Foundation

import AppKit

enum PyTypes: PythonObject {
    case str
}

import PythonKit



func launch(path: String, arguments: [String], completionHandler: @escaping (Int32, Data) -> Void) throws {
    let group = DispatchGroup()
    let pipe = Pipe()
    var standardOutData = Data()

    group.enter()
    let proc = Process()
    proc.launchPath = path
    proc.arguments = arguments
    proc.standardOutput = pipe.fileHandleForWriting
    proc.terminationHandler = { _ in
        proc.terminationHandler = nil
        group.leave()
    }

    group.enter()
    DispatchQueue.global().async {
        // Doing long-running synchronous I/O on a global concurrent queue block
        // is less than ideal, but I’ve convinced myself that it’s acceptable
        // given the target ‘market’ for this code.

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        pipe.fileHandleForReading.closeFile()
        DispatchQueue.main.async {
            standardOutData = data
            group.leave()
        }
    }

    group.notify(queue: .main) {
        completionHandler(proc.terminationStatus, standardOutData)
    }

    try proc.run()

    // We have to close our reference to the write side of the pipe so that the
    // termination of the child process triggers EOF on the read side.

    pipe.fileHandleForWriting.closeFile()
}

func launch(tool: URL, arguments: [String], completionHandler: @escaping (Int32, Data) -> Void) throws {
    let group = DispatchGroup()
    let pipe = Pipe()
    var standardOutData = Data()

    group.enter()
    let proc = Process()
    proc.executableURL = tool
    proc.arguments = arguments
    proc.standardOutput = pipe.fileHandleForWriting
    proc.terminationHandler = { _ in
        proc.terminationHandler = nil
        group.leave()
    }

    group.enter()
    DispatchQueue.global().async {
        // Doing long-running synchronous I/O on a global concurrent queue block
        // is less than ideal, but I’ve convinced myself that it’s acceptable
        // given the target ‘market’ for this code.

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        pipe.fileHandleForReading.closeFile()
        DispatchQueue.main.async {
            standardOutData = data
            group.leave()
        }
    }

    group.notify(queue: .main) {
        completionHandler(proc.terminationStatus, standardOutData)
    }

    try proc.run()

    // We have to close our reference to the write side of the pipe so that the
    // termination of the child process triggers EOF on the read side.

    pipe.fileHandleForWriting.closeFile()
}



enum ToolchainCommands: String {
    case create
    case xcode
    case clean
    case build
    case update
    case pip
    case distclean
    case recipes
    case help = "--help"
}

@discardableResult
func toolchain(command: String, args: [String]) -> Int32 {
    var targs: [String] = [command]
    targs.append(contentsOf: args)
    let task = Process()
    task.launchPath = "venv/bin/toolchain"
    task.arguments = targs
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

//func _toolchain(path: String, command: ToolchainCommands, args: [String]) {
//    toolchain_venv(path: path, command: command.rawValue, args: args)
//}
//
//func hostpython_toolchain(path: String, command: ToolchainCommands, args: [String]) {
//    toolchain_venv(path: path, command: command.rawValue, args: args)
//}




@discardableResult
func pkg_install(path: String) -> Int32 {

    let task = Process()
    task.launchPath = "/usr/sbin/installer"
    task.arguments = ["-pkg","-file", path]
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
    
}

@discardableResult
func venvpython_toolchain(command: ToolchainCommands, args: [String]) -> Int32 {
    var arguments = [command.rawValue]
    arguments.append(contentsOf: args)
    let task = Process()
    task.currentDirectoryURL = KSLPaths.shared.ROOT_URL
    //task.launchPath = venvpython_url.appendingPathComponent("bin/toolchain").path
    task.executableURL = KSLPaths.shared.TOOLCHAIN_URL
    print("venvpython_toolchain executableURL", KSLPaths.shared.TOOLCHAIN_URL.path)
    let cmd = """
    source venv/bin/activate
    toolchain \(command.rawValue) \(args.joined(separator: " "))
    """
    //task.arguments = ["eval", "\"\(cmd)\""]
    
    
    task.arguments = arguments
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}
enum PipCommands: String {
    case install
    case uninstall
}

//@discardableResult
//func venv_pip(command: PipCommands, pips: [String]) -> Int32 {
//    var arguments = [command.rawValue]
//    arguments.append(contentsOf: pips)
//    let task = Process()
//    //task.launchPath = venvpython_url.appendingPathComponent("bin/pip3.9").path
//    task.executableURL = VENVPYTHON.appendingPathComponent("bin/pip3")
//    task.arguments = arguments
//    task.launch()
//    task.waitUntilExit()
//    return task.terminationStatus
//}
//
//@discardableResult
//func toolchain_venv(path: String, command: String, args: [String]) -> Int32 {
//    //print("toolchain_venv running")
//    //var targs: [String] = ["-c","source venv/bin/activate", "&&", "python --version"]
//    let targs = ["-c", """
//    echo "path: \(path)"
//    source \(path)/venv/bin/activate
//    toolchain \(command) \(args.joined(separator: " "))
//    """]
//    let debug_args = ["-c", """
//    #source \(path)/venv/bin/activate
//    #toolchain \(command) \(args.joined(separator: " "))
//    echo "path: \(path)"
//    echo $PWD
//    """]
//    //targs.append(contentsOf: args)
//    let task = Process()
//    task.launchPath = "/bin/zsh"
//    task.arguments = targs
    //task.standardOutput = nil
    //task.terminationHandler = terminationHandler
    
//    let outputPipe = Pipe()
//    //task.standardOutput = outputPipe
//    //task.standardError = outputPipe
//    let outputHandle = outputPipe.fileHandleForReading
//    outputHandle.waitForDataInBackgroundAndNotify()
//    var start_write = false
//    var output = ""
//    let debug = false
    
//    outputHandle.readabilityHandler = { pipe in
//        var currentInfo = ""
//        guard let _currentInfo = String(data: pipe.availableData[...7], encoding: .utf8) else {return}
//        currentInfo = _currentInfo
//        guard let currentOutput = String(data: pipe.availableData, encoding: .utf8) else {
//            print("Error decoding data: \(pipe.availableData)")
//            return
//        }
//        print(currentInfo)
//        if currentOutput.contains("Error compiling Cython file:" ) {
//            print(currentOutput)
//            start_write = true
//        }
//
//
//        if currentOutput.contains("  STDERR:") {return}
//        guard !currentOutput.isEmpty else {
//            return
//        }
//
//        if start_write {output = output + currentOutput}
//
//
//            if debug {
//                DispatchQueue.main.async {
//                    print(currentOutput)
//                }
//            }
//    }
    //let pipe = Pipe()
    //task.standardOutput = pipe
    //print(pipe.fileHandleForReading)
//    task.launch()
//    task.waitUntilExit()
//    //print(output)
//    return task.terminationStatus
//}

@discardableResult
func pip_install(arg: String) -> Int32 {
    let task = Process()
    task.executableURL = KSLPaths.shared.ROOT_URL.appendingPathComponent("venv/bin/pip")
    //task.launchPath = "venv/bin/pip"
    task.arguments = ["install",arg]
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

@discardableResult
func pip_uninstall(arg: String) -> Int32 {
    let task = Process()
    task.launchPath = "venv/bin/pip"
    task.arguments = ["uninstall","-y",arg]
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

enum InternalPythons: String {
    case host = "hostpython"
    case venv = "venvpython"
}
@discardableResult
func internal_pip_install(arg: String, target: InternalPythons) -> Int32 {
    let task = Process()
    switch target {
    case .host:
        task.executableURL = KSLPaths.shared.HOSTPYTHON_APP.appendingPathComponent("bin/pip3")
    case .venv:
        task.executableURL = KSLPaths.shared.VENVPYTHON_APP.appendingPathComponent("bin/pip3")
    }
    //task.launchPath = "system_files/\(target.rawValue)/bin/pip3"
    task.arguments = ["install",arg]
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

@discardableResult
func create_venv(python: String) -> Int32 {
    let task = Process()
    //task.launchPath = python
    let paths = KSLPaths.shared
    task.executableURL = paths.VENVPYTHON_APP_EXE
    print("create_venv \(paths.VENVPYTHON_EXE.path)")
    //print("creating venv with \(python)")
    //task.launchPath = "/usr/local/bin/python3"
    task.arguments = ["-m","venv", paths.ROOT_URL.appendingPathComponent("venv").path]
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}


func promp_python_install_commands() -> String {
    var core_count = "8"
    try! launch(path: "/bin/zsh", arguments: ["nproc"]) { r, data in
        core_count = String(data: data, encoding: .utf8)!
    }
    let path = ""
    return """
    cd \(path)/temp
    ./configure --without-static-libpython --prefix=\(path)/python
    #make altinstall
    cores =$(nproc)
    make
    make install -j$\(core_count)
    """
}

@discardableResult
func InstallOpenSSL(url: URL, file: String) -> Int32 {
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
    let task = Process()
    //task.launchPath = "/bin/zsh"
    task.executableURL = ZSH
    task.arguments = targs

    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

@discardableResult
func BuildPython(version: String, target_folder: InternalPythons) -> Int32 {
    let path = KSLPaths.shared.SYSTEM_FILES.path
    let python_folder = KSLPaths.shared.SYSTEM_FILES.appendingPathComponent(target_folder.rawValue).path
    let file = "Python-\(version)"
    let task = Process()
    //task.launchPath = python
    let targs = ["-c", """
        echo "path: \(path)/\(file)"
        cd \(path)
        tar -xf \(path)/\(file).tgz
        rm \(path)/\(file).tgz
        cd \(file)
        ./configure -q --without-static-libpython --with-openssl=\(path)/openssl --prefix=\(python_folder)
        #make altinstall
        make -j$(nproc)
        make install
        rm -R -f \(path)/\(file)
        """]
        //task.launchPath = "/bin/zsh"
    task.executableURL = ZSH
    task.arguments = targs

    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

//@discardableResult
//func build_python_install(path: String) -> Int32 {
//    let task = Process()
//    //task.launchPath = python
//    task.launchPath = "/bin/zsh"
//    task.arguments = ["temp/altinstall"]
//    task.launch()
//    task.waitUntilExit()
//    return task.terminationStatus
//}


func initHostPythonSitePackages() {
    let new_pbxproj = "git+https://github.com/psychowasp/mod-pbxproj"
    let old_pbxproj = "git+https://github.com/garrik/mod-pbxproj@develop"
    for pip in ["wheel","cython","astor",new_pbxproj] {
        internal_pip_install(arg: pip, target: .host)
    }
    
    for pip in ["wheel","cython",new_pbxproj ,"git+https://github.com/kivy/kivy-ios.git"] {
        internal_pip_install(arg: pip, target: .venv)
    }
}


func InitWorkingFolder(python_path: String!, python_version: String!) {
    var py_path = "/usr/local/bin/python3"
    var py_version_major = "3.9"
    var py_version_full = "3.9.9"
    if let ppath = python_path {py_path = ppath}
    if let pversion = python_version {
        py_version_full = pversion
        py_version_major = python_version.split(separator: ".")[0...1].joined(separator: ".")
    }
    let paths = KSLPaths.shared
//    if !checkPythonVersion() {
//        downloadPython()
//        return
//    }
    //return
    let support_path = paths.SYSTEM_FILES.appendingPathComponent("project_support_files").path//"system_files/project_support_files"
    let KivySwiftSupportFiles = paths.SYSTEM_FILES.appendingPathComponent("KivySwiftSupportFiles").path//"system_files/KivySwiftSupportFiles"
    //try! Process().clone(repo: "https://github.com/psychowasp/KivySwiftLink.git", path: "KivySwiftLinkPack")
    let branch = AppVersion.release_state == .release ? "main" : "testing"
    try! Process().clone(repo: ["--branch", branch, "https://github.com/psychowasp/KivySwiftSupportFiles.git"], path: KivySwiftSupportFiles)
    
    create_venv(python: py_path)
    //https://github.com/kivy/kivy-ios
    //https://github.com/meow464/kivy-ios.git@custom_recipes
    //return
    for pip in ["wheel","cython", "kivy"] {
        pip_install(arg: pip)
    }
    //copyItem(from: "KivySwiftSupportFiles/toolchain.py", to: "venv/lib/python3.9/site-packages/kivy_ios/toolchain.py", force: true)
    
    //copyItem(from: "KivySwiftSupportFiles/swift_types.py", to: "venv/lib/python\(py_version_major)/site-packages/swift_types.py")

    copyItem(from: "\(KivySwiftSupportFiles)/project_support_files", to: support_path, force: true)
    //copyItem(from: "KivySwiftSupportFiles/pythoncall_builder.py", to: "venv/lib/python\(py_version_major)/site-packages/pythoncall_builder.py")
    
    copyItem(from: "\(KivySwiftSupportFiles)/pythoncall_builder.py", to: paths.HOSTPYTHON_SITE_PACKAGES.appendingPathComponent("pythoncall_builder.py").path, force: true)
    
    copyItem(from: "\(KivySwiftSupportFiles)/swift_types.pyi", to: paths.VENV_SITE_PACKAGES.appendingPathComponent("swift_types.pyi").path, force: true)
    //createFolder(name: "wrapper_sources")
    createFolder(name: paths.WRAPPER_BUILDS.path) //wrapper_builds
    //createFolder(name: "wrapper_headers")
    //createFolder(name: "wrapper_headers/c")
    //createFolder(name: "wrapper_headers/swift")
    //copyItem(from: "\(KivySwiftSupportFiles)/project_support_files/wrapper_typedefs.h", to: "wrapper_headers/c/wrapper_typedefs.h")
    
    let fileman = FileManager()
    do {
        //try fileman.removeItem(atPath: "KivySwiftLink")
        try fileman.removeItem(atPath: KivySwiftSupportFiles)
    } catch {
        print("cant delete folders")
    }
    //_toolchain(path: root_path, command: .build, args: ["python3", "kivy"])
    //venvpython_toolchain(command: .build, args: ["python3", "kivy"])
    //toolchain(command: "build", args: ["kivy"])
    try! moveLibToSystem_Files()
//    let proj_settings = ProjectHandler.shared
//    proj_settings.current_python_path = py_path
//    proj_settings.current_python_version = py_version_full.split(separator: ".").map{Int($0)!}
//    proj_settings.save()
//    print("Setup done")

}

func UpdateWorkingFolder() {
    let fm = FileManager()
    if fm.fileExists(atPath: "KivySwiftSupportFiles") {try! fm.removeItem(atPath: "KivySwiftSupportFiles")}
    
    try! Process().clone(repo: ["https://github.com/psychowasp/KivySwiftSupportFiles.git"], path: "KivySwiftSupportFiles")
//    let proj_settings = ProjectHandler.shared
//    let py_major = proj_settings.python_major_version
//    //copyItem(from: "KivySwiftSupportFiles/swift_types.py", to: "venv/lib/python3.9/site-packages/swift_types.py",force: true)
//
//    copyItem(from: "KivySwiftSupportFiles/project_support_files", to: "project_support_files",force: true)
//    copyItem(from: "KivySwiftSupportFiles/pythoncall_builder.py", to: "venv/lib/python\(py_major)/site-packages/pythoncall_builder.py", force: true)
//    copyItem(from: "KivySwiftSupportFiles/swift_types.pyi", to: "venv/lib/python\(py_major)/site-packages/swift_types.pyi", force: true)
//    if !fm.fileExists(atPath: "wrapper_headers/c") {createFolder(name: "wrapper_headers/c")}
//    if !fm.fileExists(atPath: "wrapper_headers/swift") {createFolder(name: "wrapper_headers/swift")}
//    copyItem(from: "KivySwiftSupportFiles/project_support_files/wrapper_typedefs.h", to: "wrapper_headers/c/wrapper_typedefs.h", force: true)
//    do {
//        try fm.removeItem(atPath: "KivySwiftSupportFiles")
//    } catch {
//        print("cant delete folders")
//    }
}


func update_project(files: [String]) {
//    let db = ProjectHandler.shared
//    if let p = db.global.current {
//        let project = ProjectManager(title: p.name)
//        project.update_frameworks_lib_a()
//        project.update_bridging_header(keys: files)
//    }
//    else {
//        print("No Project Selected - use 'ksl project select <project name (no -ios)>'")
//    }

}

func resourceURL(to path: String) -> URL? {
    return URL(string: path, relativeTo: Bundle.main.resourceURL)
}

func buildWrapper(name: String) {
//    let p_handler = ProjectHandler.shared
//    if let project = p_handler.current_project {
//        print("building \(name)")
//
//        BuildWrapperFile(py_name: name, project: project) { result, files in
//            if result {
//
//                update_project(files: files)
//            } else {
//                print("\(name) failed")
//                return
//            }
//        }
//
////        if BuildWrapperFile(root_path: root_path, site_path: site_path, py_name: name ) {
////            update_project(files: [name])
////        } else {
////            return
////        }
//        print("Done")
//    } else {
//        print("No Project Selected - use 'ksl project select <project name (no -ios)>'")
//    }
}



//func updateWrappers(path: String! = nil) {
//    let fm = FileManager()
//    var wrapper_sources: URL
//    var lib_sources: URL
//    //var rpath: String
//    //var spath: String
//    guard let project = ProjectHandler.shared.current_project else { return }
//
//    if let p = path {
//        wrapper_sources = URL(fileURLWithPath: p).appendingPathComponent("wrapper_sources")
//        lib_sources = URL(fileURLWithPath: p).appendingPathComponent("dist/lib")
//        //rpath = p
//        //spath = URL(fileURLWithPath: p).appendingPathComponent("/venv/lib/python3.9/site-packages").path
//    } else {
//        wrapper_sources = URL(fileURLWithPath: fm.currentDirectoryPath).appendingPathComponent("wrapper_sources")
//        lib_sources = URL(fileURLWithPath: fm.currentDirectoryPath).appendingPathComponent("dist/lib")
//        //rpath = ROOT_URL.path
//    }
//    let wrapper_files = try! fm.contentsOfDirectory(at: wrapper_sources, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
//
//    for file in wrapper_files {
//        let file_date = fileModificationDate(url: file)!
//        let filename = file.path.fileName()
//        let lib_file = lib_sources.appendingPathComponent("lib\(file.path.fileName()).a")
//        if fm.fileExists(atPath: lib_file.path) {
//            let lib_file_date = fileModificationDate(url: lib_file)!
//            if lib_file_date < file_date {
//                print(filename)
//                BuildWrapperFile(py_name: filename, project: project, { r, _ in
//                    if r { print("\(filename) was succesful")} else {
//                        print("\(filename) failed")
//                    }
//                })
//            }
//        } else {
//            //print(filename)
//            //BuildWrapperFile(root_path: rpath, site_path: spath, py_name: filename )
//        }
//
//    }
//}

func initLibToSystem_Files() throws {
    let paths = KSLPaths.shared
    let dst = paths.SYSTEM_FILES.appendingPathComponent("lib", isDirectory: true)
    let root_lib = paths.ROOT_LIB
    let check_url = paths.ROOTPYTHON_CHECK_PATH
    if FM.fileExists(atPath: dst.path) {
        try FM.removeItem(at: dst)
    }
    if !FM.fileExists(atPath: dst.path) {
        try FM.createDirectory(at: dst, withIntermediateDirectories: true)
    }
    if !FM.fileExists(atPath: check_url.path) {
        try FM.createDirectory(at: check_url, withIntermediateDirectories: true)
    }
    //try FM.moveItem(at: KSLPaths.shared.ROOT_LIB, to: dst)
    try FM.createSymbolicLink(at: root_lib, withDestinationURL: dst)
}

func moveLibToSystem_Files() throws {
    let dst = KSLPaths.shared.SYSTEM_FILES.appendingPathComponent("lib", isDirectory: true)
    if FM.fileExists(atPath: dst.path) {
        try FM.removeItem(at: dst)
    }
    
    try FM.moveItem(at: KSLPaths.shared.ROOT_LIB, to: dst)
    try FM.createSymbolicLink(at: KSLPaths.shared.ROOT_LIB, withDestinationURL: dst)
}

func linkLibToBackToSystem() throws {
    let paths = KSLPaths.shared
    let root_lib = paths.ROOT_LIB
    let dst = paths.SYSTEM_FILES.appendingPathComponent("lib", isDirectory: true)
    if FM.fileExists(atPath: root_lib.path) {
        try FM.removeItem(at: root_lib)
    }
    //try FM.moveItem(at: KSLPaths.shared.ROOT_LIB, to: dst)
    try FM.createSymbolicLink(at: root_lib, withDestinationURL: dst)
}

func copySystemLibToProject(proj: URL) {
    let src = KSLPaths.shared.SYSTEM_FILES.appendingPathComponent("lib", isDirectory: true).path
    copyItem(
        from: src,
        to: proj.appendingPathComponent("lib", isDirectory: true).path
    )
}

//func hardLinkProjectLib(ksl_proj: KslProject) throws {
//    print("checking hard link path exist", KSLPaths.shared.ROOT_LIB.path, FM.fileExists(atPath: KSLPaths.shared.ROOT_LIB.path) )
//    //if FM.fileExists(atPath: ROOT_LIB.path) {
//    do {
//        try FM.removeItem(at: KSLPaths.shared.ROOT_LIB)
//    }
//        
//    
//    //}
//    try FM.createSymbolicLink(at: KSLPaths.shared.ROOT_LIB, withDestinationURL: ksl_proj.python_lib)
//    //try FM.linkItem(at: ksl_proj.python_lib, to: ROOT_LIB)
//}
