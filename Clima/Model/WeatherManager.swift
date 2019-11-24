//
//  WeatherManager.swift
//  Clima
//
//  Created by Stanley Chen on 11/23/19.
//  Copyright © 2019 App Brewery. All rights reserved.
//



//api key 25eba9c46ded18157c5e24916a33fa32
import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?q=london&appid=25eba9c46ded18157c5e24916a33fa32&units=metric"
    
    var delegate: WeatherManagerDelegate?
        
        func fetchWeather(cityName: String) {
            let urlString = "\(weatherURL)&q=\(cityName)"
            performRequest(with: urlString)
        }
        
        func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
            let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
            performRequest(with: urlString)
        }
        
        func performRequest(with urlString: String) {
            if let url = URL(string: urlString) {
                let session = URLSession(configuration: .default)
                let task = session.dataTask(with: url) { (data, response, error) in
                    if error != nil {
                        self.delegate?.didFailWithError(error: error!)
                        return
                    }
                    if let safeData = data {
                        if let weather = self.parseJSON(safeData) {
                            self.delegate?.didUpdateWeather(self, weather: weather)
                        }
                    }
                }
                task.resume()
            }
        }
        
        func parseJSON(_ weatherData: Data) -> WeatherModel? {
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
                let id = decodedData.weather[0].id
                let temp = decodedData.main.temp
                let name = decodedData.name
                
                let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
                return weather
                
            } catch {
                delegate?.didFailWithError(error: error)
                return nil
            }
        }
        
        
        
    }
