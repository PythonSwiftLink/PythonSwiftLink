//
//  PythonHostRow.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 23/05/2022.
//

import SwiftUI

struct PythonHostRow: View {
    
    @State private var selected = false
    
    var body: some View {
        VStack(spacing: 2) {
            Toggle(isOn: $selected) {
                Text("RootPython (3.10)")
                    .frame(maxWidth: .infinity)
                    .padding(4)
                    
            }.toggleStyle(.switch)
                .border(Color.gray)
            if selected {
                HStack {
                    Text("...")
                    Spacer()
                    Button("pick") {
                        
                    }
                    
                }
                .padding()
            }
        }
    }
}

struct PythonHostRow_Previews: PreviewProvider {
    static var previews: some View {
        PythonHostRow()
    }
}
