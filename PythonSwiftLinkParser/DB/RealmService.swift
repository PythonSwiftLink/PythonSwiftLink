//
//  RealmService.swift
//  touchbay
//
//  Created by MacDaW on 19/02/2021.
//

import Foundation
import RealmSwift
import SwiftyJSON

class RealmService {
    
    static let shared = RealmService()
    
    func newRealm(url:URL,types:[ObjectBase.Type]) -> Realm? {
        var new_config = Realm.Configuration.init()
        new_config.fileURL = url
        new_config.objectTypes = types
        do {
            return try Realm(configuration: new_config)
        } catch {
            print("Realm Error")
            return nil
        }
        
    }
    
    func create<T: Object>(in realm: Realm, object: T){
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            print(error)
        }
    }
    
    func createMany(in realm: Realm, list: Array<Object>){
        do {
            try realm.write {
                for x in 0..<list.count {
                    let obj = list[x]
                    realm.add(obj)
                }
                
            }
        } catch {
            print(error)
        }
    }
    
    func update<T: Object>(in realm: Realm ,object: T, with dictionary: [String: Any?]){
        do {
            try realm.write {
                for (key,value) in dictionary {
                    object.setValue(value, forKey: key)
                }
            }
        } catch {
            print(error)
        }
    }
    
    func update<T: Object>(in realm: Realm ,object: T){
        do {
            try realm.write {
                print("updating",object)
                realm.add(object, update: .modified)
            }
        } catch {
            print(error)
        }
    }

    func delete<T: Object>(in realm: Realm ,object: T){
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print(error)
        }
    }
    
    func deleteMany(in realm: Realm ,object: String){
        do {
            try realm.write {
//                switch object {
//                case "BrowserItem":
//                    realm.deleteObjects(BrowserItem.allObjects(in: realm))
//                case "BrowserFolder":
//                    realm.deleteObjects(BrowserFolder.allObjects(in: realm))
//                case "InterfacePreset":
//                    realm.deleteObjects(InterfacePreset.allObjects(in: realm))
//                default:
//                    print("")
//                }
            }
        } catch {
            print(error)
        }
    }
    
    
    
    
    
}


func dataToJSON(data: NSData) -> Any? {
    do {
        return try JSONSerialization.jsonObject(with: data as Data, options: .mutableContainers)
    } catch let myJSONError {
        print(myJSONError)
    }
    return nil
}

// Convert from JSON to nsdata
func jsonToData(json: AnyObject) -> Data?{
    do {
        return try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    } catch let myJSONError {
        print(myJSONError)
    }
    return nil;
}


extension String {
    func json_list() -> Any{
        return try! JSONSerialization.jsonObject(
            with: self.data(using: .utf8)!,
                options: JSONSerialization.ReadingOptions()
        )
    }
}




//extension Object {
//    func toDict() -> [String:Any] {
//            var cat_array: [String] = []
//            if let cat_size = category?.count {
//                if cat_size > UInt(0) {
//                    for x in 0...cat_size {
//                        cat_array.append(category!.object(at: x).name)
//                    }
//                }
//    
//            }
//    
//    func toJSON() -> Array<Int8> {
//            let data = JSON(self.toDict()).rawString([.castNilToNSNull: true])
//            return data!.cString(using: .utf8)!
//}
