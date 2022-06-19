//
//  WrapperCodeEditor.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 03/06/2022.
//

import SwiftUI
import CodeEditor

struct WrapperCodeEditor: View {
    
    @State var current_code: String = ""
    
    var current_url: URL?
    
    init(url: URL?) {
        print("WrapperCodeEditor", url)
        //self.current_code = ""
        guard let url = url else { return }
        current_url = url
        
    }
    
    var body: some View {
        VStack {
            CodeEditor(source: $current_code, language: .python)
                .frame(minWidth: 640, minHeight: 480)
            HStack {
                Button("Save") {
                    guard let current_url = current_url else { return }
                    try? current_code.write(to: current_url, atomically: true, encoding: .utf8)
                }
            }
        }
        .onAppear {
            guard let url = current_url else { return }
            if FM.fileExists(atPath: url.path) {
                let code = try! String(contentsOf: url)
                print(code)
                current_code = code
                
            }
        }
    }
}

struct WrapperCodeEditor_Previews: PreviewProvider {
    static var previews: some View {
        WrapperCodeEditor(url: nil)
    }
}
