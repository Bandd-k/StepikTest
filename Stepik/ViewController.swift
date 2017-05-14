//
//  ViewController.swift
//  Stepik
//
//  Created by Denis Karpenko on 13.05.17.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import UIKit
import PagedArray
import Kingfisher
import Alamofire
import SwiftyJSON
import PopupDialog







let PreloadMargin = 5 /// How many rows "in front" should be loaded
let PageSize = 5 /// Paging size, Don't Change in the current implementation
let TotalCount = 490 /// Number of rows in table view, in the current implementation we need API method to request number of courses




class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var pagedArray = PagedArray<Course>(count: TotalCount, pageSize: PageSize)
    var shouldPreload = true
    let operationQueue = OperationQueue()
    var dataLoadingOperations = [Int: Operation]()
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var coursesTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        coursesTableView.dataSource = self
        coursesTableView.delegate = self
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 102/255, green: 204, blue: 102/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        coursesTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(self.update), for: .valueChanged)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func update(){
        dataLoadingOperations.removeAll(keepingCapacity: true)
        operationQueue.cancelAllOperations()
        pagedArray.removeAllPages()
        coursesTableView.reloadData()
        refreshControl.endRefreshing()
    }

    
    // MARK: Pagging staff
    
    fileprivate func loadDataIfNeededForRow(_ row: Int) {
        
        let currentPage = pagedArray.page(for: row)
        if needsLoadDataForPage(currentPage) {
            loadDataForPage(currentPage)
        }
        
        let preloadIndex = row+PreloadMargin
        if preloadIndex < pagedArray.endIndex && shouldPreload {
            let preloadPage = pagedArray.page(for: preloadIndex)
            if preloadPage > currentPage && needsLoadDataForPage(preloadPage) {
                loadDataForPage(preloadPage)
            }
        }
    }
    
    private func needsLoadDataForPage(_ page: Int) -> Bool {
        return pagedArray.elements[page] == nil && dataLoadingOperations[page] == nil
    }
    
    private func loadDataForPage(_ page: Int) {
        let indexes = pagedArray.indexes(for: page)
        print ("download data for \(indexes)")
        let blockOperation = BlockOperation {
            let url = "https://stepik.org/api/courses?page=\(page+1)"
            Alamofire.request(url, method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    // completion
                    var answer = [Course]()
                    let json = JSON(value)
                    for i in indexes{
                        let ind = i-indexes.startIndex
                        let course = Course(title: json["courses"][ind]["title"].stringValue, cover: json["courses"][ind]["cover"].stringValue, description: json["courses"][ind]["summary"].stringValue)
                        answer.append(course)
                    }
                    self.pagedArray.set(answer, forPage: page)
                    // Reload cells
                    if let indexPathsToReload = self.visibleIndexPathsForIndexes(indexes) {
                        self.coursesTableView.reloadRows(at: indexPathsToReload, with: .automatic)
                    }
                    
                    // Cleanup
                    self.dataLoadingOperations[page] = nil
                case .failure(let error):
                    print(error)
                }
            }
            
        }
        // Add operation to queue and save it
        operationQueue.addOperation(blockOperation)
        dataLoadingOperations[page] = blockOperation
    }
    
    private func visibleIndexPathsForIndexes(_ indexes: CountableRange<Int>) -> [IndexPath]? {
        return coursesTableView.indexPathsForVisibleRows?.filter { indexes.contains(($0 as NSIndexPath).row) }
    }
}

// MARK: Table view datasource
extension ViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if currentReachabilityStatus != .notReachable {
            return 1
        }
        else{
            TableViewHelper.EmptyMessage(message: "Sorry, You don't have an Internet connection", viewController: coursesTableView)
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pagedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        loadDataIfNeededForRow((indexPath as NSIndexPath).row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomTableCell
        cell.configure(data: pagedArray[indexPath.row])
        return cell
    }
    
}

// MARK: delegate
extension ViewController {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = pagedArray[indexPath.row]?.title
        let startUrl = "https://stepik.org"
        let message = pagedArray[indexPath.row]?.description
        let image = UIImageView()
        if let cover = pagedArray[indexPath.row]?.cover,let url = URL(string: startUrl+cover){
            image.kf.setImage(with: url)
            
        }
        
        let popup:PopupDialog?
        // Create the dialog
        if let img = image.image{
            popup = PopupDialog(title: title, message: message, image: img)
        }
        else{
            
           popup = PopupDialog(title: title, message: message, image: nil)
        }
        // Create button
        let buttonOne = CancelButton(title: "Ok") {
            print("You canceled the dialog.")
        }
        
        popup?.addButton(buttonOne)

        // Present dialog
        self.present(popup!, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.imageView?.kf.cancelDownloadTask()
    }
    
    
    
}



