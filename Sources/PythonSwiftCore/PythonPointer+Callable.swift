import Foundation
import PythonCore
//import PythonTypeAlias

extension PythonPointer {
    @inlinable public func callAsFunction_<R: PyDecodable>(_ args: [PyEncodable]) throws -> R {
        
        let _args: [PyPointer?] = args.map(\.pyPointer)
        //            _args.enumerated().forEach { i, ptr in
        //                assert(ptr != nil, "arg pos \(i) is \(ptr.printString)")
        //            }
        guard let result = _args.withUnsafeBufferPointer({ PyObject_Vectorcall(self, $0.baseAddress, args.count, nil) }) else {
            throw PythonError.call
        }
        //let rtn = PyObject_VectorcallMethod(py_name, _args , _args.count, nil)
        _args.forEach(Py_DecRef)
//        for a in _args {
//            if a != self {
//                Py_DecRef(a)
//            }
//        }
        //py_name.decref()
        if R.self == PyPointer.self {
            return result as! R
        }
        
        let rtn = try R(object: result)
        Py_DecRef(result)
        return rtn
    }
    
    @inlinable public func callAsFunction_(_ args: [PyEncodable]) throws -> PyPointer {
        
        let _args: [PyPointer?] = args.map(\.pyPointer)

        guard let result = _args.withUnsafeBufferPointer({ PyObject_Vectorcall(self, $0.baseAddress, args.count, nil) }) else {
            PyErr_Print()
            throw PythonError.call
        }
        _args.forEach(Py_DecRef)
 
        return result
    }
    
}

