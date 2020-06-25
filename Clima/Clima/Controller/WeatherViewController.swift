//
//  WeatherManager.swift
//  Clima
//
//  Created by Vlad Novik on 6/1/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var celsiusOne: UILabel!
    @IBOutlet weak var celsiusTwo: UILabel!
    
    var weatherManager = WeatherManager()
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherManager.delegate = self
        searchTextField.delegate = self
        locationManager.delegate = self
        
        hideLabels()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        
    }
    
}
//MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
}

//MARK: - Work with searchTextField
extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Enter a request"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text {
            weatherManager.fetchWeather(cityName: city)
            searchTextField.text = ""
        }
    }
}

//MARK: - Update information and search errors
extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        let cityName = weather.cityName
        let conditional = weather.conditionName
        let temperature = weather.temperatureString
        DispatchQueue.main.async {
            self.showLabels()
            self.searchTextField.placeholder = "Search"
            self.temperatureLabel.text = temperature
            self.cityLabel.text = cityName
            self.conditionImageView.image = UIImage(systemName: conditional)
        }
    }
    
    func didFailWithError(error: Error) {
        DispatchQueue.main.async {
            self.searchTextField.placeholder = "Error!"
            self.hideLabels()
        }
    }
}

//MARK: - func by hide/show labels
extension WeatherViewController { // hide/show labels
    
    func hideLabels() {
        self.conditionImageView.isHidden = true
        self.temperatureLabel.isHidden = true
        self.cityLabel.isHidden = true
        self.celsiusOne.isHidden = true
        self.celsiusTwo.isHidden = true
    }
    
    func showLabels() {
        self.conditionImageView.isHidden = false
        self.temperatureLabel.isHidden = false
        self.cityLabel.isHidden = false
        self.celsiusOne.isHidden = false
        self.celsiusTwo.isHidden = false
    }
}
