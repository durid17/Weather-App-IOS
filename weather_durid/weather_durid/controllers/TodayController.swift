//
//  TodayController.swift
//  weather_durid
//
//  Created by GEOLAB TRAININGS on 2/11/20.
//  Copyright © 2020 GEOLAB TRAININGS. All rights reserved.
//

import Foundation


import UIKit
import CoreLocation

class TodayController: UIViewController , CLLocationManagerDelegate {
    
    @IBOutlet weak var mainStack: UIStackView!
    @IBOutlet weak var cloud: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var wind: UILabel!
    @IBOutlet weak var direction: UILabel!
    @IBOutlet weak var weather: UIImageView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    var vSpinner : UIView?
    var currRotation : Int = 0
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    
        currRotation = 0
        showSpinner(onView: self.view)
        mainStack.addHorizontalSeparators(color: .gray)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        currRotation = currRotation ^ 1
        var i = mainStack.arrangedSubviews.count - 2
        while i >= 0 {
            mainStack.arrangedSubviews[i].tintColor = UIColor.white
            mainStack.arrangedSubviews[i].removeFromSuperview()
            i -= 2
        }
        
        
        if(currRotation == 1){
            mainStack.addVerticalSeparators(color: .gray)
        }else{
            mainStack.addHorizontalSeparators(color: .gray)
        }
    }
    
    
    @IBAction func share(_ sender: Any) {
        let text = "Cloudiness " + cloud.text! + ", humidity " + humidity.text! + ", pressure " + pressure.text! + ", wind" + wind.text! + ", direction " + direction.text! + ", description " + weatherDescription.text! + ", location " + location.text!

        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view

        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]

        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func refreshClicked(_ sender: Any) {
        refresh();
    }
    
    func refresh(){
        showSpinner(onView: self.view)
        updateValues()
    }
    
    func updateValues(){
        guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
        
        let url = "https://api.openweathermap.org/data/2.5/weather?appid=b07da2abebb981b5b3874956763fa118&lat=\(locValue.latitude)&lon=\(locValue.longitude)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let data = data, let httpResponse = response as? HTTPURLResponse else { return }
            guard (200 ..< 300) ~= httpResponse.statusCode else {
                return
            }

            if let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] {
//                print(dict)
                let weather = dict["weather"] as! Array<Dictionary<String, AnyObject>>
                let main = dict["main"] as! Dictionary<String, Double>
                let wind = dict["wind"] as! Dictionary<String, Double>
                let clouds = dict["clouds"] as! Dictionary<String, Double>
                let sys = dict["sys"] as! Dictionary<String, AnyObject>

                DispatchQueue.main.async() {
                    self!.location.text = (dict["name"] as! String) + ", " + (sys["country"] as! String)
                    self!.weatherDescription.text = String(round(100*(main["temp"]!-273.15))/100.0) + "C˚ | " + (weather[0]["main"] as! String)
                    self!.cloud.text = String(clouds["all"]!) + " %"
                    self!.humidity.text = String(round(100*main["humidity"]!)/100.0) + " mm"
                    self!.pressure.text = String(round(100*main["pressure"]!)/100.0) + " hPa"
                    self!.wind.text = String(round(100*wind["speed"]!)/100.0) + " km/h"
                    
                    let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
                    
                    let idx = Int((wind["deg"]! + 22.5) / 45.0) & 15
                    self!.direction.text = String(directions[idx])
                }

                let icon = weather[0]["icon"] as! String
                let iconURL = "https://openweathermap.org/img/w/" + icon + ".png"
                let url = URL(string: iconURL)!
                self?.downloadImage(from: url)
            }
        }
        task.resume()

    }
    
    
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                self.weather.image = UIImage(data: data)
                self.removeSpinner()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        refresh()
    }
    
    func showSpinner(onView : UIView) {
        if(vSpinner != nil) {return}
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.99)
        let ai = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.large)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        if(self.vSpinner == nil) {return}
        DispatchQueue.main.async {
            self.vSpinner?.removeFromSuperview()
            self.vSpinner = nil
        }
    }
}



