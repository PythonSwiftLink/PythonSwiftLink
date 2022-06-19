//
//  KSLProjectAddon.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 06/06/2022.
//

import Foundation

import RealmSwift

enum KSLProjectAddonType: String {
    case camera
    case admob
    case audiokit
    case swifty_json
    
    case custom
}

protocol KSLProjectAddon {
    
    var type: KSLProjectAddonType { get }
    var info_keys: String { get set }
    var spm_mode: Bool { get set }
    var spm_url: String { get set }
    var spm_packages: [String] { get set }
}

enum PlistItemType: String, PersistableEnum {
    case string
    case int
    case bool
    case object
    case data
    case dict
}

class SwiftPackageItem: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var url: String
    @Persisted var minimumVersion: String
    @Persisted var packages: List<String>
    
    convenience init(url: String, min: String, packages: [String]) {
        self.init()
        self.url = url
        self.minimumVersion = min
        self.packages.append(objectsIn: packages)
    }
}

class PlistItem: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var key: String
    @Persisted var type: PlistItemType
    @Persisted var value: AnyRealmValue
    
    convenience init(key: String, value: Any, type: PlistItemType) {
        self.init()
        self.key = key
        self.type = type
        
        switch type {
        case .string:
            self.value = .string(value as! String)
        case .int:
            self.value = .int(value as! Int)
        case .bool:
            self.value = .bool(value as! Bool)
        case .object:
            self.value = .object(value as! PlistItem)
        case .data:
            self.value = .data(value as! Data)
        case .dict:
            self.value = .object(value as! PlistItem)
        }
    }
}

class ProjectAddon: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var plist_items: List<PlistItem>
    @Persisted var swift_packages: List<SwiftPackageItem>
    @Persisted var type: String
    
}

extension ProjectAddon {
    
    convenience init(info_key key: String, value: String) {
        self.init()
        type = KSLProjectAddonType.custom.rawValue
        
        plist_items.append(
            PlistItem(key: key, value: value, type: .string)
        )
    }
    
    
    convenience init(admob app_id: String) {
        self.init()
        type = KSLProjectAddonType.admob.rawValue
        plist_items.append(
            PlistItem(key: "GADApplicationIdentifier", value: app_id, type: .string)
        )
        plist_items.append(
            PlistItem(key: "SKAdNetworkItems", value: getAdMobPlistString(), type: .string)
        )
        
        swift_packages.append(
            SwiftPackageItem(
                url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git",
                min: "9.0.0",
                packages: ["GoogleMobileAds"]
            )
        )
    }

    
    
    convenience init(audiokit app_id: String = "") {
        self.init()
        type = KSLProjectAddonType.admob.rawValue
//        plist_items.append(
//            PlistItem(key: "GADApplicationIdentifier", value: app_id, type: .string)
//        )
//        plist_items.append(
//            PlistItem(key: "SKAdNetworkItems", value: getAdMobPlistString(), type: .string)
//        )
        
        swift_packages.append(
            SwiftPackageItem(
                url: "https://github.com/AudioKit/AudioKit",
                min: "5.0.0",
                packages: ["AudioKit"]
            )
        )
    }
}
//extension AdMobAddon: KSLProjectAddon {
//    var type: KSLProjectAddonType { .admob }
//
//    var info_keys: String {
//        get { getAdMobPlistString(id: application_id) }
//        set { }
//    }
//
//    var spm_url: String {
//        get { "https://github.com/googleads/swift-package-manager-google-mobile-ads.git" }
//        set {}
//    }
//
//    var spm_packages: [String] {
//        get { ["GoogleMobileAds"] }
//        set {}
//    }
//
//    var spm_mode: Bool {
//        get { true }
//        set {}
//    }
//
//}
