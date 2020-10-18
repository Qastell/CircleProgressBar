//
//  ViewController.swift
//  Circle Bar Progress
//
//  Created by Кирилл Романенко on 12/10/2020.
//  Copyright © 2020 Кирилл. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // ключи для быстрого использования
    enum AnimateKeys {
        static let strokeEnd = "strokeEnd"
        static let urSoBasic = "urSoBasic"
        
        static let transformCircle = "transform.scale"
        static let pulse = "pulse"
    }
    
    enum URLKeys {
        static let baseUrl = "https://cdn.arstechnica.net/wp-content/uploads/2018/06/macOS-Mojave-Dynamic-Wallpaper-transition.jpg"
    }
    
    enum NotificationKeys {
        static let downloadDidBegin = Notification.Name("downloadDidBegin")
    }
    
    enum LabelKeys {
        static let start = "Start"
        static let loading = "loading..."
        static let complited = "complited!"
    }
    
    let shapelayer = CAShapeLayer()
    var pulsatingLayer: CAShapeLayer!
    
    let persantageLabel: UILabel = {
        let label = UILabel()
        label.text = LabelKeys.start
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 40)
        label.textAlignment = .center
        return label
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.text = LabelKeys.loading
        label.textColor = .white
        label.alpha = 0
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        return label
    }()
    
    var persantageText: String! {
        didSet{
            NotificationCenter.default.post(name: NotificationKeys.downloadDidBegin, object: nil)
            persantageLabel.text = persantageText
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        createShapeLayers()
        
        setPersantageLabel()
        setStatusLabel()
        
        addTapGesture()
        createObservers()
    }
    
    private func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(startAnimationProgress), name: NotificationKeys.downloadDidBegin, object: nil)
    }
    
    @objc func startAnimationProgress() {
        if persantageLabel.text == LabelKeys.start {
            UIView.animate(withDuration: 1) {
                self.statusLabel.alpha = 1
                self.statusLabel.frame.origin.y = self.statusLabel.frame.origin.y + 23
                self.persantageLabel.frame.origin.y = self.persantageLabel.frame.origin.y - 12
            }
        }
    }
    
    private func setPersantageLabel() {
        view.addSubview(persantageLabel)
        persantageLabel.frame = CGRect(x: 0, y: 0, width: 120, height: 100)
        persantageLabel.center = view.center
    }
    
    private func setStatusLabel() {
        view.addSubview(statusLabel)
        statusLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        statusLabel.center = view.center
    }
    
    // gesture
    private func addTapGesture() {
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        persantageLabel.isUserInteractionEnabled = true
        persantageLabel.addGestureRecognizer(labelTap)
    }

    @objc private func handleTap() {
        beginDownloadingFile()
        
//        animateCircle()
    }
    
    
    private func beginDownloadingFile() {
        
        shapelayer.strokeEnd = 0
        
        let configuration = URLSessionConfiguration.default
        let operationQueue = OperationQueue()
        let urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
        
        guard let url = URL(string: URLKeys.baseUrl) else { return }
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
    }
    
    // Был использован на момент изучения анимации прогресс бара
    private func animateCircle() {
        let basicAnimation = CABasicAnimation(keyPath: AnimateKeys.strokeEnd)
        
        basicAnimation.toValue = 1
        basicAnimation.duration = 2
        
        // в конце не исчезает
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        
        // можно нажать еще раз
        basicAnimation.isRemovedOnCompletion = false
        
        shapelayer.add(basicAnimation, forKey: AnimateKeys.urSoBasic)
    }
    
    private func createShapeLayers() {
        let center = view.center
        
        // настройка круга
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        shapelayer.path = circularPath.cgPath
        
        // цвет круга
        shapelayer.strokeColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).cgColor
        // ширина линии
        shapelayer.lineWidth = 20
        //область внутри
        shapelayer.fillColor = UIColor.clear.cgColor
        // форма кончиков (круглая)
        shapelayer.lineCap = CAShapeLayerLineCap.round
        // точка, в которой находится линия (сейчас в начале и не видно)
        shapelayer.strokeEnd = 0
        /* по сути можно в инициализаторе передать в параметр "arcCenter" поинт центра вью view.center, и обойтись без этого .position
         upd: Если так сделать, то анимация перестает работать корректно (Начинает перемещать по диагонали)
        */
        shapelayer.position = center
        // то же самое. Можно передать в startAngle -CGFloat.pi/2 и результат будет тем же. Во всяком случае, разницы я не увидел
        shapelayer.transform = CATransform3DMakeRotation( -CGFloat.pi/2, 0, 0, 1)
        
        //Типа путь
        let trackerlayer = CAShapeLayer()
        trackerlayer.path = circularPath.cgPath
        trackerlayer.strokeColor = #colorLiteral(red: 0.2340672101, green: 0.01307008943, blue: 0.1675231888, alpha: 1).cgColor
        trackerlayer.lineWidth = 20
        trackerlayer.fillColor = UIColor.black.cgColor
        trackerlayer.position = center
        
        //Пульсирующий круг
        pulsatingLayer = CAShapeLayer()
        pulsatingLayer.path = circularPath.cgPath
        pulsatingLayer.strokeColor = UIColor.clear.cgColor
        pulsatingLayer.fillColor = #colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.2184577666, alpha: 1).cgColor
        pulsatingLayer.position = center
        
        view.layer.addSublayer(pulsatingLayer)
        view.layer.addSublayer(trackerlayer)
        view.layer.addSublayer(shapelayer)
        
        animationPulsing()
    }
    
    private func animationPulsing() {
        let animation = CABasicAnimation(keyPath: AnimateKeys.transformCircle)
        
        animation.toValue = 1.3
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        pulsatingLayer.add(animation, forKey: AnimateKeys.pulse)
    }
}

extension ViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        //
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let persentage = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        
        DispatchQueue.main.async {
            self.shapelayer.strokeEnd = persentage
            self.persantageText = String(Int(persentage*100)) + "%"
            
            if Int(persentage*100) == 100 {
                self.statusLabel.text = LabelKeys.complited
            } else {
                self.statusLabel.text = LabelKeys.loading
            }
        }
        
    }
}

