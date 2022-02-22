//
//  ViewController.swift
//  LockNStockTest
//
//  Created by Yawer Khan on 22/02/22.
//

import UIKit


//MARK: I didn't use 3rd party libraries for your convenience

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let colors = [UIColor.blue, UIColor.yellow, UIColor.magenta, UIColor.red, UIColor.brown]
    var result = [Results]()
    @IBOutlet var tableView: UITableView!
    var activityIndicator = UIActivityIndicatorView()
    var page = 1
    var totalPage = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        callApi()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TableViewTVC", bundle: nil), forCellReuseIdentifier: "tableViewTVC")
    }
    
    func showLoader(){
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.center = CGPoint(x:self.view.frame.size.width / 2, y:self.view.frame.size.height / 2);
        activityIndicator.startAnimating()
        self.tableView.addSubview(activityIndicator)
    }
    
    //MARK: Parsing Data
    func parse(json: Data) {
        let decoder = JSONDecoder()
        if let json = try? decoder.decode(DataModel.self, from: json) {
            guard let data = json.results else { return }
            print(data)
            result.append(contentsOf: data)
            totalPage = json.total_pages ?? 0
        }
        stopLoader()
    }
    
    func stopLoader(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.activityIndicator.removeFromSuperview()
        }
    }
    //MARK: Calling Api
    func callApi(){
        let urlComp = NSURLComponents(string: "https://api.themoviedb.org/3/movie/top_rated")!
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "api_key", value: "ec01f8c2eb6ac402f2ca026dc2d9b8fd"))
            items.append(URLQueryItem(name: "page", value: String(page)))
            items = items.filter{!$0.name.isEmpty}
            if !items.isEmpty {
              urlComp.queryItems = items
            }
            var urlRequest = URLRequest(url: urlComp.url!)
            urlRequest.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if error != nil{
                self.stopLoader()
            }
            if let data = data{
                self.parse(json: data)
            }
            else{
                self.stopLoader()
            }
            }
            task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    //MARK: Pagination
    func pagination(indexPath:IndexPath){
        if indexPath.row == result.count - 1 {
            if page < totalPage{
                page += 1
                callApi()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell: TableViewTVC = tableView.dequeueReusableCell(withIdentifier: "tableViewTVC") as? TableViewTVC{
            cell.idLbl.text = "\(result[indexPath.row].id ?? 0)"
            cell.originalLanguage.text = result[indexPath.row].original_language ?? ""
            cell.titleLbl.text = result[indexPath.row].title ?? ""
            cell.populartyLbl.text = "\(result[indexPath.row].popularity ?? 0.0)"
            pagination(indexPath: indexPath)
            return cell
        }
        return UITableViewCell()
    }
}

