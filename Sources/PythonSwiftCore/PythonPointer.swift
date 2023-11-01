import Foundation
import CoreGraphics
import PythonCore
//import PythonTypeAlias

extension PyPointer {
    @inlinable public static var PyNone: PyPointer {
        Py_IncRef(PythonNone)
        return PythonNone
    }
    @inlinable public static var True: PyPointer {
        Py_IncRef(PythonTrue)
        return PythonTrue
    }
    @inlinable public static var False: PyPointer {
        Py_IncRef(PythonFalse)
        return PythonFalse
        
    }
    
    public static let StringIO: PyPointer? = pythonImport(from: "io", import_name: "StringIO")
    
    public var xINCREF: PyPointer {
            Py_IncRef(self)
            return self
        }
    public var xDECREF: PyPointer {
        Py_DecRef(self)
        return self
    }
    
    //@inlinable public static func Dict: Pyk
}





@inlinable public func PyObject_GetAttr(_ o: PyPointer, _ key: String) -> PyPointer {
    key.withCString { string in
        PyObject_GetAttrString(o, string)
    }
}

@inlinable public func PyObject_GetAttr(_ o: PyPointer, _ key: CodingKey) -> PyPointer {
    key.stringValue.withCString { string in
        PyObject_GetAttrString(o, string)
    }
}

@inlinable public func PyObject_HasAttr(_ o: PyPointer, _ key: String) -> Bool {
    key.withCString { string in
        PyObject_HasAttrString(o, string) == 1
    }
}

@inlinable public func PyObject_HasAttr(_ o: PyPointer, _ key: CodingKey) -> Bool {
    key.stringValue.withCString { string in
        PyObject_HasAttrString(o, string) == 1
    }
}

extension PythonPointer {
    
    @inlinable
        public func getBuffer() -> UnsafeBufferPointer<PythonPointer?> {
            let fast_list = PySequence_Fast(self, nil)
            let list_count = PythonSequence_Fast_GET_SIZE(fast_list)
            let fast_items = PythonSequence_Fast_ITEMS(fast_list)
            let buffer = PySequenceBuffer(start: fast_items, count: list_count)
            Py_DecRef(fast_list)
            return buffer
        }
    
    @inlinable public var sequence: UnsafeBufferPointer<PythonPointer?> {
        let fast_list = PySequence_Fast(self, nil)
        let buffer = PySequenceBuffer(
            start: PythonSequence_Fast_ITEMS(fast_list),
            count: PythonSequence_Fast_GET_SIZE(fast_list)
        )
        Py_DecRef(fast_list)
        return buffer
    }
    
    @inlinable public var _sequence: PySequenceBuffer? {
        guard PySequence_Check(self) == 1 else { return nil }
        
        let fast_list = PySequence_Fast(self, nil)
        let buffer = PySequenceBuffer(
            start: PythonSequence_Fast_ITEMS(fast_list),
            count: PythonSequence_Fast_GET_SIZE(fast_list)
        )
        Py_DecRef(fast_list)
        return buffer
    }
    
    
}




extension PythonPointer {
    
    @inlinable public var unicodeString: String? {
        
        guard
            PythonUnicode_Check(self),
            let ptr = PythonUnicode_DATA(self)
        else { return nil }
        
        let kind = PythonUnicode_KIND(self)
        let length = PyUnicode_GetLength(self)
        switch PythonUnicode_Kind(rawValue: kind) {
        case .PyUnicode_WCHAR_KIND:
            return nil
        case .PyUnicode_1BYTE_KIND:
            let size = length * MemoryLayout<Py_UCS1>.stride
            let data = Data(bytesNoCopy: ptr, count: size, deallocator: .none)
            return String(data: data, encoding: .utf8)
        case .PyUnicode_2BYTE_KIND:
            let size = length * MemoryLayout<Py_UCS2>.stride
            let data = Data(bytesNoCopy: ptr, count: size, deallocator: .none)
            return String(data: data, encoding: .utf16LittleEndian)
        case .PyUnicode_4BYTE_KIND:
            let size = length * MemoryLayout<Py_UCS4>.stride
            let data = Data(bytesNoCopy: ptr, count: size, deallocator: .none)
            return String(data: data, encoding: .utf32LittleEndian)
        case .none:
            print(".none",kind)
            return nil
        }
    }
    
    
    
    @inlinable public var unicodeData: Data? {
        guard let ptr = PythonUnicode_DATA(self) else { return nil }
        return Data(bytes: ptr, count: PyUnicode_GetLength(self))
    }
    
    @inlinable public var unicodeDataNoCopy: Data? {
        guard let ptr = PythonUnicode_DATA(self) else { return nil }
        return Data(bytesNoCopy: ptr, count: PyUnicode_GetLength(self), deallocator: .none)
    }
    
    
    
    
    
    @inlinable public var iterator: PythonPointer? { PyObject_GetIter(self) }
    
    @inlinable public var is_sequence: Bool { PySequence_Check(self) == 1 }
    @inlinable public var is_dict: Bool { PythonDict_Check(self) }
    @inlinable public var is_tuple: Bool { PythonTuple_Check(self)}
    @inlinable public var is_unicode: Bool { PythonUnicode_Check(self) }
    @inlinable public var is_int: Bool { PythonLong_Check(self) }
    @inlinable public var is_float: Bool {PythonBool_Check(self) }
    @inlinable public var is_iterator: Bool { PyIter_Check(self) == 1}
    @inlinable public var is_bytearray: Bool { PythonByteArray_Check(self) }
    @inlinable public var is_bytes: Bool { PythonBytes_Check(self) }
    @inlinable public var is_None: Bool { PyObject_RichCompareBool(self, PythonNone, Py_EQ) == 1 }
    @inlinable public var isNone: Bool { self == PythonNone }
    @inlinable public var is_not_None: Bool { PyObject_RichCompareBool(self, PythonNone, Py_EQ) == 0 }
    @inlinable public var notNone: Bool { self != PythonNone }
    
    @inlinable public func decref() {
        Py_DecRef(self)
    }
    
    @inlinable public func incref() {
        Py_IncRef(self)
    }
    
//    @inlinable
//    func callAsFunction(method name: PythonPointer) -> Void {
//        PyObject_CallMethodNoArgs(self, name)
//    }
    

}



public enum PythonUnicode_Kind: UInt32 {
/* String contains only wstr byte characters.  This is only possible
   when the string was created with a legacy API and _PyUnicode_Ready()
   has not been called yet.  */
    case PyUnicode_WCHAR_KIND = 0
/* Return values of the PyUnicode_KIND() macro: */
    case PyUnicode_1BYTE_KIND = 1
    case PyUnicode_2BYTE_KIND = 2
    case PyUnicode_4BYTE_KIND = 4
}


@inlinable public func bytesAsDataNoCopy(bytes: PythonPointer) -> Data? {
    let data_size = PyBytes_Size(bytes)
    // PyBytes to MemoryView
    let mview = PyMemoryView_FromObject(bytes)
    // fetch PyBuffer from MemoryView
    let py_buf = PythonMemoryView_GET_BUFFER(mview)
    var indices = [0]
    // fetch RawPointer from PyBuffer, if fail return nil
    guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
    let data = Data(bytesNoCopy: buf_ptr, count: data_size, deallocator: .none)
    // Release PyBuffer and MemoryView
    Py_DecRef(mview)
    return data
}

@inlinable public func bytearrayAsDataNoCopy(bytes: PythonPointer) -> Data? {
    let data_size = PyByteArray_Size(bytes)
    // PyBytes to MemoryView
    let mview = PyMemoryView_FromObject(bytes)
    // fetch PyBuffer from MemoryView
    let py_buf = PythonMemoryView_GET_BUFFER(mview)
    var indices = [0]
    // fetch RawPointer from PyBuffer, if fail return nil
    guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
    let data = Data(bytesNoCopy: buf_ptr, count: data_size, deallocator: .none)
    // Release PyBuffer and MemoryView
    Py_DecRef(mview)
    return data
}

@inlinable public func memoryviewAsDataNoCopy(view: PythonPointer) -> Data? {
    let data_size = PyObject_Size(view)
    // fetch PyBuffer from MemoryView
    let py_buf = PythonMemoryView_GET_BUFFER(view)
    var indices = [0]
    // fetch RawPointer from PyBuffer, if fail return nil
    guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
    return Data(bytesNoCopy: buf_ptr, count: data_size, deallocator: .none)
}


@inlinable public func bytesSlicedAsDataNoCopy(bytes: PythonPointer, start: Int, size: Int) -> Data? {
    // PyBytes to MemoryView
    let mview = PyMemoryView_FromObject(bytes)
    // fetch PyBuffer from MemoryView
    let py_buf = PythonMemoryView_GET_BUFFER(mview)
    var indices = [start]
    // fetch RawPointer from PyBuffer, if fail return nil
    guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
    let data = Data(bytesNoCopy: buf_ptr, count: size, deallocator: .none)
    // Release PyBuffer and MemoryView
    Py_DecRef(mview)
    return data
}

@inlinable public func memoryviewSlicedAsDataNoCopy(view: PythonPointer, start: Int, size: Int) -> Data? {
    // fetch PyBuffer from MemoryView
    let py_buf = PythonMemoryView_GET_BUFFER(view)
    var indices = [start]
    // fetch RawPointer from PyBuffer, if fail return nil
    guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
    let data = Data(bytesNoCopy: buf_ptr, count: size, deallocator: .none)
    // Release PyBuffer and MemoryView
    return data
}

extension PythonPointer {
    // PyBytes -> Data
    @inlinable public func bytesAsData() -> Data? {
        let data_size = PyBytes_Size(self)
        // PyBytes to MemoryView
        let mview = PyMemoryView_FromObject(self)
        // fetch PyBuffer from MemoryView
        let py_buf = PythonMemoryView_GET_BUFFER(mview)
        var indices = [0]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
        // cast RawPointer as UInt8 pointer
        let data = Data(bytes: buf_ptr, count: data_size)
        // Release MemoryView
        Py_DecRef(mview)
        return data
    }
    
    @inlinable public func strAsData() -> Data? {
        let data_size = PyBytes_Size(self)
        // PyBytes to MemoryView
        let mview = PyMemoryView_FromObject(self)
        // fetch PyBuffer from MemoryView
        let py_buf = PythonMemoryView_GET_BUFFER(mview)
        var indices = [0]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
        // cast RawPointer as UInt8 pointer
        let data = Data(bytes: buf_ptr, count: data_size)
        // Release MemoryView
        Py_DecRef(mview)
        return data
    }
    
    @inlinable public func bytesSlicedAsData(start: Int, size: Int) -> Data? {
        // PyBytes to MemoryView
        let mview = PyMemoryView_FromObject(self)
        // fetch PyBuffer from MemoryView
        let py_buf = PythonMemoryView_GET_BUFFER(mview)
        var indices = [start]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
        let data = Data(bytes: buf_ptr, count: size)
        // Release MemoryView
        Py_DecRef(mview)
        return data
    }
    
    @inlinable public func bytearrayAsData() -> Data? {
        let data_size = PyByteArray_Size(self)
        // PyBytes to MemoryView
        let mview = PyMemoryView_FromObject(self)
        // fetch PyBuffer from MemoryView
        let py_buf = PythonMemoryView_GET_BUFFER(mview)
        var indices = [0]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
        // cast RawPointer as UInt8 pointer
        let data = Data(bytes: buf_ptr, count: data_size)
        // Release MemoryView
        Py_DecRef(mview)
        return data
    }
    
    @inlinable public func memoryViewAsData() -> Data? {
        let data_size = PyObject_Size(self)
        // fetch PyBuffer from MemoryView
        let py_buf = PythonMemoryView_GET_BUFFER(self)
        var indices = [0]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
        // cast RawPointer as UInt8 pointer
        let uint8_pointer = buf_ptr.assumingMemoryBound(to: UInt8.self)
        // finally create Data from the UInt8 pointer
        let data = Data(UnsafeMutableBufferPointer(start: uint8_pointer, count: data_size))
        // Release PyBuffer and MemoryView
        PyBuffer_Release(py_buf)
        return data
    }
    
    @inlinable public func memoryViewSlicedAsData(start: Int, size: Int) -> Data? {
        // fetch PyBuffer from MemoryView
        let py_buf = PythonMemoryView_GET_BUFFER(self)
        var indices = [start]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
        return Data(bytes: buf_ptr, count: size)
    }
    
    @inlinable public func bytesAsArray() -> [UInt8]? {
        let data_size = PyBytes_Size(self)
        // PyBytes to MemoryView
        let mview = PyMemoryView_FromObject(self)
        // fetch PyBuffer from MemoryView
        let py_buf = PythonMemoryView_GET_BUFFER(mview)
        var indices = [0]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
        // finally create Array<UInt8> from the buf_ptr
        let array = [UInt8](UnsafeBufferPointer(
            start: buf_ptr.assumingMemoryBound(to: UInt8.self),
            count: data_size)
        )
        // Release PyBuffer and MemoryView
        Py_DecRef(mview)
        return array
    }
    
    @inlinable public func bytearrayAsArray() -> [UInt8]? {
        let data_size = PyByteArray_Size(self)
        // PyBytes to MemoryView
        let mview = PyMemoryView_FromObject(self)
        // fetch PyBuffer from MemoryView
        let py_buf = PythonMemoryView_GET_BUFFER(mview)
        var indices = [0]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
        // cast RawPointer as UInt8 pointer
        let array = [UInt8](UnsafeBufferPointer(
            start: buf_ptr.assumingMemoryBound(to: UInt8.self),
            count: data_size)
        )
        // Release MemoryView
        Py_DecRef(mview)
        return array
    }
    
    @inlinable public func memoryViewAsArray() -> [UInt8]? {
        let data_size = PyObject_Size(self)
        // fetch PyBuffer from MemoryView
        let py_buf = PythonMemoryView_GET_BUFFER(self)
        var indices = [0]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
        // finally create Array<UInt8> from the buf_ptr
        let array = [UInt8](UnsafeBufferPointer(
            start: buf_ptr.assumingMemoryBound(to: UInt8.self),
            count: data_size)
        )
        return array
    }
    
    
    
    
}

@inlinable public func asPyBool(_ state: Bool) -> PythonPointer {
    if state { return PythonTrue }
    
    return PythonFalse
}

extension Bool {
    @inlinable public var object: PythonPointer {
        if self { return PythonTrue.xINCREF }
        return PythonFalse.xINCREF
    }
}


extension Data {
    @inlinable public var jsonStr: PythonPointer {
        return self.withUnsafeBytes { buf in
            PyUnicode_FromKindAndData(1, buf.baseAddress, self.count)
        }
    }
}




extension String {
    
    
    
    @inlinable public var pyStringUTF8: PythonPointer? {
        guard let data = self.data(using: .utf8) else { return nil }
        return data.withUnsafeBytes { buf in
            PyUnicode_FromKindAndData(1, buf.baseAddress, data.count)
        }
    }
    @inlinable public var pyStringUTF16: PythonPointer? {
        guard let data = self.data(using: .utf16LittleEndian) else { return nil }
        return data.withUnsafeBytes { buf in
            PyUnicode_FromKindAndData(2, buf.baseAddress, data.count)
        }
    }
    @inlinable public var pyStringUTF32: PythonPointer? {
        guard let data = self.data(using: .utf32LittleEndian) else { return nil }
        return data.withUnsafeBytes { buf in
            PyUnicode_FromKindAndData(4, buf.baseAddress, data.count)
        }
    }
}

extension Data {
    @inlinable public var pyStringUTF8: PythonPointer {
        return withUnsafeBytes { buf in
            PyUnicode_FromKindAndData(1, buf.baseAddress, count)
        }
    }
    @inlinable public var pyStringUTF16: PythonPointer {
        return withUnsafeBytes { buf in
            PyUnicode_FromKindAndData(2, buf.baseAddress, count)
        }
    }
    @inlinable public var pyStringUTF32: PythonPointer {
        return withUnsafeBytes { buf in
            PyUnicode_FromKindAndData(4, buf.baseAddress, count)
        }
    }
}

//extension SignedInteger {
//    @inlinable public var python_int: PythonPointer {PyLong_FromLong(Int(self)) }
//    @inlinable public var pyInt: PythonPointer {PyLong_FromLong(Int(self)) }
//    //var python_str: PythonPointer { PyUnicode_FromString(String(self)) }
//}
//
//extension UnsignedInteger {
//    @inlinable public var python_int: PythonPointer { PyLong_FromUnsignedLong(UInt(self)) }
//    //var python_str: PythonPointer { PyUnicode_FromString(String(self)) }
//}
//
//extension Int {
//    @inlinable public var python_int: PythonPointer { PyLong_FromLong(self) }
//    //var python_str: PythonPointer { PyUnicode_FromString(String(self)) }
//}
//
//extension UInt {
//    @inlinable public var python_int: PythonPointer { PyLong_FromUnsignedLong(self) }
//    //var python_str: PythonPointer { PyUnicode_FromString(String(self)) }
//
//}
//
//extension Double {
//    @inlinable public var python_float: PythonPointer { PyFloat_FromDouble(self) }
//    //var python_str: PythonPointer { PyUnicode_FromString(String(self)) }
//}
//
//extension Float {
//    @inlinable public var python_float: PythonPointer { PyFloat_FromDouble(Double(self)) }
//    //var python_str: PythonPointer { PyUnicode_FromString(String(self)) }
//}
//#if os(iOS)
//@available(iOS 14, *)
//extension Float16 {
//    @inlinable public var python_float: PythonPointer { PyFloat_FromDouble(Double(self)) }
//    //var python_str: PythonPointer { PyUnicode_FromString(String(self)) }
//}
//#endif
//extension CGFloat {
//    @inlinable public var python_float: PythonPointer { PyFloat_FromDouble(self) }
//    //var python_str: PythonPointer { PyUnicode_FromString("\(self)") }
//}
//extension Array where Element == PyConvertible {
//        @inlinable public var pythonList: PythonPointer {
//            let list = PyList_New(0)
//            for element in self {
//                PyList_Append(list, element.pyPointer)
//            }
//            return list
//        }
//}

//extension Array where Element == PythonPointer {
//
//
////
////    @inlinable public var pythonList: PythonPointer {
////        let list = PyList_New(0)
////        for element in self {
////            PyList_Append(list, element)
////        }
////        return list
////    }
//
//    @inlinable public var pythonTuple: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, element)
//            Py_DecRef(element)
//        }
//        return tuple
//    }
//}

//extension Array where Element == String {
//    @inlinable public var pythonList: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, element.withCString(PyUnicode_FromString) )
//        }
//        return list
//    }
//
//    @inlinable public var pythonTuple: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyUnicode_FromString(element))
//        }
//        return tuple
//    }
//}
//
//extension Array where Element == URL {
//    @inlinable public var pythonList: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, element.path.withCString(PyUnicode_FromString) )
//        }
//        return list
//    }
//
//    @inlinable public var pythonTuple: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, element.path.withCString(PyUnicode_FromString) )
//        }
//        return tuple
//    }
//}

//extension Array where Element == Double {
//    @inlinable public var pythonList: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyFloat_FromDouble(element))
//        }
//        return list
//    }
//
//    @inlinable public var pythonTuple: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyFloat_FromDouble(element))
//        }
//        return tuple
//    }
//}


//extension Array where Element: SignedInteger  {
//    @inlinable public var pythonList: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromLong(Int(element)))
//        }
//        return list
//    }
//
//    @inlinable public var pythonTuple: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromLong(Int(element)))
//        }
//        return tuple
//    }
//}

//extension Array where Element: UnsignedInteger {
//    public var pythonList: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromUnsignedLong(UInt(element)))
//        }
//        return list
//    }
//
//    var pythonTuple: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromUnsignedLong(UInt(element)))
//        }
//        return tuple
//    }
//}


//extension Array where Element == Int {
//
//    init(_ object: PythonPointer) {
//        self.init()
//
//    }
//
//    @inlinable public var pythonList: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromLong(element))
//        }
//        return list
//    }
//
//    @inlinable public var pythonTuple: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromLong(element))
//        }
//        return tuple
//    }
//}

//extension Array where Element == UInt {
//    @inlinable public var pythonList: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromUnsignedLong(element))
//        }
//        return list
//    }
//
//    @inlinable public var pythonTuple: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromUnsignedLong(element))
//        }
//        return tuple
//    }
//}

//extension Array where Element == Bool {
//    @inlinable public var pythonList: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, element.object)
//        }
//        return list
//    }
//
//    @inlinable public var pythonTuple: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, element.object)
//        }
//        return tuple
//    }
//}


extension PythonPointer {
    
    public var printString: String {
        debugDescription
        //if let this = self {
            //return this.debugDescription
        //}
        //return "nil"
        
    }
}
