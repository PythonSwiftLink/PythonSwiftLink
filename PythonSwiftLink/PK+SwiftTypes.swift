//
//  PK+SwiftTypes.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 07/06/2022.
//

import Foundation
import PythonKit
import RealmSwift


extension PythonObject {
    
    var string: String? { String(self) }
    var stringFromBytes: String? { String(self.decode() )}
    
    var int: Int? { Int(self) }
    var double: Double? { Double(self) }
    
    
}


extension String {
    
    var pythonBytes_utf8: PythonObject { self.pythonObject.encode() }
    
}


extension AnyRealmValue {
    
    var pythonBytes_utf8: PythonObject? { self.stringValue?.pythonBytes_utf8 }
    
    var pythonObject: PythonObject {
        
        switch self {
            
        case .none:
            return Python.None
        case let .int(value):
            return value.pythonObject
        case let .bool(value):
            return value.pythonObject
        case let .float(value):
            return value.pythonObject
        case let .double(value):
            return value.pythonObject
        case let .string(value):
            return value.pythonObject

        case let .date(value):
            return value.description.pythonObject

        case let .uuid(value):
            return value.uuidString.pythonObject
        
        default: return Python.None
        }
        
        
    }
}
