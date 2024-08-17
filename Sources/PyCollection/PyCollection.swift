
import PySwiftCore
import PythonCore
import Foundation
import PyDecode
import PyEncode

extension Array : PyDecodable where Element : PyDecodable {
	
	public init(object: PyPointer) throws {
		if PyList_Check(object) {
			self = try object.map {
				guard let element = $0 else { throw PythonError.index }
				return try Element(object: element)
			}//(Element.init)
		} else if PyTuple_Check(object) {
			self = try object.map {
				guard let element = $0 else { throw PythonError.index }
				return try Element(object: element)
			}//(Element.init)
		} else {
			throw PythonError.sequence
		}
	}
	
}


extension PythonPointer {
	@inlinable public func append<T: PyConvertible>(_ value: T) {
		let element = value.pyPointer
		PyList_Append(self, element)
		Py_DecRef(element)
	}
	@inlinable public func append(_ value: PyPointer) { PyList_Append(self, value) }
	@inlinable public func append<T: PyConvertible>(contentsOf: [T]) {
		for value in contentsOf { PyList_Append(self, value.pyPointer) }
	}
	
	@inlinable public func append(contentsOf: [PythonPointer]) {
		for value in contentsOf { PyList_Append(self, value) }
	}
	
	@inlinable public mutating func insert<C, T: PyConvertible>(contentsOf newElements: C, at i: Int) where C : Collection, C.Element == T {
		for element in newElements {
			PyList_Insert(self, i, element.pyPointer)
		}
	}
	
	
	
}


extension PythonPointer: Sequence {
	
	public typealias Iterator = PySequenceBuffer.Iterator
	
	public func makeIterator_old() -> PySequenceBuffer.Iterator {
		let fast_list = PySequence_Fast(self, nil)!
		let buffer = PySequenceBuffer(
			start: PySequence_FastItems(fast_list),
			count: PySequence_FastSize(fast_list)
		)
		
		defer { Py_DecRef(fast_list) }
		return buffer.makeIterator()
	}
	
	public func makeIterator() -> PySequenceBuffer.Iterator {
		//let fast_list = PySequence_Fast(self, nil)!
		let buffer = try! self.withMemoryRebound(to: PyListObject.self, capacity: 1) { pointer in
			let o = pointer.pointee
			return PySequenceBuffer(start: o.ob_item, count: o.allocated)
		}
		return buffer.makeIterator()
	}
	
	@inlinable
	public func pyMap<T>(_ transform: (PyPointer) throws -> T) rethrows -> [T] where T: PyDecodable {
		try self.withMemoryRebound(to: PyListObject.self, capacity: 1) { pointer in
			let o = pointer.pointee
			return try PySequenceBuffer(start: o.ob_item, count: o.allocated).map { element in
				guard let element = element else { throw PythonError.sequence }
				return try transform(element)
			}
		}
	}
}

extension PythonPointer {
	
	@inlinable
	public subscript<R: ConvertibleFromPython & PyConvertible>(index: Int) -> R? {
		
		get {
			if PyList_Check(self) {
				if let element = PyList_GetItem(self, index) {
					return try? R(object: element)
				}
				return nil
			}
			if PyTuple_Check(self) {
				if let element = PyTuple_GetItem(self, index) {
					return try? R(object: element)
				}
				return nil
			}
			return nil
		}
		
		set {
			if PyList_Check(self) {
				if let newValue = newValue {
					PyList_SetItem(self, index, newValue.pyPointer)
					return
				}
				PyList_SetItem(self, index, .None)
				return
			}
			if PyTuple_Check(self) {
				if let newValue = newValue {
					PyTuple_SetItem(self, index, newValue.pyPointer)
					return
				}
				PyTuple_SetItem(self, index, .None)
				return
			}
		}
	}
	
}
