//
//  PipManager.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 14/06/2022.
//

import SwiftUI
import RealmSwift
import Combine
import SwiftUIWindow


struct PipOperatorSelectView: View {
    
    @ObservedRealmObject var pip: PipVersion
    
    var operators = PipOperator.allCases
    
    var body: some View {
        Picker("", selection: $pip.versionOperator) {
            ForEach(operators, id: \.self) { o in
                Text(o.rawValue).tag(o.rawValue)
            }
        }
    }
}

struct PipListsViewer: View {
    
    @ObservedObject var pip_man: PipManagerData
    //@State var sel: PipManagerList?
    var body: some View {
        VStack {
            ZStack {
                if let lists = pip_man.pip_lists {
                    UIList(lists, id: \.self, selection: $pip_man.selected_pip_list) { n in
                        Text(n.name)
                    }
                    
                } else {EmptyView()}
            }.frame(height: 520)
                
            VStack {
                HStack {
                    Button("Create") {
                        pip_man.create(pip_list: "list\(pip_man.pip_lists?.count ?? 0)")
                    }
                    Button("Delete") {
                        
                    }
                    
                }
                Spacer()
                Button("Update Projects") {
                    
                }
                Spacer()
            }
        }
        
    }
}

struct CurrentPipListViewer: View {
    
    @ObservedRealmObject var pip_list: PipManagerList
    
    @Binding var selections: Set<PipData>
    
    var body: some View {
        VStack {
            
            UIList(selection: _selections) {
                ForEach(pip_list.filtered_pips, id: \.self) { pip in
                    PipDataRowList(pip: pip)
                }
            }
            HStack {
                Button("Import") {
                    selectFile { url in
                        pip_list.importRequirements_txt(url: url)
                    }
                }
            }
        }
        .padding()
        
    }
    
}

struct PipGlobalListViewer: View {
    
    @ObservedObject var pip_man: PipManagerData
    //var pips: [PipData]
    //@ObservedResults(PipData.self) var pips
    
    @Binding var selections: Set<PipData>
    //@Binding var pip_edit_states: [ObjectId:Bool]
    var body: some View {
        
        VStack {
            Text("Global pips:")
            UIList(selection: $selections) {
                //if let pips = pip_man.pips {
                    ForEach(getPips(), id: \.self) { pip in
                        PipDataRow(pip: pip)
 
                    }
                //}
                
            }
//            HStack {
//                Button("Add") {
//                    pip_man.create(pip: "pip_\(pip_man.pips!.count)", versions: [("==", "1.0.0")])
//                }
//                Button("Edit") {
//                    guard let first = selections.first else { return }
////                    pip_man.pipEditStates[first.id] = true
////                    print(pip_man.pipEditStates)
//                    SwiftUIWindow.open { w in
//                        PipDataEditPopover(pip: first)
//                    }
//                }
//                Button("Remove") {
//
//                }
//            }.frame(height: 48)
        }
        .padding()
        .background(ZStack{
            RoundedRectangle(cornerRadius: 8)
                .stroke()
        })
        
    }
    
    func getPips() -> [PipData] {
        if let pip_array = pip_man.pips?.sorted(by: { l, r in l.name > r.name}) {
            return pip_array.filter{ ItemExistInList(item: $0) && !$0.deleted}
        } else {
            return []
        }
        
    }
    
    func ItemExistInList(item: PipData) -> Bool {
        guard let list_items = pip_man.selected_pip_list?.pips else { return true}
        return !list_items.contains(item)
    
    }
    
    private func binding(for key: ObjectId) -> Binding<Bool> {
        return .init(
            
            get: { self.pip_man.pipEditStates[key, default: false] },
            set: { self.pip_man.pipEditStates[key] = $0 })
    }
}

struct PipListsManager: View {
    //@ObservedResults var
    @ObservedObject var pip_man: PipManagerData
    
    @State var testSeletion = Set<PipData>()
    @State var testSelection2 = PipData(name: "", versions: [("==","1.0.0")])
    //@State private var selections = Set<PipData>()
    
    
    var body: some View {
        //let pips = preview_pips
        HStack {
            PipGlobalListViewer(
                //pips: pip_man.pips,
                pip_man: pip_man,
                selections: $pip_man.selectedPips
                //pip_edit_states: pip
                
            )
                
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            //ZStack {
            
                VStack {
                    Image(systemName: "arrow.right.square")
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            pip_man.moveItemToList()
                        }
                    Image(systemName: "arrow.left.square")
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            pip_man.removeItemsFromList()
                        }
                    

                }
                
                
                
                //.padding(.vertical, 8)
                .padding(8)
                .frame(maxWidth: 48,maxHeight: .infinity)
                    
            //}.padding()
                
            
            
                
            VStack {
                Text("Current Pip List:")
                if let curList = pip_man.selected_pip_list {
                    CurrentPipListViewer(pip_list: curList, selections: $pip_man.selectedPipsInCurList)
                        .frame(maxWidth: 424)
                } else {
                    Text("No Selected List")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }.padding()
            .background(ZStack{
                RoundedRectangle(cornerRadius: 8)
                    .stroke()
            })
            PipListsViewer(pip_man: pip_man)
        }
        .padding()
        .frame(width: 1272 , height: 720)
    }
    
    
    private func newAlertMessage(pips: [PipData]) -> some View {
        
        VStack {
            Text("Duplicate Pip Names Selected !!!")
            VStack {
                ForEach(pips, id: \.self) { pip in
                    PipDataRowList(pip: pip)
                        
                }
                
            }
            
            Button("OK") {
                pip_man.duplicatedPipNames.toggle()
            }
        }
        .padding()
        
        
        
    }
}

struct PipManager_Previews: PreviewProvider {
    
    
    static var previews: some View {
        PipListsManager(
            pip_man: PipManagerData.init()
        
        )
            
    }
}
