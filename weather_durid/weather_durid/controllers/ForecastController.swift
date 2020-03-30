//
//  ForecastController.swift
//  weather_durid
//
//  Created by GEOLAB TRAININGS on 2/18/20.
//  Copyright © 2020 GEOLAB TRAININGS. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation


class ForecastController: UIViewController , CLLocationManagerDelegate{
    
    let locationManager = CLLocationManager()
    var vSpinner : UIView?
    var errorPage : UIView?
    let weekDays = [ "Sunday" , "Monday", "Tuesday", "Wednesday", "Thursday", "Friday" , "Saturday"]
    @IBOutlet weak var tableView: UITableView!
    
    
    lazy var data = [SectionModel]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerViews()

        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        showSpinner(onView: self.view)

    }
    
    func registerViews() {
        tableView.register(
            UINib(nibName: "cell", bundle: nil),
            forCellReuseIdentifier: "cell"
        )
        
        tableView.register(
            UINib(nibName: "headerTableViewCell", bundle: nil),
            forCellReuseIdentifier: "headerTableViewCell"
        )
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        refresh()
    }
    
    func refresh(){
        showSpinner(onView: self.view)
        updateValues()
        removeSpinner()
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
       
    
    func downloadImage(from url: URL , imageView : UIImageView) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                imageView.image = UIImage(data: data)
            }
        }
    }
    
    func updateValues(){
        guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
        
        let url = "https://api.openweathermap.org/data/2.5/forecast?appid=b07da2abebb981b5b3874956763fa118&lat=\(locValue.latitude)&lon=\(locValue.longitude)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        var weekday = Calendar.current.component(.weekday, from: Date())
        weekday -= 1
            
        
        for _ in 0...5{
            data.append(SectionModel(header: HeaderModel(weekDay : weekDays[weekday]), cells: [CellModel]()))
            weekday = (weekday + 1) % 7
        }
        
        weekday = Calendar.current.component(.weekday, from: Date())
        weekday -= 1
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let dat = data, let httpResponse = response as? HTTPURLResponse else { return }
            guard (200 ..< 300) ~= httpResponse.statusCode else {
                return
            }
                
            if let dict = try? JSONSerialization.jsonObject(with: dat, options: .mutableContainers) as? [String: AnyObject] {
                let list = dict["list"] as! Array<Dictionary<String, AnyObject>>
                print(list)
                var index = 0
                for l in list{
                    let main = l["main"] as! Dictionary<String, AnyObject>
                    let weather = l["weather"] as! Array<Dictionary<String, Any>>
                    let description = weather[0]["description"] as! String
                    let icon = weather[0]["icon"] as! String
                    let tmp = (main["temp"] as! Double)
                    let temp = String( Int ( round(100 * (tmp - 273.15))/100.0) )  + "C˚"
                    let date = l["dt_txt"] as! String
                    if self!.getDay(date) != weekday {
                        index += 1
                        weekday = self!.getDay(date)
                    }
                    if let imgData = try? Data(contentsOf:URL(string: "https://openweathermap.org/img/wn/" + icon + "@2x.png")!) {
                        if let image = UIImage(data: imgData) {
                            self!.data[index].cells.append(CellModel(image: image, description: description, temp: temp, hour: self!.getHour(date)))
                        }
                    }
                    DispatchQueue.main.async {
                        self!.tableView.reloadData()
                    }
                }
                
            }
        }
        task.resume()

    }
    
    func getDay(_ dt_txt: String) -> Int{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let time = dateFormatter.date(from: dt_txt)!
        let cal = Calendar(identifier: .gregorian)
        return cal.component(.weekday, from: time) - 1
    }
    
    func getHour(_ dt_txt: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let time = dateFormatter.date(from: dt_txt)!
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: time)
    }
}


extension ForecastController: UITableViewDataSource, UITableViewDelegate {
    

    func numberOfSections(in tableView: UITableView) -> Int {
        print(data.count)
        return data.count
    }

    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "headerTableViewCell") as! headerTableViewCell
        header.configure(from: data[section].header)
        return header
    }

    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        return 44
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return data[section].cells.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! cell
        cell.configure(from: data[indexPath.section].cells[indexPath.row])
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 70
    }

    func tableView(
        _ tableView: UITableView,
        viewForFooterInSection section: Int
    ) -> UIView? {
//        let footer = UIView()
//        footer.frame.height = 1
//        footer.frame.width = self.view.frame.width
//        return footer
        return nil
    }

    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        return 1
    }
}

extension ForecastController{
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


