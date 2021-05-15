//
//  MediaPermissions.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/15/21.
//

import Foundation
import AVFoundation
import Photos

struct MediaPermissions {
    
    static func checkCameraPermission() -> AVAuthorizationStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        return status
    }
    
    static func checkMediaLibraryPermission() -> PHAuthorizationStatus {
        let status = PHPhotoLibrary.authorizationStatus()
        return status
    }
}
