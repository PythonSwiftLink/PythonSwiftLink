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
//        return .None
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

//public struct PyScriptError {
//    public let except_text: String
//    public let line_no: Int
//    public let start: Int
//    public let end: Int
//    public let line_text: String
//}
//
//public func PyErr_Printer() -> PyScriptError {
//    var except_string = ""
//    var line_no = 0
//    var start = 0
//    var end = 0
//    var text = ""
//    
//    PyErr_Printer { type, value, tb in
//        do {
//            except_string = try PyTuple_GetItem(value, 0)
//            let line_tuple = PyTuple_GetItem(value, 1)
//            
//            line_no = try PyTuple_GetItem(line_tuple, 1)
//            start = try PyTuple_GetItem(line_tuple, 2)
//            text = try PyTuple_GetItem(line_tuple, 3)
//            end = try PyTuple_GetItem(line_tuple, 5)
//        } catch _ { }
//    }
//    //print(except_string)
//    text.removeFirst()
//    print(line_no,start,end,text)
//    
//    return .init(except_text: except_string, line_no: line_no, start: start, end: end, line_text: text)
//    
//}



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



extension Error {
	public func pyExceptionError(exc: PyPointer? = nil ) {
        localizedDescription.withCString { PyErr_SetString(exc ?? PyExc_Exception, $0) }
    }
	
	public func raiseException(exc: PyPointer, _ message: String) {
		message.withCString { PyErr_SetString(exc, $0) }
	}
}


public enum PyExceptionType: Error {
	case arithmeticError
	case assertionError
	case attributeError
	case baseException
	case baseExceptionGroup
	case blockingIOError
	case brokenPipeError
	case bufferError
	case bytesWarning
	case childProcessError
	case connectionAbortedError
	case connectionError
	case connectionRefusedError
	case connectionResetError
	case deprecationWarning
	case eofError
	case encodingWarning
	case environmentError
	case exception
	case fileExistsError
	case fileNotFoundError
	case floatingPointError
	case futureWarning
	case generatorExit
	case ioError
	case importError
	case importWarning
	case indentationError
	case indexError
	case interruptedError
	case isADirectoryError
	case keyError
	case keyboardInterrupt
	case lookupError
	case memoryError
	case moduleNotFoundError
	case nameError
	case notADirectoryError
	case notImplementedError
	case osError
	case overflowError
	case pendingDeprecationWarning
	case permissionError
	case processLookupError
	case recursionError
	case referenceError
	case resourceWarning
	case runtimeError
	case runtimeWarning
	case stopAsyncIteration
	case stopIteration
	case syntaxError
	case syntaxWarning
	case systemError
	case systemExit
	case tabError
	case timeoutError
	case typeError
	case unboundLocalError
	case unicodeDecodeError
	case unicodeEncodeError
	case unicodeError
	case unicodeTranslateError
	case unicodeWarning
	case userWarning
	case valueError
	case warning
	case windowsError
	case zeroDivisionError
}

public func handlePyException(type: PyPointer) -> PyExceptionType? {
	switch type {
	case PyExc_ArithmeticError: return .arithmeticError
	case PyExc_AssertionError: return .assertionError
	case PyExc_AttributeError: return .attributeError
	case PyExc_BaseException: return .baseException
	case PyExc_BaseExceptionGroup: return .baseExceptionGroup
	case PyExc_BlockingIOError: return .blockingIOError
	case PyExc_BrokenPipeError: return .brokenPipeError
	case PyExc_BufferError: return .bufferError
	case PyExc_BytesWarning: return .bytesWarning
	case PyExc_ChildProcessError: return .childProcessError
	case PyExc_ConnectionAbortedError: return .connectionAbortedError
	case PyExc_ConnectionError: return .connectionError
	case PyExc_ConnectionRefusedError: return .connectionRefusedError
	case PyExc_ConnectionResetError: return .connectionResetError
	case PyExc_DeprecationWarning: return .deprecationWarning
	case PyExc_EOFError: return .eofError
	case PyExc_EncodingWarning: return .encodingWarning
	case PyExc_EnvironmentError: return .environmentError
	case PyExc_Exception: return .exception
	case PyExc_FileExistsError: return .fileExistsError
	case PyExc_FileNotFoundError: return .fileNotFoundError
	case PyExc_FloatingPointError: return .floatingPointError
	case PyExc_FutureWarning: return .futureWarning
	case PyExc_GeneratorExit: return .generatorExit
	case PyExc_IOError: return .ioError
	case PyExc_ImportError: return .importError
	case PyExc_ImportWarning: return .importWarning
	case PyExc_IndentationError: return .indentationError
	case PyExc_IndexError: return .indexError
	case PyExc_InterruptedError: return .interruptedError
	case PyExc_IsADirectoryError: return .isADirectoryError
	case PyExc_KeyError: return .keyError
	case PyExc_KeyboardInterrupt: return .keyboardInterrupt
	case PyExc_LookupError: return .lookupError
	case PyExc_MemoryError: return .memoryError
	case PyExc_ModuleNotFoundError: return .moduleNotFoundError
	case PyExc_NameError: return .nameError
	case PyExc_NotADirectoryError: return .notADirectoryError
	case PyExc_NotImplementedError: return .notImplementedError
	case PyExc_OSError: return .osError
	case PyExc_OverflowError: return .overflowError
	case PyExc_PendingDeprecationWarning: return .pendingDeprecationWarning
	case PyExc_PermissionError: return .permissionError
	case PyExc_ProcessLookupError: return .processLookupError
	case PyExc_RecursionError: return .recursionError
	case PyExc_ReferenceError: return .referenceError
	case PyExc_ResourceWarning: return .resourceWarning
	case PyExc_RuntimeError: return .runtimeError
	case PyExc_RuntimeWarning: return .runtimeWarning
	case PyExc_StopAsyncIteration: return .stopAsyncIteration
	case PyExc_StopIteration: return .stopIteration
	case PyExc_SyntaxError: return .syntaxError
	case PyExc_SyntaxWarning: return .syntaxWarning
	case PyExc_SystemError: return .systemError
	case PyExc_SystemExit: return .systemExit
	case PyExc_TabError: return .tabError
	case PyExc_TimeoutError: return .timeoutError
	case PyExc_TypeError: return .typeError
	case PyExc_UnboundLocalError: return .unboundLocalError
	case PyExc_UnicodeDecodeError: return .unicodeDecodeError
	case PyExc_UnicodeEncodeError: return .unicodeEncodeError
	case PyExc_UnicodeError: return .unicodeError
	case PyExc_UnicodeTranslateError: return .unicodeTranslateError
	case PyExc_UnicodeWarning: return .unicodeWarning
	case PyExc_UserWarning: return .userWarning
	case PyExc_ValueError: return .valueError
	case PyExc_Warning: return .warning
		//case PyExc_WindowsError: return .windowsError
	case PyExc_ZeroDivisionError: return .zeroDivisionError
	default: return nil
	}
}
