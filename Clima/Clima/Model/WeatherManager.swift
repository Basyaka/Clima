//
//  WeatherManager.swift
//  Clima
//
//  Created by Vlad Novik on 6/1/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    
    var delegate: WeatherManagerDelegate?
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=ec4ce8533b17b015dd4666b757bdfb51&units=metric"
    
    func fetchWeather(cityName: String) {
        let cityString = "&q=\(cityName)"
        let urlString = "\(weatherURL)" + cityString
        performRequest(with: urlString)
    }
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let latitude = "&lat=\(String(latitude))"
        let longitude = "&lon=\(String(longitude))"
        let urlString = "\(weatherURL)" + latitude + longitude
        performRequest(with: urlString)
    }
    
    
    func performRequest(with urlString: String)  {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, responce, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self ,weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decoder = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decoder.weather[0].id
            let temperature = decoder.main.temp
            let name = decoder.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temperature)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

