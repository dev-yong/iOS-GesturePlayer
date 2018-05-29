//
//  RequestService.swift
//  GPlayer
//
//  Created by 이광용 on 2018. 5. 18..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation
import Alamofire

struct RequestService: APIService {
    static func getData(url: String, parameter: [String : Any]?, completion: @escaping (Result<Any>)->()) {
        let url = self.getURL(path: url)
        Alamofire.request(url,
                          method: .get,
                          parameters: parameter,
                          encoding: JSONEncoding.default,
                          headers: nil).responseJSON { (response) in
                            guard let resultData = getResult_StatusCode(response: response) else {return}
                            completion(resultData)
        }
    }
}

//**********    Example Code    **********
//SignService.getSignData(url: "addedURL", parameter: ...) { (result) in
//    switch result {
//    case .Success(let response):
//        guard let data = response as? Data else {return}
//        let dataJSON = JSON(data)
//        print(dataJSON)
//    case .Failure(let failureCode):
//        print("Sign In Failure : \(failureCode)")
//          switch failureCode {
//              case ... :
//          }
//    }
//}
