//
//  MasterViewController.swift
//  cbqmethod challenge
//
//  Created by Francis Martin Fuerte on 5/24/21.
//

import UIKit
import CoreData
import Foundation

//delegate to handle user selection
protocol UserSelectionDelegate: AnyObject {
  func userSelected(_ newUser: UserList)
}

class MasterViewController: UITableViewController, UsersModelProtocol {
    var container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer //CoreData container
    
    var refreshController = UIRefreshControl() //controller to handle pull to refresh
    
    var usersModel = UsersModel() //model to handle Loading of users
    
    var users = [UserList]()
    var delegate: UserSelectionDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        usersModel.delegate = self
        
        refreshController.beginRefreshing()
        
        refreshController.addTarget(self, action:  #selector(refresh), for: .valueChanged)
        
        tableView.addSubview(refreshController)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    

    
    //fetch the saved data when view will appear
    override func viewWillAppear(_ animated: Bool) {
         fetchSavedData()
    }
    
    
    @objc func refresh(){
        refreshController.beginRefreshing()
        deleteSavedData()
        fetchSavedData()
    }
    
    func usersRetrieved(_ data: [UserList]) {
        users = data
        
        refreshController.endRefreshing()
        
        // Refresh the tableview
        tableView.stopLoading()
        tableView.reloadData()
    }
    
    func showAlert(_ message: String, _ buttonStyle: UIAlertAction.Style) {
        tableView.stopLoading()
        refreshController.endRefreshing()
       
       
          let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
 
          alert.addAction(UIAlertAction(title: "Ok", style: buttonStyle, handler: nil))

          self.present(alert, animated: true)
    }
    
     //fetch the saved data
     func fetchSavedData() {
       // usersModel.loadSavedData()
        
             let request: NSFetchRequest<UserList> = UserList.fetchRequest()
             let sort = NSSortDescriptor(key: "id", ascending: true)
             request.sortDescriptors = [sort]
             do {
                 // fetch is performed on the NSManagedObjectContext
                 let data = try container.viewContext.fetch(request)
            
            //    users = data
                
                if(data.count == 0){
                    usersModel.getUsersList()
                }else{
                    users = data
                }
                
                refreshController.endRefreshing()
                 
                 //relead the tableview
                tableView.stopLoading()
                 tableView.reloadData()
             } catch {
                 print("Fetch failed")
             }
     }
     
     //only used for testing and debugging - deletes all save data
     func deleteSavedData(){
         
                // create the delete request for the specified entity
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserList.fetchRequest()
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

                // perform the delete
                do {
                    try container.viewContext.execute(deleteRequest)
                    try container.viewContext.save()
                    
                    users = [UserList]()
                   // usersModel.getUsersList()
                 /*   if(users.count == 0){
                      usersModel.getUsersList(0)
                    }
                     
 */
                    
                } catch let error as NSError {
                    print(error)
                }
                
        refreshController.endRefreshing()
        // Refresh the tableview
        tableView.stopLoading()
        tableView.reloadData()
     }
     
     
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Get the user based on index
        let user = users[indexPath.row]
    
        cell.textLabel?.text = user.title

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = users[indexPath.row]
        
          delegate?.userSelected(selectedUser) // call the delegate to set the user for detailviewcontroller
        
        
        //navigates to the detailviewcontroller
        if let detailViewController = delegate as? DetailViewController,
          let detailNavigationController = detailViewController.navigationController {
            splitViewController?
              .showDetailViewController(detailNavigationController, sender: nil)
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            let alert = UIAlertController(title: "Confirmation", message: "Would you like to delete?", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Ok", style: .destructive){ _ in
            
                self.deleteRow(indexPath.row)
                
                self.users.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
    
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
            self.present(alert, animated: true)
            
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    
    //deletes a row from CoreData
    func deleteRow(_ row:Int){
        let request: NSFetchRequest<UserList> = UserList.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sort]
        do {
            // fetch is performed on the NSManagedObjectContext
            var data = try container.viewContext.fetch(request)
       
            data.remove(at: row)
            
            try container.viewContext.save()
           
           refreshController.endRefreshing()
           
            //reload the tableview
           tableView.stopLoading()
            tableView.reloadData()
        } catch {
            print("Fetch failed")
        }
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */




//add a loading progress view to the tableview when scrolled to load more users
extension UITableView{

func indicatorView() -> UIActivityIndicatorView{
    var activityIndicatorView = UIActivityIndicatorView()
    if self.tableFooterView == nil{
        let indicatorFrame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 40)
        activityIndicatorView = UIActivityIndicatorView(frame: indicatorFrame)
        activityIndicatorView.isHidden = false
        activityIndicatorView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        activityIndicatorView.isHidden = true
        self.tableFooterView = activityIndicatorView
        return activityIndicatorView
    }else{
        return activityIndicatorView
    }
}

func addLoading(_ indexPath:IndexPath, closure: @escaping (() -> Void)){
    indicatorView().startAnimating()
    
    if let lastVisibleIndexPath = self.indexPathsForVisibleRows?.last {
        if indexPath == lastVisibleIndexPath && indexPath.row == self.numberOfRows(inSection: 0) - 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                closure()
            }
        }
    }
    indicatorView().isHidden = false
}

func stopLoading(){
    indicatorView().stopAnimating()
    indicatorView().isHidden = true
}
    
}

