//
//  PointsViewController.swift
//  FCCTestApplication
//
//  Created by Mikhail Kirillov on 01/09/2018.
//  Copyright © 2018 Mikhail Kirillov. All rights reserved.
//

import UIKit

class PointsViewController: UITableViewController {
    
    private let service: DataPointsService
    
    private var staticDataSource = [UITableViewCell]()
    
    private var buttonCell: ButtonTableCell?
    private var fieldCell: TextFieldTableCell?
    
    private var chartView: ChartView?
    
    init(_ testCase: TestCase) {
        service = DataPointsService(testCase)
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        service = DataPointsService()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 100
        
        let graphFrame = CGRect(origin: .zero, size: CGSize(width: self.view.bounds.width, height: self.view.bounds.width / 2))
        chartView = ChartView(frame: graphFrame.offsetBy(dx: -10, dy: -10))
        chartView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.tableFooterView = chartView
        
        fillStaticDataSource()
        
        service.addListener(observer: self, selector: #selector(didRecievePointsUpdate(notification:)))
    }
    
    @objc func didRecievePointsUpdate(notification: Notification) {
        if let userInfo = notification.userInfo, let error = userInfo["error"] as? Error {
            displayError(error)
            return
        }
        tableView.reloadData()
        
        let cgPoints = service.points.compactMap({ return $0.cgPoint })
        chartView?.displayPoints(points: cgPoints)
    }
    
    private func displayError(_ error: Error) {
        let alert = UIAlertController.init(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    private func fillStaticDataSource() {
        let cell = UITableViewCell()
        cell.textLabel?.text = "Enter number of point you want to see displayed, then press go"
        cell.textLabel?.numberOfLines = 0
        cell.selectionStyle = .none
        staticDataSource.append(cell)
        
        buttonCell = ButtonTableCell.create(for: tableView)
        buttonCell?.button.addTarget(self, action: #selector(startRequestAction), for: .touchUpInside)
        
        fieldCell = TextFieldTableCell.create(for: tableView)
        
        staticDataSource.append(fieldCell!)
        staticDataSource.append(buttonCell!)
    }
    
    @objc func startRequestAction() {
        self.view.endEditing(true)
        
        guard let text = fieldCell?.textField.text, let number = Int(text)  else {
            return
        }
        service.requestPoints(number)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return staticDataSource.count
        case 1:
            return service.points.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return staticDataSource[indexPath.row]
        case 1:
            let point = service.points[indexPath.row]
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.textLabel?.text = "x: \(point.xAxis)"
            cell.detailTextLabel?.text = "y: \(point.yAxis)"
            cell.selectionStyle = .none
            return cell
        default:
            return UITableViewCell()
        }
    }
}



