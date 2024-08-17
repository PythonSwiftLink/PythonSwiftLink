import XCTest
@testable import PySwiftCore
@testable import PythonCore
@testable import PyExecute
@testable import PyDictionary
//@testable import PythonTestSuite
fileprivate extension PyPointer {
    
    var refCount: Int { Py_REFCNT(self) }
}
private func createPyTestFunction(name: String, _ code: String) throws -> PyPointer? {
    guard
        let kw = PyDict_New(),
        let lkw = PyDict_New(),
        let result = PyRun_String(string: code, flag: .file, globals: kw, locals: lkw)
    else {
        PyErr_Print()
        throw CocoaError(.coderInvalidValue)
    }
	let pyfunc: PyPointer = PyDict_GetItem(lkw, name).xINCREF
    kw.decref()
    lkw.decref()
    result.decref()
    return pyfunc
}
private var pythonIsRunning = false

var pystdlib: URL {
    Bundle.module.url(forResource: "python_stdlib", withExtension: nil)!
}
private func initPython() {
    if pythonIsRunning { return }
    pythonIsRunning.toggle()
//    let resourcePath = "/Users/musicmaker/Library/Mobile Documents/com~apple~CloudDocs/Projects/xcode_projects/touchBay_files/touchBay/touchBay"
    let resourcePath: String
    if #available(macOS 13, iOS 16, *) {
        resourcePath = pystdlib.path()
    } else {
        resourcePath = pystdlib.path
    }
    print(resourcePath)
    var config: PyConfig = .init()
    print("Configuring isolated Python for Testing...")
    PyConfig_InitIsolatedConfig(&config)
    
    // Configure the Python interpreter:
    // Run at optimization level 1
    // (remove assertions, set __debug__ to False)
    config.optimization_level = 1
    // Don't buffer stdio. We want output to appears in the log immediately
    config.buffered_stdio = 0
    // Don't write bytecode; we can't modify the app bundle
    // after it has been signed.
    config.write_bytecode = 0
    // Isolated apps need to set the full PYTHONPATH manually.
    config.module_search_paths_set = 1
    
    var status: PyStatus
    
    let python_home = "\(resourcePath)"
    
    var wtmp_str = Py_DecodeLocale(python_home, nil)
    
    var config_home: UnsafeMutablePointer<wchar_t>!// = config.home
    
    status = PyConfig_SetString(&config, &config_home, wtmp_str)
    
    PyMem_RawFree(wtmp_str)
    
    config.home = config_home
    
    status = PyConfig_Read(&config)
    
    print("PYTHONPATH:")
    
    let path = "\(resourcePath)"
    //let path = "\(resourcePath)/"
    
    print("- \(path)")
    wtmp_str = Py_DecodeLocale(path, nil)
    status = PyWideStringList_Append(&config.module_search_paths, wtmp_str)
    
    PyMem_RawFree(wtmp_str)
    
    
    //PyImport_AppendInittab(makeCString(from: "fib"), PyInitFib)
    
    //PyErr_Print()
    
    //let new_obj = NewPyObject(name: "fib", cls: Int.self, _methods: FibMethods)
    print("Initializing Python runtime...")
    status = Py_InitializeFromConfig(&config)
        
}
final class PythonSwiftCoreTests: XCTestCase {
    
    

    
    
    func test_PythonSwiftCore_callingPyFunction_shouldNotChangeRefCount() throws {
        initPython()
 
        let pyfunc = try createPyTestFunction(name: "doubleTest", """
            def doubleTest(a):
                print(a)
            """)
        let a: PyPointer = 4.56786442134.pyPointer
        let start_ref = a.refCount
        
        //print(_Py_REFCNT(a))
        XCTAssertNotNil(pyfunc)
        PyObject_CallOneArg(pyfunc, a)
        
        XCTAssertEqual(a.refCount, start_ref, "pyobject ref count should be equal after call")
        
        a.decref()
        //print(_Py_REFCNT(a))
        XCTAssertLessThan(Py_REFCNT(a), start_ref, "decref required after PyObject_CallOneArg")
        //XCTAssertEqual(start_start, _Py_REFCNT(a))
    }
    
    private func newDictionary() throws -> PyPointer {
        let _dict = PyDict_New()
        XCTAssertNotNil(_dict, "dictionary should not be nil")
        return _dict.unsafelyUnwrapped
    }
    
    private func newList() throws -> PyPointer {
        let object = PyList_New(0)
        XCTAssertNotNil(object, "list should not be nil")
        return object.unsafelyUnwrapped
    }
    
    private func newTuple(_ size: Int) throws -> PyPointer {
        let object = PyTuple_New(size)
        XCTAssertNotNil(object, "list should not be nil")
        return object.unsafelyUnwrapped
    }
    
    func test_PythonSwiftCore_pyDict_shouldChangeRefCount() throws {
        initPython()
        let dict = try newDictionary()
        let string = "world!!!!".pyPointer
        let string_rc = string.refCount
        PyDict_SetItem(dict, "hello", string)
        XCTAssertGreaterThan(string.refCount, string_rc)
        string.decref()
        dict.decref()
    }
	
	func test_PythonSwiftCore_pyDict_shouldChangeRefCount2() throws {
		initPython()
		let dict = try newDictionary()
		let string = "hello!!!!".pyPointer
		let string2 = "world!!!!".pyPointer
		let string_rc = string.refCount
		
		PyDict_SetItem(dict, "hello", string)
		XCTAssertGreaterThan(string.refCount, string_rc)
		if PyDict_Contains(dict, "hello") {
			PyDict_DelItem(dict, "hello")
			XCTAssertEqual(string.refCount, string_rc)
			PyDict_SetItem(dict, "hello", string)
			XCTAssertGreaterThan(string.refCount, string_rc)
		}
		
		PyDict_SetItem(dict, "hello", string2)
		XCTAssertEqual(string.refCount, string_rc)
		dict.decref()
		XCTAssertEqual(string_rc, string.refCount)
		XCTAssertEqual(string.refCount, 1)
		string.decref()
		
	}
    
    func test_PythonSwiftCore_pyDict_keyValues_afterGC_DidNotChange() throws {
        initPython()
        let dict = try newDictionary()
        let string = "world!!!!".pyPointer
        let string_rc = string.refCount
        PyDict_SetItem(dict, "hello", string)
        dict.decref()
        XCTAssertEqual(string_rc, string.refCount)
        XCTAssertEqual(string.refCount, 1)
        string.decref()
        
    }
    
    
    func test_PythonSwiftCore_pyList_shouldChangeRefCount() throws {
        initPython()
        let object = try newList()
        let string = "hello world!!!!".pyPointer
        let string_rc = string.refCount
        PyList_Append(object, string)
        XCTAssertGreaterThan(string.refCount, string_rc)
        string.decref()
        object.decref()
    }
    
    func test_PythonSwiftCore_pyList_Values_afterGC_DidNotChange() throws {
        initPython()
        let object = try newList()
        let string = "hello world!!!!".pyPointer
        let string_rc = string.refCount
        PyList_Append(object, string)
        object.decref()
        XCTAssertEqual(string_rc, string.refCount)
        XCTAssertEqual(string.refCount, 1)
        string.decref()
        
    }
    
    func test_PythonSwiftCore_pyTupleSetItem_shouldNotChangeRefCount() throws {
        initPython()
        let object = try newTuple(1)
        let string = "hello world!!!!".pyPointer
        let string_rc = string.refCount
        PyTuple_SetItem(object, 0, string)
        XCTAssertEqual(string_rc, string.refCount)
        object.decref()
      
    }
    
    func test_PythonSwiftCore_pyTuple_Values_afterGC_DidChange() throws {
        initPython()
        let object = try newTuple(1)
        let string = "hello world!!!!".pyPointer
        let string_rc = string.refCount
        PyTuple_SetItem(object, 0, string)
        let after_rc = string.refCount
        string.incref()
        XCTAssertEqual(string.refCount, 2)
        object.decref()
        XCTAssertEqual(string.refCount, after_rc)
        XCTAssertEqual(string.refCount, 1)
        string.decref()
        
    }
}
