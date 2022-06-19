//
//  KSLUpdate.swift
//  PythonSwiftLink
//
//  Created by MusicMaker on 06/12/2021.
//

import Foundation
import Zip

struct ApiAssests: Codable {
    let browser_download_url: URL
    let updated_at: Date
    
    
    private enum CodingKeys: CodingKey {
        case browser_download_url
        case updated_at
        }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        browser_download_url = try container.decode(URL.self, forKey: .browser_download_url )
        updated_at = try container.decode(Date.self, forKey: .updated_at)
    }
}

struct KSLRelease: Codable {
    let name: String
    let published_at: Date
    var assets: [ApiAssests]
    
    private enum CodingKeys: CodingKey {
        case name
        case published_at
        case assets
        }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name )
        published_at = try container.decode(Date.self, forKey: .published_at )
        assets = try container.decode([ApiAssests].self, forKey: .assets)
    }
}
func InstallKSL(forced: Bool) {
    let programPath = Bundle.main.executablePath!
    if forced {
        copyItem(from: programPath, to: "/usr/local/bin/ksl",force: forced)
    } else {
        print("Do you wish to copy PythonSwiftLink as ksl to /usr/local/bin/")
        print("enter y or yes: ", separator: "", terminator: " ")
        if let input_string = readLine()?.lowercased() {
            let input = input_string.trimmingCharacters(in: .whitespaces)
            if ANSWERS.contains(input) {
                print("copied file to /usr/local/bin/ksl")
                copyItem(from: programPath, to: "/usr/local/bin/ksl")
                
            }
        }
    }
    
}




func getKslReleases() -> [KSLRelease] {
    let url = URL(string: "https://api.github.com/repos/psychowasp/PythonSwiftLink/releases")!
    let data = try! Data.init(contentsOf: url)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try! decoder.decode([KSLRelease].self, from: data)
}

func downloadKslRelease(release: KSLRelease, forced: Bool) {
    //let target = getKslReleases().first!
    print("version <\(release.name)> is available, do you wish to update ?")
    print("enter y or yes: ", separator: "", terminator: " ")
    if let input_string = readLine()?.lowercased() {
        let input = input_string.trimmingCharacters(in: .whitespaces)
        if ANSWERS.contains(input) {
            let asset = release.assets.first!
            FileDownloader.loadFileSyncTemp(url: asset.browser_download_url) { (path_url, error) in
                if let _url = path_url {
                    installRelease(url: _url, error: error, forced: forced)
                }
            }
        }
    }
    
}

func installRelease(url: URL,error: Error?, forced: Bool) -> Void {
    //let path = url.path
    //let test_url = URL(fileURLWithPath: "/Users/musicmaker/Library/Developer/Xcode/DerivedData/PythonSwiftLink-eewvehksjwljcddezgmkixwtkicv/Build/Products/Debug/PythonSwiftLink.zip")
    if forced {
        installFromZip(url: url)
    } else {
        print("Do you wish to unzip PythonSwiftLink as ksl to /usr/local/bin/")
        print("enter y or yes: ", separator: "", terminator: " ")
            if let input_string = readLine()?.lowercased() {
                let input = input_string.trimmingCharacters(in: .whitespaces)
                if ANSWERS.contains(input) {
                    print("unzipping file to /usr/local/bin/ksl")
                    installFromZip(url: url)
            }
        }
    }
}

func installFromZip(url: URL) {
    //print(url)
    try! Zip.unzipFile(url, destination: url.deletingLastPathComponent(), overwrite: true, password: nil) { (process) in
        print(process)
    } fileOutputHandler: { (furl) in
        let path = furl.path
        autoinstall(path: path)
    }

}

func autoinstall(path: String) {
    print("making executable: \(path)")
    makeExecutable(file: path)
    copyItem(from: path, to: "/usr/local/bin/ksl", force: true)
}
