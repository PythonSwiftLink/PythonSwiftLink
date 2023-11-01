import Foundation
//import PythonSwiftCore
//import PythonTypeAlias


//@inlinable func makeCString(from str: String) -> UnsafeMutablePointer<Int8> {
//	let _count = str.utf8.count + 1
//	let result = UnsafeMutablePointer<Int8>.allocate(capacity: _count)
//	str.withCString { (baseAddress) in
//		// func initialize(from: UnsafePointer<Pointee>, count: Int)
//		result.initialize(from: baseAddress, count: _count)
//	}
//	//count = _count
//	return result
//}
//
//@inlinable func makeCString(from str: String) -> UnsafePointer<Int8> {
//	let _count = str.utf8.count + 1
//	let result = UnsafeMutablePointer<Int8>.allocate(capacity: _count)
//	str.withCString { (baseAddress) in
//		// func initialize(from: UnsafePointer<Pointee>, count: Int)
//		result.initialize(from: baseAddress, count: _count)
//	}
//	//count = _count
//	return .init(result)
//}
