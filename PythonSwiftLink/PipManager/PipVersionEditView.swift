//
//  PipRowEditMenu.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 17/06/2022.
//

import SwiftUI
import RealmSwift

struct PipVersionEditView: View {
    @ObservedRealmObject var version: PipVersion
    
    var body: some View {
        HStack {
            PipOperatorSelectView(pip: version)
                .frame(width: 64)
            TextField("version", text: $version.version)
        }
    }
}

struct PipVersionEditViewWithInfoData: View {
    @ObservedRealmObject var version: PipVersion
    let info_data: PipJsonData
    var body: some View {
        HStack {
            PipOperatorSelectView(pip: version)
                .frame(width: 64)
            Picker("", selection: $version.version) {
                ForEach(info_data.release_array) { r in
                    Text(r).tag(r)
                }
            }
       
        }
    }
}

struct PipDataEditPopover: View {
    //@Binding var pip_name: String
    @ObservedRealmObject var pip: PipData
    //@ObservedRealmObject var versions: RealmList<PipVersion>
    var body: some View {
        VStack {
            TextField("pip name", text: $pip.name)
                //.frame(width: 164)
            ForEach(pip.versions) { v in
                if let json_data = pip.loadJsonData() {
                    PipVersionEditViewWithInfoData(version: v, info_data: json_data)
                } else {
                    PipVersionEditView(version: v)
                }
            }
            if pip.versions.count < 2 {
                Button("&&") {
                    guard let list = pip.versions.thaw() else { return }
                    guard let realm = list.realm else { return }
                    let new = PipVersion(version: "", op: "<=")
                    try? realm.write {
                        list.append(new)
                    }
                }
            }
        }.padding()
    }
}
var testPip = PipData(name: "pyosc", versions: [("==", "1.0.0")])

struct PipDataEditPopover_Previews: PreviewProvider {
 
    static var previews: some View {
        PipDataEditPopover(pip: testPip)
    }
}
