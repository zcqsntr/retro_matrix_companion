//
//  ViewController.swift
//  MQTTDemo
//
//  Created by Neythen Treloar on 30/06/2020.
//  Copyright © 2020 Neythen Treloar. All rights reserved.
//

import UIKit
import CocoaMQTT

extension UIButton {

    func setBackgroundColor(color: UIColor, forState: UIControl.State) {

        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.setBackgroundImage(colorImage, for: forState)
    }
}

class LED: UIView {
    var row:Int?
    var col:Int?
    
}

func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
    let xDist = a.x - b.x
    let yDist = a.y - b.y
    return CGFloat(sqrt(xDist * xDist + yDist * yDist))
}

class ViewController: UIViewController {
    @IBOutlet weak var connect_button: UIButton!
    @IBOutlet weak var colour_picker: UIView!
    @IBOutlet weak var matrix_view: UIScrollView!
    
    var brush_size:CGFloat!
    
    let mqttClient = CocoaMQTT(clientID: "iOS Device", host: "192.168.43.141", port: 1883)
    var LEDs = [LED]()
    
    func touched(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = event?.allTouches?.first else {return}
        let touchLocation = touch.location(in: self.view)
        var message:String = ""
        LEDs.forEach { (LED) in
            let pos = CGPoint(x: LED.frame.midX, y: LED.frame.midY)
            let dist = distance(pos, touchLocation)
            
            if dist < self.brush_size/2 || LED.frame.contains(touchLocation)  {
                message.append(LED_tapped(sender: LED))
            }
        }
        mqttClient.publish("rpi/gpio", withString: message)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touched(touches, with: event)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touched(touches, with: event)
    }
    
    
    
    @IBAction func clear(_ sender: UIButton) {
        for led in self.LEDs {
            led.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
            
        }
        mqttClient.publish("rpi/gpio", withString: "clear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        // make all the buttons
        let n_rows = 64
        let n_cols = 64
        for row in 0 ..< n_rows {
            for col in 0 ..< n_cols {
                let led = LED(frame:CGRect(x:col*11+35, y:row*11+40, width:10, height:10))
                led.row = row
                led.col = col
                led.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
                
                LEDs.append(led)
                self.view.addSubview(led)
            }
        }
        colour_picker.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        
        connectButton(connect_button)
        
        self.brush_size = 50
        
       // var frame = colour_picker.frame
        
     
        self.colour_picker.frame.size.width = self.brush_size
        self.colour_picker.frame.size.height = self.brush_size
        
        self.colour_picker.layer.cornerRadius = self.colour_picker.frame.size.width/2
        self.colour_picker.clipsToBounds = true

        
    }
    
    @objc func LED_tapped(sender: LED) -> String{
        
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
       
        sender.backgroundColor = self.colour_picker.backgroundColor!
        sender.backgroundColor!.getRed(&r, green: &g, blue: &b, alpha: &a)
        return "\(sender.row!),\(sender.col!),\(Int(r*255)),\(Int(g*255)),\(Int(b*255)),"
    }
    
    @IBAction func red_slider(_ sender: UISlider) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        colour_picker.backgroundColor!.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        r = CGFloat(sender.value)
        
        colour_picker.backgroundColor = UIColor(red: r, green: g, blue: b, alpha:1)
        
    }
    
    @IBAction func green_slider(_ sender: UISlider) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        colour_picker.backgroundColor!.getRed(&r, green: &g, blue: &b, alpha: &a)
        g = CGFloat(sender.value)
        
        colour_picker.backgroundColor = UIColor(red: r, green: g, blue: b, alpha:1)
    }
    
    @IBAction func blue_slider(_ sender: UISlider) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        colour_picker.backgroundColor!.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        b = CGFloat(sender.value)
        
        colour_picker.backgroundColor = UIColor(red: r, green: g, blue: b, alpha:1)
    }
    
    @IBAction func size_slider(_ sender: UISlider) {
        self.brush_size = CGFloat(sender.value) * 100
        
        self.colour_picker.frame.size.width = self.brush_size
        self.colour_picker.frame.size.height = self.brush_size
        
        self.colour_picker.layer.cornerRadius = self.colour_picker.frame.size.width/2
        self.colour_picker.clipsToBounds = true
        
    }
    
    @IBAction func gpio40SW(_ sender: UISwitch) {
        if sender.isOn {
            mqttClient.publish("rpi/gpio", withString: "on")
        }
        else {
            mqttClient.publish("rpi/gpio", withString: "off")
            
        }
    }
    @IBAction func connectButton(_ sender: UIButton) {
        let connected = mqttClient.connect()
        if connected {
            sender.setTitleColor(UIColor.green, for: .normal)
        } else {
            sender.setTitleColor(UIColor.red, for: .normal)
        }
    }
    @IBAction func disconnectButton(_ sender: UIButton) {
        mqttClient.disconnect()
    }
    
    
    
   
    
    
}

