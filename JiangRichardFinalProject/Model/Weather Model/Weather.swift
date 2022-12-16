//
//  Weather.swift
//  JiangRichardFinalProject
//
//  Created by XuGX on 2022/12/5.
//

import Foundation

struct WeatherInfo: Decodable {
    let weather: [Weather]
    let main: Main
}

struct Weather: Decodable {
    let main: String
    let description: String
}

struct Main: Decodable {
    let temp: Float
}
