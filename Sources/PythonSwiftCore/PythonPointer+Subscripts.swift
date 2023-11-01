import Foundation
import PythonCore
//import PythonTypeAlias



extension PythonPointer: Sequence {

    public typealias Iterator = PySequenceBuffer.Iterator

    public func makeIterator() -> PySequenceBuffer.Iterator {
        let fast_list = PySequence_Fast(self, nil)
        let buffer = PySequenceBuffer(
            start: PythonSequence_Fast_ITEMS(fast_list),
            count: PythonSequence_Fast_GET_SIZE(fast_list)
        )
        Py_DecRef(fast_list)
        return buffer.makeIterator()
    }

}

extension PythonPointer {
    
    @inlinable
    public subscript<R: ConvertibleFromPython & PyConvertible>(index: Int) -> R? {
        
        get {
            if PythonList_Check(self) {
                if let element = PyList_GetItem(self, index) {
                    return try? R(object: element)
                }
                return nil
            }
            if PythonTuple_Check(self) {
                if let element = PyTuple_GetItem(self, index) {
                    return try? R(object: element)
                }
                return nil
            }
            return nil
        }
        
        set {
            if PythonList_Check(self) {
                if let newValue = newValue {
                    PyList_SetItem(self, index, newValue.pyPointer)
                    return
                }
                PyList_SetItem(self, index, .PyNone)
                return
            }
            if PythonTuple_Check(self) {
                if let newValue = newValue {
                    PyTuple_SetItem(self, index, newValue.pyPointer)
                    return
                }
                PyTuple_SetItem(self, index, .PyNone)
                return
            }
        }
    }
    
}

extension PythonPointer {
    @inlinable public func append<T: PyConvertible>(_ value: T) { PyList_Append(self, value.pyPointer) }
    @inlinable public func append(_ value: PyPointer) { PyList_Append(self, value) }
    @inlinable public func append<T: PyConvertible>(contentsOf: [T]) {
        for value in contentsOf { PyList_Append(self, value.pyPointer) }
    }
    
    @inlinable public func append(contentsOf: [PythonPointer]) {
        for value in contentsOf { PyList_Append(self, value) }
    }
    
    @inlinable public mutating func insert<C, T: PyConvertible>(contentsOf newElements: C, at i: Int) where C : Collection, C.Element == T {
        for element in newElements {
            PyList_Insert(self, i, element.pyPointer)
        }
    }
    
    
    
}

//extension PythonPointer {
//
//    @inlinable
//    public subscript(index: Int) -> PythonPointer {
//        
//        get {
//            if PythonList_Check(self) {
//                return PyList_GetItem(self, index)!
//            }
//            if PythonTuple_Check(self) {
//                return PyTuple_GetItem(self, index)!
//            }
//            return nil
//            }
//            
//        set {
//            if PythonList_Check(self) {
//                PyList_SetItem(self, index, newValue)
//            }
//            if PythonTuple_Check(self) {
//                PyTuple_SetItem(self, index, newValue)
//            }
//        }
//    }
//
//    @inlinable
//    public subscript(index: Int) -> PythonPointerU {
//        
//        get {
//            if PythonList_Check(self) {
//                return PyList_GetItem(self, index)
//            }
//            if PythonTuple_Check(self) {
//                return PyTuple_GetItem(self, index)
//            }
//            fatalError()
//            }
//            
//        set {
//            if PythonList_Check(self) {
//                PyList_SetItem(self, index, newValue)
//            }
//            if PythonTuple_Check(self) {
//                PyTuple_SetItem(self, index, newValue)
//            }
//        }
//    }
//
//    @inlinable
//    public subscript(bounds: Range<Int>) -> PythonPointerU {
//        get {
//            if PythonList_Check(self) { return PyList_GetSlice(self, bounds.lowerBound, bounds.upperBound) }
//            fatalError()
//        }
//        set {
//            if PythonList_Check(self) { PyList_SetSlice(self, bounds.lowerBound, bounds.upperBound, newValue) }
//        }
//    }
//    
//    @inlinable
//    public subscript(bounds: Range<Int>) -> PythonPointer {
//        get {
//            if PythonList_Check(self) { return PyList_GetSlice(self, bounds.lowerBound, bounds.upperBound) }
//            return nil
//        }
//        set {
//            if PythonList_Check(self) { PyList_SetSlice(self, bounds.lowerBound, bounds.upperBound, newValue) }
//        }
//    }
//
//        @inlinable
//    public subscript(index: Int) -> String {
//        
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetItem(self, index)
//                let value = String(cString: PyUnicode_AsUTF8(temp))
//                //Py_DecRef(temp)
//                return value
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyTuple_GetItem(self, index)
//                let value = String(cString: PyUnicode_AsUTF8(temp))
//                //Py_DecRef(temp)
//                return value
//            }
//            fatalError()
//            }
//            
//        set {
//            if PythonList_Check(self) {
//                let temp = PyUnicode_FromString(newValue)
//                PyList_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyUnicode_FromString(newValue)
//                PyTuple_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//        }
//    }
//
//    @inlinable
//    public subscript(bounds: Range<Int>) -> [String] {
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetSlice(self, bounds.lowerBound, bounds.upperBound)
//                let array: [String] = temp.array()
//                //Py_DecRef(temp)
//                return array
//            }
//            fatalError()
//        }
//        set {
//            if PythonList_Check(self) {
//                let list = newValue.list_object
//                PyList_SetSlice(self, bounds.lowerBound, bounds.upperBound, list)
//                Py_DecRef(list)
//            }
//        }
//    }
//    
//    @inlinable
//    public subscript(index: Int) -> Int {
//        
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetItem(self, index)
//                let value = PyLong_AsLong(temp)
//                //Py_DecRef(temp)
//                return value
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyTuple_GetItem(self, index)
//                let value = PyLong_AsLong(temp)
//                //Py_DecRef(temp)
//                return value
//            }
//            fatalError()
//            }
//            
//        set {
//            if PythonList_Check(self) {
//                let temp = PyLong_FromLong(newValue)
//                PyList_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyLong_FromLong(newValue)
//                PyTuple_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//        }
//    }
//
//    @inlinable
//    public subscript(bounds: Range<Int>) -> [Int] {
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetSlice(self, bounds.lowerBound, bounds.upperBound)
//                let array: [Int] = temp.array()
//                //Py_DecRef(temp)
//                return array
//            }
//            fatalError()
//        }
//        set {
//            if PythonList_Check(self) {
//                let list = newValue.list_object
//                PyList_SetSlice(self, bounds.lowerBound, bounds.upperBound, list)
//                Py_DecRef(list)
//            }
//        }
//    }
//    
//    @inlinable
//    public subscript(index: Int) -> UInt {
//        
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetItem(self, index)
//                let value = PyLong_AsUnsignedLong(temp)
//                //Py_DecRef(temp)
//                return value
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyTuple_GetItem(self, index)
//                let value = PyLong_AsUnsignedLong(temp)
//                //Py_DecRef(temp)
//                return value
//            }
//            fatalError()
//            }
//            
//        set {
//            if PythonList_Check(self) {
//                let temp = PyLong_FromUnsignedLong(newValue)
//                PyList_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyLong_FromUnsignedLong(newValue)
//                PyTuple_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//        }
//    }
//
//    @inlinable
//    public subscript(bounds: Range<Int>) -> [UInt] {
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetSlice(self, bounds.lowerBound, bounds.upperBound)
//                let array: [UInt] = temp.array()
//                //Py_DecRef(temp)
//                return array
//            }
//            fatalError()
//        }
//        set {
//            if PythonList_Check(self) {
//                let list = newValue.list_object
//                PyList_SetSlice(self, bounds.lowerBound, bounds.upperBound, list)
//                Py_DecRef(list)
//            }
//        }
//    }
//    
//    @inlinable
//    public subscript(index: Int) -> Int64 {
//        
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetItem(self, index)
//                let value = PyLong_AsLongLong(temp)
//                //Py_DecRef(temp)
//                return value
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyTuple_GetItem(self, index)
//                let value = PyLong_AsLongLong(temp)
//                //Py_DecRef(temp)
//                return value
//            }
//            fatalError()
//            }
//            
//        set {
//            if PythonList_Check(self) {
//                let temp = PyLong_FromLongLong(newValue)
//                PyList_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyLong_FromLongLong(newValue)
//                PyTuple_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//        }
//    }
//
//    @inlinable
//    public subscript(bounds: Range<Int>) -> [Int64] {
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetSlice(self, bounds.lowerBound, bounds.upperBound)
//                let array: [Int64] = temp.array()
//                //Py_DecRef(temp)
//                return array
//            }
//            fatalError()
//        }
//        set {
//            if PythonList_Check(self) {
//                let list = newValue.list_object
//                PyList_SetSlice(self, bounds.lowerBound, bounds.upperBound, list)
//                Py_DecRef(list)
//            }
//        }
//    }
//    
//    @inlinable
//    public subscript(index: Int) -> UInt64 {
//        
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetItem(self, index)
//                let value = PyLong_AsUnsignedLongLong(temp)
//                //Py_DecRef(temp)
//                return value
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyTuple_GetItem(self, index)
//                let value = PyLong_AsUnsignedLongLong(temp)
//                //Py_DecRef(temp)
//                return value
//            }
//            fatalError()
//            }
//            
//        set {
//            if PythonList_Check(self) {
//                let temp = PyLong_FromUnsignedLongLong(newValue)
//                PyList_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyLong_FromUnsignedLongLong(newValue)
//                PyTuple_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//        }
//    }
//
//    @inlinable
//    public subscript(bounds: Range<Int>) -> [UInt64] {
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetSlice(self, bounds.lowerBound, bounds.upperBound)
//                let array: [UInt64] = temp.array()
//                //Py_DecRef(temp)
//                return array
//            }
//            fatalError()
//        }
//        set {
//            if PythonList_Check(self) {
//                let list = newValue.list_object
//                PyList_SetSlice(self, bounds.lowerBound, bounds.upperBound, list)
//                Py_DecRef(list)
//            }
//        }
//    }
//    
//    @inlinable
//    public subscript(index: Int) -> Int32 {
//        
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetItem(self, index)
//                let value = Int32(PyLong_AsLong(temp))
//                //Py_DecRef(temp)
//                return value
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyTuple_GetItem(self, index)
//                let value = Int32(PyLong_AsLong(temp))
//                //Py_DecRef(temp)
//                return value
//            }
//            fatalError()
//            }
//            
//        set {
//            if PythonList_Check(self) {
//                let temp = PyLong_FromLong(Int(newValue))
//                PyList_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyLong_FromLong(Int(newValue))
//                PyTuple_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//        }
//    }
//
//    @inlinable
//    public subscript(bounds: Range<Int>) -> [Int32] {
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetSlice(self, bounds.lowerBound, bounds.upperBound)
//                let array: [Int32] = temp.array()
//                //Py_DecRef(temp)
//                return array
//            }
//            fatalError()
//        }
//        set {
//            if PythonList_Check(self) {
//                let list = newValue.list_object
//                PyList_SetSlice(self, bounds.lowerBound, bounds.upperBound, list)
//                Py_DecRef(list)
//            }
//        }
//    }
//    
//    @inlinable
//    public subscript(index: Int) -> UInt32 {
//        
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetItem(self, index)
//                let value = UInt32(PyLong_AsUnsignedLong(temp))
//                //Py_DecRef(temp)
//                return value
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyTuple_GetItem(self, index)
//                let value = UInt32(PyLong_AsUnsignedLong(temp))
//                //Py_DecRef(temp)
//                return value
//            }
//            fatalError()
//            }
//            
//        set {
//            if PythonList_Check(self) {
//                let temp = PyLong_FromUnsignedLong(UInt(newValue))
//                PyList_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyLong_FromUnsignedLong(UInt(newValue))
//                PyTuple_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//        }
//    }
//
//    @inlinable
//    public subscript(bounds: Range<Int>) -> [UInt32] {
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetSlice(self, bounds.lowerBound, bounds.upperBound)
//                let array: [UInt32] = temp.array()
//                //Py_DecRef(temp)
//                return array
//            }
//            fatalError()
//        }
//        set {
//            if PythonList_Check(self) {
//                let list = newValue.list_object
//                PyList_SetSlice(self, bounds.lowerBound, bounds.upperBound, list)
//                Py_DecRef(list)
//            }
//        }
//    }
//    
//    @inlinable
//    public subscript(index: Int) -> Int16 {
//        
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetItem(self, index)
//                let value = Int16(PyLong_AsLong(temp))
//                //Py_DecRef(temp)
//                return value
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyTuple_GetItem(self, index)
//                let value = Int16(PyLong_AsLong(temp))
//                //Py_DecRef(temp)
//                return value
//            }
//            fatalError()
//            }
//            
//        set {
//            if PythonList_Check(self) {
//                let temp = PyLong_FromLong(Int(newValue))
//                PyList_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyLong_FromLong(Int(newValue))
//                PyTuple_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//        }
//    }
//
//    @inlinable
//    public subscript(bounds: Range<Int>) -> [Int16] {
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetSlice(self, bounds.lowerBound, bounds.upperBound)
//                let array: [Int16] = temp.array()
//                //Py_DecRef(temp)
//                return array
//            }
//            fatalError()
//        }
//        set {
//            if PythonList_Check(self) {
//                let list = newValue.list_object
//                PyList_SetSlice(self, bounds.lowerBound, bounds.upperBound, list)
//                Py_DecRef(list)
//            }
//        }
//    }
//    
//    @inlinable
//    public subscript(index: Int) -> UInt16 {
//        
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetItem(self, index)
//                let value = UInt16(PyLong_AsUnsignedLong(temp))
//                //Py_DecRef(temp)
//                return value
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyTuple_GetItem(self, index)
//                let value = UInt16(PyLong_AsUnsignedLong(temp))
//                //Py_DecRef(temp)
//                return value
//            }
//            fatalError()
//            }
//            
//        set {
//            if PythonList_Check(self) {
//                let temp = PyLong_FromUnsignedLong(UInt(newValue))
//                PyList_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyLong_FromUnsignedLong(UInt(newValue))
//                PyTuple_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//        }
//    }
//
//    @inlinable
//    public subscript(bounds: Range<Int>) -> [UInt16] {
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetSlice(self, bounds.lowerBound, bounds.upperBound)
//                let array: [UInt16] = temp.array()
//                //Py_DecRef(temp)
//                return array
//            }
//            fatalError()
//        }
//        set {
//            if PythonList_Check(self) {
//                let list = newValue.list_object
//                PyList_SetSlice(self, bounds.lowerBound, bounds.upperBound, list)
//                Py_DecRef(list)
//            }
//        }
//    }
//    
//    @inlinable
//    public subscript(index: Int) -> Int8 {
//        
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetItem(self, index)
//                let value = Int8(PyLong_AsLong(temp))
//                //Py_DecRef(temp)
//                return value
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyTuple_GetItem(self, index)
//                let value = Int8(PyLong_AsLong(temp))
//                //Py_DecRef(temp)
//                return value
//            }
//            fatalError()
//            }
//            
//        set {
//            if PythonList_Check(self) {
//                let temp = PyLong_FromLong(Int(newValue))
//                PyList_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyLong_FromLong(Int(newValue))
//                PyTuple_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//        }
//    }
//
//    @inlinable
//    public subscript(bounds: Range<Int>) -> [Int8] {
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetSlice(self, bounds.lowerBound, bounds.upperBound)
//                let array: [Int8] = temp.array()
//                //Py_DecRef(temp)
//                return array
//            }
//            fatalError()
//        }
//        set {
//            if PythonList_Check(self) {
//                let list = newValue.list_object
//                PyList_SetSlice(self, bounds.lowerBound, bounds.upperBound, list)
//                Py_DecRef(list)
//            }
//        }
//    }
//    
//    @inlinable
//    public subscript(index: Int) -> UInt8 {
//        
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetItem(self, index)
//                let value = UInt8(PyLong_AsUnsignedLong(temp))
//                //Py_DecRef(temp)
//                return value
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyTuple_GetItem(self, index)
//                let value = UInt8(PyLong_AsUnsignedLong(temp))
//                //Py_DecRef(temp)
//                return value
//            }
//            fatalError()
//            }
//            
//        set {
//            if PythonList_Check(self) {
//                let temp = PyLong_FromUnsignedLong(UInt(newValue))
//                PyList_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyLong_FromUnsignedLong(UInt(newValue))
//                PyTuple_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//        }
//    }
//
//    @inlinable
//    public subscript(bounds: Range<Int>) -> [UInt8] {
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetSlice(self, bounds.lowerBound, bounds.upperBound)
//                let array: [UInt8] = temp.array()
//                //Py_DecRef(temp)
//                return array
//            }
//            fatalError()
//        }
//        set {
//            if PythonList_Check(self) {
//                let list = newValue.list_object
//                PyList_SetSlice(self, bounds.lowerBound, bounds.upperBound, list)
//                Py_DecRef(list)
//            }
//        }
//    }
//    
//    @inlinable
//    public subscript(index: Int) -> Float {
//        
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetItem(self, index)
//                let value = Float(PyFloat_AsDouble(temp))
//                //Py_DecRef(temp)
//                return value
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyTuple_GetItem(self, index)
//                let value = Float(PyFloat_AsDouble(temp))
//                //Py_DecRef(temp)
//                return value
//            }
//            fatalError()
//            }
//            
//        set {
//            if PythonList_Check(self) {
//                let temp = PyFloat_FromDouble(Double(newValue))
//                PyList_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyFloat_FromDouble(Double(newValue))
//                PyTuple_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//        }
//    }
//
//    @inlinable
//    public subscript(bounds: Range<Int>) -> [Float] {
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetSlice(self, bounds.lowerBound, bounds.upperBound)
//                let array: [Float] = temp.array()
//                //Py_DecRef(temp)
//                return array
//            }
//            fatalError()
//        }
//        set {
//            if PythonList_Check(self) {
//                let list = newValue.list_object
//                PyList_SetSlice(self, bounds.lowerBound, bounds.upperBound, list)
//                Py_DecRef(list)
//            }
//        }
//    }
//    
//    @inlinable
//    public subscript(index: Int) -> Double {
//        
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetItem(self, index)
//                let value = Double(PyFloat_AsDouble(temp))
//                ////Py_DecRef(temp)
//                return value
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyTuple_GetItem(self, index)
//                let value = Double(PyFloat_AsDouble(temp))
//                ////Py_DecRef(temp)
//                return value
//            }
//            fatalError()
//            }
//            
//        set {
//            if PythonList_Check(self) {
//                let temp = PyFloat_FromDouble(newValue)
//                PyList_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//            if PythonTuple_Check(self) {
//                let temp = PyFloat_FromDouble(newValue)
//                PyTuple_SetItem(self, index, temp)
//                //Py_DecRef(temp)
//            }
//        }
//    }
//
//    @inlinable
//    public subscript(bounds: Range<Int>) -> [Double] {
//        get {
//            if PythonList_Check(self) {
//                let temp = PyList_GetSlice(self, bounds.lowerBound, bounds.upperBound)
//                let array: [Double] = temp.array()
//                //Py_DecRef(temp)
//                return array
//            }
//            fatalError()
//        }
//        set {
//            if PythonList_Check(self) {
//                let list = newValue.list_object
//                PyList_SetSlice(self, bounds.lowerBound, bounds.upperBound, list)
//                Py_DecRef(list)
//            }
//        }
//    }
//    
//
//}
