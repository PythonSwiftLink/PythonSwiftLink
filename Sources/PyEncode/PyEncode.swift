import Foundation
import PythonCore
//import PythonTypeAlias
import PySwiftCore


public typealias PyConvertible = PyEncProtocol
public typealias PyEncodable = PyEncProtocol
public typealias SwiftToPy = PyEncProtocol

public protocol PyEncProtocol {
	
	//var pyObject: PythonObject { get }
	var pyPointer: PyPointer { get }
	
	
}


public func optionalPyPointer<T: PyEncodable>(_ v: T?) -> PyPointer {
	if let this = v {
		return this.pyPointer
	}
	return .None
}



//@inlinable
//public func UnPackPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer?) throws -> T? {
//    guard
//        let self = self,
//        PyObject_TypeCheck(self, check),
//        let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
//    else { throw PythonError.attribute }
//    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
//}

//@inlinable
//public func UnPackPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer?) -> T {
//    guard
//        let self = self,
//        PyObject_TypeCheck(self, check),
//        let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
//    else { fatalError("self is not a PySwiftObject") }
//    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
//}


extension PyEncodable {
	public static func ~= (l: Self, r: PyPointer) -> Bool {
		let left = l.pyPointer
		defer { Py_DecRef(left) }
		return PyObject_RichCompareBool(left, r, Py_EQ) == 1
	}
}



extension PyPointer : PyEncodable {

    public var pyPointer: PyPointer {
        self
    }
    
}

extension Optional: PyEncodable where Wrapped: PyEncodable {
	public var pyPointer: PyPointer {
		self?.pyPointer ?? .None
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
        self?.pyPointer ?? .None
    }
}

extension Data: PyEncodable {
   
    public var pyPointer: PyPointer {
        var this = self
        return this.withUnsafeMutableBytes { buffer -> PyPointer in
            let size = self.count //* uint8_size
            var pybuf = Py_buffer()
            PyBuffer_FillInfo(&pybuf, nil, buffer.baseAddress, size , 0, PyBUF_WRITE)
            let mem = PyMemoryView_FromBuffer(&pybuf)
            let bytes = PyBytes_FromObject(mem)
            Py_DecRef(mem)
            return bytes ?? .None
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
    
}

//extension String? {
//    public var pyPointer: PyPointer {
//        if let this = self {
//            return this.withCString(PyUnicode_FromString) ?? .None
//        }
//        return .None
//    }
//}

extension String : PyEncodable {
    
    public var pyPointer: PyPointer {
        withCString(PyUnicode_FromString) ?? .None
    }
}


//extension URL? {
//    public var pyPointer: PyPointer {
//        if let this = self {
//            return this.pyPointer
//        }
//        return .None
//    }
//}

extension URL : PyEncodable {

    public var pyPointer: PyPointer {
        path.withCString(PyUnicode_FromString) ?? .None
    }
    
}

extension Int : PyEncodable {
    
    public var pyPointer: PyPointer {
        PyLong_FromLong(self)
    }
    
}

extension UInt : PyEncodable {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromUnsignedLong(self)
    }
    

    
}
extension Int64: PyEncodable {
    
    public var pyPointer: PyPointer {
        PyLong_FromLongLong(self)
    }

}

extension UInt64: PyEncodable {
    
    public var pyPointer: PyPointer {
        PyLong_FromUnsignedLongLong(self)
    }
    
}

extension Int32: PyEncodable {
    
    public var pyPointer: PyPointer {
        PyLong_FromLong(Int(self))
    }
    
}

extension UInt32: PyEncodable {
    
    public var pyPointer: PyPointer {
        PyLong_FromLong(Int(self))
    }

}

extension Int16: PyEncodable {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromLong(Int(self))
    }

}

extension UInt16: PyEncodable {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromUnsignedLong(UInt(self))
    }

}

extension Int8: PyEncodable {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromLong(Int(self))
    }

}

extension UInt8: PyEncodable {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromUnsignedLong(UInt(self))
    }
}

extension Double: PyEncodable {
    
    
    public var pyPointer: PyPointer {
        PyFloat_FromDouble(self)
    }
    
}

extension CGFloat: PyEncodable {
    
    
    public var pyPointer: PyPointer {
        PyFloat_FromDouble(self)
    }

}

extension Float32: PyEncodable {
    
    public var pyPointer: PyPointer {
        PyFloat_FromDouble(Double(self))
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
        return list ?? .None
    }
    
    
    @inlinable public var pythonTuple: PythonPointer {
        let tuple = PyTuple_New(self.count)
        for (i, element) in self.enumerated() {
            PyTuple_SetItem(tuple, i, element.pyPointer)
        }
        return tuple ?? .None
    }
    
}


extension Dictionary: PyEncodable where Key == StringLiteralType, Value == PyEncodable  {
    

    public var pyPointer: PyPointer {
        let dict = PyDict_New()
        for (key,value) in self {
            let v = value.pyPointer
            _ = key.withCString{PyDict_SetItemString(dict, $0, v)}
            //Py_DecRef(v)
        }
        return dict ?? .None
    }
    
    
}

extension KeyValuePairs: PyEncodable where Key: PyEncodable, Value: PyEncodable {
	public var pyPointer: PyPointer {
		let dict = PyDict_New()!
		for (k, v) in self {
			let key = k.pyPointer
			let o = v.pyPointer
			PyDict_SetItem(dict, key, o)
			_Py_DecRef(key)
			_Py_DecRef(o)
		}
		return dict
	}
}
extension PythonError: PyConvertible {

	public var pyPointer: PyPointer {
		switch self {
			
		case .unicode: return PyExc_UnicodeError
		case .long: return PyExc_MemoryError
		case .float: return PyExc_FloatingPointError
		case .call: return PyExc_RuntimeError
		case .attribute: return PyExc_AttributeError
		case .index: return PyExc_IndexError
		case .sequence:         return PyExc_BufferError
		case .notPySwiftObject: return PyExc_TypeError
		case .type(_): return PyExc_TypeError
		case .memory(_): return PyExc_MemoryError
		}
	}
	
}

extension PythonError {
	public func triggerError(_ msg: String) {
		msg.withCString { PyErr_SetString(pyPointer, $0) }
	}
	public func raiseError(label: String = "arg") {
		var msg: String {
			switch self {
			case .unicode:
				return "\(label) is not an <unicode object>"
			case .long:
				return "\(label) is not a <int object>"
			case .float:
				return "\(label) is not a <float object>"
			case .call:
				return "\(label) is not <callable object>"
			case .attribute:
				return "\(label) could not assigned."
			case .index:
				return "\(label) index out of bound"
			case .sequence:
				return "\(label) is not a <sequence object>"
			case .notPySwiftObject:
				return "self is not a <PySwiftObject>"
			case .type(let t):
				return "\(label) is not the type <\(t)>"
			case .memory(let t):
				return "pointer to the type <\(t)> is deallocated"
			}
		}
		msg.withCString { PyErr_SetString(pyPointer, $0) }
	}
}

