//
//  UITableViewCell+Create.swift
//  FCCTestApplication
//
//  Created by Mikhail Kirillov on 05/09/2018.
//  Copyright © 2018 Mikhail Kirillov. All rights reserved.
//

import UIKit

extension UITableViewCell {
    static func create<T>(for tableView: UITableView) -> T where T: UITableViewCell {
        let cellIdentifier = String(describing: self)
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? T {
            return cell
        }
        if Bundle.main.path(forResource: cellIdentifier, ofType: "nib") != nil {
            let nib = UINib(nibName: cellIdentifier, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        } else {
            tableView.register(T.self, forCellReuseIdentifier: cellIdentifier)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)! as? T
        return cell!
    }
}

