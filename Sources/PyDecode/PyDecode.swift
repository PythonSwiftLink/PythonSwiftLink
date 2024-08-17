import Foundation
import PySwiftCore
import PythonCore
//import PythonTypeAlias
//import PyMemoryView

public typealias ConvertibleFromPython = PyDecodeProtocol
public typealias PyDecodable = PyDecodeProtocol


public protocol PyDecodeProtocol {
	
	init(object: PyPointer) throws
	//static func from(_ object: PyPointer) throws -> Self
}
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
		//self = object.xINCREF
		Py_XINCREF(object)
		self = object
    }


}

extension Data: PyDecodable {
    
    public init(object: PyPointer) throws {
        
        switch object {
        case let mem where PyMemoryView_Check(mem):
			let data_size = PyObject_Size(object)
			// fetch PyBuffer from MemoryView
			let py_buf = PyMemoryView_GetBuffer(object)
			var indices = [0]
			// fetch RawPointer from PyBuffer, if fail return nil
			guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { throw PythonError.memory("Data from memmoryview failed") }
			// cast RawPointer as UInt8 pointer
			let uint8_pointer = buf_ptr.assumingMemoryBound(to: UInt8.self)
			// finally create Data from the UInt8 pointer
			self = Data(UnsafeMutableBufferPointer(start: uint8_pointer, count: data_size))
			// Release PyBuffer and MemoryView
			PyBuffer_Release(py_buf)
            
        case let bytes where PyBytes_Check(bytes):
            self = bytes.bytesAsData() ?? .init()
        case let bytearray where PyByteArray_Check(bytearray):
            self = bytearray.bytearrayAsData() ?? .init()
        default: throw PythonError.memory("object is not a byte or memoryview type")
        }
    }
}

extension Bool : PyDecodable {
    
    public init(object: PyPointer) throws {
        if object == PyTrue {
            self = true
        } else if object == PyFalse {
            self = false
        } else {
            throw PythonError.attribute
        }
        
    }
}


extension String : PyDecodable {
    
    public init(object: PyPointer) throws {
        //guard object.notNone else { throw PythonError.unicode }
        if PyUnicode_Check(object) {
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
        guard PyUnicode_Check(object) else { throw PythonError.unicode }
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
        guard PyLong_Check(object) else { throw PythonError.long }
        self = PyLong_AsLong(object)
    }
}

extension UInt : PyDecodable {
    
    public init(object: PyPointer) throws {
        guard PyLong_Check(object) else { throw PythonError.long }
        self = PyLong_AsUnsignedLong(object)
    }
}
extension Int64: PyDecodable {
    
    
    public init(object: PyPointer) throws {
        guard PyLong_Check(object) else { throw PythonError.long }
        self = PyLong_AsLongLong(object)
    }
}

extension UInt64:PyDecodable {
    
    public init(object: PyPointer) throws {
        guard PyLong_Check(object) else { throw PythonError.long }
        self = PyLong_AsUnsignedLongLong(object)
    }
}

extension Int32: PyDecodable {
    
    public init(object: PyPointer) throws {
        guard PyLong_Check(object) else { throw PythonError.long }
        self = _PyLong_AsInt(object)
    }
}

extension UInt32: PyDecodable {
    
    public init(object: PyPointer) throws {
        guard PyLong_Check(object) else { throw PythonError.long }
        self.init(PyLong_AsUnsignedLong(object))
    }
}

extension Int16: PyDecodable {
    
    public init(object: PyPointer) throws {
        guard PyLong_Check(object) else { throw PythonError.long }
        self.init(clamping: PyLong_AsLong(object))
    }
    
}

extension UInt16: PyDecodable {
    
    public init(object: PyPointer) throws {
        guard PyLong_Check(object) else { throw PythonError.long }
        self.init(clamping: PyLong_AsUnsignedLong(object))
    }
    
}

extension Int8: PyDecodable {
    
    public init(object: PyPointer) throws {
        guard PyLong_Check(object) else { throw PythonError.long }
        self.init(clamping: PyLong_AsUnsignedLong(object))
    }
    
}

extension UInt8: PyDecodable {
    
    public init(object: PyPointer) throws {
        guard PyLong_Check(object) else { throw PythonError.long }
        self.init(clamping: PyLong_AsUnsignedLong(object))
    }
}

extension Double: PyDecodable {
    
    public init(object: PyPointer) throws {
        if PyFloat_Check(object){
            self = PyFloat_AsDouble(object)
        } else if PyLong_Check(object) {
            self = PyLong_AsDouble(object)
        }
        else { throw PythonError.float }
        
    }
}

extension Float32: PyDecodable {
    
    public init(object: PyPointer) throws {
        guard PyFloat_Check(object) else { throw PythonError.float }
        self.init(PyFloat_AsDouble(object))
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



