//
//  DetailViewController.swift
//  Extension
//
//  Created by Евгения Зорич on 07.03.2023.
//

import UIKit


protocol LoaderDelegate {
    func loader(_ loader: DetailViewController, didSelect script: String)
}
    
    class DetailViewController: UITableViewController {
        
        var savedCode: [UserCode]!
        var nameCode: String!
        
        var delegate: LoaderDelegate?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            guard savedCode != nil && nameCode != nil else {
                print("Parameters do not exist")
                navigationController?.popViewController(animated: true)
                return
            }
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return savedCode.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Code", for: indexPath)
            cell.textLabel?.text = savedCode[indexPath.row].name
            return cell
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            delegate?.loader(self, didSelect: savedCode[indexPath.row].code)
            navigationController?.popViewController(animated: true)
        }
    }
    
