import Foundation
import PythonCore
//import PythonTypeAlias


@inlinable
public func optionalPyCast<R: ConvertibleFromPython>(from o: PyPointer?) -> R? {
    guard let object = o, object != PythonNone else { return nil }
    return try? R(object: object)
}



@inlinable
public func pyCast<R: ConvertibleFromPython>(from o: PyPointer?) throws -> R {
    guard let object = o, object != PythonNone else { throw PythonError.type(.init(describing: R.self)) }
    return try R(object: object)
}

@inlinable
public func UnPackPyPointer<T: AnyObject>(from o: PyPointer?) -> T {
    guard
        let object = o, object != PythonNone,
        let pointee = unsafeBitCast(o, to: PySwiftObjectPointer.self)?.pointee
    else { fatalError() }
    
    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
}

@inlinable
public func UnPackOptionalPyPointer<T: AnyObject>(from o: PyPointer?) -> T? {
    guard
        let object = o, object != PythonNone,
        let pointee = unsafeBitCast(o, to: PySwiftObjectPointer.self)?.pointee
    else { return nil }
    
    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
}


@inlinable
public func UnPackOptionalPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer, as: T.Type) -> T? {
    guard
        PythonObject_TypeCheck(self, check),
        let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
    else { return nil }
    
    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
}

@inlinable
public func UnPackOptionalPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer?, as: T.Type) throws -> T? {
    guard let self = self, self.notNone else { return nil }
    guard
        PythonObject_TypeCheck(self, check),
        let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
    else { throw PythonError.type(.init(describing: T.self)) }
    
    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
}

@inlinable
public func UnPackOptionalPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer?) -> T? {
    guard
        let self = self,
        PythonObject_TypeCheck(self, check),
        let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
    else { fatalError() }
    
    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
}


@inlinable
public func UnPackPySwiftObject<T: AnyObject>(with self: PySwiftObjectPointer, as: T.Type) -> T {
    guard let pointee = self?.pointee else { fatalError("self is not a PySwiftObject") }
    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
}

@inlinable
public func UnPackPySwiftObject<T: AnyObject>(with self: PySwiftObjectPointer) -> T  {
    guard let pointee = self?.pointee else { fatalError("self is not a PySwiftObject") }
    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
}

@inlinable
public func UnPackPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer, as: T.Type) -> T {
    guard
        PythonObject_TypeCheck(self, check),
        let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
    else { fatalError("self is not a PySwiftObject") }
    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
}

@inlinable
public func UnPackPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer?, as: T.Type) throws -> T {
    guard
        PythonObject_TypeCheck(self, check),
        let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
    else { throw PythonError.notPySwiftObject }
    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
}

@inlinable
public func UnPackPyPointer<T: AnyObject>(with type: PythonType, from self: PyPointer?) throws -> [T] {
    guard
        let self = self
    else { throw PythonError.notPySwiftObject }
    return try self.map { try UnPackPyPointer(with: type, from: $0) }
}

@inlinable
public func UnPackPyPointer<T: AnyObject>(with type: PythonType, from self: PyPointer?, as: T.Type) throws -> [T] {
    guard
        let self = self
    else { throw PythonError.notPySwiftObject }
    return try self.map { try UnPackPyPointer(with: type, from: $0) }
}

@inlinable
public func UnPackPyPointer<T: AnyObject>(with type: PythonType, from self: PyPointer?) throws -> [T]? {
    guard let self = self else { throw PythonError.notPySwiftObject }
	if self.isNone { return nil }
    return try self.map { try UnPackPyPointer(with: type, from: $0) }
}

@inlinable
public func UnPackPyPointer<T: AnyObject>(with type: PythonType, from self: PyPointer?, as: T.Type) throws -> [T]? {
    guard let self = self else { throw PythonError.notPySwiftObject }
	if self.isNone { return nil }
    return try self.map { try UnPackPyPointer(with: type, from: $0) }
}

@inlinable
public func UnPackPyPointer<T: AnyObject>(with type: PythonType, from self: PyPointer?) throws -> [T?] {
    guard
        let self = self
    else { throw PythonError.notPySwiftObject }
    return try self.map { try UnPackPyPointer(with: type, from: $0) }
}

@inlinable
public func UnPackPyPointer<T: AnyObject>(with type: PythonType, from self: PyPointer?, as: T.Type) throws -> [T?] {
    guard
        let self = self
    else { throw PythonError.notPySwiftObject }
    return try self.map { try UnPackPyPointer(with: type, from: $0) }
}

@inlinable
public func UnPackPyPointer<T: AnyObject>(with type: PythonType, from self: PyPointer?) throws -> [T?]? {
    guard let self = self else { throw PythonError.notPySwiftObject }
    return try self.map { try UnPackPyPointer(with: type, from: $0) }
}

@inlinable
public func UnPackPyPointer<T: AnyObject>(with type: PythonType, from self: PyPointer?, as: T.Type) throws -> [T?]? {
    guard let self = self else { throw PythonError.notPySwiftObject }
    return try self.map { try UnPackPyPointer(with: type, from: $0) }
}

@inlinable
public func UnPackPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer?) throws -> T {
    guard
        let self = self,
        PythonObject_TypeCheck(self, check),
        let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
    else { throw PythonError.type(.init(cString: _PyType_Name(check))) }
    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
}

@inlinable
public func UnPackPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer?) throws -> T? {
    guard let self = self, self.notNone else { return nil }
    
    guard PythonObject_TypeCheck(self, check), let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
    else { throw PythonError.type(.init(cString: _PyType_Name(check))) }
    
    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
}

//@inlinable
//public func UnPackPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer?) throws -> T? {
//    guard
//        let self = self,
//        PythonObject_TypeCheck(self, check),
//        let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
//    else { throw PythonError.attribute }
//    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
//}

//@inlinable
//public func UnPackPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer?) -> T {
//    guard
//        let self = self,
//        PythonObject_TypeCheck(self, check),
//        let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
//    else { fatalError("self is not a PySwiftObject") }
//    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
//}
