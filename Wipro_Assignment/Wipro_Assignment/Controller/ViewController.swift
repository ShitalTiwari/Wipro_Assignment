//
//  ViewController.swift
//  Wipro_Assignment
//
//  Created by SierraVista Technologies Pvt Ltd on 10/07/18.
//  Copyright © 2018 Shital. All rights reserved.
//  This class is responsible to call API get server data and bind it in table view

import UIKit
import SVProgressHUD
import Reachability

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Declaring properties
    var tblImageContainer : UITableView? //Table view to display data in tabular format
    var tableData = [[String: AnyObject]]() //Temporary property to hold data received form API
    var loadedImages = [String: UIImage]() //Local cache of images to store downloaded images
    
    //Pull to refresh: Controller to refresh table data on pulling down
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(ViewController.pullToRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.black
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initializing and setting up properties of table view
        self.tblImageContainer = UITableView(frame: self.view.bounds, style: .plain)
        self.tblImageContainer?.delegate = self
        self.tblImageContainer?.dataSource = self
        self.tblImageContainer?.tableFooterView = UIView() //Removing empty cell from table
        self.tblImageContainer?.translatesAutoresizingMaskIntoConstraints = false
        self.tblImageContainer?.addSubview(self.refreshControl) //Adding refresh controller to refresh table data
        self.tblImageContainer?.allowsSelection = false
        
        //Registering table view custom cell class to layout custom design
        self.tblImageContainer?.register(ImageContainerTableViewCell.self, forCellReuseIdentifier: Constants.GlobalConstants.strTableCellIdentifier)
        
        //Adding table view to view controller as subView
        self.view.addSubview(self.tblImageContainer!)
        
        //Adding constraints to table view to fit in display window on device
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tblView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["tblView": self.tblImageContainer!]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tblView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["tblView":self.tblImageContainer!]))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Updating table data by calling API
        self.updateTableData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //UITableView Delegate and Datasource methods
    
    //Informing number of rows to display in table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.tableData.count > 0 {
            return self.tableData.count
        }
        return 0
    }
    
    //Informing number of sections to display in table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Creating, reusing and configuring table view cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Creating custom table view cell
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.GlobalConstants.strTableCellIdentifier, for: indexPath) as! ImageContainerTableViewCell
        
        let dict = self.tableData[indexPath.row] //Getting data dictionary for displaying cell at Index path
        cell.loadCellData(dict: dict) //Setting data to cell
        
        //Initiating Image download process
        if dict[Constants.GlobalConstants.descriptionKey] as? String != nil && dict[Constants.GlobalConstants.titleKey] as? String != nil {
            cell.cellImageView.image = nil
            if let imageURL = dict[Constants.GlobalConstants.imageUrlKey] as? String {
                if loadedImages[imageURL] != nil { //If image is already downloaded reuse downloaded image
                    cell.cellImageView.image = loadedImages[imageURL]
                } else {
                    //Start downloading image
                    self.downloadImage(url: imageURL) { (image) in
                        if let image = image {
                            self.loadedImages[imageURL] = image
                            DispatchQueue.main.async {//Update UI with cell image on main thread
                                cell.cellImageView.image = image
                            }
                        }
                    }
                }
            }
        }
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        return cell
    }
    
    //Sending tableviewcell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dict = self.tableData[indexPath.row]
        var height = 70.0 as CGFloat //Default table view cell height
        
        //If not data available for cell returning cell height as 0
        if dict[Constants.GlobalConstants.descriptionKey] as? String == nil && dict[Constants.GlobalConstants.titleKey] as? String == nil && dict[Constants.GlobalConstants.imageUrlKey] as? String == nil {
            return 0
        }
        
        //Calculating height for description text to be displayed
        if dict[Constants.GlobalConstants.descriptionKey] as? String != nil {
            let descriptionHeight = CommonMethods.getCellHeight(text: dict[Constants.GlobalConstants.descriptionKey] as! String, width: tableView.bounds.width, font: UIFont.boldSystemFont(ofSize: 15))
    
            
            if descriptionHeight > 70  && dict[Constants.GlobalConstants.imageUrlKey] as? String != nil{
                height = descriptionHeight + 70 //Adding constant for cell image height
            } else {
                height = descriptionHeight + 40 // Adding constant for cell title
            }
        }
        
        return height
    }
    
    //Method to download images from server and save them in temporary property
    func downloadImage(url: String, callback: @escaping (UIImage?) -> Void) {
        let urlRequest = URLRequest(url: URL(string: url)!)
        //Initialing URL session with image download url
        URLSession.shared.dataTask(with: urlRequest) { (dataResponse, response, error) in
            //Check if data received from url for image
            if dataResponse != nil {
                // execute in UI thread and extracting image from data
                DispatchQueue.global(qos: .utility).async {
                    callback(UIImage(data: dataResponse!))
                }
            } else {//Returning nil image on Image download fialed
                DispatchQueue.global(qos: .utility).async {
                    callback(nil)
                }
            }
            }.resume()
    }
    
    //Refreshing table data on pull down
    @objc func pullToRefresh(_ refreshControl: UIRefreshControl) {
        //Resetting all table data to refresh
        self.tableData.removeAll()
        self.loadedImages.removeAll()
        self.tblImageContainer?.reloadData()
        self.updateTableData() //Calling API to get refreshed table data
        refreshControl.endRefreshing()
    }
    
    //Refreshing table data and reloading
    func updateTableData() {
        SVProgressHUD.show() //Adding progress indicator to inform user for activity in progress
        
        weak var weakSelf = self //Declaring weak self reference to avoid self nil
        
        //Check for network availability
        let checkInternet = Reachability()
        
        //Call API if network is reacheable and update table data accordingly
        checkInternet?.whenReachable = { reachability in
            if reachability.connection == .wifi || reachability.connection == .cellular {
                checkInternet?.stopNotifier()
                //API call to hit API URL
                APICall().getAPIDataFromURL { (response) in
                    SVProgressHUD.dismiss()
                    //Check if valid data received from API
                    if (response[Constants.GlobalConstants.rowsKey] as? [[String: AnyObject]]) != nil {
                        //Refreshing table data in local temporary store
                        weakSelf?.tableData = (response[Constants.GlobalConstants.rowsKey] as? [[String: AnyObject]])!
                        DispatchQueue.main.async {
                            //Setting Navigation Bar Title based on title received from server and refreshing table view
                            weakSelf?.title = response[Constants.GlobalConstants.titleKey] as? String
                            weakSelf?.tblImageContainer?.reloadData()
                        }
                        
                    } else {
                        //If incorrect data received from API show error message to user
                        let alert = UIAlertController(title: "ERROR", message: response["Error"] as? String, preferredStyle: UIAlertControllerStyle.actionSheet)
                        let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                        alert.addAction(alertAction)
                    }
                }
            } else {//If no network available display error message
                SVProgressHUD.dismiss()
                checkInternet?.stopNotifier()
                let alert = UIAlertController(title: "ERROR", message: "No Internet Connection!", preferredStyle: UIAlertControllerStyle.actionSheet)
                let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(alertAction)
            }
            
        }
        
        //If network is unreacheable show error message
        checkInternet?.whenUnreachable = { _ in
            SVProgressHUD.dismiss()
            checkInternet?.stopNotifier()
            
            let alert = UIAlertController(title: "ERROR", message: "No Internet Connection!", preferredStyle: UIAlertControllerStyle.actionSheet)
            let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(alertAction)
        }
        
        //Starting network notifier to notify network status
        do {
            try checkInternet?.startNotifier()
        } catch  {
            //Show error message is any exception found
            SVProgressHUD.dismiss()
            checkInternet?.stopNotifier()
            
            let alert = UIAlertController(title: "ERROR", message: "No Internet Connection!", preferredStyle: UIAlertControllerStyle.actionSheet)
            let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(alertAction)
        }
    }
    
    
}
