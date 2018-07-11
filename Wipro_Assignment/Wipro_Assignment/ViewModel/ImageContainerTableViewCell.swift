//
//  ImageContainerTableViewCell.swift
//  Wipro_Assignment
//
//  Created by SierraVista Technologies Pvt Ltd on 11/07/18.
//  Copyright © 2018 Shital. All rights reserved.
//  This class manages TableViewCell creation programmatically

import UIKit

class ImageContainerTableViewCell: UITableViewCell {

    //Declaring cell image view property and adding its configuration for display
    let cellImageView:UIImageView = {
        let cellImage = UIImageView()
        cellImage.contentMode = .scaleAspectFill // image will never be strecthed vertially or horizontally
        cellImage.translatesAutoresizingMaskIntoConstraints = false // enable autolayout
        cellImage.clipsToBounds = true
        return cellImage
    }()
    
    //Declaring cell title label property and adding its configuration for display
    let lblCellTitle:UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor =  UIColor.black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0 //This enables to display multiline text in label
        return titleLabel
    }()
    
    //Declaring cell dexcription label property and adding its configuration for display
    let lblCellDescription:UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 15)
        descriptionLabel.textColor =  UIColor.black
        descriptionLabel.clipsToBounds = true
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0 //This enables to display multiline text in label
        descriptionLabel.lineBreakMode = .byWordWrapping //Indicates how line ill be broken to show multiline text
        
        return descriptionLabel
    }()
    
    //Declaring container property and adding its configuration for display and to hold title and description in it
    let containerView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true // this will make sure its subview/child view do not go out of the boundary
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //Adding subviews on content view of cell to hold them for display
        self.contentView.addSubview(cellImageView)
        containerView.addSubview(lblCellTitle)
        containerView.addSubview(lblCellDescription)
        self.contentView.addSubview(containerView)
        
  
        //Adding constraints to cell image view to manage its layout when displaying
    cellImageView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        cellImageView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant:10).isActive = true
        cellImageView.widthAnchor.constraint(equalToConstant:70).isActive = true
        cellImageView.heightAnchor.constraint(equalToConstant:70).isActive = true
        
        //Adding autolayout constraints to container view to hold its position when displayed:
    containerView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo:self.cellImageView.trailingAnchor, constant:10).isActive = true
        containerView.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant:-10).isActive = true
        containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        //Adding constraints to cell title to fit in its container view
        lblCellTitle.topAnchor.constraint(equalTo:self.containerView.topAnchor).isActive = true
        lblCellTitle.leadingAnchor.constraint(equalTo:self.containerView.leadingAnchor).isActive = true
        lblCellTitle.trailingAnchor.constraint(equalTo:self.containerView.trailingAnchor).isActive = true
        lblCellTitle.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        //Adding constraints to cell description to fit in its container view
    lblCellDescription.topAnchor.constraint(equalTo:self.lblCellTitle.bottomAnchor).isActive = true
    lblCellDescription.leadingAnchor.constraint(equalTo:self.containerView.leadingAnchor).isActive = true
    lblCellDescription.trailingAnchor.constraint(equalTo:self.containerView.trailingAnchor).isActive = true
        lblCellDescription.bottomAnchor.constraint(equalTo:self.containerView.bottomAnchor).isActive = true
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //Method to load cell data
    func loadCellData(dict: [String: AnyObject]) {
        //Resetting cell components to default
        lblCellTitle.text = ""
        lblCellDescription.text = ""
        cellImageView.image = nil
        
        //Checking for title availability and set it to label
        if let title = dict[Constants.GlobalConstants.titleKey] as? String {
            self.lblCellTitle.text = title
        }
        //Checking for description availability and set it to label
        if let desc = dict[Constants.GlobalConstants.descriptionKey] as? String {
            self.lblCellDescription.text = desc
        }
    }

}
