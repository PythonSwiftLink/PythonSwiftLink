//
//  CommandQueueItem.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 25/05/2022.
//

import Foundation
import RealmSwift



protocol CommandQueueExecutable {
    
    
    func runTask( _ logger: @escaping ((String)->Void) ) throws
    
}


enum CommandQueueType: String, Decodable {
    
    case install_python_venv
    case install_python_host
    case toolchain
    case pip
    case tooolchain_pip
    case create_venv
    case venv_pip
    case move_item
    case copy_item
    case delete_item
    case create_folder
}

class KSL_CommandQueueItem {
    
    var command_args: [String] = []
    
    var type: CommandQueueType
    
    init(_ type: CommandQueueType, commands: [String]) {
        
        self.type = type
    
        
        
    }
    
    func handleType() {
        switch self.type {
            
        case .install_python_venv:
            break
        case .install_python_host:
            break
        case .toolchain:
            break
        case .pip:
            break
        case .tooolchain_pip:
            break
        case .create_venv:
            break
        case .venv_pip:
            break
        case .move_item:
            break
        case .copy_item:
            break
        case .delete_item:
            break
        case .create_folder:
            break
        }
        
        
    }
    
}
