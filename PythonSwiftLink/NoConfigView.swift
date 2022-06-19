//
//  NoConfigView.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 03/06/2022.
//

import SwiftUI

struct NoConfigView: View {
    
    @State var path: String
    
    @Binding var active: Bool
    var completion: ( ()->Void )?
    
    var body: some View {
        let msg = """
        not found in the DB
        
        do you wish to add it ?
        """
        VStack {
            Text(path)
                .padding()
                .frame(maxWidth: .infinity)
                .background(ZStack{
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder()
                })
            Text(msg)
                .padding(8)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack {
                Button("Accept") {
                    DispatchQueue.main.async {
                        completion?()
                        active.toggle()
                    }
                    
                    
                }
                Button("Cancel") {
                    active.toggle()
                }
            }.padding()
                .background(ZStack{
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder()
                })

        }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
        
        
    }
}

struct NoConfigView_Previews: PreviewProvider {
    static var previews: some View {
        NoConfigView(path: "/some_path/some_folder", active: .constant(false))
            .previewLayout(.fixed(width: 480, height: 240))
    }
}
