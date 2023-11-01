//
//  PythonBuffer+AutoDecRef.swift
//  metacam
//
//  Created by MusicMaker on 01/03/2022.
//

import Foundation


//class PythonPointerAutoRelease {
//    let ptr: PythonPointer
//    private let keep: Bool
//    
//    init(pointer: PythonPointer, keep: Bool = true) {
//        self.ptr = pointer
//        self.keep = keep
//        if keep {
//            Py_IncRef(pointer)
//        }
//    }
//    
//    init(from_getattr pointer: PythonPointer) {
//        ptr = pointer
//        self.keep = true
//    }
//    
//    deinit {
//        if keep {
//            Py_DecRef(ptr)
//            print("deinit \(ptr!) ref count is now \(ptr!.pointee.ob_refcnt)")
//        }
//    }
//}
