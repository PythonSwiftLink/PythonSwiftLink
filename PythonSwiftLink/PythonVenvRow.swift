//
//  PythonVenvRow.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 23/05/2022.
//

import SwiftUI

struct PythonVenvRow: View {
    @State private var selected = false
        
        var body: some View {
            VStack(spacing: 2) {
                Toggle(isOn: $selected) {
                    Text("VenvPython (3.9)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        //.padding(4)
                        
                }
                //.toggleStyle(.switch)
                .padding(4)
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

struct PythonVenvRow_Previews: PreviewProvider {
    static var previews: some View {
        PythonVenvRow()
    }
}
