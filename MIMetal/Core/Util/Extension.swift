//
//  Extension.swift
//  MIMetal
//
//  Created by 影子 on 2019/8/14.
//  Copyright © 2019 影子. All rights reserved.
//

import Foundation
import CommonCrypto
import UIKit

let lerpW:CGFloat = ScreenWidth/1024
let lerpH:CGFloat = ScreenHeight/1366

extension String{
    
    //清理
    func ClearString() -> String {
        return String(self.filter{!"\n\t\r".contains($0)})
    }
    
    public func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let len = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!,len,result)
        let hash = NSMutableString()
        
        for i in 0 ..< digestLen{
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize(count: 0)
        
        return String(format:hash as String)
    }
    
}



extension CGPoint{
    
    var length:CGFloat{
        get{
            return sqrt(self.x * self.x + self.y * self.y)
        }
    }
}

extension UIImage{
    func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale)
        self.draw(in: CGRect.init(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return reSizeImage
    }
    
    /**
     *  等比率缩放
     */
    func scaleImage(scaleSize:CGFloat)->UIImage {
        let reSize = CGSize.init(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
}

extension UIView{
    //通用ZKlabel
    func getCommonLabel(rect: CGRect, color: UIColor = UIColor.ZKBlack, alignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel.init(frame: rect)
        label.textColor = color
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = NSTextAlignment.left
        return label
    }
    
    //通用ZKlabel
    func getCommonLabel(rect:CGRect,fontSize:CGFloat,color:UIColor) -> UILabel {
        let label = UILabel.init(frame: rect)
        label.textColor = color
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = NSTextAlignment.left
        return label
    }
    
    func getRadiusButton(rect:CGRect,radius:CGFloat,title:String="") -> UIButton{
        let button = UIButton.init(frame: rect)
        button.setTitleColor(UIColor.ZKGray_AA, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptW(20))
        button.layer.cornerRadius = radius
        button.layer.borderColor = UIColor.init(hexString: "#DCDCDC").cgColor
        button.layer.borderWidth = 1
        button.setTitle(title, for: .normal)
        return button
    }
    
    
    
}


//自适应高
func adaptH(_ value:CGFloat) -> CGFloat {
    return value * lerpH
}

func adaptH(_ value:Int) -> CGFloat {
    return CGFloat(value) * lerpH
}
func adaptH(_ value:Double) -> Double {
    return value * Double(lerpH)
}

//自适应宽
func adaptW(_ value:CGFloat) -> CGFloat {
    return value * lerpW
}

func adaptW(_ value:Int) -> CGFloat {
    return CGFloat(value) * lerpW
}

func adaptW(_ value:Double) -> Double {
    return value * Double(lerpW)
}

//获取通用时间字符串
func getCommonDateString(date:Date) -> String {
    let dateFormatter = DateFormatter.init()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    return dateFormatter.string(from: date)
}

func getCommonDateString(time:Int) -> String {
    let date = Date.init(timeIntervalSince1970: TimeInterval(time))
    let dateFormatter = DateFormatter.init()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    return dateFormatter.string(from: date)
}


//UIImage颜色
extension UIImage{
    
    func tintColor(color:UIColor,blendMode:CGBlendMode) -> UIImage {
        let drawRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        //let context = UIGraphicsGetCurrentContext()
        //CGContextClipToMask(context, drawRect, CGImage)
        color.setFill()
        UIRectFill(drawRect)
        draw(in: drawRect, blendMode: blendMode, alpha: 1.0)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage!
    }
    
}

////loading动画
//var loadAni:LOTAnimationView{
//    let loadAni = LOTAnimationView.init(name: "loadingAni")
//    loadAni.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//    loadAni.layer.cornerRadius = 30
//    loadAni.contentMode = .scaleAspectFill
//    loadAni.frame = CGRect.adaptRect(x: 1024/2, y: 1336/2, width: 340, height: 340)
//    loadAni.insertSubview(loadAni, at: 0)
//    loadAni.loopAnimation = true
//    loadAni.alpha = 0.8
//    return loadAni
//}

//UIViewController扩展
extension UIViewController{
    
    func setLoadingTips(target:UIView) -> UIView {
        
        return UIView();
    }
    
    
    func Loading(_ parent:UIView) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.whiteLarge)
        //indicator.frame.size = CGSize.init(width: 150, height: 150)
        indicator.center = parent.center
        
        parent.addSubview(indicator)
        return indicator
    }
    
    //连接失败提示
    func showNetFailTips() -> Void {
        
        let image = UIImageView.init(image: #imageLiteral(resourceName: "bugeili"))
        image.contentMode = .scaleAspectFill
        image.bounds.size = CGSize(width: 60, height: 60)
        image.alpha = 0
        image.center = self.view.center
        self.view.addSubview(image)
        UIView.animate(withDuration: 0.1, animations: {
            image.bounds.size = CGSize(width: 100, height: 100)
            image.alpha = 1
        }) { (isOK) in
            Timer.scheduledTimer(withTimeInterval: 1,repeats: false, block: { (time) in
                UIView.animate(withDuration: 0.2, delay: 0.1, options: [.curveEaseOut], animations: {
                    image.bounds.size = CGSize(width: 10, height: 10)
                    image.alpha = 0
                }, completion: { (isOk) in
                    image.removeFromSuperview()
                })
            })
        }
    }
    
    //loading
    func openLoading(view:UIView,style:UIActivityIndicatorView.Style) -> UIActivityIndicatorView {
        let loadingTip = UIActivityIndicatorView.init(style: style)
        loadingTip.center = CGPoint.init(x: view.bounds.midX, y: view.bounds.midY)
        view.addSubview(loadingTip)
        return loadingTip
    }
    
    //    func openLoad(view:UIView) -> LOTAnimationView {
    //        loadAni.center = view.center
    //        view.addSubview(loadAni)
    //        return loadAni
    //    }
    
    
    /// 本地化准备
    ///
    /// - Parameter key: string
    /// - Returns: string
    func LocalizedString(key: String) -> String {
        return key
    }
    
    @objc func openAlert(notification:Notification){
        let alertViewController = UIAlertController(title: LocalizedString(key: "网络连接异常"), message: String(describing: notification), preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: LocalizedString(key: "确定"), style: .cancel, handler: { (action) in
            
        })
        alertViewController.addAction(actionCancel)
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    
    func openAlert(title:String,content:String) -> Void {
        let alertViewController = UIAlertController(title: LocalizedString(key: title), message: LocalizedString(key: content), preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: LocalizedString(key: "确定"), style: .cancel, handler: { (action) in
            
        })
        alertViewController.addAction(actionCancel)
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    func openAlert(title:String,content:String,sure:@escaping ()->Void,cancel:@escaping ()->Void) -> Void {
        let alertViewController = UIAlertController(title: LocalizedString(key: title), message: LocalizedString(key: content), preferredStyle: .alert)
        let actionSure = UIAlertAction(title: LocalizedString(key: "确定"), style: .default, handler: { (action) in
            sure()
        })
        let actionCancel = UIAlertAction(title: LocalizedString(key: "取消"), style: .cancel, handler: { (action) in
            cancel()
        })
        alertViewController.addAction(actionCancel)
        alertViewController.addAction(actionSure)
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    func openAlert(title:String,content:String,sure:@escaping ()->Void) -> Void {
        let alertViewController = UIAlertController(title: LocalizedString(key: title), message: LocalizedString(key: content), preferredStyle: .alert)
        let actionSure = UIAlertAction(title: LocalizedString(key: "确定"), style: .default, handler: { (action) in
            sure()
        })
        alertViewController.addAction(actionSure)
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    
}


extension UIView{
    
    // 绘制左上和右下圆角
    // rectCorners = UIRectCorner.init(rawValue: UIRectCorner.topLeft.rawValue | UIRectCorner.bottomRight.rawValue)
    func addCornersRadius(_ rectCorners:UIRectCorner,_ cornerRadius:CGFloat,_ strokeColor:UIColor = UIColor.init(white: 0, alpha: 0)) -> Void {
        let radius = CGSize.init(width: cornerRadius, height: cornerRadius)
        let maskLayer = CAShapeLayer.init()
        maskLayer.frame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        let borderLayer = CAShapeLayer.init()
        borderLayer.frame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        borderLayer.lineWidth = 1
        borderLayer.strokeColor = strokeColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        
        let bezierPath = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: rectCorners, cornerRadii: radius)
        maskLayer.path = bezierPath.cgPath
        borderLayer.path = bezierPath.cgPath
        self.layer.insertSublayer(borderLayer, at: 0)
        self.layer.mask = maskLayer
    }
    
}

extension UIImage{
    
    //纯色转UIImage
    static func color2UIImage(color:UIColor,size:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale);
        color.set()
        UIRectFill(CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
        let colorImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return colorImg!;
    }
    
}

extension UITextView{
    
    /**
     根据字符串的的长度来计算UITextView的高度
     
     - parameter textView:   UITextView
     - parameter fixedWidth:      UITextView宽度
     - returns:              返回UITextView的高度
     */
    internal class func heightForTextView(textView: UITextView, fixedWidth: CGFloat) -> CGFloat {
        let size = CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude)
        let constraint = textView.sizeThatFits(size)
        return constraint.height
    }
    
}

extension UIColor{
    
    convenience init(hexString:String) {
        self.init(hexString: hexString, alpha:1)
    }
    
    convenience init(hexString:String,alpha:CGFloat) {
        if hexString.count <= 0 || hexString.count != 7 || hexString == "(null)" || hexString == "<null>" {
            self.init(red: 1, green: 1, blue: 1, alpha: 1)
            return
        }
        var red: UInt32 = 0x0
        var green: UInt32 = 0x0
        var blue: UInt32 = 0x0
        let redString = String(hexString[hexString.index(hexString.startIndex, offsetBy: 1)...hexString.index(hexString.startIndex, offsetBy: 2)])
        let greenString = String(hexString[hexString.index(hexString.startIndex, offsetBy: 3)...hexString.index(hexString.startIndex, offsetBy: 4)])
        let blueString = String(hexString[hexString.index(hexString.startIndex, offsetBy: 5)...hexString.index(hexString.startIndex, offsetBy: 6)])
        Scanner(string: redString).scanHexInt32(&red)
        Scanner(string: greenString).scanHexInt32(&green)
        Scanner(string: blueString).scanHexInt32(&blue)
        self.init(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
    }
    
    static var ZKBlack:UIColor {
        get{
            return UIColor.init(hexString: "#2C2B2E")
        }
    }
    
    static var ZKGray:UIColor{
        get{
            return UIColor.init(hexString: "#797979")
        }
    }
    
    static var ZKGray_AA:UIColor{
        get{
            return UIColor.init(hexString: "#AAAAAA")
        }
    }
    
    static var ZKLightGray:UIColor{
        get{
            return UIColor.init(hexString: "#D3CDC6")
        }
    }
    
    
    static var ZKBlue:UIColor{
        get{
            return UIColor.init(hexString: "#3E97FF")
        }
    }
    
    static var ZKGreen:UIColor{
        get{
            return UIColor.init(hexString: "#7ED321")
        }
    }
    
    static var ZKOrange:UIColor{
        get{
            return UIColor.init(hexString: "#EF7317")
        }
    }
    
    static var ZKRed:UIColor{
        get{
            return UIColor.init(hexString: "#FF798A")
        }
    }
    
}

extension CGRect{
    static func adaptRect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> CGRect {
        return CGRect.init(x: adaptW(x), y: adaptH(y), width: adaptW(width), height: adaptH(height))
    }
    
}

extension CGPoint{
    
    init(_ x: Float, _ y: Float) {
        self.init(x: CGFloat(x), y: CGFloat(y))
    }
    
    static func adaptPoint(x:CGFloat,y:CGFloat) -> CGPoint {
        return CGPoint.init(x: adaptW(x), y: adaptH(y))
    }
    
    static func adaptPointWithDouble(x:Double,y:Double) ->CGPoint{
        return CGPoint.init(x: adaptW(x), y: adaptH(y))
    }
    
    static func *(left: CGPoint, right: CGFloat) -> CGPoint{
        return CGPoint.init(x: left.x * right, y: left.y * right)
    }
    
    static func +=(left: inout CGPoint, right: CGPoint) -> Void{
        left = CGPoint.init(x: left.x + right.x, y: left.y + right.y)
    }
    
}

extension CGSize{
    static func adaptSize(width:CGFloat,height:CGFloat) ->CGSize{
        return CGSize.init(width: adaptW(width), height: adaptH(height))
    }
}

