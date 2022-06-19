//
//  NewWrapperView.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 03/06/2022.
//

import SwiftUI
import RealmSwift

struct NewWrapperView: View {
    
    @EnvironmentObject var view_states: ViewStatesModel
    //@ObservedRealmObject var data: KSLProjectData
    
    @State var wrapper_name = ""
    @State var cls_name = ""
    
    @Binding var active: Bool
    
    var completion: ( (_ filename: String, _ cls_name: String)->Void )?
    
    var body: some View {
        ZStack {
            Form {
                  Section {
                      
                      VStack {
                          HStack {
                              Text("file name:")
                              TextField("wrapper filename", text: $wrapper_name)
                                  .multilineTextAlignment(.center)
                                  .focusable(!view_states.wrapperFileExistAlert)
                          }
                              //.foregroundColor(.gray)
                          HStack {
                              Text("class name:")
                              TextField("wrapper class name", text: $cls_name)
                                  .multilineTextAlignment(.center)
                                  .focusable(!view_states.wrapperFileExistAlert)
                          }
                          
                      }
                      
                      
                  } header: {
                      HStack {
                          Text("final wrapper name:")
                              .font(.bold(.subheadline)())
                              .foregroundColor(.gray)
                              .padding()
                          Text("\(wrapper_name).py")
                          
                    }
                }
                Divider()
                
                  
                HStack {
                    Button("Create") {
                          completion?(wrapper_name, cls_name)
                        if !view_states.wrapperFileExistAlert {
                            active.toggle()
                        }
                    }
                    .disabled(wrapper_name.count == 0 || cls_name.count < 4)
                    Button("Cancel") {
                          active.toggle()
                      }
                  }
              }
            .padding()
            
            
            if view_states.wrapperFileExistAlert {
                VStack {
                    Text("file already exist")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Button("Ok") {
                        view_states.wrapperFileExistAlert.toggle()
                    }
                }.background(Color.black)
            }
        }
          //.frame( maxWidth: .infinity, maxHeight: .infinity)
        
    }
}

struct NewWrapperView_Previews: PreviewProvider {
    static var previews: some View {
        NewWrapperView(active: .constant(true))
    }
}
