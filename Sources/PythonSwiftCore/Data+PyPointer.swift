import Foundation
import PythonCore
//import PythonTypeAlias



extension Data {
    
    init(pyUnicode o: PyPointer) throws {
        guard let ptr = PythonUnicode_DATA(o) else { throw PythonError.unicode }
        self.init(bytes: ptr, count: PyUnicode_GetLength(o))
    }
    
    init(pyUnicodeNoCopy o: PyPointer) throws {
        guard let ptr = PythonUnicode_DATA(o) else { throw PythonError.unicode }
        self.init(bytesNoCopy: ptr, count: PyUnicode_GetLength(o), deallocator: .none)
    }
    
    init(memoryviewNoCopy o: PyPointer) throws {
        var indices = [0]
        guard
            let py_buf = PythonMemoryView_GET_BUFFER(o),
            let buf_ptr = PyBuffer_GetPointer(py_buf, &indices)
        else { throw PythonError.unicode }
        let data_size = PyObject_Size(o)
        
        self.init(bytesNoCopy: buf_ptr, count: data_size, deallocator: .none)
    }
    
}
