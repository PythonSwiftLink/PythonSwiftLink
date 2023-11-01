import Foundation
import PythonCore
//import PythonTypeAlias



//extension PythonObject : PyDecodable {
//    
//    public init(object: PyPointer) throws {
//        self = .init(getter: object)
//    }
//    
//}
//
extension PyPointer : PyDecodable {

    public init(object: PyPointer) throws {
		self = object.xINCREF
    }


}

extension Data: PyDecodable {
    
    public init(object: PyPointer) throws {
        
        switch object {
        case let mem where PythonMemoryView_Check(mem):
            self = mem.memoryViewAsData() ?? .init()
        case let bytes where PythonBytes_Check(bytes):
            self = bytes.bytesAsData() ?? .init()
        case let bytearray where PythonByteArray_Check(bytearray):
            self = bytearray.bytearrayAsData() ?? .init()
        default: throw PythonError.memory("object is not a byte or memoryview type")
        }
    }
}

extension Bool : PyDecodable {
    
    public init(object: PyPointer) throws {
        if object == PythonTrue {
            self = true
        } else if object == PythonFalse {
            self = false
        } else {
            throw PythonError.attribute
        }
        
    }
}


extension String : PyDecodable {
    
    public init(object: PyPointer) throws {
        //guard object.notNone else { throw PythonError.unicode }
        if PythonUnicode_Check(object) {
            self.init(cString: PyUnicode_AsUTF8(object))
        } else {
            guard let unicode = PyUnicode_AsUTF8String(object) else { throw PythonError.unicode }
            self.init(cString: PyUnicode_AsUTF8(unicode))
            Py_DecRef(unicode)
        }
    }
    
}


extension URL : PyDecodable {
    
    public init(object: PyPointer) throws {
        guard PythonUnicode_Check(object) else { throw PythonError.unicode }
        let path = String(cString: PyUnicode_AsUTF8(object))

        if path.hasPrefix("http") {
            guard let url = URL(string: path) else { throw URLError(.badURL) }
            self = url
        } else {
            let url = URL(fileURLWithPath: path)
            self = url
        }
        
    }
    
}

extension Int : PyDecodable {
    
    public init(object: PyPointer) throws {
        guard PythonLong_Check(object) else { throw PythonError.long }
        self = PyLong_AsLong(object)
    }
}

extension UInt : PyDecodable {
    
    public init(object: PyPointer) throws {
        guard PythonLong_Check(object) else { throw PythonError.long }
        self = PyLong_AsUnsignedLong(object)
    }
}
extension Int64: PyDecodable {
    
    
    public init(object: PyPointer) throws {
        guard PythonLong_Check(object) else { throw PythonError.long }
        self = PyLong_AsLongLong(object)
    }
}

extension UInt64:PyDecodable {
    
    public init(object: PyPointer) throws {
        guard PythonLong_Check(object) else { throw PythonError.long }
        self = PyLong_AsUnsignedLongLong(object)
    }
}

extension Int32: PyDecodable {
    
    public init(object: PyPointer) throws {
        guard PythonLong_Check(object) else { throw PythonError.long }
        self = _PyLong_AsInt(object)
    }
}

extension UInt32: PyDecodable {
    
    public init(object: PyPointer) throws {
        guard PythonLong_Check(object) else { throw PythonError.long }
        self.init(PyLong_AsUnsignedLong(object))
    }
}

extension Int16: PyDecodable {
    
    public init(object: PyPointer) throws {
        guard PythonLong_Check(object) else { throw PythonError.long }
        self.init(clamping: PyLong_AsLong(object))
    }
    
}

extension UInt16: PyDecodable {
    
    public init(object: PyPointer) throws {
        guard PythonLong_Check(object) else { throw PythonError.long }
        self.init(clamping: PyLong_AsUnsignedLong(object))
    }
    
}

extension Int8: PyDecodable {
    
    public init(object: PyPointer) throws {
        guard PythonLong_Check(object) else { throw PythonError.long }
        self.init(clamping: PyLong_AsUnsignedLong(object))
    }
    
}

extension UInt8: PyDecodable {
    
    public init(object: PyPointer) throws {
        guard PythonLong_Check(object) else { throw PythonError.long }
        self.init(clamping: PyLong_AsUnsignedLong(object))
    }
}

extension Double: PyDecodable {
    
    public init(object: PyPointer) throws {
        if PythonFloat_Check(object){
            self = PyFloat_AsDouble(object)
        } else if PythonLong_Check(object) {
            self = PyLong_AsDouble(object)
        }
        else { throw PythonError.float }
        
    }
}

extension Float32: PyDecodable {
    
    public init(object: PyPointer) throws {
        guard PythonFloat_Check(object) else { throw PythonError.float }
        self.init(PyFloat_AsDouble(object))
    }
}



extension Array : PyDecodable where Element : PyDecodable {
    
    public init(object: PyPointer) throws {
        if PythonList_Check(object) {
            self = try object.map {
                guard let element = $0 else { throw PythonError.index }
                return try Element(object: element)
            }//(Element.init)
        } else if PythonTuple_Check(object) {
            self = try object.map {
                guard let element = $0 else { throw PythonError.index }
                return try Element(object: element)
            }//(Element.init)
        } else {
            throw PythonError.sequence
        }
    }
    
}

extension Dictionary: PyDecodable where Key == String, Value == PyPointer {
    public init(object: PyPointer) throws {
        var d: [Key:Value] = .init()
        var pos: Int = 0
        var key: PyPointer?
        var value: PyPointer?
        while PyDict_Next(object, &pos, &key, &value) == 1 {
            if let k = key {
                d[try String(object: k)] = value
            }
        }
        
        self = d
    }
    
    
}



