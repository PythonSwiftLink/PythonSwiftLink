//
//  PipJsonData.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 17/06/2022.
//

import Foundation
import PythonKit

struct PipReleaseData: Decodable {
    
    let upload_time: String
    
    private enum CodingKeys: CodingKey {
        case upload_time
    }
    
}


struct PipJsonDataProjectsUrls: Decodable {
    
    let homepage: URL
    let source: URL?
    
    private enum CodingKeys: String, CodingKey {
        case homepage = "Homepage"
        case source = "Source"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        homepage = try c.decode(URL.self, forKey: .homepage)
        if c.contains(.source) {
            source = try c.decode(URL.self, forKey: .source)
        } else { source = nil }
        
    }
    
}

struct PipJsonDataInfo: Decodable {
    
    let name: String
    let project_url: URL
    var project_urls: PipJsonDataProjectsUrls?
    
    
    private enum CodingKeys: CodingKey {
        case name
        case project_url
        case project_urls
        //case releases
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        project_url = try c.decode(URL.self, forKey: .project_url)
        if c.contains(.project_urls) {
            project_urls = try c.decode(PipJsonDataProjectsUrls?.self, forKey: .project_urls)
        }
        
        //releases = try c.decode([String:PipReleaseData].self, forKey: .releases)
    }
    
    
}

struct PipJsonData: Decodable {
    
    let info: PipJsonDataInfo
    let releases: [String:[PipReleaseData]]
    
    private enum CodingKeys: CodingKey {
        case info
        case releases

    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        info = try c.decode(PipJsonDataInfo.self, forKey: .info)
        releases = try c.decode([String:[PipReleaseData]].self, forKey: .releases)
    }
    
    var release_array: [String] {
        releases.keys.map{$0}.sorted()
    }
}
