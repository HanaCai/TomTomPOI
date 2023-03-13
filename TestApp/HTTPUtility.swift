//
//  HTTPUtility.swift
//  TestApp
//
//  Created by Hana Cai on 12/29/2022.
//

import Foundation
typealias ResponseCompletion = (ResponseModel?)->()

class HTTPUtility{
    
    static let shared = HTTPUtility()
    private init(){}
    
    private func parse(_ data: Data)->ResponseModel?{
        let decoder = JSONDecoder()
        return  try? decoder.decode(ResponseModel.self, from: data)
    }
    
    //MARK: - Public methods
    func getNearByPlacesUsing(lat: String, long: String, completion: @escaping ResponseCompletion){
        
        let urlString = "https://api.tomtom.com/search/2/nearbySearch/.json?key=\(AppConstants.apiKey)&lat=\(lat)&lon=\(long)&radius=\(metersFromMiles(AppConstants.regionRadiusInMiles))"
        guard let urlRequest = URL.init(string: urlString) else {
            completion(nil)/// unable to create url issues with the params
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) {[weak self] data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            completion(self?.parse(data))
        }
        task.resume()
    }
    
}

