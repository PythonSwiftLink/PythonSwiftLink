import Foundation
import PythonCore
//import PythonTypeAlias

public enum PyEvalFlag: Int32 {
    case single = 256
    case file = 257
    case eval = 258
    case func_type = 345
    case fstring = 800
    
    
    
}
//#if BEEWARE

public func Py_ValidateCode(code: String,  filename: String, flag: PyEvalFlag) -> Bool {
    print("Py_CompileString:\n", code)
    PyErr_Clear()
    return code.withCString { str in
        //let gil = PyGILState_Ensure()
        return true
        
        if let result = Py_CompileString(str, filename, flag.rawValue) {
            print(result)
            result.decref()
            return true
        }
        
        return false
        //PyGILState_Release(gil)
        
        
        //return result
    }
}

public func Py_CompileString(code: String,  filename: String, flag: PyEvalFlag) -> PyPointer? {
    print("Py_CompileString:\n\n", code)
    PyErr_Clear()
    return code.withCString { str in
        //let gil = PyGILState_Ensure()
        return .PyNone
        
        let result = Py_CompileString(str, filename, flag.rawValue)
        //PyGILState_Release(gil)
        print(result)
        return result
    }
}
//#endif

public func PyRun_String(string: String, flag: PyEvalFlag, globals: PyPointer, locals: PyPointer) -> PyPointer? {
    string.withCString { str in
        PyRun_String(str, flag.rawValue, globals, locals)
    }
}

public func PyRun_URL(url: URL, flag: PyEvalFlag, globals: PyPointer, locals: PyPointer) -> PyPointer? {
    let string = try? String(contentsOf: url)
    return string?.withCString { str in
        PyRun_String(str, flag.rawValue, globals, locals)
    }
}
