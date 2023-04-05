//
//  ViewController.swift
//  MyWeather
//
//  Created by Apple on 24/03/23.
//

import UIKit
import CoreLocation
//location: CoreLocation
//table view
//custom cell :collection view
//API request to get the data
class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate {
    @IBOutlet var table: UITableView!
    var models = [DailyWeatherEntry]()
    var hourlyModels = [HourlyWeatherEntry]()
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var current: CurrentWeather?

    override func viewDidLoad() {
        super.viewDidLoad()
        table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
        view.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
    }
    //Location
    func setupLocation(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty,currentLocation == nil {
            currentLocation = locations.first
            //locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
            
        }
    }
    func requestWeatherForLocation(){
        guard let currentLocation = currentLocation else {
            return
        }

        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        let url = "https://api.darksky.net/forecast/ddcc4ebb2a7c9930b90d9e59bda0ba7a/\(lat),\(long)?exclude=[flagsminutely"
       
        //print("\(long) | \(lat)")
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: {
            data,response,error in
            //validation
            guard let data = data,error == nil else {
                print("something went wrong")
                return
            }

            //convert data to models/some object
            var json: WeatherResponse?
            do{
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
            }
            catch{
                print("error: \(error)")
            }
            guard let result = json else{
                return
            }
           // print(result.currently.summary)
            let entries = result.daily.data
            self.models.append(contentsOf: entries)
            
            let current = result.currently
            self.current = current
            self.hourlyModels = result.hourly.data
            
            
            //update user interface
            DispatchQueue.main.async {
                self.table.reloadData()
                
                
                self.table.tableHeaderView = self.createTableHeader()
            }
        }).resume()
        
    }
    func createTableHeader() -> UIView{
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height/3))
        
        headerView.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
        
        let locationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.width, height: headerView.frame.size.height/4))
        let summaryLabel = UILabel(frame: CGRect(x: 10, y: 10+locationLabel.frame.size.height, width: view.frame.size.width, height: headerView.frame.size.height/4))
        let tempLabel = UILabel(frame: CGRect(x: 10, y: 10+summaryLabel.frame.size.height, width: view.frame.size.width, height: headerView.frame.size.height/1))
        
        
        headerView.addSubview(locationLabel)
        headerView.addSubview(summaryLabel)
        headerView.addSubview(tempLabel)
        
        tempLabel.textAlignment = .center
        locationLabel.textAlignment = .center
        summaryLabel.textAlignment = .center
        
        locationLabel.text = "Current location"
        guard let currentWeather = self.current else {
            return UIView()
        }

        tempLabel.text = "\(currentWeather.temperature)°"
    
        tempLabel.font = UIFont(name: "Helvetica-Bold", size: 32)
        
        summaryLabel.text = self.current?.summary
        
        
        
        return headerView
    }
//Table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            // 1 cell that is collectiontableviewcell
            return 1
        }
        //return models count
        return models.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: HourlyTableViewCell.identifier,for: indexPath) as! HourlyTableViewCell
            cell.configure(with: hourlyModels)
            cell.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
            return cell
            
        }
        //continue
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier,for: indexPath) as! WeatherTableViewCell
        cell.configure(with: models[indexPath.row])
        cell.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
        return cell
        
        
        
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
struct WeatherResponse:Codable{
    let latitude: Float
    let longitude: Float
    let timezone: String
    let currently: CurrentWeather
    let hourly: HourlyWeather
    let daily: DailyWeather
    let offset: Float
    
}
/*struct wheather:Codable{
    let something: String
}*/
struct CurrentWeather:Codable{
    
    let time : Int
    let summary : String
    let icon : String
   // let nearestStormDistance: Int
  //  let nearestStormBearing: Int
    let  precipIntensity : Double
    let precipProbability : Double
    let precipType : String?
    let temperature : Double
    let apparentTemperature : Double
    let dewPoint : Double
    let humidity : Double
    let pressure : Double
    let windSpeed : Double
    let windGust : Double
    let  windBearing : Int
    let cloudCover : Double
    let uvIndex : Int
    let  visibility : Int
    let ozone : Double
}

struct DailyWeather:Codable {
    let summary: String
    let icon: String
    let data: [DailyWeatherEntry]
}
struct DailyWeatherEntry:Codable{
    
    let time : Int
    let summary : String
    let icon : String
    let  sunriseTime : Int
    let  sunsetTime : Int
    let  moonPhase : Double
    let precipIntensity : Float
   // let precipIntensityMax : Float
    let precipIntensityMax : Float
    let  precipProbability : Double
    let precipType : String?
    let temperatureHigh : Double
    let  temperatureHighTime : Int
    let   temperatureLow : Double
    let temperatureLowTime : Int
    let apparentTemperatureHigh : Double
    let apparentTemperatureHighTime : Int
    let apparentTemperatureLow : Double
    let apparentTemperatureLowTime : Int
    let  dewPoint : Double
    let humidity : Double
    let pressure : Double
    let  windSpeed : Double
    let windGust : Double
    let windGustTime : Int
    let windBearing : Int
    let cloudCover : Double
    let  uvIndex : Int
    let  uvIndexTime : Int
    let visibility : Double
    let  ozone : Double
    let temperatureMin : Double
    let temperatureMinTime : Int
    let temperatureMax : Double
    let temperatureMaxTime : Int
    let apparentTemperatureMin : Double
    let apparentTemperatureMinTime : Int
    let apparentTemperatureMax : Double
    let apparentTemperatureMaxTime : Int
}
struct HourlyWeather:Codable{
    let summary: String
    let icon: String
    let data: [HourlyWeatherEntry]
}
struct HourlyWeatherEntry:Codable{
    
    let time : Int
    let summary : String
    let icon : String
    let precipIntensity : Float
    let  precipProbability : Double
    let precipType : String?
    let  temperature: Double
    let apparentTemperature: Double
    let dewPoint : Double
    let humidity : Double
    let pressure : Double
    let windSpeed : Double
    let  windGust : Double
    let  windBearing : Int
    let cloudCover : Double
    let uvIndex : Int
    let visibility : Double
    let ozone : Double
    
}
