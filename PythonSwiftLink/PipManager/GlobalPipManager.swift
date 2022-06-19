//
//  GlobalPipManager.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 17/06/2022.
//

import SwiftUI
import SwiftUIWindow

struct GlobalPipManager: View {
    
    @ObservedObject var pip_man: PipManagerData
    @State var selection: PipData?
    var body: some View {
        HStack {
            ZStack {
                VStack {
                    Text("Global pips:")
                    UIList(selection: $selection) {
                        //if let pips = pip_man.pips {
                            
                        ForEach(pip_man.avail_pips, id: \.self) { pip in
                                PipDataRow(pip: pip)
         
                            }
                        //}
                        
                    }
                    .frame(width: 480)
                    //.frame(maxHeight: .infinity)
                    HStack {
                        Button("Add") {
                            pip_man.create(pip: "pip_\(pip_man.pips!.count)", versions: [("==", "1.0.0")])
                        }
//                        Button("Edit") {
//                            guard let first = selection else { return }
//        //                    pip_man.pipEditStates[first.id] = true
//        //                    print(pip_man.pipEditStates)
//                            SwiftUIWindow.open { w in
//                                PipDataEditPopover(pip: first)
//                            }
//                        }
                        Button("Remove") {
                            guard let selection = selection else {return}
                            self.selection = nil
                            pip_man.delete(pip: selection)
                            
                        }
                    }.frame(height: 48)
                }
                RoundedRectangle(cornerRadius: 8)
                    .stroke()
    
            }
            VStack{
                if let sel = selection {
                    PipDataEditPopover(pip: sel)
                         
                         .frame(maxHeight: .infinity)
                    
                    Button("download info") {
                        sel.downloadPipInfo()
                    }
                }
              
            }
            .frame(width: 240)
                .padding()
                .background(ZStack{
                    RoundedRectangle(cornerRadius: 8)
                        .stroke()
                })
        }
        .padding()
        .frame(height: 640)
    }
}

struct GlobalPipManager_Previews: PreviewProvider {
    static var previews: some View {
        GlobalPipManager(pip_man: PipManagerData.init())
    }
}
