//
//  QRReaderViewController.swift
//  AnkenPractice
//
//  Created by 河野慎也 on 2019/03/16.
//  Copyright © 2019年 河野慎也. All rights reserved.
//

import UIKit
import AVFoundation

class QRReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    // MARK: Properties
    @IBOutlet weak var guideView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var rightView: UIView!
    
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    private var videoDevice: AVCaptureDevice?
    private var qrCodeFrameView: UIView?
    private var baseZoomFanctor: CGFloat = 1.0
    
    private var readedSymbol =  [StructuralConnectionInfo]()
    private var currentSymbolTotalCount = 0
    private var currentParity = 0
    
    // MARK: Override Methods
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        // ガイドの設定
        self.guideView.backgroundColor = UIColor.clear
        self.guideView.layer.borderWidth = 1
        self.guideView.layer.borderColor = UIColor.green.cgColor
        
        // カメラの権限取得
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
            // 初回起動時に許可設定を促す
        case .notDetermined: requestCameraPermission()
            // 許可されている
        case .authorized: presentCamera()
            // プライバシー設定でカメラの使用が禁止されている場合
        case .restricted, .denied: alertCameraAccessNeeded()
        }
        
        // 拡大･縮小のジェスチャー設定
        self.setupPinchGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.readedSymbol.removeAll()
        self.currentSymbolTotalCount = 0
        self.currentParity = 0
        self.setReadViewVisible()
        self.captureSession?.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 端末の向きに合わせてカメラの向きとプレビュー画像のサイズを合わせる
        let orientation = UIApplication.shared.statusBarOrientation
        
        videoPreviewLayer?.frame = self.view.bounds
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        switch orientation {
        case .portrait:
            videoPreviewLayer?.connection?.videoOrientation = .portrait
        case .landscapeLeft:
            videoPreviewLayer?.connection?.videoOrientation = .landscapeLeft
        case .landscapeRight:
            videoPreviewLayer?.connection?.videoOrientation = .landscapeRight
        case .portraitUpsideDown:
            videoPreviewLayer?.connection?.videoOrientation = .portraitUpsideDown
        default:
            videoPreviewLayer?.connection?.videoOrientation = .portrait
        }
        
        if let videoPreviewLayer = self.videoPreviewLayer {
            self.view.layer.addSublayer(videoPreviewLayer)
            
            // プレビュー画像の前面に設定
            view.bringSubviewToFront(qrCodeFrameView!)
            view.bringSubviewToFront(guideView)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.captureSession?.stopRunning()
    }
    
    // MARK: Action Methods
    @objc private func onPinchGesture(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .began {
            self.baseZoomFanctor = (self.videoDevice?.videoZoomFactor)!
        }
        
        let tempZoomFactor: CGFloat = self.baseZoomFanctor * sender.scale
        let newZoomFactdor: CGFloat
        if tempZoomFactor < (self.videoDevice?.minAvailableVideoZoomFactor)! {
            newZoomFactdor = (self.videoDevice?.minAvailableVideoZoomFactor)!
        } else if (self.videoDevice?.maxAvailableVideoZoomFactor)! < tempZoomFactor {
            newZoomFactdor = (self.videoDevice?.maxAvailableVideoZoomFactor)!
        } else {
            newZoomFactdor = tempZoomFactor
        }
        
        do {
            try self.videoDevice?.lockForConfiguration()
            self.videoDevice?.ramp(toVideoZoomFactor: newZoomFactdor, withRate: 32.0)
            self.videoDevice?.unlockForConfiguration()
        } catch {
            print("Failed to change zoom factor.")
        }
    }
    
    
    // MARK: Delegate Methods
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        print("metadataObjects.count = \(metadataObjects.count)")
        
        for metadataObj in metadataObjects {
            let obj = metadataObj as! AVMetadataMachineReadableCodeObject
            if let descriptor = obj.descriptor as? CIQRCodeDescriptor {
                //            let symbolVersion = descriptor.symbolVersion
                // CIQRCodeDescriptor#errorCorrectedPayload は誤り訂正済みのData.
                let errorCorrectedPayload = descriptor.errorCorrectedPayload
                
                let binary = Binary(data: errorCorrectedPayload)
                
                if var structuralConnectionInfo = decode(binary) {
                    // 構造的連接QRコード
                    if self.currentParity != structuralConnectionInfo.parity || self.currentSymbolTotalCount != structuralConnectionInfo.totalCount {
                        // パリティまたはシンボル数が異なる場合はリセットする
                        self.currentParity = structuralConnectionInfo.parity
                        self.currentSymbolTotalCount = structuralConnectionInfo.totalCount
                        self.readedSymbol.removeAll()
                    }
                    
                    let readedPositions = self.readedSymbol.map{$0.position}
                    
                    
                    if !readedPositions.contains(structuralConnectionInfo.position) {
                        structuralConnectionInfo.string = obj.stringValue
                        self.readedSymbol.append(structuralConnectionInfo)
                    }
                    
                    if self.readedSymbol.count >= self.currentSymbolTotalCount {
                        // 全ての読み取りが完了
                        self.captureSession?.stopRunning()
                        let vc = ShowQRInfoViewController(readedSymbols: self.readedSymbol)
                        self.navigationController?.pushViewController(vc, animated: true)
                        return
                    }
                } else {
                    // 単体のQRコード
                    print(obj.stringValue)
                }
                
            }
        }
        
        self.setReadViewVisible()
        
        
    }
    
    // MARK: Private Methods
    
    func presentCamera() {
        // 端末のカメラを取得
        self.videoDevice = self.defaultCamera()
        if self.videoDevice == nil {
            // カメラが取得できない場合は処理不可
            // TODO: 使用を拒否された場合の処理
            print("Failed to get the camera device")
            return
        }
        
        do {
            // AVCaptureSessionを生成し、端末のカメラを入力情報をして設定する
            captureSession = AVCaptureSession()
            let input = try AVCaptureDeviceInput(device: self.videoDevice!)
            captureSession?.addInput(input)
            
            // メタデータ（QRコード）をアウトプットに設定
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            
            // 画面一杯にカメラ画像を表示
            videoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            
            
            qrCodeFrameView = UIView()
            // スキャンしたQRコードを緑の枠で囲む
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
        } catch {
            print(error)
            return
        }
    }
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
            guard accessGranted == true else { return }
            self.presentCamera()
        })
    }
    
    func alertCameraAccessNeeded() {
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
        
        let alert = UIAlertController(
            title: "Need Camera Access",
            message: "Camera access is required to make full use of this app.",
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    private func defaultCamera() -> AVCaptureDevice? {
        if let device = AVCaptureDevice.default(.builtInDualCamera,
                                                for: AVMediaType.video,
                                                position: .back) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: AVMediaType.video,
                                                       position: .back) {
            return device
        } else {
            return nil
        }
    }
    
    private func setupPinchGestureRecognizer() {
        // pinch recognizer for zooming
        let pinchGestureRecognizer: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.onPinchGesture(_:)))
        self.view.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    private func decode(_ binary: Binary) -> StructuralConnectionInfo? {
        var binary = binary
        let modeBitsLength = 4
        guard binary.bitsWithInternalOffsetAvailable(modeBitsLength) else { return nil }
        
        let modeBits = binary.next(bits: modeBitsLength)
        guard let mode = Mode(rawValue: modeBits) else {
                return nil
        }
        
        guard mode != .endOfMessage else { return nil }
        
        if case .structuredAppend = mode {
            let symbolPosition = binary.next(bits: 4)
            let totalSymbols = binary.next(bits: 4)
            let parity = binary.next(bits: 8)
            print("Total: \(totalSymbols + 1), Position: \(symbolPosition + 1). Parity: \(parity).\n\n")
            return StructuralConnectionInfo(position: symbolPosition + 1, totalCount: totalSymbols + 1, parity: parity, string: nil)
            
        } else {
            return nil
        }
    }
    
    
    private func setReadViewVisible() {
        self.leftView.isHidden = true
        self.middleView.isHidden = true
        self.rightView.isHidden = true
        
        if self.currentSymbolTotalCount == 3 {
            for readSymbol in self.readedSymbol {
                switch readSymbol.position {
                case 1:
                    self.leftView.isHidden = false
                case 2:
                    self.middleView.isHidden = false
                case 3:
                    self.rightView.isHidden = false
                default:
                    continue
                }
            }
        }
        
        self.view.bringSubviewToFront(self.guideView)
    }

}

enum Mode: Int {
    case numeric              = 1 // 0001 数字
    case alphanumeric         = 2 // 0010 英数字
    case byte                 = 4 // 0100 バイト
    case kanji                = 8 // 1000 漢字
    case structuredAppend     = 3 // 0011 構造的連接
    case eci                  = 7 // 0111 ECI
    case fnc1InFirstPosition  = 5 // 0101 FNC1（1番目の位置）
    case fnc1InSecondPosition = 9 // 1001 FNC1（1番目の位置）
    case endOfMessage         = 0 // 0000 終端パターン
    
    var description: String {
        switch self {
        case .numeric:              return "0001 数字"
        case .alphanumeric:         return "0010 英数字"
        case .byte:                 return "0100 バイト"
        case .kanji:                return "1000 漢字"
        case .structuredAppend:     return "0011 構造的連接"
        case .eci:                  return "0111 ECI"
        case .fnc1InFirstPosition:  return "0101 FNC1（1番目の位置）"
        case .fnc1InSecondPosition: return "1001 FNC1（1番目の位置）"
        case .endOfMessage:         return "0000 終端パターン"
        }
    }
    
}


/// 構造的連接情報
struct StructuralConnectionInfo {
    var position: Int
    var totalCount: Int
    var parity: Int
    var string: String?
}
