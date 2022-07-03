import Foundation
import RealmSwift
import Combine




var preview_pips = PipManagerData.preview_pips()

class PipManagerData: ObservableObject, Encodable {
    
    //private(set) var realm: Realm?
    var realm: Realm?
    
    @Published var pips: Results<PipData>?
    @Published var pip_lists: Results<PipManagerList>?
    @Published var selected_pip_list: PipManagerList?
    //let selectedPipsInput = PassthroughSubject< Set<PipData>, Never>()
    @Published var selectedPips = Set<PipData>()
    
    @Published var selectedPipsInCurList = Set<PipData>()
    
    @Published var duplicatedPipNames = false
    @Published var duplicatedDict = [String: [PipData]]()
    
    @Published var pipEditStates = [ObjectId: Bool]()
    
    weak var rootmodel: KSLDataModelNew?
    
    var avail_pips: [PipData] {
        guard let pips = pips else {
            return []
        }
        return pips.map{$0}.filter( {!$0.deleted} )
        
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {

//        $pips.sink { [unowned self] new in
//            guard let new = new else { return }
//
//            for items in new {
//                pipEditStates[items.id] = false
//            }
//            //print(pipEditStates)
////            if realm == nil {
////                if let first = new.first {
////                    realm = first.realm
////                }
////            }
//
//        }.store(in: &subscriptions)
        
//        $pip_lists.sink { new in
//           // self.selected_pip_list = new?.first
//        }.store(in: &subscriptions)
        
        $selectedPips.sink { [unowned self] pips in
            
            let dups_dict = Dictionary(grouping: pips, by: {$0.name})
            let dup_items = dups_dict.filter { $1.count > 1 }
            //print(dup_items.keys.count)
            
            if dup_items.keys.count > 0 {
                duplicatedDict = dup_items
                duplicatedPipNames.toggle()
                
            } else {
                
            }
            
        }.store(in: &subscriptions)
        
        $selected_pip_list.sink { [unowned self] new in
            //selectedPipsInCurList.removeAll()
            
        }.store(in: &subscriptions)
    }
    
    static func preview_pips() -> [PipData] {
        return [
            .init(name: "kivy", versions: [(PipOperator.EQ.rawValue, "1.0.0")]),
            .init(name: "osc", versions: [(PipOperator.LT.rawValue, "1.0.0")]),
            .init(name: "sdl", versions: [(PipOperator.GE.rawValue, "1.0.0")]),
            .init(name: "whatever", versions: [(PipOperator.LE.rawValue, "1.0.0")]),
            .init(name: "ahhh", versions: [(PipOperator.EQ.rawValue, "1.0.0")]),
            .init(name: "git_link", versions: [(PipOperator.EQ.rawValue, "1.0.0")], git_string: "git+"),
            .init(name: "ahhh", versions: [(PipOperator.EQ.rawValue, "1.0.0")]),
            .init(name: "ahhh", versions: [(PipOperator.EQ.rawValue, "2.0.0")])
        ]
        
    }
    
    private enum Codingkeys: CodingKey {
        case pips
        case pip_lists
    }
    
    
//    func exportPips(url: URL) throws {
//        let encoder = JSONEncoder()
//        let data = try encoder.encode(pips)
//        try data.write(to: url)
//    }
//
//    func exportPipLists(url: URL) throws {
//        let encoder = JSONEncoder()
//        let data = try encoder.encode(pip_lists)
//        try data.write(to: url)
//    }
    
    func create(pip name: String, versions: [(String, String)]) {
        guard let realm = realm else { return }
        
        try? realm.write {
            realm.add(
                PipData(name: name, versions: versions)
            )
        }
    }
    func create(pip_list name: String) {
        guard let realm = realm else { return }
        
        try? realm.write {
            realm.add(
                PipManagerList(new: name)
            )
        }
    }
    
    
    func delete(pip: PipData) {
        selectedPips.removeAll()
        selectedPipsInCurList.removeAll()
        guard let realm = realm else { return }
        
        guard let pip = pip.thaw() else { return }
        
        try? realm.write {
            
            for ver in pip.versions {
                realm.delete(ver)
            }
//            for list in pip.used_by_lists {
//                if let pos = list.pips.firstIndex(of: pip) {
//                    list.pips.remove(at: pos)
//                }
//            }
            //realm.delete(pip)
            pip.deleted = true
            //pip.removeObserver(<#T##observer: NSObject##NSObject#>, forKeyPath: <#T##String#>)
            for list in pip.used_by_lists {
                for project in list.used_by_projects {
//                    if project.installed_pips.contains(pip) {
//                        guard let project = project.thaw() else { continue }
//                        
//                    }
//                    if !project.uninstalled_pips.contains(pip) {
//                        guard let project = project.thaw() else { continue }
//                        
//                    }
                }
            }
        }
        
    }
    
    func moveItemToList() {
        guard let list = selected_pip_list?.thaw() else { return }
        guard let realm = list.realm else { return }
        try? realm.write {
            list.pips.append(objectsIn: selectedPips)
        }
        
        selectedPips.removeAll()
    }
    
    func removeItemsFromList() {
        guard let list = selected_pip_list?.thaw() else { return }
        guard let realm = list.realm else { return }
        
        for item in selectedPipsInCurList {
            guard let item = item.thaw() else { continue }
            //print(item.id)
            //print(list.pips.firstIndex(of: item))
            if let pos = list.pips.firstIndex(of: item) {
                //(pos)
                try? realm.write({
                    list.pips.remove(at: pos)
                    
                    //list.pips.removeAll()
                })
                
            }
            
            
            
            
        }
        selectedPipsInCurList.removeAll()
        
    }
    
    func updateProjectsPips() async {
        guard let pips = pips else { return }
        guard let rootmodel = rootmodel else {return}
        guard let recentFolder = rootmodel.recentFolder else { return }
        //var projects2handle = [KSLProjectData: Set<PipData>]()
        var projects2update = Set<KSLProjectData>()
        
        for pip in pips.filter({$0.deleted}) {
            for list in pip.used_by_lists {
                for project in list.used_by_projects.filter({recentFolder.projects.contains($0)}) {
                    projects2update.insert(project)
                }
            }
        }
       
       
            for project in projects2update {
                //rootmodel.
                await project.updateProject()
                
            }
        
    }
    
    private enum ExportCodingKeys: CodingKey {
        case pips
        case pip_lists
        case recentFolder
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: ExportCodingKeys.self)
        try c.encode(pips, forKey: .pips)
        try c.encode(pip_lists, forKey: .pip_lists)
    }
    
    
    
    func export(path: URL) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else { return }
        
        let export_path = path.path as NSString
        let pathExtention = export_path.pathExtension
        let fileName = export_path.deletingPathExtension
        
        print(pathExtention, pathExtention == "")
        print(fileName)
        let export_url = URL(fileURLWithPath: "\(fileName).json")
        try? data.write(to: export_url)
        
        
        
    }
}
