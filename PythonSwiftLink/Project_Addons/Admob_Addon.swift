//
//  Admob_Addon.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 06/06/2022.
//

import Foundation
import PythonKit


func getAdMobPlistString(id: String = "ca-app-pub-3940256099942544~1458002511") -> String {
    
    
    return """

      <array>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>cstr6suwn9.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>4fzdc2evr5.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>2fnua5tdw4.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>ydx93a7ass.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>5a6flpkh64.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>p78axxw29g.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>v72qych5uu.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>c6k4g5qg8m.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>s39g8k73mm.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>3qy4746246.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>3sh42y64q3.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>f38h382jlk.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>hs6bdukanm.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>prcb7njmu6.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>v4nxqhlyqp.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>wzmmz9fp6w.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>yclnxrl5pm.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>t38b2kh725.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>7ug5zh24hu.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>9rd848q2bz.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>n6fk4nfna4.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>kbd757ywx3.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>9t245vhmpl.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>4468km3ulz.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>2u9pt9hc89.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>8s468mfl3y.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>av6w8kgt66.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>klf5c3l5u5.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>ppxm28t8ap.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>424m5254lk.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>uw77j35x4d.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>578prtvx9j.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>4dzt52r2t5.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>e5fvkxwrpn.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>8c4e2ghe7u.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>zq492l623r.skadnetwork</string>
        </dict>
        <dict>
          <key>SKAdNetworkIdentifier</key>
          <string>3qcr597p9d.skadnetwork</string>
        </dict>
    </array>
    """
}



func addAdmobKeysToProject_(project: KSLProjectData) {
    let url = project.path_url.appendingPathComponent("\(project.name)-Info.plist")
    let data = try! Data(contentsOf: url)
    
    var p_strings = String(data: data, encoding: .utf8)!.split(separator: "\n")
    
    if let dict_end = p_strings.lastIndex(of: "</dict>") {
        print(dict_end, p_strings[dict_end])
        let admob_string = getAdMobPlistString()
        p_strings.insert("\(admob_string)", at: dict_end)
    }
    let plist_string = p_strings.joined(separator: newLine)
    try? plist_string.write(to: url, atomically: true, encoding: .utf8)
}

func getAdmobKeys() -> PythonObject {
//    let pbytes = python_buildins["bytes"]
//    let plist = Python.import("plistlib")
//    let ploads = plist.loads
//    let pdumps = plist.dumps
//    let fmt_xml = plist.FMT_XML
    
    //let url = project.path_url.appendingPathComponent("\(project.name)-Info.plist")
    //guard let plist_string = try? String(contentsOf: url) else { fatalError() }
    
    //let p_dict = ploads(pbytes(plist_string, encoding: "utf8"), fmt: fmt_xml )
    return ploads(pbytes(getAdMobPlistString(), encoding: "utf8"), fmt: fmt_xml )
    //print(p_dict)
    //print(admob_dict)
    //p_dict.update(admob_dict)
    //let output = pdumps(p_dict)
    //print(admob_dict)
}
