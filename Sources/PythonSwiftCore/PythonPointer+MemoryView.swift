//
//  PythonPointer+MemoryView.swift
//


import AVFoundation
import Foundation
import PythonCore
//import PythonTypeAlias

@inlinable
func createMemoryView(data: inout [UInt8],_ completion: @escaping (PythonPointer)->Void )  {
    let size = data.count //* uint8_size
    data.withUnsafeMutableBytes { buffer in
        var pybuf = Py_buffer()
        PyBuffer_FillInfo(&pybuf, nil, buffer.baseAddress, size , 0, PyBUF_WRITE)
        pybuf.format = nil
        guard let view = PyMemoryView_FromBuffer(&pybuf) else { return }
        completion(view)
        //PyBuffer_Release(&pybuf)
        Py_DecRef(view)
    }
}

@inlinable
func createMemoryView(data: inout Data,_ completion: @escaping (PythonPointer)->Void )  {
    let size = data.count //* uint8_size
    data.withUnsafeMutableBytes { buffer in
        var pybuf = Py_buffer()
        PyBuffer_FillInfo(&pybuf, nil, buffer.baseAddress, size , 0, PyBUF_WRITE)
        pybuf.format = nil
        guard let view = PyMemoryView_FromBuffer(&pybuf) else { return }
        completion(view)
        //PyBuffer_Release(&pybuf)
        Py_DecRef(view)
    }
}



//AVFoundation Pixels to MemoryView
@inlinable
func createMemoryView(pixels: CVPixelBuffer,_ completion: @escaping (PythonPointer)->Void )  {
    CVPixelBufferLockBaseAddress(pixels, [])
    let buffer = CVPixelBufferGetBaseAddress(pixels)
    let size = CVPixelBufferGetDataSize(pixels)
    var pybuf = Py_buffer()
    PyBuffer_FillInfo(&pybuf, nil, buffer, size , 0, PyBUF_WRITE)
    pybuf.format = nil
    
    guard let view = PyMemoryView_FromBuffer(&pybuf) else { return }
    completion(view)
    CVPixelBufferUnlockBaseAddress(pixels, [])
    //PyBuffer_Release(&pybuf)
    Py_DecRef(view)
}

extension CVPixelBuffer {
    
    //AVFoundation Pixels to MemoryView
    @inlinable
    public func withMemoryView(_ completion: @escaping (PythonPointer)->Void )  {
        CVPixelBufferLockBaseAddress(self, [])
        let buffer = CVPixelBufferGetBaseAddress(self)
        let size = CVPixelBufferGetDataSize(self)
        var pybuf = Py_buffer()
        PyBuffer_FillInfo(&pybuf, nil, buffer, size , 0, PyBUF_WRITE)
        guard let view = PyMemoryView_FromBuffer(&pybuf) else { return }
        CVPixelBufferUnlockBaseAddress(self, [])
        completion(view)
        
        //PyBuffer_Release(&pybuf)
        Py_DecRef(view)
    }
    
    @inlinable
    public func withTextureData(_ completion: @escaping (_ data: PythonPointer?,_ w: PythonPointer?,_ h: PythonPointer?,_ size: PythonPointer?)->Void )  {
        CVPixelBufferLockBaseAddress(self, [])
        let buffer = CVPixelBufferGetBaseAddress(self)
        let w = PyLong_FromLong(CVPixelBufferGetBytesPerRow(self) / 4)
        let h = PyLong_FromLong(CVPixelBufferGetHeight(self))
        let size = CVPixelBufferGetDataSize(self)
        let _size = PyLong_FromLong(size)
        var pybuf = Py_buffer()
        PyBuffer_FillInfo(&pybuf, nil, buffer, size , 0, PyBUF_WRITE)
        guard let view = PyMemoryView_FromBuffer(&pybuf) else { return }
        CVPixelBufferUnlockBaseAddress(self, [])
        completion(view, w, h, _size)
        Py_DecRef(w)
        Py_DecRef(h)
        Py_DecRef(_size)
        //PyBuffer_Release(&pybuf)
        Py_DecRef(view)
    }
}

public extension Data {
    @inlinable
    mutating func withMemoryView(_ completion: @escaping (PythonPointer)->Void ) -> Void  {
        let size = self.count //* uint8_size
        self.withUnsafeMutableBytes { buffer in
            var pybuf = Py_buffer()
            PyBuffer_FillInfo(&pybuf, nil, buffer.baseAddress, size , 0, PyBUF_WRITE)
            pybuf.format = nil
            guard let view = PyMemoryView_FromBuffer(&pybuf) else { return }
            completion(view)
            //PyBuffer_Release(&pybuf)
            Py_DecRef(view)
        }
    }
    
    @inlinable
    public mutating func memoryView() -> PythonPointer {
        let size = self.count //* uint8_size
        let buffer = self.withUnsafeMutableBytes {$0.baseAddress}
        var pybuf = Py_buffer()
        PyBuffer_FillInfo(&pybuf, nil, buffer, size , 0, PyBUF_WRITE)
        return PyMemoryView_FromBuffer(&pybuf)
    }
    
    @inlinable
    public mutating func pythonBytes() -> PythonPointer {
        let size = self.count //* uint8_size
        let buffer = self.withUnsafeMutableBytes {$0.baseAddress}
        var pybuf = Py_buffer()
        PyBuffer_FillInfo(&pybuf, nil, buffer, size , 0, PyBUF_WRITE)
        let mem = PyMemoryView_FromBuffer(&pybuf)
        let bytes = PyBytes_FromObject(mem) ?? .PyNone
        Py_DecRef(mem)
        return bytes
    }
}

extension Array where Element == UInt8 {
    @inlinable
    mutating func withMemoryView(_ completion: @escaping (PythonPointer)->Void ) -> Void {
        let size = self.count //* uint8_size
        self.withUnsafeMutableBytes { buffer in
            var pybuf = Py_buffer()
            PyBuffer_FillInfo(&pybuf, nil, buffer.baseAddress, size , 0, PyBUF_WRITE)
            pybuf.format = nil
            guard let view = PyMemoryView_FromBuffer(&pybuf) else { return }
            completion(view)
            //PyBuffer_Release(&pybuf)
            Py_DecRef(view)
        }
    }
    
    @inlinable
    mutating func memoryView() -> PythonPointer  {
        let size = self.count //* uint8_size
        let buffer = self.withUnsafeMutableBytes {$0.baseAddress}
        var pybuf = Py_buffer()
        PyBuffer_FillInfo(&pybuf, nil, buffer, size , 0, PyBUF_WRITE)
        return PyMemoryView_FromBuffer(&pybuf)
    }
}


