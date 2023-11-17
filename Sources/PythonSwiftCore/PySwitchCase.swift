//
//  File.swift
//  
//
//  Created by CodeBuilder on 16/11/2023.
//

import Foundation
import PythonCore

public protocol PyTypeProtocol {
	static func ~=(l: Self, r: PyPointer) -> Bool
}


extension PyPointer {
	
	public static func ~=(l: PythonType, r: PyPointer) -> Bool  {
		return PyObject_TypeCheck(r, l) == 1
	}
	
}

extension PyEncodable {
	public static func ~= (l: Self, r: PyPointer) -> Bool {
		let left = l.pyPointer
		defer { Py_DecRef(left) }
		return PyObject_RichCompareBool(left, r, Py_EQ) == 1
	}
}

extension String: PyTypeProtocol {
	public static func ~= (l: String, r: PyPointer) -> Bool {
		l.withCString { str in
			PyUnicode_CompareWithASCIIString(r, str) == 1
		}
	}
}


public extension Optional where Wrapped == UnsafeMutablePointer<PyTypeObject> {
	static func newType(_ t: PyTypeObject) -> Self {
		let new: Self = .allocate(capacity: 1)
		new?.pointee = t
		return new
	}
}


public let pyLong_Type = PythonType.newType(PyLong_Type)!
public let pyFloat_Type = PythonType.newType(PyFloat_Type)!
public let pyUnicode_Type = PythonType.newType(PyUnicode_Type)!
public let pyComplex_Type = PythonType.newType(PyComplex_Type)!
public let pyBool_Type = PythonType.newType(PyBool_Type)!

public let pyList_Type = PythonType.newType(PyList_Type)!
public let pyDict_Type = PythonType.newType(PyDict_Type)!
public let pyTuple_Type = PythonType.newType(PyTuple_Type)!
public let pySet_Type = PythonType.newType(PySet_Type)!

public let pyBytes_Type = PythonType.newType(PyBytes_Type)!
public let pyByteArray_Type = PythonType.newType(PyByteArray_Type)!
public let pyMemoryView_Type = PythonType.newType(PyMemoryView_Type)!


public let pySuper_Type = PythonType.newType(PySuper_Type)!


public let pyEnum_Type = PythonType.newType(PyEnum_Type)!
public let pyNone_Type = PythonType.newType(_PyNone_Type)!

//private func test() {
//	let a = "a".pyPointer // PyObject
//	
//	switch a {
//		
//	case pyLong_Type: print("i am PyLong type")
//	case pyFloat_Type: print("i am PyFloat type")
//	case "a": print("i am the string \"a\"")
//	case 10: print("i am int value 10")
//	case 0.0: print("i am 0.0")
//	case [2, 1]: print("i am [2, 1]")
//	default: fatalError()
//		
//	}
//}
