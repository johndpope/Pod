//
//  PodViewController.swift
//  Pod
//
//  Created by Michael-Anthony Doshi on 5/22/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class PodViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Sample"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 24.0)
        return titleLabel
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 26.0
        return tableView
    }()
    
    private lazy var postButton: UIButton = {
        let postButton = UIButton()
        postButton.setTitle("New Post", for: .normal)
        postButton.setTitleColor(.white, for: .normal)
        postButton.backgroundColor = .lightBlue
        postButton.titleLabel?.textAlignment = .center
        return postButton
    }()
    
    let postButtonHeight: CGFloat = 50.0
    let titleTopMargin: CGFloat = 11.0 + UIApplication.shared.statusBarFrame.height
    let titleBottomMargin: CGFloat = 6.0
    
    // MARK: - PodViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .lightBlue
        
        view.addSubview(titleLabel.usingAutolayout())
        view.addSubview(tableView.usingAutolayout())
        view.addSubview(postButton.usingAutolayout())
        setupConstraints()
    }
    
    // MARK: - Helper Methods
    
    private func setupConstraints() {
        
        // Title Label
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: titleTopMargin),
            ])
        
        // Post Button
        NSLayoutConstraint.activate([
            postButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            postButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            postButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            postButton.heightAnchor.constraint(equalToConstant: postButtonHeight)
            ])
        
        // Table View
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: titleBottomMargin),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
}

// MARK: - UITableView Methods

extension PodViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
}
