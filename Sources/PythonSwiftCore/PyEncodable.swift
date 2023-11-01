import Foundation
import PythonCore
//import PythonTypeAlias


public func optionalPyPointer<T: PyEncodable>(_ v: T?) -> PyPointer {
	if let this = v {
		return this.pyPointer
	}
	return .PyNone
}



//@inlinable
//public func UnPackPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer?) throws -> T? {
//    guard
//        let self = self,
//        PythonObject_TypeCheck(self, check),
//        let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
//    else { throw PythonError.attribute }
//    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
//}

//@inlinable
//public func UnPackPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer?) -> T {
//    guard
//        let self = self,
//        PythonObject_TypeCheck(self, check),
//        let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
//    else { fatalError("self is not a PySwiftObject") }
//    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
//}



extension PythonObject : PyEncodable {
    
    
    public var pyPointer: PyPointer {
        ptr ?? .PyNone
    }
    
    public var pyObject: PythonObject {
        self
    }
    
}

extension PyPointer : PyEncodable {
    
    
    public var pyObject: PythonObject {
        .init(getter: self)
    }
    
    public var pyPointer: PyPointer {
        self
    }
    
}

//extension UnsafeMutablePointer<_object> : PyEncodable {
//    public var pyObject: PythonObject {
//        .init(getter: self)
//    }
//
//    public var pyPointer: PyPointer {
//        self
//    }
//
//}

extension Data? {
    public var pyPointer: PyPointer {
        self?.pyPointer ?? .PyNone
    }
}

extension Data: PyEncodable {
    public var pyObject: PythonObject {
        .init(getter: nil)
    }
    
    public var pyPointer: PyPointer {
        var this = self
        return this.withUnsafeMutableBytes { buffer -> PyPointer in
            let size = self.count //* uint8_size
            var pybuf = Py_buffer()
            PyBuffer_FillInfo(&pybuf, nil, buffer.baseAddress, size , 0, PyBUF_WRITE)
            let mem = PyMemoryView_FromBuffer(&pybuf)
            let bytes = PyBytes_FromObject(mem)
            Py_DecRef(mem)
            return bytes ?? .PyNone
        }
    }
    
}

extension Bool : PyEncodable {
    
    
    public var pyPointer: PyPointer {
        if self {
            return .True
        }
        return .False
    }
    
    public var pyObject: PythonObject {
        if self {
            return .init(getter: .True)
        }
        return .init(getter: .False)
    }
    
}

//extension String? {
//    public var pyPointer: PyPointer {
//        if let this = self {
//            return this.withCString(PyUnicode_FromString) ?? .PyNone
//        }
//        return .PyNone
//    }
//}

extension String : PyEncodable {
    
    
    public var pyPointer: PyPointer {
        withCString(PyUnicode_FromString) ?? .PyNone
    }
    
    public var pyObject: PythonObject {
        .init(getter: withCString(PyUnicode_FromString) )
    }
    
}


//extension URL? {
//    public var pyPointer: PyPointer {
//        if let this = self {
//            return this.pyPointer
//        }
//        return .PyNone
//    }
//}

extension URL : PyEncodable {
    public var pyObject: PythonObject {
        .init(getter: path.withCString(PyUnicode_FromString))
    }
    
    public var pyPointer: PyPointer {
        path.withCString(PyUnicode_FromString) ?? .PyNone
    }
    
}

extension Int : PyEncodable {
    
    public var pyPointer: PyPointer {
        PyLong_FromLong(self)
    }
    
    public var pyObject: PythonObject {
        .init(getter: PyLong_FromLong(self))
    }

}

extension UInt : PyEncodable {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromUnsignedLong(self)
    }
    
    public var pyObject: PythonObject {
        .init(getter: PyLong_FromUnsignedLong(self))
    }
    
}
extension Int64: PyEncodable {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromLongLong(self)
    }
    
    public var pyObject: PythonObject {
        .init(getter: PyLong_FromLongLong(self))
    }
    
}

extension UInt64: PyEncodable {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromUnsignedLongLong(self)
    }
    
    public var pyObject: PythonObject {
        .init(getter: PyLong_FromUnsignedLongLong(self))
    }
    
}

extension Int32: PyEncodable {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromLong(Int(self))
    }
    
    public var pyObject: PythonObject {
        .init(getter: PyLong_FromLong(Int(self)))
    }
    
}

extension UInt32: PyEncodable {
    
    public var pyPointer: PyPointer {
        PyLong_FromLong(Int(self))
    }
    
    public var pyObject: PythonObject {
        .init(getter: PyLong_FromLong(Int(self)))
    }
    
}

extension Int16: PyEncodable {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromLong(Int(self))
    }
    
    public var pyObject: PythonObject {
        .init(getter: PyLong_FromLong(Int(self)))
    }
    
}

extension UInt16: PyEncodable {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromUnsignedLong(UInt(self))
    }
    
    public var pyObject: PythonObject {
        .init(getter: PyLong_FromUnsignedLong(UInt(self)))
    }
    
}

extension Int8: PyEncodable {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromLong(Int(self))
    }
    
    public var pyObject: PythonObject {
        .init(getter: PyLong_FromLong(Int(self)))
    }
    
}

extension UInt8: PyEncodable {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromUnsignedLong(UInt(self))
    }
    
    public var pyObject: PythonObject {
        .init(getter: PyLong_FromUnsignedLong(UInt(self)))
    }
    
}

extension Double: PyEncodable {
    
    
    public var pyPointer: PyPointer {
        PyFloat_FromDouble(self)
    }
    
    public var pyObject: PythonObject {
        .init(getter: PyFloat_FromDouble(self))
    }
    
}

extension CGFloat: PyEncodable {
    
    
    public var pyPointer: PyPointer {
        PyFloat_FromDouble(self)
    }
    
    public var pyObject: PythonObject {
        .init(getter: PyFloat_FromDouble(self))
    }
    
}

extension Float32: PyEncodable {
    
    public var pyPointer: PyPointer {
        PyFloat_FromDouble(Double(self))
    }
    
    public var pyObject: PythonObject {
        .init(getter: PyFloat_FromDouble(Double(self)))
    }
    
}


extension Array: PyEncodable where Element : PyEncodable {

    public var pyPointer: PyPointer {
        let list = PyList_New(count)
        var _count = 0
        for element in self {
            // `PyList_SetItem` steals the reference of the object stored. dont DecRef
            PyList_SetItem(list, _count, element.pyPointer)
            _count += 1
        }
        return list ?? .PyNone
    }
    
    public var pyObject: PythonObject {
        return .init(getter: pyPointer)
    }
    
    @inlinable public var pythonTuple: PythonPointer {
        let tuple = PyTuple_New(self.count)
        for (i, element) in self.enumerated() {
            PyTuple_SetItem(tuple, i, element.pyPointer)
        }
        return tuple ?? .PyNone
    }
    
}


extension Dictionary: PyEncodable where Key == StringLiteralType, Value == PyEncodable  {
    
    
    public var pyObject: PythonObject {
        .init(getter: pyPointer)
    }
    
    public var pyPointer: PyPointer {
        let dict = PyDict_New()
        for (key,value) in self {
            let v = value.pyPointer
            _ = key.withCString{PyDict_SetItemString(dict, $0, v)}
            //Py_DecRef(v)
        }
        return dict ?? .PyNone
    }
    
    
}

public extension Dictionary where Key == String, Value == PyPointer {
    var pyDict: PyPointer { self.reduce(PyDict_New()!, PyDict_SetItem_ReducedIncRef) }
}

