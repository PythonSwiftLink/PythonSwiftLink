import Foundation
import Combine
import RealmSwift
import Cocoa







class WorkingFolderData: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var path: String
    var path_url: URL { URL(fileURLWithPath: path) }
        
    @Persisted var projects: RealmList<KSLProjectData>
    @Persisted var last_project: KSLProjectData?
    @Persisted var selected_project_id: ObjectId
    
    
    @Persisted var recipes: RealmList<KivyRecipeData>
    var selectedRecipes: [KivyRecipeData] {
        recipes.filter{$0.last_selection}
    }
    
    var last_projectNotificationToken: NotificationToken?
    
    @Published var setupIsDone = false
    
    @Persisted var python_lib_each_project = false
    @Persisted var plep_locked = false
    
    var external_host_python = false
    var external_venv_python = false
    
    let workingFolderInput = PassthroughSubject<URL,Never>()
    let logInput = PassthroughSubject<String, Never>()
    
    var subscriptions = Set<AnyCancellable>()
    
    
    
    convenience init(filePath: URL) {
        self.init()
        
        path = filePath.path
        
        fillRecipes()
        
        
        
    }
    
    
    func handleObserver() {
        last_projectNotificationToken = observe(keyPaths: ["last_project"], { [unowned self] change in
            
            switch change {
            case .error(_):
                break
            case .change(let project , let properties):
                print("folder changes")
                guard let project = last_project else { return }
                print(project.name, project.path)
                if python_lib_each_project {
                    try! hardLinkProjectLib(ksl_proj: project)
                }
                
            case .deleted:
                break
            }
            
        })
    }
    
    
    func cancelObservers() {
        last_projectNotificationToken = nil
    }
    
    func getPipLists() -> [PipManagerList] {
         
        let lists = realm_shared.objects(PipManagerList.self)
        return ResultsToArray(results: lists)
    }
    
    func fillRecipes() {
        
        
        
        let recipe_url = URL(string: "https://api.github.com/repos/kivy/kivy-ios/contents/kivy_ios/recipes?ref=master")!
//        if let url = recipe_url {
            URLSession.shared.dataTask(with: recipe_url) { data, response, error in
                var recipe_data: Data
                if let data = data {
                    recipe_data = data
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print(jsonString)
                    }
                } else {
                    guard let asset = NSDataAsset(name: "recipes", bundle: .main) else { fatalError() }
                    recipe_data = asset.data
                }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let _recipes = try! decoder.decode([KivyRecipeData].self, from: recipe_data)
                
                
                
                
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
                DispatchQueue.main.async {
                    try! realm_shared.write {
                        self.recipes.append(objectsIn: filtered_recipes)
                    }
                }
                
            }.resume()
//        }
        
        
//        if recipe_data == nil {
//            guard let asset = NSDataAsset(name: "recipes", bundle: .main) else { fatalError() }
//            //recipe_data = asset.data
//        }
//        guard let recipe_data = recipe_data else {
//            fatalError()
//        }
        
    }
    
    
    
}

func hardLinkProjectLib(ksl_proj: KSLProjectData) throws {
    print("checking hard link path exist", KSLPaths.shared.ROOT_LIB.path, FM.fileExists(atPath: KSLPaths.shared.ROOT_LIB.path) )
    //if FM.fileExists(atPath: ROOT_LIB.path) {
    do {
        try FM.removeItem(at: KSLPaths.shared.ROOT_LIB)
    }

    do {
        try FM.createSymbolicLink(at: KSLPaths.shared.ROOT_LIB, withDestinationURL: ksl_proj.python_lib)
    }

    //}
    
    //try FM.linkItem(at: ksl_proj.python_lib, to: ROOT_LIB)
}
