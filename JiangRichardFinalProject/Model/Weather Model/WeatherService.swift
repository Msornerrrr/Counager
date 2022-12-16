//
//  WeatherService.swift
//  JiangRichardFinalProject
//
//  Created by XuGX on 2022/12/5.
//

import Foundation

class WeatherService {
    private let BASE_URL = "https://api.openweathermap.org/data/2.5/weather?"
    private let API_KEY = "ac2091dc95493fe33fe3bc003c91f5c5"
    private let unitOption = ["metric", "imperial"]
    
    var city: String = "jinan"
    var unitIndex: Int = 0
    
    static let sharedInstance: WeatherService = WeatherService()
    
    func updateWeatherData(onSuccess: @escaping ((WeatherInfo) -> Void)) {
        let parsedString = "\(BASE_URL)q=\(city)&units=\(unitOption[unitIndex])&appid=\(API_KEY)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: parsedString)!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                let decoder = JSONDecoder()
                let weather = try decoder.decode(WeatherInfo.self, from: data!)
                onSuccess(weather)
            } catch {
                print(error)
                exit(1)
            }
        }
        task.resume()
    }
}
