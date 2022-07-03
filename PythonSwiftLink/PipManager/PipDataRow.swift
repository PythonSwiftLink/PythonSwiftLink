//
//  PipDataRow.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 15/06/2022.
//

import SwiftUI
import RealmSwift





struct PipDataRow: View {
    @ObservedRealmObject var pip: PipData
    //@Binding var edit: Bool
    //@Binding var selections: Set<PipData>
    
//    var isSelected: Bool {
//        selections.contains(pip)
//    }
    
    var body: some View {
        HStack{
            Text(pip.name)
            if let git_string = pip.git_string {
                Text(git_string)
            }
            Text(pip.versions.first?.versionOperator.rawValue ?? "")
            Text(pip.versions.first?.version ?? "")
        }
        

//        .background(ZStack{
//            if isSelected {
//                Rectangle()
//                    .foregroundColor(.gray)
//            }
//        })
            .contentShape(Rectangle())
    }
}

struct PipDataRowList: View {
    @ObservedRealmObject var pip: PipData
    //@Binding var edit: Bool
    //@Binding var selections: Set<PipData>
    
//    var isSelected: Bool {
//        selections.contains(pip)
//    }
    
    var body: some View {
        HStack{
            Text(pip.name)
            if let git_string = pip.git_string {
                Text(git_string)
            }
            Text(pip.versions.first?.versionOperator.rawValue ?? "")
            Text(pip.versions.first?.version ?? "")
        }

//        .background(ZStack{
//            if isSelected {
//                Rectangle()
//                    .foregroundColor(.gray)
//            }
//        })
            .contentShape(Rectangle())
    }
}

struct PipDataRow_Previews: PreviewProvider {
    static var previews: some View {
        PipDataRow(
            pip: PipData(
                name: "KivyTest",
                versions: [(PipOperator.EQ.rawValue, "1.0.0")],
                git_string: ""
            )
        )
        
    }
}
