import Foundation
import PythonCore
//import PythonTypeAlias


prefix operator ??

postfix operator *

infix operator =?


extension PythonPointer {
 
//        static prefix func - (obj: PythonPointer) -> String {
//            return PyUnicode_FromString(<#T##u: UnsafePointer<CChar>!##UnsafePointer<CChar>!#>)
//        }


    static func ??(lhs: PythonPointer, rhs: String.Type ) -> String {
        guard let ptr = PythonUnicode_DATA(lhs) else { return "nil" }
          
          let kind = PythonUnicode_KIND(lhs)
          let length = PyUnicode_GetLength(lhs)
          switch PythonUnicode_Kind(rawValue: kind) {
          case .PyUnicode_1BYTE_KIND:
              let size = length * MemoryLayout<Py_UCS1>.stride
              let data = Data(bytesNoCopy: ptr, count: size, deallocator: .none)
              return String(data: data, encoding: .utf8)!
          case .PyUnicode_2BYTE_KIND:
              let size = length * MemoryLayout<Py_UCS2>.stride
              let data = Data(bytesNoCopy: ptr, count: size, deallocator: .none)
              return String(data: data, encoding: .utf16LittleEndian)!
          case .PyUnicode_4BYTE_KIND:
              let size = length * MemoryLayout<Py_UCS4>.stride
              let data = Data(bytesNoCopy: ptr, count: size, deallocator: .none)
              return String(data: data, encoding: .utf32LittleEndian)!
          default:
              return "nil"
          }
    }
    
    static func ??(lhs: String.Type, rhs: PythonPointer) -> String  {
        guard let ptr = PythonUnicode_DATA(rhs) else { return "nil" }
          
          let kind = PythonUnicode_KIND(rhs)
          let length = PyUnicode_GetLength(rhs)
          switch PythonUnicode_Kind(rawValue: kind) {
          case .PyUnicode_1BYTE_KIND:
              let size = length * MemoryLayout<Py_UCS1>.stride
              let data = Data(bytesNoCopy: ptr, count: size, deallocator: .none)
              return String(data: data, encoding: .utf8)!
          case .PyUnicode_2BYTE_KIND:
              let size = length * MemoryLayout<Py_UCS2>.stride
              let data = Data(bytesNoCopy: ptr, count: size, deallocator: .none)
              return String(data: data, encoding: .utf16LittleEndian)!
          case .PyUnicode_4BYTE_KIND:
              let size = length * MemoryLayout<Py_UCS4>.stride
              let data = Data(bytesNoCopy: ptr, count: size, deallocator: .none)
              return String(data: data, encoding: .utf32LittleEndian)!
          default:
              return "nil"
          }
    }
}

let asdfgh = {
    let a: PyPointer = ""
    
    let str = a ?? String.self
    
    let str2 = String.self ?? a
    
}

