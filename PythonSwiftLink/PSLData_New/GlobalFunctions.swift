//
//  GlobalFunctions.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 03/06/2022.
//

import Foundation
import AppKit


func showInFinder(url: URL?) {
    guard let url = url else { return }
    
    if url.isDirectory {
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
    }
    else {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}
