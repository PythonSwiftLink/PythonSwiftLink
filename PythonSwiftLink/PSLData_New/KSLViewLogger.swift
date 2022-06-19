//
//  KSLSetupLogger.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 23/05/2022.
//

import Foundation
import Combine

struct LogLine: Identifiable, Equatable {
    
    
    var id: Int
    var text: String
    
    static func == (lhs: LogLine, rhs: LogLine) -> Bool {
        return lhs.id == rhs.id &&
        lhs.text == rhs.text
    }
}

class KSLViewLogger: ObservableObject {
    
    @Published var current_logs = [LogLine]()
    
    
    func reset() {
        current_logs.removeAll()
    }
}
