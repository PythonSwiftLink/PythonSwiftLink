//
//  AlertView.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 31/05/2022.
//

import SwiftUI
import Cocoa
import RealmSwift

struct NoConfigAlertView: View {
     
     //@Binding var shown: Bool
    @ObservedRealmObject var root_data: KSLDataModelNew
     //@Binding var closureA: Alert
     var isSuccess: Bool
     var message: String
     
     var body: some View {
         VStack {
             
             //Image(isSuccess ? "check":"remove").resizable().frame(width: 80, height: 50).padding(.top, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
             Spacer()
             Text(message).foregroundColor(Color.white)
             Spacer()
             Divider()
             HStack {
//                 Button("Close") {
//                     //closureA = .cancel
//                     //shown.toggle()
//                 }.frame(width: 80, height: 40)
                 //.foregroundColor(.white)
                 
                 Button("Ok") {
                     //closureA = .ok
                     let folder = WorkingFolderData(filePath: URL(fileURLWithPath: root_data.current_url))
                     $root_data.recentFolders.append(folder)
                     $root_data.recentFolder_id.wrappedValue = folder.id
                     
                     $root_data.no_config_alert.wrappedValue.toggle()
                     //shown.toggle()
                 }.frame(width: 80, height: 40)
                 .foregroundColor(.white)
                 
             }
             
         }
         //.frame(width: 300, height: 200)
         
         .background(Color.black.opacity(0.5))
         .cornerRadius(12)
         .clipped()
         
     }
 }

struct NoConfigAlertView_Previews: PreviewProvider {
    static var previews: some View {
        NoConfigAlertView(root_data: KSLDataModelNew(), isSuccess: true, message: "Hello")
    }
}
