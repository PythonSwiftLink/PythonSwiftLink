//
//  DeleteProjectView.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 07/06/2022.
//

import SwiftUI

struct DeleteProjectView: View {
    
    @State var path: String
    
    @Binding var active: Bool
    var completion: ( ()->Void )?
    
    var body: some View {
        let msg = """
        Do you wish to delete "\(path)-ios"?
        """
        VStack {
//            Text(path)
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(ZStack{
//                    RoundedRectangle(cornerRadius: 8)
//                        .strokeBorder()
//                })
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

struct DeleteProjectView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteProjectView(path: "some_project", active: .constant(true))
    }
}
