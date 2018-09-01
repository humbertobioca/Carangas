//
//  CarsTableViewController.swift
//  Carangas
//
//  Created by Eric Brito on 21/10/17.
//  Copyright © 2017 Eric Brito. All rights reserved.
//

import UIKit

class CarsTableViewController: UITableViewController {
    var cars : [Car] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "Caregando Dados"
        
    }
    var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(named: "main")
        return label
    }()
    
    fileprivate func loadCars(){
        
        
        REST.loadCars(onComplete: { (cars) in
            
            self.cars = cars
            
            DispatchQueue.main.async {
                self.label.text = "Não existem carros cadastrados."
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
            
            
        }) { (error) in
            
            var response: String = ""
            
            switch error {
            case .invalidJSON:
                response = "JSON inválido"
            case .noData:
                response = "JSON inválido"
            case .noResponse:
                response = "JSON inválido"
            case .url:
                response = "JSON inválido"
            case .taskError(let error):
                response = "\(error.localizedDescription)"
            case .responseStatusCode(let code):
                if code != 200 {
                    response = "Algum problema com o servidor. :( \nError:\(code)"
                }
            }
            
            DispatchQueue.main.async {
                self.label.text = response
                self.tableView.backgroundView = self.label
                print(response)
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if cars.count == 0 {
            //mostrar mensagem padrao
            label.text = "Sem Dados"
        tableView.backgroundView = label
        }
        return cars.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // Configure the cell...
        let car = cars[indexPath.row]
        cell.textLabel?.text = car.name
        cell.detailTextLabel?.text = car.brand
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // Delete the row from the data source
        
            let car = cars[indexPath.row]
            REST.delete(car: car) { (success) in
                if success {
                    
                    // ATENCAO nao esquecer disso
                    self.cars.remove(at: indexPath.row)
                    
                    DispatchQueue.main.async {
                        // Delete the row from the data source
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
       // if let destinationViewController = segue.destinationViewController as? CarViewController {
       //     destinationViewController.data = "foo"
       // }
        // Pass the selected object to the new view controller.
        if segue.identifier == "viewSegue"{
            let vc = segue.destination as! CarViewController
            vc.car = cars[tableView.indexPathForSelectedRow!.row]
        }
    }
    

}
