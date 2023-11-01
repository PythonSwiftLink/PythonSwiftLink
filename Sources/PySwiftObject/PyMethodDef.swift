import Foundation
import PythonSwiftCore
//import PythonTypeAlias
import PythonCore

public class PyMethodDefWrap {
    
    public struct Flags: RawRepresentable {
        public var rawValue: Int32
        
        public typealias RawValue = Int32
        
        public static let NOARGS = Flags(rawValue: METH_NOARGS)!
        public static let VARARGS = Flags(rawValue: METH_VARARGS)!
        public static let KEYWORDS = Flags(rawValue: METH_KEYWORDS)!
        
        public static let O = Flags(rawValue: METH_O)!
        public static let CLASS = Flags(rawValue: METH_CLASS)!
        public static let STATIC = Flags(rawValue: METH_STATIC)!
        public static let COEXIST = Flags(rawValue: METH_COEXIST)!
        public static let FASTCALL = Flags(rawValue: METH_FASTCALL)!
        public static let METHOD = Flags(rawValue: METH_METHOD)!
        
        public static let FAST_KEYWORDS: Flags = FASTCALL | KEYWORDS
        
        public static let METHOD_FAST_KEYWORDS: Flags = METHOD | FASTCALL | KEYWORDS
        //        static let CLASS_NOARGS: Flags = CLASS | NOARGS
        //        static let CLASS_VARARGS: Flags = CLASS | VARARGS
        //        static let CLASS_KEYWORDS: Flags = CLASS | KEYWORDS
        //
        //        static let CLASS_FAST_VARARGS: Flags = CLASS | FASTCALL | VARARGS
        //        static let CLASS_FAST_KEYWORDS: Flags = CLASS | FASTCALL | KEYWORDS
        
        public init?(rawValue: Int32) {
            self.rawValue = rawValue
        }
        
        
        public static func |(lhs: Flags, rhs: Flags) -> Int32 {
            return lhs.rawValue | rhs.rawValue
        }
        public static func |(lhs: Flags, rhs: Flags) -> Flags {
            return .init(rawValue: lhs.rawValue | rhs.rawValue)!
        }
    }
    
    public let method_name: UnsafePointer<CChar>
    public let doc_string: UnsafePointer<CChar>!
    public var pyMethod: PyMethodDef
    public var auto_deallocate = true
    
    public convenience init(noArgs name: String,_ function: PyCFunc) {
        self.init(name: name, flag: .NOARGS, doc: nil, meth: function)
    }
    
    public convenience init(withArgs name: String, function: PyCVectorCall) {
        self.init(name: name, flag: .FASTCALL, doc: nil, meth: PyCFunctionFast_Cast(function))
    }
    
    public convenience init(oneArg name: String, function: PyCFunc) {
        self.init(name: name, flag: .O, doc: nil, meth: function)
    }
    
    public convenience init(withKeywords name: String, function: PyCVectorCallKeywords) {
        self.init(name: name, flag: .FAST_KEYWORDS, doc: nil, meth: PyCFunctionFastWithKeywords_Cast(function))
    }
    
    public convenience init(methodWithKeywords name: String, function: PyCMethodVectorCall) {
        self.init(name: name, flag: .FAST_KEYWORDS, doc: nil, meth: PyCMethod_Cast(function))
    }
    
    // self: PySwiftObjectPointer
    public convenience init(_noArgs name: String,_ function: PySwiftCFunc) {
        self.init(name: name, flag: .NOARGS, doc: nil, meth: unsafeBitCast(function, to: PyCFunc.self))
    }
    
    public convenience init(_withArgs name: String, function: PySwiftCVectorCall) {
        self.init(name: name, flag: .FASTCALL, doc: nil, meth: unsafeBitCast(function, to: PyCFunc.self))
    }
    
    public convenience init(_oneArg name: String, function: PySwiftCFunc) {
        self.init(name: name, flag: .O, doc: nil, meth: unsafeBitCast(function, to: PyCFunc.self))
    }
    
    public convenience init(_withKeywords name: String, function: PySwiftCVectorCallKeywords) {
        self.init(name: name, flag: .FAST_KEYWORDS, doc: nil, meth: unsafeBitCast(function, to: PyCFunc.self))
    }
    
    public convenience init(_methodWithKeywords name: String, function: PySwiftCMethodVectorCall) {
        self.init(name: name, flag: .FAST_KEYWORDS, doc: nil, meth: unsafeBitCast(function, to: PyCFunc.self))
    }
    
    public init(name: String, flag: Flags = .FASTCALL, doc: String? = nil, meth: PyCFunc) {
        let method_name: UnsafePointer<Int8> = makeCString(from: name)
        var doc_string: UnsafePointer<Int8>? = nil
        if let doc = doc {
            doc_string = doc.withCString { ptr in
                    .init(ptr)
            }
        }
        
        self.method_name = method_name
        self.doc_string = doc_string
        
        pyMethod = .init(
            ml_name: method_name,
            ml_meth: meth,
            ml_flags: flag.rawValue,
            ml_doc: doc_string
        )
    }
    
    deinit {
        if auto_deallocate {
            method_name.deallocate()
            if let doc_string = doc_string {
                doc_string.deallocate()
            }
        }
    }
}

@resultBuilder
public struct PyMethodDefBuilder {
    static public func buildBlock(_ components: PyMethodDefWrap...) -> ([PyMethodDefWrap], UnsafeMutablePointer<PyMethodDef>) {
        let count = components.count
        let methods_ptr: UnsafeMutablePointer<PyMethodDef> = .allocate(capacity: count + 1)
        
        for (i, meth) in components.enumerated() {
            methods_ptr[i] = meth.pyMethod
        }
        methods_ptr[count] = .init()
        return (components, methods_ptr)
    }
    static public func buildBlock(_ components: PyMethodDefWrap...) -> [PyMethodDefWrap] {
        let count = components.count
        let methods_ptr: UnsafeMutablePointer<PyMethodDef> = .allocate(capacity: count + 1)
        
        for (i, meth) in components.enumerated() {
            methods_ptr[i] = meth.pyMethod
        }
        methods_ptr[count] = .init()
        return (components)
    }
    
}

public func PyModule_AddFunctions(module: PyPointer?, @PyMethodDefBuilder methods: () -> ([PyMethodDefWrap], UnsafeMutablePointer<PyMethodDef>)) -> PyModuleCustomFunctions {
    let result = methods()
    PyModule_AddFunctions(module, result.1 )
    return .init(functions_pointer: result.1, functions: result.0)
}

public class PyModuleCustomFunctions {
    
    let functions_pointer: UnsafeMutablePointer<PyMethodDef>
    
    let functions: [PyMethodDefWrap]
    
    init(functions_pointer: UnsafeMutablePointer<PyMethodDef>, functions: [PyMethodDefWrap]) {
        self.functions_pointer = functions_pointer
        self.functions = functions
    }
    
    deinit {
        self.functions_pointer.deinitialize(count: functions.count + 1)
        self.functions_pointer.deallocate()
    }
    
    
}

public class PyMethodDefHandler {
    
    public let methods_ptr: UnsafeMutablePointer<PyMethodDef>
    var methods_container: [PyMethodDefWrap]
    var alloc_count: Int
    public var auto_deallocate = true
    
    public init(methods: [PyMethodDefWrap]) {
        
        methods_container = methods
        let count = methods.count
        alloc_count = count
        methods_ptr = .allocate(capacity: count + 1)
        for (i, meth) in methods.enumerated() {
            methods_ptr[i] = meth.pyMethod
        }
        methods_ptr[count] = .init()
        
    }
    
    public init(_ methods: PyMethodDefWrap... ) {
        methods_container = methods
        let count = methods.count
        methods_ptr = .allocate(capacity: count + 1)
        for (i, meth) in methods.enumerated() {
            methods_ptr[i] = meth.pyMethod
            
        }
        methods_ptr[count] = .init()
        alloc_count = count
    }
    //@PyMethodDefBuilder
    public init(@PyMethodDefBuilder input: () -> UnsafeMutablePointer<PyMethodDef> ) {
        methods_container = []
        methods_ptr = input()
        alloc_count = 0
    }
    
    public var methods_name_pointers: [UnsafePointer<CChar>] {
        methods_container.map(\.method_name)
    }
    
    deinit {
        if auto_deallocate {
            methods_ptr.deinitialize(count: alloc_count + 1)
            methods_ptr.deallocate()
        }
    }
}
