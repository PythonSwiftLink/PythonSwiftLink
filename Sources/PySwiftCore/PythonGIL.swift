//
//  GIL.swift
//


import Foundation
//#if BEEWARE
import PythonCore

//#endif

@inlinable
public func withGIL(handle: @escaping ()->Void ) {
    let gil = PyGILState_Ensure()
    handle()
    PyGILState_Release(gil)
}
@discardableResult
public func gilCheck(_ title: String) -> Bool {
    let state = PyGILState_Check() == 1
    
    if state  {
        print("/* \(title) have the GIL */",state)
    } else {
        print("/* \(title) have no GIL */",state)
    }
    return state
}

@inlinable
public func withAutoGIL(handle: @escaping ()->Void ) {
    print("autogil")
    if PyGILState_Check() == 0 {
        if let state = PyThreadState_Get() {
            print("getting thread state:", state.pointee)
            gilCheck("PyThreadState_Get")
            handle()
            
            print(PyEval_RestoreThread(state) )
            return
        }
        let gil = PyGILState_Ensure()
        handle()
        PyGILState_Release(gil)
        return
    }
    
    gilCheck("autogil")
    //
    handle()
    
//    if PyGILState_Check() == 0 {
//
//        print(gil)
//        handle()
//
//    } else {
//        handle()
//    }
    
    PyEval_SaveThread()
}

extension DispatchQueue {
    
    @inlinable
    public func withGIL(handle: @escaping ()->Void ) {
        self.async {
            let gil = PyGILState_Ensure()
            handle()
            PyGILState_Release(gil)
        }
    }
}
