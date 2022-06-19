//
//  KSLProjectData+PList.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 06/06/2022.
//

import Foundation
import PythonKit



extension KSLProjectData {
    
    func add_plist(keys: PythonObject) {
        let url = path_url.appendingPathComponent("\(name)-Info.plist")
        guard let plist = try? String(contentsOf: url) else { fatalError() }
        //let plist_obj = plist.pythonObject
        let plist_dict = ploads(plist.pythonBytes_utf8, fmt: fmt_xml)
        
        plist_dict.update(keys)
        let dump = pdumps(plist_dict).decode()
        //print(dump)
        if let plist_dump = dump.string {
            try! plist_dump.write(to: url, atomically: true, encoding: .utf8)
        }
    }
    
    func update_plist(keys: PythonObject) {
        
    }
    
    func update_plist(key: String, value: PythonObject) {
        let url = path_url.appendingPathComponent("\(name)-Info.plist")
        guard let plist = try? String(contentsOf: url) else { return }
        
        let plist_dict = ploads(plist.pythonBytes_utf8, fmt: fmt_xml)
        
        plist_dict[key] = value
        
        if let plist_dump = pdumps(plist_dict).string {
            try? plist_dump.write(to: url, atomically: true, encoding: .utf8)
        }
    }
    
    func remove(plist key: String) {
        let url = path_url.appendingPathComponent("\(name)-Info.plist")
        guard let plist = try? String(contentsOf: url) else { return }
        
        let plist_dict = ploads(plist.pythonBytes_utf8, fmt: fmt_xml)
        
        plist_dict.pop(key)
        
        if let plist_dump = pdumps(plist_dict).string {
            try? plist_dump.write(to: url, atomically: true, encoding: .utf8)
        }
    }
    
    func remove(plist keys: [String]) {
        let url = path_url.appendingPathComponent("\(name)-Info.plist")
        guard let plist = try? String(contentsOf: url) else { return }
        
        let plist_dict = ploads(plist.pythonBytes_utf8, fmt: fmt_xml)
        
        for key in keys {
            plist_dict.pop(key)
        }
        
        if let plist_dump = String(pdumps(plist_dict)) {
            try? plist_dump.write(to: url, atomically: true, encoding: .utf8)
        }
    }
    
    
    
    
    
    
    
}
