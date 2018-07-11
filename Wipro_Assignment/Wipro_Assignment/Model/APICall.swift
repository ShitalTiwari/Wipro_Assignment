//
//  APICall.swift
//  iOS_Infosys
//
//  Created by SierraVista Technologies Pvt Ltd on 10/07/18.
//  Copyright © 2018 Shital. All rights reserved.
//  This class manages all network API calls to get data from server

import UIKit

class APICall: NSObject {
    
    //This method calls API to download data from url
    func getAPIDataFromURL(completionHandler: @escaping (_ result: [String:AnyObject])-> Void) {
        //Creating URL from API url String
        let callURL = URL(string: Constants.GlobalConstants.apiURL)
        
        //Calling session to fetch data from url
        URLSession.shared.dataTask(with: callURL!) { (data, response, error) in
            //Checking if avalid data received from server
            if let dataResponse = data {
                if let responseString = String(data: dataResponse, encoding: String.Encoding.ascii) {
                    //Converting data to string
                    if let jsonData = responseString.data(using: String.Encoding.utf8) {
                        do {
                            //Checking and converting data string in JSON format
                            let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: AnyObject]
                            
                            //Checking if data is present with > 0 rows in table
                            if (json[Constants.GlobalConstants.rowsKey] as? [[String: AnyObject]]) != nil {
                                //Sending callback with valid data
                                completionHandler(json)
                            } else {//Sending callbak with error
                                completionHandler(["Error": "Invalid JSON data" as AnyObject])
                            }
                            
                        } catch {//Sending callbak with error
                            completionHandler(["Error": error.localizedDescription as AnyObject])
                        }
                    }
                }
                
            }
            }.resume() //Resuming URLSession task to initiate API call
    }
}
