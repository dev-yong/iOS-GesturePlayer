//
//  GPlayerSlideUpMenu.swift
//  GPlayer
//
//  Created by 이광용 on 2018. 5. 18..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

protocol GSlideUpMenuDelgate {
    func  gSlideUpMenu<T: EnumCollection>(menu: GSlideUpMenu, data: T)
}

class GSlideUpMenu: UIView {
    var data: [Any] = [] {
        didSet {
            self.tableView.reloadData()
            self.updateConstraints(height: CGFloat(self.data.count * 50))
        }
    }
    var delegate: GSlideUpMenuDelgate?
    
    var selectedIndex: Int = 0 {
        didSet {
            let indexPath = IndexPath(row: selectedIndex, section: 0)
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }
    
    var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.alpha = 0
        return view
    }()
    var tableViewHeightConstraint: NSLayoutConstraint?
    var tableViewBottomConstraint: NSLayoutConstraint?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GSlideUpMenuCell.self, forCellReuseIdentifier: "GSlideUpMenuCell")
        tableView.alwaysBounceVertical = false
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp() {
        setUpConstraint()
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissSlideUpMenu)))
        
    }
    
    func setUpConstraint() {
        self.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    func updateConstraints(height: CGFloat) {
        self.tableViewHeightConstraint?.isActive = false
        self.tableViewHeightConstraint = self.tableView.heightAnchor.constraint(equalToConstant: height)
        self.tableViewHeightConstraint?.isActive = true
        self.tableViewBottomConstraint?.isActive = false
        self.tableViewBottomConstraint = self.tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: height)
        self.tableViewBottomConstraint?.isActive = true
    }
    @objc func dismissSlideUpMenu() {
        slideUpMenuAnimation(show: false)
    }
    
    func slideUpMenuAnimation(show: Bool) {
        let alpha: CGFloat = show ? 1.0 : 0.0
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.5,
                       animations: {
                        self.backgroundView.alpha = alpha
                        if let height = self.tableViewHeightConstraint?.constant {
                            self.tableViewBottomConstraint?.constant = show ? 0 : height
                        }
                        self.layoutIfNeeded()
        }, completion: {_ in
            if !show {
                self.removeFromSuperview()
            }
        })
    }
}

extension GSlideUpMenu: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "GSlideUpMenuCell", for: indexPath) as! GSlideUpMenuCell
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.selectionStyle = .none
        //        cell.layoutMargins = UIEdgeInsets.zero
        cell.textLabel?.textColor = cell.isSelected ? Default.Color.green : .black
        if let data = data as? [Definition] {
            cell.textLabel?.text = data[indexPath.row].description
        }
        else if let data = data as? [Subtitle] {
            cell.textLabel?.text = data[indexPath.row].description
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.textLabel?.textColor = Default.Color.green
        if let data = self.data as? [Definition] {
            delegate?.gSlideUpMenu(menu: self, data: data[indexPath.row])
        }
        else if let data = self.data as? [Subtitle] {
            delegate?.gSlideUpMenu(menu: self, data: data[indexPath.row])
        }
        dismissSlideUpMenu()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.textLabel?.textColor = .black
    }
}


class GSlideUpMenuCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
