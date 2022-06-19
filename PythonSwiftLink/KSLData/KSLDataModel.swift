//
//  KSLDataModel.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 22/05/2022.
//

import Foundation
import Combine
import SwiftUI

import SwiftyBeaver
import RealmSwift

var _realm: Realm? = nil
var realm_services = RealmService()
enum GithubPathType: String, Decodable {
    case dir
    case file
}

//class KivyRecipeData: Decodable, ObservableObject {

enum RecipeStatus: Int, PersistableEnum {
    case bulld
    case builded
    case uninstall
    case ready_to_build
    case disabled
}

class KivyRecipeData: Object, Decodable, Identifiable {
    
    let id = UUID()
    
    @Persisted var name: String
    @Persisted var path: String
    @Persisted var sha: String
    @Persisted var url: String
    @Persisted var git_url: String
    //@Persisted var type: GithubPathType
    
    
    
    
    
    
    
    @Persisted var status: RecipeStatus = .ready_to_build
    
    @Published var selected: Bool = false
    @Persisted var last_selection: Bool = false
    
    
    static func ==(lhs: KivyRecipeData, rhs: KivyRecipeData) -> Bool {
        lhs.sha == rhs.sha
    }

    private enum CodingKeys: CodingKey {
        case name
        case path
        case sha
        case url
        case html_url
        case git_url
        //case download_url
        case type
        
        }
    
    
    
    @Persisted private var private_type: String = GithubPathType.file.rawValue
    
    private var subscriptions = Set<AnyCancellable>()
    
    var type: GithubPathType {
        get { return GithubPathType(rawValue: private_type)! }
        set { private_type = newValue.rawValue }
    }
    
    
    
    override init() {
        name = "a recipe"
        path = ""
        sha = ""
        url = "https://kivy.org"
        git_url = "https://kivy.org"
        //type = .dir
        private_type = GithubPathType.dir.rawValue
        
    }
    
    
    
    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        path = try c.decode(String.self, forKey: .path)
        sha = try c.decode(String.self, forKey: .sha)
        url = try c.decode(String.self, forKey: .url)
        git_url = try c.decode(String.self, forKey: .url)
        private_type = try c.decode(String.self, forKey: .type)
        //type = try c.decode(GithubPathType.self, forKey: .type)
        super.init()
        
    }
    
    func selectSync() {
        selected = last_selection
        $selected.sink { [unowned self] state in
            if state != self.last_selection {
                //print("selected.sink")
                //if let r = _realm {
                    try! realm_shared.write {
                        //print("writing to realm")
                        self.last_selection = state
                    }
                //}
                
            }
        }.store(in: &subscriptions)
    }
    
}


class WorkingFolder: Codable, Identifiable, ObservableObject, Hashable {
    
    
    var id = UUID()
    
    var fileURL: URL
    @Published var path: String
    @Published var last_project: String = ""
    
    private enum CodingKeys: CodingKey {
        case path
        case last_project
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(path, forKey: .path)
        if last_project != "" {
            try c.encode(last_project, forKey: .last_project)
        }
    }
    
    init(url: URL) {
        self.fileURL = url
        self.path = url.path
    }
    
    init(path: String) {
        self.fileURL = URL(fileURLWithPath: path)
        self.path = path
    }
    
    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let _path = try c.decode(String.self, forKey: .path)
        path = _path
        fileURL = URL(fileURLWithPath: _path)
        if c.contains(.last_project) {
            last_project = try c.decode(String.self, forKey: .last_project)
        }
        
    }
    
    static func == (lhs: WorkingFolder, rhs: WorkingFolder) -> Bool {
        lhs.path == rhs.path
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
}


class KSLDataModel: ObservableObject {
    
    static let shared = KSLDataModel(preview: false)
    
    @AppStorage("recent_folders") var recent_folders_data: Data?
    @AppStorage("last_folder_path") var last_folder_path: String?
    
    
    @Published var main_config_needed = false
    
    @Published var recentFolders: [WorkingFolder] = []
    @Published var recentFolder: WorkingFolder = WorkingFolder(path: "")
    
    //@Published var recentFolders_ : [WorkingFolderData] = []
    
    let setup_log = SwiftyBeaver.self
    //let build_log = SwiftyBeaver.self
    
    @Published var setup_path: URL!
    @Published var setup_path_config_missing: Bool = true
    @Published var no_config_alert: Bool = false
    @Published var recipes: [KivyRecipeData] = []
    var selectedRecipes: [KivyRecipeData] {
        recipes.filter{$0.selected}
    }
    //@Published var logData = LogData()
    
    @Published var setupLogData = KSLViewLogger()
    
    @Published var setupIsRunning = false
    
    @Published var projects_data = KSLProjects()
    
    var external_host_python = false
    var external_venv_python = false
    
    let workingFolderInput = PassthroughSubject<URL,Never>()
    let logInput = PassthroughSubject<String, Never>()
    
    var subscriptions = Set<AnyCancellable>()
    
    init(preview: Bool = false) {
        
        print(KSLPaths.shared.HOSTPYTHON_APP)
        
        if preview {
            
            
        } else {
//            let recipe_url = URL(string: "https://api.github.com/repos/kivy/kivy-ios/contents/kivy_ios/recipes?ref=master")!
//            recipes_data = try! Data(contentsOf: recipe_url)
            let app_dir = KSLPaths.shared.APPLICATION_SUPPORT_FOLDER
            
            for check in ["openssl","hostpython","venvpython","KivySwiftSupportFiles"].map({app_dir.appendingPathComponent($0)}) {
                if !FM.fileExists(atPath: check.path) {
                    mainConfig()
                    break
                }
            }
//            if !FM.fileExists(atPath: KSLPaths.shared.HOSTPYTHON_APP.path) {
//                print("App Pythons Not Build")
//
//
//            }
        }
//        //let url = URL(string: "https://api.github.com/repos/psychowasp/KivySwiftLink/releases")!
//            //let data = try! Data.init(contentsOf: recipe_url)
//        if let app_config = app_realm.objects(GlobalAppData.self).first {
//            recentFolders_.append(contentsOf: app_config.recent_folders)
//        }
        
        if let rdata = recent_folders_data {
            let decoder = JSONDecoder()
            do {
                let _recent_folders = try decoder.decode([WorkingFolder].self, from: rdata)
                recentFolders = _recent_folders
            } catch let err {
                print(err.localizedDescription)
            }
            
        }
        if let last = last_folder_path {
            if let recentfolder = recentFolders.first(where: { $0.path == last }) {
                recentFolder = recentfolder
                print("ksldatamodel init",recentfolder,recentfolder.path)
            }
            
        }
        
        workingFolderInput.sink { [unowned self] url in
            
            //build_log.removeAllDestinations()
            setup_path = url
            let paths = KSLPaths.shared
            paths._root = url
            if FM.fileExists(atPath: paths.SYSTEM_FILES.path) {
                //createFolder(name: paths.SYSTEM_FILES.path)
                paths._root = url
                reload_realm()
                setup_path_config_missing = false
                
            } else {
                setup_path_config_missing = true
                no_config_alert = true
            }
            
            if let folder = recentFolders.first(where: { $0.fileURL == url}) {
                last_folder_path = folder.path
                recentFolder = folder
                
                print(last_folder_path)
                
                projects_data.last_projectInput.send(folder.last_project)
                
            } else {
                recentFolders.insert(WorkingFolder(url: url), at: 0)
                if recentFolders.count > 10 {
                    recentFolders.removeLast()
                }
                
                let encoder = JSONEncoder()
                recent_folders_data = try! encoder.encode(recentFolders)
                
//                let wfolder = WorkingFolderData(path: url.path)
//                recentFolders_.append(wfolder)
            }
            
            //projects_data.reload_pbxproj()
            
            //last_folder_path = url.path
            
            //build_log.addDestination(build_file)
            //_realm.configuration.fileURL = KSLPaths.shared.SYSTEM_FILES.appendingPathComponent("global_config.realm")
            
        }.store(in: &subscriptions)
        
        $recentFolder.sink { f in
            print("$recentFolder sink", f.path)
            //projects_data.current_project = 
        }.store(in: &subscriptions)
        
        var log_count = 0
        logInput
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] log_text in
                print(log_text)
                setupLogData.current_logs.append(LogLine(id: log_count, text: log_text))
                //log.debug(log_text)
                log_count += 1
            }.store(in: &subscriptions)
        
        projects_data.$current_project.sink { [unowned self] proj in
            print("sink $current_project", proj)
            recentFolder.last_project = proj.name
            let encoder = JSONEncoder()
            recent_folders_data = try! encoder.encode(recentFolders)
        }.store(in: &subscriptions)
        
        projects_data.reload_pbxproj()
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
    
    
    func newConfig() {
        let paths = KSLPaths.shared
        if !FM.fileExists(atPath: paths.SYSTEM_FILES.path) {
            try! FM.createDirectory(at: paths.SYSTEM_FILES, withIntermediateDirectories: true)
        }
        reload_realm()
    }
    
    func reload_realm() {
        let paths = KSLPaths.shared

        let realm_path = paths.SYSTEM_FILES.appendingPathComponent("config.realm")
        var config = Realm.Configuration(fileURL: realm_path)
        config.schemaVersion = 1004
        config.objectTypes = [KivyRecipeData.self, KSLProjectData.self, PipData.self, KSLWrapperBuild.self, KSLWrapperData.self, CodeFile.self]
        _realm = try! Realm(configuration: config, queue: .main)
        guard let _realm = _realm else { return }
        let recipe_objs = _realm.objects(KivyRecipeData.self)
        
        
        if recipe_objs.count == 0 {
            var recipes_data: Data
            guard let asset = NSDataAsset(name: "recipes", bundle: .main) else { fatalError() }
            recipes_data = asset.data
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let _recipes = try! decoder.decode([KivyRecipeData].self, from: recipes_data)
            let filtered_recipes = _recipes.filter{
                $0.type == .dir && ![
                    "freetype",
                    "host_setuptools",
                    "host_setuptools3",
                    "ios",
                    "kivy",
                    "pyobjus",
                    "python3",
                    "hostopenssl",
                    "hostpython3",
                    "libffi",
                    "sdl2_image",
                    "sdl2_mixer",
                    "sdl2_ttf",
                    "sdl2",
                    "openssl"
                ].contains($0.name)
                
            }
            
            try! _realm.write {
                _realm.add(filtered_recipes)
            }
            recipes = Array(_realm.objects(KivyRecipeData.self))
        } else {
            recipes = Array(_realm.objects(KivyRecipeData.self))
        }
//
        projects_data.sync()
        for r in recipes {
            r.selectSync()
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
    
    func run_setup() {
        print("running setup")
        new_log(name: "setup")
        let extra_recipes = selectedRecipes.map{$0.name}
        DispatchQueue.global().async { [unowned self] in
            //BuildPythons()
            InitWorkingFolder(python_path: nil, python_version: nil, extra_recipes: extra_recipes)
            print("Adding extra recipe:")
            
//            let selected_recipes = recipes.filter{$0.selected}
//            for r in selected_recipes {
//                print(r.name)
//            }
            DispatchQueue.main.async {
                setupIsRunning = false
            }
            
        }
        
        
        
        
    }
    
    
    func loadRecipeDats() {
        guard let recipe_url =  URL(string: "https://api.github.com/repos/kivy/kivy-ios/contents/kivy_ios/recipes?ref=master") else { fatalError() }
        

            let task = URLSession.shared.dataTask(with: recipe_url) { [unowned self] data, response, err in
                guard let data = data else { fatalError() }
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                recipes = try! decoder.decode([KivyRecipeData].self, from: data)
            }
            task.resume()

    }
    
    
    var script: NSAppleScript = {
        let script = NSAppleScript(source: """
            tell application "Terminal"
                activate
                set shell to do script "echo 1" in window 1
                do script "echo 2" in shell
                do script "echo 3" in shell
            end tell
            """
        )!
        let success = script.compileAndReturnError(nil)
        assert(success)
        return script
    }()
    
}




func selectFolder(_ complete: @escaping ( (URL)->Void )) {
    
    
    let folderChooserPoint = CGPoint(x: 0, y: 0)
    let folderChooserSize = CGSize(width: 500, height: 600)
    let folderChooserRectangle = CGRect(origin: folderChooserPoint, size: folderChooserSize)
    let folderPicker = NSOpenPanel(contentRect: folderChooserRectangle, styleMask: .utilityWindow, backing: .buffered, defer: true)
    
    folderPicker.canChooseDirectories = true
    folderPicker.canChooseFiles = false
    folderPicker.allowsMultipleSelection = false
    folderPicker.canCreateDirectories = true
    folderPicker.canDownloadUbiquitousContents = true
    folderPicker.canResolveUbiquitousConflicts = true
    
    folderPicker.begin { response in
        switch response {
        case .OK:
            //print(folderPicker.urls)
            if let url = folderPicker.url {
                complete(url)
            }
        case .cancel:
            print("canceled")
            
        default:
            print(response)
        }
        
        
    }
}
func selectFile_Folder(_ complete: @escaping ( (URL)->Void )) {
    
    
    let folderChooserPoint = CGPoint(x: 0, y: 0)
    let folderChooserSize = CGSize(width: 500, height: 600)
    let folderChooserRectangle = CGRect(origin: folderChooserPoint, size: folderChooserSize)
    let folderPicker = NSOpenPanel(contentRect: folderChooserRectangle, styleMask: .utilityWindow, backing: .buffered, defer: true)
    
    folderPicker.canChooseDirectories = false
    folderPicker.canChooseFiles = true
    folderPicker.allowsMultipleSelection = false
    folderPicker.canDownloadUbiquitousContents = true
    folderPicker.canResolveUbiquitousConflicts = true
    
    folderPicker.begin { response in
        switch response {
        case .OK:
            print(folderPicker.urls)
            if let url = folderPicker.url {
                complete(url)
            }
        case .cancel:
            print("canceled")
            
        default:
            print(response)
        }
        
        
    }
}

func selectFile(_ complete: @escaping ( (URL)->Void )) {
    
    
    let folderChooserPoint = CGPoint(x: 0, y: 0)
    let folderChooserSize = CGSize(width: 500, height: 600)
    let folderChooserRectangle = CGRect(origin: folderChooserPoint, size: folderChooserSize)
    let folderPicker = NSOpenPanel(contentRect: folderChooserRectangle, styleMask: .utilityWindow, backing: .buffered, defer: true)
    
    folderPicker.canChooseDirectories = false
    folderPicker.canChooseFiles = true
    folderPicker.allowsMultipleSelection = false
    folderPicker.canDownloadUbiquitousContents = true
    folderPicker.canResolveUbiquitousConflicts = true
    
    folderPicker.begin { response in
        switch response {
        case .OK:
            print(folderPicker.urls)
            if let url = folderPicker.url {
                complete(url)
            }
        case .cancel:
            print("canceled")
            
        default:
            print(response)
        }
        
        
    }
}
extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
