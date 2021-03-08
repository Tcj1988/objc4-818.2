//
//  TCJServiceSetting.swift
//  TCJService
//
//  Created by tangchangjiang on 2021/2/11.
//

import UIKit
import Alamofire

//类需要声明为public
public class TCJServiceSetting: NSObject {
    //属性需要声明为public
    public static let SCRET_KEY = "SCRET_KEY"
    func addNet() {
        AF.request("https://test/get").response { response in
            debugPrint(response)
        }
    }
}
