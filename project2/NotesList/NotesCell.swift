//
//  NotesCell.swift
//  project2
//
//  Created by Дмитрий Войтович on 17.04.2022.
//

import UIKit

class NotesCell: UITableViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black | UIColor.white
        label.font = .systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    let bodyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.numberOfLines = 2
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        sv.axis = .vertical
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )
        
        setupConstraints()
    }
    
    required init?(
        coder: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func setup(with note: Note) {
        titleLabel.text = note.title
        bodyLabel.text = note.text
    }
}

private extension NotesCell {
    func setupConstraints() {
        contentView.addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12).isActive = true
        stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12).isActive = true
        stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -12).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12).isActive = true
    }
}
