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



class ViewController: UIViewController {
    
    let mqttClient = CocoaMQTT(clientID: "iOS Device", host: "192.168.43.141", port: 1883)
    var LEDs = [LED]()
    

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = event?.allTouches?.first else {return}
        let touchLocation = touch.location(in: self.view)
        LEDs.forEach { (LED) in
            if LED.frame.contains(touchLocation) {
                button_tapped(sender: LED)
                
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        // make all the buttons
        let n_rows = 32
        let n_cols = 64
        for row in 0 ..< n_rows {
            for col in 0 ..< n_cols {
                let button = LED(frame:CGRect(x:col*11+50, y:row*11+50, width:10, height:10))
                button.row = row
                button.col = col
                button.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
                
                LEDs.append(button)
                self.view.addSubview(button)
            }
        }
        colour_picker.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
    }
    
    @objc func button_tapped(sender: LED){
        
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
       
        sender.backgroundColor = self.colour_picker.backgroundColor!
        sender.backgroundColor!.getRed(&r, green: &g, blue: &b, alpha: &a)
        mqttClient.publish("rpi/gpio", withString: "\(sender.row!),\(sender.col!),\(Int(r*255)),\(Int(g*255)),\(Int(b*255))")
    }
    
    @IBOutlet weak var colour_picker: UIView!
    
    
    
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
    
    @IBAction func gpio40SW(_ sender: UISwitch) {
        if sender.isOn {
            mqttClient.publish("rpi/gpio", withString: "on")
        }
        else {
            mqttClient.publish("rpi/gpio", withString: "off")
            
        }
    }
    @IBAction func connectButton(_ sender: UIButton) {
        mqttClient.connect()
    }
    @IBAction func disconnectButton(_ sender: UIButton) {
        mqttClient.disconnect()
    }
    
    
    
   
    
    
}

