
import Foundation
import CoreGraphics
import PythonCore
//import PythonTypeAlias

extension String {
//    @inlinable public var python_str: PythonPointer { withCString(PyUnicode_FromString) }
//    @inlinable public var py_object: PythonPointer { withCString(PyUnicode_FromString) }
//    @inlinable public var py_string: PythonPointer { withCString(PyUnicode_FromString) }
    @inlinable public var _pyBytes: PythonPointer? { withCString(PyBytes_FromString) }
//        var py_str: PythonPointer = nil
//        self.withCString { ptr in
//            py_str = PyUnicode_FromString(ptr)
//        }
//        return py_str
    
}
extension Data {
    @inlinable public var python_str_utf8: PythonPointer { PyUnicode_FromString(String.init(data: self, encoding: .utf8)) }
    @inlinable public var python_str_utf16: PythonPointer { PyUnicode_FromString(String.init(data: self, encoding: .utf16)) }
    @inlinable public var python_str_utf32: PythonPointer { PyUnicode_FromString(String.init(data: self, encoding: .utf32)) }
    @inlinable public var python_str_unicode: PythonPointer { PyUnicode_FromString(String.init(data: self, encoding: .unicode)) }
    @inlinable public var pythonList: PythonPointer {
        let list = PyList_New(0)
        for element in self {
            PyList_Append(list, PyLong_FromUnsignedLong(UInt(element)))
        }
        return list ?? .PyNone
    }
        
    public var pythonTuple: PythonPointer {
        let tuple = PyTuple_New(self.count)
        for (i, element) in self.enumerated() {
            PyTuple_SetItem(tuple, i, PyLong_FromUnsignedLong(UInt(element)))
        }
        return tuple ?? .PyNone
    }
}



extension UnsafeMutablePointer where Pointee == PythonPointer {
    var test: String {""}
}








//func test3434() {
//    let array: [Int8] = [1,2,3,4,5,6,7,8,9,0]
//    let list = array.pythonList
//    list.decref()
//    let array2: [Int] = [1,2,3,4,5,6,7,8,9,0]
//    let tuple = array2.pythonTuple
//    tuple.decref()
//}
