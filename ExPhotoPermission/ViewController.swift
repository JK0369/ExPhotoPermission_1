//
//  ViewController.swift
//  ExPhotoPermission
//
//  Created by 김종권 on 2023/03/22.
//

import UIKit
import Photos
import PhotosUI

class ViewController: UIViewController {
    private let photoButton: UIButton = {
        let button = UIButton()
        button.setTitle("사진", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.blue, for: .highlighted)
        button.addTarget(self, action: #selector(tap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let presentMorePhotoButton: UIButton = {
        let button = UIButton()
        button.setTitle("사진 더 추가하기(현재 limited 상태)", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.blue, for: .highlighted)
        button.addTarget(self, action: #selector(tapMorePhoto), for: .touchUpInside)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let settingButton: UIButton = {
        let button = UIButton()
        button.setTitle("모든 사진 허용 - 설정 이동(현재 limited 상태)", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.blue, for: .highlighted)
        button.addTarget(self, action: #selector(tapGoSetting), for: .touchUpInside)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private var status: PHAuthorizationStatus {
        PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    private var isLimited: Bool {
        status == .limited
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // PHPhotoLibrary.shared().register(self)를 호출하면 바로 권한 물어보므로 isLimited 상태일때만 delegate 설정
        if isLimited {
            PHPhotoLibrary.shared().register(self)
        }
        
        updateButtonAssociatedLimitedStatus()
        
        view.addSubview(photoButton)
        view.addSubview(presentMorePhotoButton)
        view.addSubview(settingButton)
        
        NSLayoutConstraint.activate([
            photoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            photoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        NSLayoutConstraint.activate([
            presentMorePhotoButton.topAnchor.constraint(equalTo: photoButton.bottomAnchor, constant: 16),
            presentMorePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        NSLayoutConstraint.activate([
            settingButton.topAnchor.constraint(equalTo: presentMorePhotoButton.bottomAnchor, constant: 16),
            settingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    @objc private func tap() {
        printStatus()
        guard status == .notDetermined else { return }
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            self.printStatus()
            
            DispatchQueue.main.async {
                self.updateButtonAssociatedLimitedStatus()
            }
            
            if self.isLimited {
                PHPhotoLibrary.shared().register(self)
            }
        }
    }
    
    @objc private func tapMorePhoto() {
        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
    }
    
    @objc private func tapGoSetting() {
        guard
            let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url)
        else { return }
        
        UIApplication.shared.open(url, completionHandler: { (success) in
            print("finished")
        })
    }
    
    private func printStatus() {
        switch status {
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        case .authorized:
            print("authorized")
        case .limited:
            print("limited")
        case .notDetermined:
            print("notDetermined")
        @unknown default:
            print("@unknown")
        }
    }
    
    private func showPresentMorePhotoButtonIfNeeded() {
        presentMorePhotoButton.isHidden = !(status == .limited)
    }
    
    private func updateButtonAssociatedLimitedStatus() {
        presentMorePhotoButton.isHidden = !isLimited
        settingButton.isHidden = presentMorePhotoButton.isHidden
    }
}

extension ViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // done 버튼 누른 경우 메소드 실행
        print("test>", changeInstance)
    }
}
