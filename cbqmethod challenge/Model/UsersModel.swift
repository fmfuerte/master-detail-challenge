//
//  UsersModel.swift
//  cbqmethod challenge
//
//  Created by Francis Martin Fuerte on 5/24/21.
//

import Foundation


//
//  UsersModel.swift
//  GitHubUsersChallenge
//
//  Created by Francis Martin Fuerte on 12/13/20.
//  Copyright © 2020 Fuerte Francis. All rights reserved.
//

import UIKit
import Foundation
import CoreData


protocol UsersModelProtocol {
    
    func usersRetrieved(_ data:[UserList])
    
    func showAlert(_ message:String,_ buttonStyle:UIAlertAction.Style)
}

class UsersModel {
    
    var networkContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
   var delegate:UsersModelProtocol?
   
    
   func getUsersList() {
       // Create a string URL
    let stringUrl = "https://jsonplaceholder.typicode.com/todos/"
  
       
       // Create a URL object
       let url = URL(string: stringUrl)
   
       
       // Check that it isn't nil
       guard url != nil else {
           print("Couldn't create url object")
           return
       }
       
    
       // Get the URL Session
       let session = URLSession.shared
    
    session.configuration.httpMaximumConnectionsPerHost = 1
    
    session.configuration.timeoutIntervalForResource = 60
    
    session.configuration.waitsForConnectivity = true
    
       // Create the data task
    let dataTask = session.dataTask(with: url!) { (data, response, error) in
           
           // Check that there are no errors and that there is data
           if error == nil && data != nil {
            
               
               // Attempt to parse the JSON
               let decoder = JSONDecoder()
               
               do {
                // Assign the NSManagedObject Context to the decoder
               decoder.userInfo[CodingUserInfoKey.context!] = self.networkContext
                
                //decode the data to translate into a list of users
                let LoadedUsers = try decoder.decode([UserList].self, from: data!)
                
                
                //save the loaded users to CoreData
                do {
                    try self.networkContext.save()
                } catch {
                    DispatchQueue.main.async {
                        self.delegate?.showAlert("An error occurred while saving: \(error)", .destructive)
                    }
                }
                
                        // Move back on the main thread, and load the saved Data
                        DispatchQueue.main.async {
                            self.loadSavedData()
                        }
               }
               catch {
                DispatchQueue.main.async {
                    // call the delegate to show an error
                self.delegate?.showAlert("An error occurred while parsing the json: \(error)", .destructive)
                }
                
               } // End Do - Catch
               
           } // End if
           else{
            DispatchQueue.main.async {
                // call the delegate to show an error
            self.delegate?.showAlert("An error occurred while loading the network. Connect to the internet and pull to refresh", .destructive)
            }
        }
           
    } // End Data Task
       
       // Start the data task
       dataTask.resume()
 
   }
    
    
    
    func loadSavedData() {
        let request: NSFetchRequest<UserList> = UserList.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sort]
        do {
            // load data by fetching from context
            let data = try networkContext.fetch(request)
            
            //sends data to the delegate
            DispatchQueue.main.async {
                self.delegate?.usersRetrieved(data)
            }
            
            
        } catch {
            print("Fetch failed")
        }
    }
    
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        DispatchQueue.main.async {
        //calls the delegate to show an alert
        self.delegate?.showAlert("Waiting for internet connection", .destructive)
        }
    }
    
 
    

}

