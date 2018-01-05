//
//  DemoURL.swift
//  Cassini
//
//  Created by WangBo on 2018/1/4.
//  Copyright © 2018年 WangBo. All rights reserved.
//

import Foundation

struct DemoURL {
    static let stanford = URL(string: "https://www-media.stanford.edu/wp-content/uploads/2017/03/24182714/about_landing-1.jpg")
    
    static var NASA: Dictionary<String,URL> = {
        let NASAURLStrings = [
            "Cassini" : "http://www.nasachina.cn/wp-content/uploads/2017/09/LastRingPortrait_Cassini_1080.jpg",
            "Earth" : "http://www.nasachina.cn/wp-content/uploads/2017/09/ega_1ms_mapcam_color_corrected_0.png",
            "Saturn" : "http://www.nasachina.cn/wp-content/uploads/2017/10/pia21352-1041.jpg"
        ]
        var urls = Dictionary<String,URL>()
        for (key,value) in NASAURLStrings {
            urls[key] = URL(string: value)
        }
        return urls
    }()
}
