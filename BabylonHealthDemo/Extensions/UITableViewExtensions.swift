//
//  UITableViewExtensions.swift
//  DRToolkit
//
//  Created by David Rodrigues on 05/04/16.
//  Copyright © 2016-2017 David Rodrigues. All rights reserved.
//

import UIKit

extension UITableView {

    enum ReusableStrategy {
        case Class
        case Nib
    }

    private func identifier<T: UITableViewCell>(_ type: T.Type) -> String {
        return String(describing: type)
    }

    private func nib<T: UITableViewCell>(of type: T.Type) -> UINib {
        return UINib(nibName: String(describing: type), bundle: nil)
    }

    func registerReusableCell<Cell: UITableViewCell>(_ type: Cell.Type, strategy: ReusableStrategy = .Nib) {
        switch strategy {
        case .Class: register(type, forCellReuseIdentifier: identifier(type))
        case .Nib: register(nib(of: type), forCellReuseIdentifier: identifier(type))
        }
    }

    func reusableCell<Cell: UITableViewCell>(for indexPath: IndexPath) -> Cell {
        guard let cell: Cell = reusableCell(identifier: identifier(Cell.self), for: indexPath) else {
            fatalError("💥 Congrats, you have done something deeply wrong 🤓")
        }
        return cell
    }

    func reusableCell<Cell: UITableViewCell>(identifier: String, for indexPath: IndexPath) -> Cell? {
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? Cell
    }
}
