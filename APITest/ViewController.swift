//
//  ViewController.swift
//  APITest
//
//  Created by John Li on 2/18/18.
//  Copyright © 2018 Blueprint. All rights reserved.
//
import UIKit
import Foundation

class ViewController: UIViewController {
    
    var tableArray = [String]()
    var token = "";
    
    @IBOutlet weak var artImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("view loaded")
        getToken()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getToken()
    {
        let url = URL(string: "https://api.artsy.net/api/tokens/xapp_token/")!
        var request = URLRequest(url: url)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "client_id=3e783deff0736c786adc&client_secret=cb7d3b2c7644e13147d2d952295d61bf"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 201 {           // check for http errors
                print("statusCode should be 201, but is \(httpStatus.statusCode)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            if responseString!.range(of:"ey") != nil {
                let str = responseString!
                let start = str.index(str.startIndex, offsetBy: 30)
                let end = str.index(str.endIndex, offsetBy: -55)
                let range = start..<end
                //print("Response: \(responseString)")
                let sub = str[range]
                self.token = String(sub)
                print("1: \(self.token)")
                
                self.retrieve(sstoken: self.token)
            }
            //print("responseString = \(responseString)")
        }
        task.resume()
       
    }
    func retrieve(sstoken:String)
    {
        let url = URL(string: "https://api.artsy.net/api/artworks/516dfb9ab31e2b2270000c45")!
        var request = URLRequest(url: url)
        
        //print("sstoken = \(sstoken)")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(sstoken, forHTTPHeaderField: "X-Xapp-Token")
        request.setValue("application/vnd.artsy-v2+json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode > 201 {           // check for http errors
                print("statusCode should be 201, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("response = \(responseString)")
            
            var Id = responseString!.substring(from: responseString!.range(of: "https")!.upperBound)
            Id = Id.substring(to: Id.range(of: ".jpg")!.upperBound)
            Id = "https" + Id
            print("SJSDJLIJLFSKDJLKS \(Id)")
            self.displayImage(url: Id)
            }
        
            task.resume()
    }
    func displayImage(url:String)
    {
        let aURL = URL(string: url)!
        
        let session = URLSession(configuration: .default)
        
        let downloadPicTask = session.dataTask(with: aURL) { (data, response, error) in
 
            if let e = error {
                print("Error downloading artwork picture: \(e)")
            } else {

                if let res = response as? HTTPURLResponse {
                    print("Downloaded cat picture with response code \(res.statusCode)")
                    if let imageData = data {
                        // convert data to image
                        let image = UIImage(data: imageData)
                        self.artImage.image = image
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Error getting response code")
                }
            }
        }
        
        downloadPicTask.resume()
    }
    }




