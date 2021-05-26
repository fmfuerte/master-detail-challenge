//
//  UserList+CoreDataClass.swift
//  cbqmethod challenge
//
//  Created by Francis Martin Fuerte on 5/24/21.
//
//

import Foundation
import CoreData

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")
}

@objc(UserList)
public class UserList: NSManagedObject, Codable {
    
    enum CodingKeys: CodingKey {
           case userId
           case id
           case completed
           case title
       }
       
       public func encode(to encoder: Encoder) throws {
              var container = encoder.container(keyedBy: CodingKeys.self)
              do {
                  try container.encode(id, forKey: .id)
              } catch {
                  print("error")
              }
          }
          
          required convenience public init(from decoder: Decoder) throws {
              // return the context from the decoder userinfo dictionary
              guard let contextUserInfoKey = CodingUserInfoKey.context,
              let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: "UserList", in: managedObjectContext)
              else {
                  fatalError("decode failure")
              }
              // Super init of the NSManagedObject
              self.init(entity: entity, insertInto: managedObjectContext)
              let values = try decoder.container(keyedBy: CodingKeys.self)
           
           do {
               title = try values.decode(String.self, forKey: .title)
               id = try values.decode(Int64.self, forKey: .id)
               completed = try values.decode(Bool.self, forKey: .completed)
               userId = try values.decode(Int64.self, forKey: .userId)
              } catch {
                print(error.localizedDescription)
                  print ("error")
              }
          }
    
    
    

}
