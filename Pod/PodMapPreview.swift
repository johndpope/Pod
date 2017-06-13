//
//  PodMapPreview.swift
//  Pod
//
//  Created by Michael-Anthony Doshi on 6/12/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class PodMapPreview: UIView {
    
    // MARK: - Properties
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 24.0)
        titleLabel.textColor = .white
        titleLabel.text = self.podData._name
        return titleLabel
    }()
    
    private lazy var mutualFriendsLabel: UILabel = {
        let mutualFriendsLabel = UILabel()
        mutualFriendsLabel.font = .systemFont(ofSize: 14.0)
        mutualFriendsLabel.textColor = .white
        var text = "Information N/A"
        if let numPeople = self.podData._userIdList?.count {
            if numPeople == 1 {
                text = "\(numPeople) person"
            } else {
                text = "\(numPeople) people"
            }
        }
        mutualFriendsLabel.text = text
        return mutualFriendsLabel
    }()
    
    private lazy var openLabel: UILabel = {
        let openLabel = UILabel()
        openLabel.font = .systemFont(ofSize: 14.0)
        openLabel.textColor = .white
        openLabel.text = "OPEN"
        return openLabel
    }()
    
    private lazy var openButton: UIButton = {
        let openButton = UIButton()
        openButton.backgroundColor = .darkBlue
        openButton.setImage(UIImage(named:"up_caret"), for: .normal)
        openButton.layer.cornerRadius = 22.5
        openButton.layer.shadowColor = UIColor.black.cgColor
        openButton.layer.shadowOpacity = 0.5
        openButton.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        openButton.layer.shadowRadius = 2.0
        openButton.layer.masksToBounds = true
        openButton.addTarget(self, action: #selector(openButtonPressed), for: .touchUpInside)
        return openButton
    }()
    
    let podData: PodList
    weak var delegate: PodMapPreviewDelegate?
    
    // MARK: - PodMapPreview
    
    init(frame: CGRect, podData data: PodList) {
        podData = data
        super.init(frame: frame)
        
        backgroundColor = .lightBlue
        addSubview(titleLabel.usingAutolayout())
        addSubview(mutualFriendsLabel.usingAutolayout())
        addSubview(openLabel.usingAutolayout())
        addSubview(openButton.usingAutolayout())
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper Methods
    
    private func setupConstraints() {
        
        // Title Label
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8.0),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10.0),
            titleLabel.rightAnchor.constraint(equalTo: openButton.leftAnchor, constant: -10.0)
            ])
        
        // Mutual Friends Label
        NSLayoutConstraint.activate([
            mutualFriendsLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0),
            mutualFriendsLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8.0),
            mutualFriendsLabel.rightAnchor.constraint(equalTo: centerXAnchor)
            ])
        
        // Open Label
        NSLayoutConstraint.activate([
            openLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0),
            openLabel.centerXAnchor.constraint(equalTo: openButton.centerXAnchor)
            ])
        
        // Open Button
        NSLayoutConstraint.activate([
            openButton.centerYAnchor.constraint(equalTo: topAnchor),
            openButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -10.0),
            openButton.widthAnchor.constraint(equalToConstant: 45.0),
            openButton.heightAnchor.constraint(equalTo: openButton.widthAnchor)
            ])
    }
    
    // MARK: - Button Actions
    
    func openButtonPressed() {
        if let delegate = self.delegate {
            print("here")
            delegate.openButtonPressed(podData)
        }
    }
}

protocol PodMapPreviewDelegate: class {
    func openButtonPressed(_ pod: PodList)
}
