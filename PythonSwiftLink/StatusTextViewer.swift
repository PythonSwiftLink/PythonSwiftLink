//
//  StatusTextViewer.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 23/05/2022.
//

import SwiftUI

struct StatusTextViewer: View {
    
    @ObservedObject var data: KSLViewLogger
    
    var body: some View {
        ScrollView {
            ScrollViewReader { scroll_value in
                ForEach(data.current_logs) { line in
                    HStack{
                        Text(line.text)
                          .font(.system(.subheadline, design: .monospaced))
                          .padding(.leading, 2)
                          .foregroundColor(Color.green)
                          
                        Spacer()
                    }
                    .frame(maxHeight: 15)
                    .multilineTextAlignment(.leading)
                }
                .onChange(of: data.current_logs.count) { newValue in
                    scroll_value.scrollTo(newValue - 1)
                }
            }
    
        //.foregroundColor(.black)
        //.background(Color(.black))
        }
        .padding()
        .background(Color(.black))
    }
}

struct StatusTextViewer_Previews: PreviewProvider {
    static var previews: some View {
        StatusTextViewer(
            data: KSLViewLogger()
        )
    }
}
