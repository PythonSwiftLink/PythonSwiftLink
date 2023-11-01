import Foundation
import PythonCore
//import PythonTypeAlias

extension String {
    var object: PythonPointerU { PyUnicode_FromString(self) }
}
extension Int {
    var object: PythonPointerU { PyLong_FromLong(self) }
}
extension UInt {
    var object: PythonPointerU { PyLong_FromUnsignedLong(self) }
}
extension Int64 {
    var object: PythonPointerU { PyLong_FromLongLong(self) }
}
extension UInt64 {
    var object: PythonPointerU { PyLong_FromUnsignedLongLong(self) }
}
extension Int32 {
    var object: PythonPointerU { PyLong_FromLong(Int(self)) }
}
extension UInt32 {
    var object: PythonPointerU { PyLong_FromUnsignedLong(UInt(self)) }
}
extension Int16 {
    var object: PythonPointerU { PyLong_FromLong(Int(self)) }
}
extension UInt16 {
    var object: PythonPointerU { PyLong_FromUnsignedLong(UInt(self)) }
}
extension Int8 {
    var object: PythonPointerU { PyLong_FromLong(Int(self)) }
}
extension UInt8 {
    var _object: PythonPointerU { PyLong_FromUnsignedLong(UInt(self)) }
    var object: PythonPointer { PyLong_FromUnsignedLong(UInt(self)) }
}
extension Float {
    var object: PythonPointerU { PyFloat_FromDouble(Double(self)) }
}
extension Double {
    var object: PythonPointerU { PyFloat_FromDouble(self) }
}


