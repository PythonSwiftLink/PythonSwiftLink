import Foundation
import PythonCore
//import PythonTypeAlias


public protocol PyEncodable {
    
    var pyObject: PythonObject { get }
    var pyPointer: PyPointer { get }
}


public protocol PyDecodable {
    
    init(object: PyPointer) throws
}


public protocol PyBufferProtocol {
    func __buffer__(s: PyPointer, buffer: UnsafeMutablePointer<Py_buffer>) -> Int32
}
public protocol PyBufferStructProtocol {
    mutating func __buffer__(s: PyPointer, buffer: UnsafeMutablePointer<Py_buffer>) -> Int32
}


public protocol PySequenceProtocol {
    func __getitem__(idx: Int) -> PyPointer?
}

public protocol PyMappingProtocol {
    
}

public protocol PyNumericProtocol {
    
}

public protocol PyHashable {
    var __hash__: Int { get }
}
