//
//  ViewController.swift
//  DatabaseManager
//
//  Created by yu qin on 2019/8/5.
//  Copyright © 2019 yu qin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let p = Person()
        p.name = "pq666"
        p.age = "12"
        DatabaseManager.shared.createTable(Person.self)
        DatabaseManager.shared.insert(p)
        DatabaseManager.shared.getAll(cls: Person.self)

        // Do any additional setup after loading the view.
    }


}

