////
////  ZlibTool.swift
////  Mirage3D
////
////  Created by 影子.zsr on 2018/3/29.
////  Copyright © 2018年 影子. All rights reserved.
////
//
//import Foundation
//import SSZipArchive
//import MINetwork
//
//class ZlibTool : NSObject{
//
//
//    static func LoadAvartar(fileName: String,OnFinish: @escaping (String) -> Void){
//        let password:String = "Mirage1@3$"
//
//        let Path = AppConfig_Network.FaceDataPath + "/"
//        let filePath = "\(Path)\(fileName)/\(fileName).m3d"
//        let desPath = "\(Path)\(fileName)/\(fileName)"
//
//        if FileManager.default.fileExists(atPath:filePath){
//            SSZipArchive.unzipFile(atPath: filePath, toDestination: desPath, overwrite: false, password: password, progressHandler: { (s, info, entryNumber, total) in
//
//            }, completionHandler: { (s,isOk ,error) in
//                if isOk{
//                    OnFinish(desPath)
//                }else{
//                    print(error.debugDescription)
//                    OnFinish("error")
//                }
//            })
//        }else{
//            OnFinish("error")
//        }
//    }
//
//    static func decompressionM3D(at path: String, OnFinish: @escaping (Bool) -> Void){
//        let password:String = "Mirage1@3$"
//
//        let filePath = "\(path).m3d"
//        let desPath = path
//
//        if FileManager.default.fileExists(atPath: filePath){
//            SSZipArchive.unzipFile(atPath: filePath, toDestination: desPath, overwrite: false, password: password, progressHandler: { (s, info, entryNumber, total) in
//
//            }, completionHandler: { (s,isOk ,error) in
//                if isOk{
//                    OnFinish(true)
//                }else{
//                    print(error.debugDescription)
//                    OnFinish(false)
//                }
//            })
//        }else{
//            OnFinish(false)
//        }
//    }
//
//    static func encryption(contents: String, path: String, isKeepParentDir: Bool = false) -> Bool{
//        let password:String = "Mirage1@3$"
//        guard FileManager.default.fileExists(atPath: contents) else{
//            return false
//        }
//
//        if FileManager.default.fileExists(atPath: path){
//            try? FileManager.default.removeItem(atPath: path)
//        }
//        return SSZipArchive.createZipFile(atPath: path, withContentsOfDirectory: contents, keepParentDirectory: isKeepParentDir, withPassword: password)
//    }
//
//
//    static func decompression(atPath:String,toPath:String) ->Bool{
//
//        if FileManager.default.fileExists(atPath: atPath){
//            return SSZipArchive.unzipFile(atPath: atPath, toDestination: toPath)
//        }
//        return false
//    }
//
//}
//
