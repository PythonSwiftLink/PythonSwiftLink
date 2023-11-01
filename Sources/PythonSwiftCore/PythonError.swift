import Foundation
import PythonCore
//import PythonTypeAlias

//public func PyErr_Printer() -> (type: PyPointer, value: PyPointer, tb: PyPointer) {
//    var type: PyPointer = nil
//    var value: PyPointer = nil
//    var tb: PyPointer = nil
//    PyErr_Fetch(&type, &value, &tb)
//    return (type,value,tb)
//}



//extension Error {
//    public var pyPointer: PyPointer {
//        localizedDescription.pyPointer
//    }
//}


//extension Optional where Wrapped == Error {
//    public var pyPointer: PyPointer {
//        if let this = self {
//            return this.localizedDescription.pyPointer
//        }
//        return .PyNone
//    }
//}


public func PyErr_Printer(_ com: @escaping (_ type: PyPointer?,_ value: PyPointer?,_ tb: PyPointer?) -> () ) {
    var type: PyPointer? = nil
    var value: PyPointer? = nil
    var tb: PyPointer? = nil
    PyErr_Fetch(&type, &value, &tb)
    com(type,value,tb)
    
    if let type = type { type.decref() }
    if let value = value { value.decref() }
    if let tb = tb { tb.decref() }
    //PyErr_Restore(type, value, tb)
    //PyErr_Clear()
}

/**
    Repeats a string `times` times.

    - Parameter str:   The string to repeat.
    - Parameter times: The number of times to repeat `str`.

    - Throws: `MyError.InvalidTimes` if the `times` parameter
      is less than zero.

    - Returns: A new string with `str` repeated `times` times.
*/

public struct PyScriptError {
    public let except_text: String
    public let line_no: Int
    public let start: Int
    public let end: Int
    public let line_text: String
}

public func PyErr_Printer() -> PyScriptError {
    var except_string = ""
    var line_no = 0
    var start = 0
    var end = 0
    var text = ""
    
    PyErr_Printer { type, value, tb in
        do {
            except_string = try PyTuple_GetItem(value, 0)
            let line_tuple = PyTuple_GetItem(value, 1)
            
            line_no = try PyTuple_GetItem(line_tuple, 1)
            start = try PyTuple_GetItem(line_tuple, 2)
            text = try PyTuple_GetItem(line_tuple, 3)
            end = try PyTuple_GetItem(line_tuple, 5)
        } catch _ { }
    }
    //print(except_string)
    text.removeFirst()
    print(line_no,start,end,text)
    
    return .init(except_text: except_string, line_no: line_no, start: start, end: end, line_text: text)
    
}



public enum PythonError: Error {
    case unicode
    case long
    case float
    case call
    case attribute
    case index
    case sequence
    case notPySwiftObject
    case type(String)
    case memory(String)
}

extension PythonError: PyConvertible {
    public var pyObject: PythonObject {
        .init(getter: pyPointer)
    }
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

extension Error {
    public func pyExceptionError() {
        localizedDescription.withCString { PyErr_SetString(PyExc_Exception, $0) }
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


extension String {
    
}



// example
//
//fileprivate func PythonToSwift(input: PythonPointer) -> PythonPointer {
//    
//    let nargs = Int.random(in: 0...16)
//    do {
//        guard nargs > 0 else { throw PythonError.call }
//        try String(object: input) // throws Unicode error
//    }
//    catch let err as PythonError {
//        switch err {
//        case .call: err.triggerError("wanted \(5) got \(nargs)")
//        default: err.triggerError("PythonToSwift fucked up")
//        }
//        return nil
//    }
//    catch let other_error {
//        other_error.pyExceptionError()
//        return nil
//    }
//    return .PyNone
//}
