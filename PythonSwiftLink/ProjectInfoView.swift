//
//  ProjectInfoView.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 28/05/2022.
//

import SwiftUI
import RealmSwift
//import ArgumentParser
import SwiftUIWindow
import CodeEditor

extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}
var needs_update_test: Bool = false


struct ProjectInfoView: View {
    
    
    @ObservedRealmObject var data: KSLProjectData
    
    //@ObservedRealmObject var cur_wrapper: KSLWrapperData
    
    @State var wrap_sel: String = ""
    
    @State var create_wrapper_active = false
    
    @State var code_string = ""
    
    @State var selected_wrapper: KSLWrapperData?
    
    @State private var last_wrapper_state: WrapperStatus?
    
    var selected_wrapper_: KSLWrapperData? {
        guard let wrap = data.wrapper_builds.first(where: { $0.name == wrap_sel }) else { return nil }
        return wrap
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("name:")
                        .foregroundColor(.gray)
                    Text(data.name)
                        
                }
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                VStack(spacing: 4) {
                    HStack {
                        Text("path:")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(data.path)
                    }
                    HStack {
                        Text("python source:")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(data.python_folder)
                    }
                }.padding(.horizontal, 8)
                
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            ZStack {
                
                
                Section {
                    
                    VStack {
                        HStack {
                            Text("Wrappers:")
                                .padding(8)
                            Spacer()
                            Image(systemName: "arrow.clockwise.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 24)
                                .padding(.horizontal, 4)
                                .onTapGesture {
                                    
                                }
                        }
                        .padding(.horizontal, 4)
                        .frame(maxWidth: .infinity)
                        Divider()
                        List {
                            
                            ForEach( data.wrapper_builds ) { f in
                                
                                HStack {
                                    Text(f.name)
                                    if f.status == .deleted {
                                        Image(systemName: "exclamationmark.triangle")
                                            .foregroundColor(.red)
                                    }
                                    
                                    Spacer()
                                    Text("file")
                                }
                                .contentShape(Rectangle())
                                .padding(4)
                                .background(
                                    f.name == wrap_sel ? Color.gray.opacity(0.2) : Color.clear
                                )
                            
                                .onTapGesture {
                                    wrap_sel = f.name
                                }

                            }
                        }.background(Color.black)
                        HStack {
                            
                            Button("Show") {
                                showInFinder(url: selected_wrapper_?.firstCodeURL())
                            }
                            
                            Button("Edit") {
                                SwiftUIWindow.open() {_ in
                                    WrapperCodeEditor(
                                        url: selected_wrapper_?.firstCodeURL()
                                    )
                                }
                            }
                            Button("Import") {
                                selectFile_Folder { file in data.importWrapper(file: file) }
                            }
                            Button("New") {
                                create_wrapper_active.toggle()
                            }
                            if selected_wrapper_?.status == .deleted {
                                Button("Undo Remove") {
                                    if let wrapper = selected_wrapper_?.thaw() {
                                        guard let state = last_wrapper_state else { return }
                                        try? realm_shared.write {
                                            wrapper.status = state
                                        }
                                    }
                                }
                            } else {
                                Button("Remove") {
                                    if let wrapper = selected_wrapper_?.thaw() {
                                        last_wrapper_state = wrapper.status
                                        try? realm_shared.write {
                                            wrapper.status = .deleted
                                        }
                                    }
                                }.disabled(selected_wrapper_ == nil)
                            }
                            
                        }
                        .padding()
                    }
                    .frame(maxHeight: .infinity)
                }
                   
                RoundedRectangle(cornerRadius: 8)
                    .stroke()
            }
            Spacer()
        }
        
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        .onChange(of: wrap_sel, perform: { newValue in
            //guard let wrap = data.wrapper_builds.first(where: { $0.name == newValue }) else { return }
            //selected_wrapper = wrap
            //cur_wrapper.wrappedValue = wrap
        })
        
        .sheet(isPresented: $create_wrapper_active) {
            NewWrapperView(active: $create_wrapper_active, completion: { file, cls_name in
                data.newWrapper(name: file, cls_name: cls_name)
            }).frame(width: 480)
        }
    }
    
    
    
    var current_wrappers: [String] {
        print("current_wrappers")
        do {
            
            let files = try FM.contentsOfDirectory(atPath: data.path_url.appendingPathComponent("wrapper_sources").path)
            print(files.filter {$0 != ".DS_Store"})
            return files.filter {$0 != ".DS_Store"}
            
        } catch let err {
            print(err.localizedDescription)
        }
        
        
        return []
    }
    
}

struct ProjectInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectInfoView(data: KSLProjectData(name: "qwerty", dummy: true))

            .previewLayout(.fixed(width: 499, height: 680))
    }
}
