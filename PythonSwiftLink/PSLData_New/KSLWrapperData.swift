//
//  KSLWrapperData.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 30/05/2022.
//

import Foundation
import Combine
import RealmSwift


protocol WrapperInfo {
    
    func compare(filename: String, code: String) -> Bool
}


enum RLMEnumTest: String, PersistableEnum {
    case created
    case deleted
    case updated
    
}

enum WrapperStatus: String, PersistableEnum {
    case created
    case deleted
    case updated
    case up2date
    
}

enum KSLWrapperType: String, PersistableEnum {
    case file
    case bundle
}

class CodeFile: Object {
    
    @Persisted var name: String
    @Persisted var path: String
    @Persisted var code: String
    
    var fileURL: URL { URL(fileURLWithPath: path) }
    
    var needsUpdate: Bool {
            do {
                let file_string = try String(contentsOf: fileURL)
                if file_string != code {
                    try _realm?.write {
                        code = file_string
                    }
                    return true
                }
            } catch let err {
                print(err.localizedDescription)
            }
            
            return false
        }
    
    convenience init(name: String, path: String , code: String) {
        self.init()
        self.name = name
        self.path = path
        self.code = code
    }
}

class KSLWrapperData: Object, ObjectKeyIdentifiable {
    private let ksl_paths = KSLPaths.shared
    
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var name: String
    
    @Persisted var type: KSLWrapperType
    
    @Persisted var working_folder: WorkingFolderData?
    @Persisted var project: KSLProjectData?
//    var enumType: KSLWrapperType {
//        get { KSLWrapperType(rawValue: type)! }
//        set { type = newValue.rawValue}
//    }
    @Persisted var status: WrapperStatus = .created
    
    @Persisted var require_update = false
    
    @Persisted var code_files = List<CodeFile>()
    
    convenience init(file name: String, code_url: URL ) {
        self.init()
        //let filename = code_url.deletingPathExtension().lastPathComponent
        self.name = name
        self.type = .file
        //let code = try! String(contentsOf: code_url)
        
        code_files.append(
            CodeFile(name: name, path: code_url.path, code: "")
        )
    }
    
}

extension KSLWrapperData: WrapperInfo {
    
    func compare(filename: String, code: String) -> Bool {
        if let file = code_files.first(where: { cf in cf.name == filename }) {
            return code == file.code
        }
        return false
    }
    var needsUpdate: Bool {
        var update = false
        for file in code_files {
            guard let new_code = try? String(contentsOf: file.fileURL) else { continue }
            if file.code != new_code {
                guard let file = file.thaw() else { continue }
                try? realm_shared.write {
                    file.code = new_code
                }
                update = true
            }
        }
        return update
    }
    
    func firstCodeURL() -> URL? {
        if let wrap = code_files.first {
            return URL(fileURLWithPath: wrap.path)
        }
        
            
        return nil
    }
}


