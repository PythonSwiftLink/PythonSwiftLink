import Foundation
import PythonCore
//import PythonTypeAlias

extension Collection where Element == PyConvertible {
    public var list_object: PythonPointer {
        let list = PyList_New(0)
        for element in self {
            PyList_Append(list, element.pyPointer)
        }
        return list!
    }
}

//
//extension Collection where Element == String {
//
//    public var list_object: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyUnicode_FromString(element))
//        }
//        return list
//    }
//
//    public var tuple_object: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyUnicode_FromString(element))
//        }
//        return tuple
//    }
//
//    public var _list_object: PythonPointerU {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyUnicode_FromString(element))
//        }
//        return list!
//    }
//
//    public var _tuple_object: PythonPointerU {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyUnicode_FromString(element))
//        }
//        return tuple!
//    }
//}
//
//extension Collection where Element == Int {
//
//    public var list_object: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromLong(element))
//        }
//        return list
//    }
//
//    public var tuple_object: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromLong(element))
//        }
//        return tuple
//    }
//
//    public var _list_object: PythonPointerU {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromLong(element))
//        }
//        return list!
//    }
//
//    public var _tuple_object: PythonPointerU {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromLong(element))
//        }
//        return tuple!
//    }
//}
//
//extension Collection where Element == UInt {
//
//    public var list_object: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromUnsignedLong(element))
//        }
//        return list
//    }
//
//    public var tuple_object: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromUnsignedLong(element))
//        }
//        return tuple
//    }
//
//    public var _list_object: PythonPointerU {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromUnsignedLong(element))
//        }
//        return list!
//    }
//
//    public var _tuple_object: PythonPointerU {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromUnsignedLong(element))
//        }
//        return tuple!
//    }
//}
//
//extension Collection where Element == Int64 {
//
//    public var list_object: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromLongLong(element))
//        }
//        return list
//    }
//
//    public var tuple_object: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromLongLong(element))
//        }
//        return tuple
//    }
//
//    public var _list_object: PythonPointerU {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromLongLong(element))
//        }
//        return list!
//    }
//
//    public var _tuple_object: PythonPointerU {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromLongLong(element))
//        }
//        return tuple!
//    }
//}
//
//extension Collection where Element == UInt64 {
//
//    public var list_object: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromUnsignedLongLong(element))
//        }
//        return list
//    }
//
//    public var tuple_object: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromUnsignedLongLong(element))
//        }
//        return tuple
//    }
//
//    public var _list_object: PythonPointerU {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromUnsignedLongLong(element))
//        }
//        return list!
//    }
//
//    public var _tuple_object: PythonPointerU {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromUnsignedLongLong(element))
//        }
//        return tuple!
//    }
//}
//
//extension Collection where Element == Int32 {
//
//    public var list_object: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromLong(Int(element)))
//        }
//        return list
//    }
//
//    public var tuple_object: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromLong(Int(element)))
//        }
//        return tuple
//    }
//
//    public var _list_object: PythonPointerU {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromLong(Int(element)))
//        }
//        return list!
//    }
//
//    public var _tuple_object: PythonPointerU {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromLong(Int(element)))
//        }
//        return tuple!
//    }
//}
//
//extension Collection where Element == UInt32 {
//
//    public var list_object: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromUnsignedLong(UInt(element)))
//        }
//        return list
//    }
//
//    public var tuple_object: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromUnsignedLong(UInt(element)))
//        }
//        return tuple
//    }
//
//    public var _list_object: PythonPointerU {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromUnsignedLong(UInt(element)))
//        }
//        return list!
//    }
//
//    public var _tuple_object: PythonPointerU {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromUnsignedLong(UInt(element)))
//        }
//        return tuple!
//    }
//}
//
//extension Collection where Element == Int16 {
//
//    public var list_object: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromLong(Int(element)))
//        }
//        return list
//    }
//
//    public var tuple_object: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromLong(Int(element)))
//        }
//        return tuple
//    }
//
//    public var _list_object: PythonPointerU {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromLong(Int(element)))
//        }
//        return list!
//    }
//
//    public var _tuple_object: PythonPointerU {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromLong(Int(element)))
//        }
//        return tuple!
//    }
//}
//
//extension Collection where Element == UInt16 {
//
//    public var list_object: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromUnsignedLong(UInt(element)))
//        }
//        return list
//    }
//
//    public var tuple_object: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromUnsignedLong(UInt(element)))
//        }
//        return tuple
//    }
//
//    public var _list_object: PythonPointerU {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromUnsignedLong(UInt(element)))
//        }
//        return list!
//    }
//
//    public var _tuple_object: PythonPointerU {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromUnsignedLong(UInt(element)))
//        }
//        return tuple!
//    }
//}
//
//extension Collection where Element == Int8 {
//
//    public var list_object: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromLong(Int(element)))
//        }
//        return list
//    }
//
//    public var tuple_object: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromLong(Int(element)))
//        }
//        return tuple
//    }
//
//    public var _list_object: PythonPointerU {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromLong(Int(element)))
//        }
//        return list!
//    }
//
//    public var _tuple_object: PythonPointerU {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromLong(Int(element)))
//        }
//        return tuple!
//    }
//}
//
//extension Collection where Element == UInt8 {
//
//    public var list_object: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromUnsignedLong(UInt(element)))
//        }
//        return list
//    }
//
//    public var tuple_object: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromUnsignedLong(UInt(element)))
//        }
//        return tuple
//    }
//
//    public var _list_object: PythonPointerU {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromUnsignedLong(UInt(element)))
//        }
//        return list!
//    }
//
//    public var _tuple_object: PythonPointerU {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromUnsignedLong(UInt(element)))
//        }
//        return tuple!
//    }
//}
//
//extension Collection where Element == Float {
//
//    public var list_object: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyFloat_FromDouble(Double(element)))
//        }
//        return list
//    }
//
//    public var tuple_object: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyFloat_FromDouble(Double(element)))
//        }
//        return tuple
//    }
//
//    public var _list_object: PythonPointerU {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyFloat_FromDouble(Double(element)))
//        }
//        return list!
//    }
//
//    public var _tuple_object: PythonPointerU {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyFloat_FromDouble(Double(element)))
//        }
//        return tuple!
//    }
//}
//
//extension Collection where Element == Double {
//
//    public var list_object: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyFloat_FromDouble(element))
//        }
//        return list
//    }
//
//    public var tuple_object: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyFloat_FromDouble(element))
//        }
//        return tuple
//    }
//
//    public var _list_object: PythonPointerU {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyFloat_FromDouble(element))
//        }
//        return list!
//    }
//
//    public var _tuple_object: PythonPointerU {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyFloat_FromDouble(element))
//        }
//        return tuple!
//    }
//}
