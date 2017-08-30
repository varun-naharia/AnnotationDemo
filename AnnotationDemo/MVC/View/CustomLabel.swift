//
//  CustomLabel.swift
//  Sharpr
//
//  Created by Varun Naharia on 08/03/17.
//  Copyright © 2017 Logictrixtech. All rights reserved.
//

import UIKit

@IBDesignable
class CustomLabel: UILabel {
    @IBInspectable
    public var cornerRadius :CGFloat {
        
        set { layer.cornerRadius = newValue }
        
        get {
            return layer.cornerRadius
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    func setUpView() {
        
    }
    
    @IBInspectable var underlineColor:UIColor = UIColor.black
        {
        didSet{
            self.updateView()
        }
    }
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var rightImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var leftPadding: Int = 0 {
        didSet {
            updateView()
        }
    }
    @IBInspectable var rightPadding: Int = 0{
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var isUnderLine:Bool = false
        {
        didSet{
            updateView()
        }
    }

    func updateView() {
        if let imageLeft = leftImage {
            //Resize image
            let newSize = CGSize(width: self.frame.size.height, height: self.frame.size.height)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            imageLeft.draw(in: CGRect(x: 0, y: 1, width: newSize.width, height: newSize.height))
            let imageResized = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            //Create attachment text with image
            let attachment = NSTextAttachment()
            attachment.image = imageResized
            let attachmentString = NSAttributedString(attachment: attachment)
            let myString = NSMutableAttributedString(string: "")
            myString.append(attachmentString)
            for _ in 0...leftPadding {
                myString.append(NSAttributedString(string: " "))
            }
            myString.append(NSAttributedString(string: self.text!))
            self.attributedText = myString
        }
        
        if let imageRight = rightImage {
            //Resize image
            let newSize = CGSize(width: self.frame.size.height, height: self.frame.size.height)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            imageRight.draw(in: CGRect(x: 0, y: 2, width: newSize.width, height: newSize.height))
            let imageResized = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            //Create attachment text with image
            let attachment = NSTextAttachment()
            attachment.image = imageResized
            let attachmentString = NSAttributedString(attachment: attachment)
            let myString = NSMutableAttributedString(string: self.text!)
            for _ in 0...rightPadding {
                myString.append(NSAttributedString(string: " "))
            }
            myString.append(attachmentString)
            self.attributedText = myString
        }
        
        if(self.isUnderLine)
        {
            
            underline.frame = CGRect(x: 0, y: self.frame.size.height-1, width: self.frame.size.width, height: 1)
            underline.backgroundColor = underlineColor
            self.addSubview(underline)
        }
    }
    let underline:UIView = UIView()
    override func layoutSubviews() {
        super.layoutSubviews()
        underline.frame = CGRect(x: 0, y: self.frame.size.height-1, width: self.frame.size.width, height: 1)
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
     
     //Get image and set it's size
     let image = UIImage(named: "imageNameWithHeart")
     let newSize = CGSize(width: 10, height: 10)
     
     //Resize image
     UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
     image?.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
     let imageResized = UIGraphicsGetImageFromCurrentImageContext()
     UIGraphicsEndImageContext()
     
     //Create attachment text with image
     var attachment = NSTextAttachment()
     attachment.image = imageResized
     var attachmentString = NSAttributedString(attachment: attachment)
     var myString = NSMutableAttributedString(string: "I love swift ")
     myString.appendAttributedString(attachmentString)
     myLabel.attributedText = myString
    */

}
