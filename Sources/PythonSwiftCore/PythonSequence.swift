import Foundation
import PythonCore
//import PythonTypeAlias


public struct PySequenceIterator: IteratorProtocol {
    
    //let autorelease: PythonPointerAutoRelease
    let ptr: PythonPointer
    public var buffer: PySequenceBuffer.Iterator
    
    init(pointer: PythonPointer) {
        buffer = pointer.getBuffer().makeIterator()
        ptr = pointer
        //autorelease = PythonPointerAutoRelease(pointer: pointer, keep: false, from_getattr: false)
    }
    
    @inlinable
    mutating public func next() -> PySequenceBuffer.Element? {
        return buffer.next()
//        if let next = buffer.next() {
//                    return next
//                }
//                Py_DecRef(ptr)
//                return nil
    }
    
    public typealias Element = PySequenceBuffer.Element
    
    
    
    
}

public struct PythonSequence: Sequence {
    __consuming public func makeIterator() -> PySequenceBuffer.Iterator {
        //PySequenceIterator.init(pointer: ptr)
        ptr.getBuffer().makeIterator()
    }
    

    
    
    public var ptr: PythonPointer
    private let object_autorelease: PythonPointerAutoRelease
    private var _iter: PySequenceBuffer.Iterator? = nil
    private var iter_count: Int = 0
    
    var iter: PySequenceBuffer.Iterator? {
        get {return _iter}
        set {_iter = newValue}
    }

    
    @inlinable var count: Int {
        0
        //PySequence_Size(ptr)
    }
    
    init(object: PythonPointer) {
        ptr = object
        object_autorelease = PythonPointerAutoRelease(pointer: object)
    }
    
    
    

}


extension PythonSequence  {
    
    
    
    
    
    
    
}

extension PySequenceBuffer {
    
    
}
