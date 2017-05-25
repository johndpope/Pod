//
//  PodView.swift
//  Pod
//
//  Created by Michael-Anthony Doshi on 5/16/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class PodView: UIView {
    
    // MARK: - Properties
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private lazy var joinButton: UIButton = {
        let joinButton = UIButton()
        joinButton.backgroundColor = .lightBlue
        joinButton.layer.cornerRadius = 7.0
        joinButton.layer.borderColor = UIColor.darkerGray.cgColor
        joinButton.layer.borderWidth = 1.0
        joinButton.setTitle("Request to join", for: .normal)
        joinButton.setTitleColor(.darkerGray, for: .normal)
        return joinButton
    }()
    
    private lazy var blurEffectView: UIView = {
        if self.lockedPod && !UIAccessibilityIsReduceTransparencyEnabled() {
            let blurEffect = UIBlurEffect(style: .light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            return blurEffectView
        } else {
            let transparentView = UIView()
            let podTapGesture = UITapGestureRecognizer(target: self, action: #selector(toSinglePod))
            transparentView.addGestureRecognizer(podTapGesture)
            return transparentView
        }
    }()
    
    var lockedPod = false
    
    weak var delegate: PodViewDelegate?
    
    private lazy var lockImageView: UIImageView = {
        let lockImageView = UIImageView(image: UIImage(named: "lock"))
        return lockImageView
    }()
    
    // MARK: - PodView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 26.0
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 1.0
        layer.masksToBounds = true
        
        addSubview(tableView.usingAutolayout())
        addSubview(blurEffectView.usingAutolayout())
        addSubview(lockImageView.usingAutolayout())
        addSubview(joinButton.usingAutolayout())
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper Methods
    
    private func setupConstraints() {
        
        // Table View
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        // Blur View
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.leftAnchor.constraint(equalTo: leftAnchor),
            blurEffectView.rightAnchor.constraint(equalTo: rightAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        /// Lock ImageView
        NSLayoutConstraint.activate([
            lockImageView.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -46.0),
            lockImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            lockImageView.widthAnchor.constraint(equalToConstant: 67.0),
            lockImageView.heightAnchor.constraint(equalToConstant: 87.0)
            ])
        
        // Join Button
        NSLayoutConstraint.activate([
            joinButton.topAnchor.constraint(equalTo: centerYAnchor, constant: 24.5),
            joinButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            joinButton.widthAnchor.constraint(equalToConstant: 191.0),
            joinButton.heightAnchor.constraint(equalToConstant: 34.0)
            ])
    }
    
    func toSinglePod() {
        if let delegate = delegate {
            delegate.toSinglePod(tableView.copyView())
        }
    }
}

extension PodView: UITableViewDelegate, UITableViewDataSource {
    
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

protocol PodViewDelegate: class {
    func toSinglePod(_ podView: UITableView)
}
