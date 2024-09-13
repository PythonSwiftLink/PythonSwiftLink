import Foundation
import PythonCore
//import PythonTypeAlias






public func PyBuffer_FillInfo<B: StaticPyBufferProtocol>(src: inout B, buffer: UnsafeMutablePointer<Py_buffer>) -> Int32 {
	B.__fill_buffer__(src: &src, buffer: buffer)
}

public protocol PyBufferProtocol {
	func __buffer__(s: PyPointer, buffer: UnsafeMutablePointer<Py_buffer>) -> Int32
}

public protocol StaticPyBufferProtocol {
	static func __fill_buffer__(src: inout Self, buffer: UnsafeMutablePointer<Py_buffer>) -> Int32
}
public protocol PyBufferProtocol_AnyClass: AnyObject {
	static func __fill_buffer__(AnyObject src: Self, buffer: UnsafeMutablePointer<Py_buffer>) -> Int32
}

public protocol PyBytesProtocol {
	func __bytes__() -> PyPointer?
}

public protocol PySequenceProtocol {
	func __len__() -> Int
	func __add__(_ other: PyPointer?) -> PyPointer?
	func __iadd__(_ item: PyPointer?) -> PyPointer?
	func __mul__(_ n: Int) -> PyPointer?
	func __imul__(_ n: Int) -> PyPointer?
    func __getitem__(_ i: Int) -> PyPointer?
	func __setitem__(_ i: Int, _ item: PyPointer?) -> Int32
	func __contains__(_ item: PyPointer?) -> Int32
//	func __repeat__(count: Int, value: PyPointer?) -> PyPointer?
//	func __irepeat__(count: Int, value: PyPointer?)
}

public protocol PyMappingProtocol {
	func __len__() -> Int
	func __getitem__(key: String) -> PyPointer?

}

public protocol PyMutableMappingProtocol: PyMappingProtocol {
	func __setitem__(_ key: PyPointer?, _ item: PyPointer?) -> Int32
//	func __getitem__(key: String) -> PyPointer?
//	func __setitem__(key: String, value: PyPointer) -> Int32
//	func __delitem__(key: String) -> Int32
}

public protocol PyNumericProtocol {
    
}

public protocol PyHashable {
    func __hash__() -> Int
}

public protocol PyStrProtocol {
	func __str__() -> String
}

public protocol PyIntProtocol {
	func __int__() -> Int
}

public protocol PyFloatProtocol {
	func __float__() -> Double
}

public protocol PyNumberProtocol {
	func __nb_add__(_ other: PyPointer?) -> PyPointer?
	func __nb_subtract__(_ other: PyPointer?) -> PyPointer?
	func __nb_multiply__(_ other: PyPointer?) -> PyPointer?
	func __nb_remainder__(_ other: PyPointer?) -> PyPointer?
	func __nb_divmod__(_ other: PyPointer?) -> PyPointer?
	func __nb_power__(_ other: PyPointer?, _ kw: PyPointer?) -> PyPointer?
	func __nb_negative__() -> PyPointer?
	func __nb_positive__() -> PyPointer?
	func __nb_absolute__() -> PyPointer?
	func __nb_bool__() -> Int32
	func __nb_invert__() -> PyPointer?
	func __nb_lshift__(_ other: PyPointer?) -> PyPointer?
	func __nb_rshift__(_ other: PyPointer?) -> PyPointer?
	func __nb_and__(_ other: PyPointer?) -> PyPointer?
	func __nb_xor__(_ other: PyPointer?) -> PyPointer?
	func __nb_or__(_ other: PyPointer?) -> PyPointer?
	func __nb_int__() -> PyPointer?
	func __nb_float__() -> PyPointer?
	func __nb_inplace_add__(_ other: PyPointer?) -> PyPointer?
	func __nb_inplace_subtract__(_ other: PyPointer?) -> PyPointer?
	func __nb_inplace_multiply__(_ other: PyPointer?) -> PyPointer?
	func __nb_inplace_remainder__(_ other: PyPointer?) -> PyPointer?
	func __nb_inplace_power__(_ other: PyPointer?, _ kw: PyPointer?) -> PyPointer?
	func __nb_inplace_lshift__(_ other: PyPointer?) -> PyPointer?
	func __nb_inplace_rshift__(_ other: PyPointer?) -> PyPointer?
	func __nb_inplace_and__(_ other: PyPointer?) -> PyPointer?
	func __nb_inplace_xor__(_ other: PyPointer?) -> PyPointer?
	func __nb_inplace_or__(_ other: PyPointer?) -> PyPointer?
	func __nb_floor_divide__(_ other: PyPointer?) -> PyPointer?
	func __nb_true_divide__(_ other: PyPointer?) -> PyPointer?
	func __nb_inplace_floor_divide__(_ other: PyPointer?) -> PyPointer?
	func __nb_inplace_true_divide__(_ other: PyPointer?) -> PyPointer?
	func __nb_index__() -> PyPointer?
	func __nb_matrix_multiply__(_ other: PyPointer?) -> PyPointer?
	func __nb_inplace_matrix_multiply__(_ other: PyPointer?) -> PyPointer?
}

public protocol PyAsyncIterableProtocol {
	func __am_aiter__() -> PyPointer?
}

public protocol PyAsyncIteratorProtocol {
	func __am_anext__() -> PyPointer?
}

public protocol PyAsyncProtocol: PyAsyncIteratorProtocol, PyAsyncIterableProtocol {
	func __am_await__() -> PyPointer?
	func __am_send__(_ arg: PyPointer?, _ kwargs: UnsafeMutablePointer<PyPointer?>?) -> PySendResultFlag
}
