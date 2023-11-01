import Foundation
//import PythonTypeAlias
import PythonSwiftCore


public func GenericPyCFuncCall<A: PyDecodable, B: PyDecodable, R: PyEncodable>(args: UnsafePointer<PyPointer?>?, count: Int,_ function: @escaping ((A,B)-> R) ) -> R? {
    do {
        guard count > 1, let args = args else { throw PythonError.call }
        return function(
            try A(object: args[0]!),
            try B(object: args[1]!)
        )
    } catch let err as PythonError {
        err.raiseError()
    } catch _ { }
    return nil
}

public func GenericPyCFuncCall<A: PyDecodable, B: PyDecodable, C: PyDecodable, R: PyEncodable>(args: UnsafePointer<PyPointer?>?, count: Int,_ function: @escaping ((A,B,C)-> R) ) -> R? {
    do {
        guard count > 2, let args = args else { throw PythonError.index }
        return function(
            try A(object: args[0]!),
            try B(object: args[1]!),
            try C(object: args[2]!)
        )
    } catch let err as PythonError {
        err.raiseError()
    } catch _ { }
    return nil
}
