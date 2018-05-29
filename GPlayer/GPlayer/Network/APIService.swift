//
//  APIService.swift
//  GPlayer
//
//  Created by 이광용 on 2018. 5. 18..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation
import Alamofire

enum Result<T> {
    case Success(T)
    case Failure(Int)
    case FailDescription(String)
}

protocol APIService {
    
}

extension APIService  {
    static func getURL(path: String) -> String {
        return "https://dantonglaw.firebaseio.com/videolist.json" + path
    }
    static func getResult_StatusCode(response: DataResponse<Any>) -> Result<Any>? {
        switch response.result {
        case .success :
            guard let statusCode = response.response?.statusCode as Int? else {return nil}
            let result = response.result
            switch statusCode {
            case 200..<400 :
                guard let value = result.value else {return Result.FailDescription("value is empty")}
                return Result.Success(value)
            default :
                return Result.Failure(statusCode)
            }
        case .failure(let err) :
            return Result.FailDescription(err.localizedDescription)
        }
    }
}

