
import Foundation
import RealmSwift
import Combine



//extension RealmSwift.List: Decodable where Element: Decodable {
//    public convenience init(from decoder: Decoder) throws {
//        self.init()
//        let container = try decoder.singleValueContainer()
//        let decodedElements = try container.decode([Element].self)
//        self.append(objectsIn: decodedElements)
//    }
//}
//
//extension RealmSwift.List: Encodable where Element: Encodable {
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encode(self.map { $0 })
//    }
//}



enum PipOperator: String, PersistableEnum, Codable, CaseIterable {
    case EQ = "=="
    case LE = "<="
    case GE = ">="
    case LT = "<"
    case GT = ">"
    case GITLINK = "@"
}

class PipVersion: Object, ObjectKeyIdentifiable, Codable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var versionOperator: PipOperator
    @Persisted var version: String
    @Persisted(originProperty: "versions") var used_by_pip: LinkingObjects<PipData>
    
    convenience init(version: String, op: String) {
        self.init()
        self.version = version
        self.versionOperator = PipOperator(rawValue: op)!
    }
    
    private enum CodingKeys: CodingKey {
        case versionOperator
        case version
    }
    
    static func decode(from data: Data) -> [PipVersion]? {
        //let c = decoder.container(keyedBy: <#T##CodingKey.Protocol#>)
        let decoder = JSONDecoder()
        let pips = try? decoder.decode([PipVersion].self, from: data)
        return pips
    }
    
//    required init(from decoder: Decoder) throws {
//        super.init()
//        let c = try decoder.container(keyedBy: CodingKeys.self)
//        versionOperator = try c.decode(String.self, forKey: .versionOperator)
//        version = try c.decode(String.self, forKey: .version)
//
//    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(versionOperator, forKey: .versionOperator)
        try c.encode(version, forKey: .version)
    }
}


class PipData: Object, Encodable,  ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String
    @Persisted var git_string: String?
    @Persisted var versions: List<PipVersion>
    @Persisted var jsondata: Data?
    @Persisted var deleted: Bool = false
    @Persisted(originProperty: "pips") var used_by_lists: LinkingObjects<PipManagerList>
    
    var full_name: String {
        guard let first = versions.first else { return name }
        
        if first.versionOperator == .GITLINK {
            
            if deleted { return name }
            if let gstring = git_string {
                return "git+\(gstring)"
            }
        }
        
        return "\(name)\(first.versionOperator.rawValue)\(first.version)"
    }
    private enum PipDataCodingKeys: CodingKey {
        case name
        case git_string
        case versions
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: PipDataCodingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encode(git_string, forKey: .git_string)
        try c.encode(versions, forKey: .versions)
    }
    
//    required init(from decoder: Decoder) throws {
////        self.init()
//        super.init()
//        let c = try decoder.container(keyedBy: PipDataCodingKeys.self)
//        name = try c.decode(String.self, forKey: .name)
//        git_string = try c.decode(String.self, forKey: .git_string)
//        versions.append(objectsIn: try c.decode([PipVersion].self, forKey: .versions))
//    }
 
            
//    func encode(to encoder: Encoder) throws {
//        var c = encoder.container(keyedBy: PipDataCodingKeys.self)
//        try c.encode(name, forKey: .name)
//        try c.encode(git_string, forKey: .git_string)
//        try c.encode(versions, forKey: .versions)
//    }
            
    convenience init(name: String, versions: [(String,String)], git_string: String = "") {
        self.init()
        self.name = name
        self.versions.append(
            objectsIn: versions.map {o,v in
                PipVersion(version: v, op: o)
                
            }
        )
        self.git_string = git_string
    }
    
    func downloadPipInfo() {

        guard let pypi_url = URL(string: "https://pypi.org/pypi/\(name)/json") else { return }
        
        URLSession.shared.dataTask(with: pypi_url) { data, response, error in
            if let data = data {
                
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    if jsonString == "{\"message\": \"Not Found\"}" { return }
                    //print(jsonString)
                    self.storeJsonData(data: data)
                }
                
            }
            
        }.resume()
        
    }
    
    func storeJsonData(data: Data) {
        DispatchQueue.main.async {
            guard let realm = self.realm else { return }
            try? realm.write {
                self.jsondata = data
            }
        }
    }
    
    func loadJsonData() -> PipJsonData? {
        guard let jsondata = jsondata else { return nil }
        //print(String(data: jsondata, encoding: .utf8)!)
        let decoder = JSONDecoder()
        return try? decoder.decode(PipJsonData.self, from: jsondata)
    }
    
}

