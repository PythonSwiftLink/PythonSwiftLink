

import Foundation
import RealmSwift
import Combine





class PipManagerList: Object, ObjectKeyIdentifiable, Encodable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String
    @Persisted var pips: List<PipData>
    @Persisted(originProperty: "pips") var used_by_projects: LinkingObjects<KSLProjectData>
//
    
    var filtered_pips: [PipData] {
        pips.filter{ !$0.deleted }
    }
    
    convenience init(new name: String) {
        self.init()
        self.name = name
    }
    
    convenience init(new name: String, pips: [PipData]) {
        self.init()
        self.name = name
        self.pips.append(objectsIn: pips)
    }
    
    convenience init(clone name: String, target: PipManagerList) {
        self.init()
        self.name = name
        self.pips.append(objectsIn: target.pips)
    }
    
    private enum ExportCodingKeys: CodingKey {
        case name
        case pips
        
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: ExportCodingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encode(pips, forKey: .pips)
    }
    
    func importRequirements_txt(url: URL) {
        guard let txt = try? String(contentsOf: url) else { return }
        let check_strings = PipOperator.allCases.map{$0.rawValue} + ["@"]
        guard let pips = pips.thaw() else { return }
        for line in txt.components(separatedBy: "\n") {
            if let (x, y, z) = splitText(with: check_strings, target: line) {
                print(x,y,z)
                if let pip = checkIfPipExist(name: x, op: y, version: z) {
                    guard let pip = pip.thaw() else { return }
                    
                    
                    try? realm_shared.write {
                        pips.append(pip)
                    }
                } else {
                    try? realm_shared.write {
                        pips.append(PipData(name: x, versions: [(y, z)]))
                    }
                }
            }
        }
    }
    
    func checkIfPipExist(name: String, op: String, version: String) -> PipData? {
        
        for pip in realm_shared.objects(PipData.self) {
            if pip.name == name {
                if let first = pip.versions.first {
                    if first.versionOperator.rawValue == op && first.version == version {
                        return pip
                    }
                }
            }
        }
        
        
        return nil
    }
}


func splitText(with strings: [String], target: String) -> (String, String, String)? {
    for key in strings {
        if target.contains(key) {
            let split = target.replacingOccurrences(of: " ", with: "").components(separatedBy: key)
            //split.insert(key, at: 1)
            return (split[0], key, split[1])
        }
    }
    return nil
}
