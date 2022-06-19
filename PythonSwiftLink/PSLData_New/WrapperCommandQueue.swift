//
//  WrapperCommandQueue.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 28/05/2022.
//

import Foundation


class WrapperFile {
    
}

enum WrapperCommandQueueType: String, Decodable {
    
    case remove
    case new
    case update
}


class KSL_WrapperQueueItem: CommandQueueExecutable {
    
    var command_args: [String]
    
    var task_target: URL
    
    var task_directory: URL
    
    var type: WrapperCommandQueueType
    
    var recipe: recipePathHandler_new
    
    
    
    var project: KSLProjectData
    
    
    init(_ type: WrapperCommandQueueType, recipe: recipePathHandler_new, commands: [String]) {
        
        self.type = type
        task_target = ZSH
        task_directory = KSLPaths.shared.ROOT_URL
        
        self.project = recipe.project
        
        //recipe_dir = KSLPaths.shared.WRAPPER_BUILDS
        self.recipe = recipe
        command_args = commands
    }
    
    
    
    static func item(new recipe_name: String, project: KSLProjectData ) -> KSL_WrapperQueueItem {
        let recipe = recipePathHandler_new(name: recipe_name, project: project)
        let _recipe_name = recipe.recipe_name
        let recipe_dir = recipe.recipe_target_dir.path
        let commands = ["-c","""
        echo "Script executed from: ${PWD}"
        . venv/bin/activate
        toolchain build \(_recipe_name) --add-custom-recipe \(recipe_dir)
        """]
   
        
        return KSL_WrapperQueueItem(.new, recipe: recipe, commands: commands)
    }
    
    static func item(update recipe_name: String, project: KSLProjectData) -> KSL_WrapperQueueItem {
        
        let recipe = recipePathHandler_new(name: recipe_name, project: project)
        let _recipe_name = recipe.recipe_name
        let recipe_dir = recipe.recipe_target_dir.path
        let commands = ["-c","""
        source venv/bin/activate
        toolchain clean \(_recipe_name) --add-custom-recipe \(recipe_dir)
        toolchain build \(_recipe_name) --add-custom-recipe \(recipe_dir)
        """]
        
        
        return KSL_WrapperQueueItem(.update, recipe: recipe, commands: commands)
    }
    
    static func item(remove recipe_name: String, project: KSLProjectData) -> KSL_WrapperQueueItem {
        let recipe = recipePathHandler_new(name: recipe_name, project: project)
        let _recipe_name = recipe.recipe_name
        let recipe_dir = recipe.recipe_target_dir.path
        let commands = ["-c","""
        source venv/bin/activate
        toolchain clean \(_recipe_name) --add-custom-recipe \(recipe_dir)
        """]
        
        
        return KSL_WrapperQueueItem(.remove, recipe: recipe, commands: commands)
    }
    
    
    func runTask(_ logger: @escaping ((String) -> Void)) throws {
        
        switch type {
        case .remove:
            wrapperTask(
                target: task_target,
                directory: task_directory,
                args: command_args,
                logger
            )
            try recipe.cleanRecipe()
        case .new:
            try recipe.makeRecipe()
            print("running task")
            wrapperTask(
                target: task_target,
                directory: task_directory,
                args: command_args,
                logger
            )
            
            try! FM.createDirectory(at: recipe.c_headers, withIntermediateDirectories: true, attributes: nil)
            copyCheaders(from: recipe.h_files, to: recipe.c_headers.path, force: true)
            if let wrapper = project.wrapper_builds.first(where: {$0.name == recipe.name})?.thaw() {
                try! realm_shared.write {
                    wrapper.status = .up2date
                }
            }
            //recipe.updateBridgeFile()
        case .update:
            try recipe.makeRecipe()
            print("running task")
            wrapperTask(
                target: task_target,
                directory: task_directory,
                args: command_args,
                logger
            )
            
            copyCheaders(from: recipe.h_files, to: recipe.c_headers.path, force: true)
        }
        recipe.updateBridgeFile()
        
 
        
    }
    
    
    
}


class WrapperCommandQueue {
    
    static let shared = WrapperCommandQueue()
    
    private var queue: [CommandQueueExecutable] = []
 
    @discardableResult
    func handleQueue() -> Int {
        let queue_size = queue.count
        for task in queue {
            
            try! task.runTask { log in
                print(log)
            }
        }
        
        queue.removeAll()
        return queue_size
    }
    
    func Task(add item: CommandQueueExecutable) {
        queue.append(item)
    }
    
}

class recipePathHandler_new {
    private var url: URL?
    private var use_project_folder = false
    private var asDir = false
    let name: String
    let project: KSLProjectData
    
    private var src_files: [(name: String, url: URL)] = []
    var result_files: [String] = []
    
    init(name: String, project: KSLProjectData) {
        print("\niniting recipePathHandler\n")
        self.name = name
        self.project = project
        
        checkWrapperPath { url, asDir in
            self.url = url
            self.use_project_folder = true
            self.asDir = asDir
        }
        
        //guard let url = url else { fatalError("wrapper \(name) not found")}
//        print("\tname: \(name)")
//        print("\tproject name:\(project.name)")
//        print("\tuse_project_folder: \(use_project_folder)")
//        print("\tbuild is dir instead of .py: \(asDir)")
//        print("\tfinal recipe name: \(recipe_name)")
//        print("\trecipe_dir: \(url.path)")
//        print("\tksl project path: \(project.path)")
//        print("-------------------------------------------\n")
    }
    
    
    var recipe_name: String { "\(project.name)_\(name)" }
    
    var recipe_src: URL { return url! }
    
    var recipe_target_dir: URL { KSLPaths.shared.WRAPPER_BUILDS.appendingPathComponent("\(project.name)/\(recipe_name)", isDirectory: true) }
    
    var recipe_target_src_dir: URL { recipe_target_dir.appendingPathComponent("src", isDirectory: true) }
    var swift_headers: URL {
        if folder_mode {
            return project.swift_headers.appendingPathComponent(name, isDirectory: true)
        }
        return project.swift_headers
    }
    
    var c_headers: URL {
        if folder_mode {
            return project.c_headers.appendingPathComponent(name, isDirectory: true)
        }
        return project.c_headers
    }
    
    var folder_mode: Bool { asDir }
    
    
    var pyxfiles: [URL] = []
    var h_files: [URL] = []
    
    var swift_files: [URL] = []
    
    
    private func checkWrapperPath(_ complete: @escaping (_ url: URL?, _ asDir: Bool)->Void) {
        let proj_dir = project.url
        if FM.fileExists(atPath: proj_dir.path) {
            
            let src_path = project.wrapper_src
            //print("checkWrapperPath: ",src_path)
            if FM.fileExists(atPath: src_path.path) {
                
                let wrap_path = src_path.appendingPathComponent(name)
                if FM.fileExists(atPath: wrap_path.path) {
                    if wrap_path.isDirectory {
                        complete(wrap_path,true)
                        return
                    }
                }
                let wrap_file = wrap_path.appendingPathExtension("py")
                print("wrap_file mode: \(wrap_file.path)")
                if FM.fileExists(atPath: wrap_file.path) {
                    complete(wrap_file, false)
                    return
                }
                //if FM.fileExists(atPath: wrap_file.path)
            }
        }
        
        complete(nil, false)
    }
    
    
    
    func makeRecipe() throws {
        guard let url = url else { fatalError("no url")}
        
        let recipe_target_src = recipe_target_dir.appendingPathComponent("src", isDirectory: true)
        let c_headers = project.c_headers
        
        
        if FM.fileExists(atPath: recipe_target_src.path) {
            try! FM.removeItem(at: recipe_target_src)
        }
        //if !FM.fileExists(atPath: recipe_target_src.path) {
        try FM.createDirectory(at: recipe_target_src, withIntermediateDirectories: true, attributes: nil)
        //}
        var result_files: [String] = []
        let setup_file = recipe_target_src.appendingPathComponent("setup.py")
        if folder_mode {
            //print("folder mode: \(url.path)")
            let files = try! FM.contentsOfDirectory(atPath: url.path)
            for f in files {
                if f == ".DS_Store" { continue }
                let f_url = url.appendingPathComponent(f)
                let f_name = URL(string: f)!.deletingPathExtension().path
                //print(f,f_url.path)
                src_files.append((f_name,f_url))
                result_files.append("\(name)/\(f_name)")
            }
            
            
            try createSetupPy_Module(title: name, files: src_files.map{$0.name}).write(to: setup_file, atomically: true, encoding: .utf8)
        } else {
            //print("file mode: \(url.path)")
            src_files.append( (name, url) )
            result_files.append(name)
            
            try createSetupPy(title: name).write(to: setup_file, atomically: true, encoding: .utf8)
        }
        
        try createRecipe(title: recipe_name).write(to: recipe_target_dir.appendingPathComponent("__init__.py"), atomically: true, encoding: .utf8)
        if !FM.fileExists(atPath: swift_headers.path) {
            //print("\(swift_headers.path) dont exist")
            try FM.createDirectory(at: swift_headers, withIntermediateDirectories: true, attributes: nil)
        }
        try createWrapFiles()
        
    }
    
    func cleanRecipe() throws {
        guard let url = url else { return }
        print(name)
        if let wrapper = project.wrapper_builds.first(where: {$0.name == name})?.thaw() {
            if let wrap_file = wrapper.firstCodeURL() {
                if FM.fileExists(atPath: wrap_file.path) {
                    try FM.removeItem(at: wrap_file)
                }
                
                if FM.fileExists(atPath: recipe_target_dir.path) {
                    try FM.removeItem(at: recipe_target_dir)
                }
                let swift_header = swift_headers.appendingPathComponent("\(name).swift")
                let c_header = c_headers.appendingPathComponent("\(name).h")
                
                if FM.fileExists(atPath: c_header.path) {
                    try FM.removeItem(at: c_header)
                }
                if FM.fileExists(atPath: swift_header.path) {
                    try FM.removeItem(at: swift_header)
                }
            }
            
            try realm_shared.write {
                realm_shared.delete(wrapper.code_files)
                realm_shared.delete(wrapper)
            }
        }
        //let recipe_target_src = recipe_target_dir.appendingPathComponent("src", isDirectory: true)
        if FM.fileExists(atPath: recipe_target_dir.path) {
            try FM.removeItem(at: recipe_target_dir)
            
        }
        
    }
    
    func updateBridgeFile() {
        print("updating bridge header", project.bridge_header_url)
        let bridge_url = project.bridge_header_url
        if let bridge_string = try? String(contentsOf: bridge_url) {
            let bridge_strings = bridge_string.split(separator: "\n")
            var b_strings = [String.SubSequence]()
            //print(bridge_strings)
            guard let start = bridge_strings.firstIndex(of: "//#Wrappers Start") else {
                return
            }
            //print(start)
            guard let end = bridge_strings.firstIndex(of: "//#Wrappers End")  else { return }
            
            let start_strings = bridge_strings[0...start]
            let end_strings = bridge_strings[(end)...]
            //print(start_strings)
            //print(end_strings)
            //var wrap_strings = bridge_strings[start..<end]//.map{String($0)}
            var wrap_strings = [String.SubSequence]()
            for wrap in project.wrapper_builds.filter({$0.status != .deleted }) {
                wrap_strings.append("#include \"\(wrap.name).h\"")
            }
            
            b_strings.append(contentsOf: start_strings)
            b_strings.append(contentsOf: wrap_strings )
            b_strings.append(contentsOf: end_strings)
            
            let output = b_strings.joined(separator: newLine)
            //print(output)
            try? output.write(to: bridge_url, atomically: true, encoding: .utf8)
        }
        
        
    }
    
    private func createWrapFiles() throws {
        for _file_ in src_files {
            //let afile = _file_.url.deletingPathExtension()
            
            let pyxfile = recipe_target_src_dir.appendingPathComponent("\(_file_.name).pyx")
            pyxfiles.append(pyxfile)
            let h_file = recipe_target_src_dir.appendingPathComponent("_\(_file_.name).h")
            h_files.append(h_file)
            let swift_file = swift_headers.appendingPathComponent("\(_file_.name).swift")
            swift_files.append(swift_file)
            //let wrapper_header = c_headers.appendingPathComponent("\(_file_.name).h")
        
            let py_ast = PythonASTconverter(filename: _file_.name)
            let wrap_module = py_ast.generateModule(root: _file_.url.path, pyi_mode: false)
            print("writing to \(pyxfile)")
            try wrap_module.pyx_new.write(to: pyxfile, atomically: true, encoding: .utf8)
            try wrap_module.h_new.write(to: h_file, atomically: true, encoding: .utf8)
            try wrap_module.swift_new.write(to: swift_file, atomically: true, encoding: .utf8)
            
            
            
            let extra = [
                        "\(if: wrap_module.custom_enums.count != 0, "from enum import IntEnum")",
                        generateGlobalEnums(mod: wrap_module, options: [.python]).replacingOccurrences(of: "    ", with: "\t")
                        ].joined(separator: newLine)
            try py_ast.generatePYI(code: String(contentsOf: _file_.url), extra: extra).write(to: KSLPaths.shared.VENV_SITE_PACKAGES.appendingPathComponent("\(_file_.name).py"), atomically: true, encoding: .utf8)
        }
    }
    
}


@discardableResult
func wrapperTask(target: URL, directory: URL , args: [String], _ logger: @escaping ((String)->Void)) -> Int32 {
    
    let task = Process()
    task.currentDirectoryURL = directory
    
    
    //task.launchPath = "/bin/zsh"
    
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    
    let outputHandler = pipe.fileHandleForReading
    outputHandler.waitForDataInBackgroundAndNotify()

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
    
    
    
    task.executableURL = target
    //print(args.joined(separator: " "))
    task.arguments = args

    task.launch()
    task.waitUntilExit()

    //return task.terminationStatus
    return task.terminationStatus
}
