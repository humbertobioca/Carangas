//
//  AddEditViewController.swift
//  Carangas
//
//  Created by Eric Brito.
//  Copyright © 2017 Eric Brito. All rights reserved.
//

import UIKit

class AddEditViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tfBrand: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var scGasType: UISegmentedControl!
    @IBOutlet weak var btAddEdit: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var car : Car!
    var brands: [Brand] = []
    
    lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .white
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if car != nil {
            
            tfBrand.text = car.brand
            tfName.text = car.name
            tfPrice.text = "\(car.price)"
            scGasType.selectedSegmentIndex = car.gasType
            btAddEdit.setTitle("Alterar carro", for: .normal)
        }
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        toolbar.tintColor = UIColor(named: "main")
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [btCancel, btSpace, btDone]
        
        tfBrand.inputAccessoryView = toolbar
        tfBrand.inputView = pickerView
        loadBrands()
        
    }
    @objc func cancel() {
        tfBrand.resignFirstResponder()
    }
    
    @objc func done() {
        tfBrand.text = brands[pickerView.selectedRow(inComponent: 0)].fipe_name
        cancel()
    }
    
    
    func startLoadingAnimation() {
        self.btAddEdit.isEnabled = false
        self.btAddEdit.backgroundColor = .gray
        self.btAddEdit.alpha = 0.5
        self.loading.startAnimating()
    }
    
    func stopLoadingAnimation() {
        self.btAddEdit.isEnabled = true
        self.btAddEdit.backgroundColor = UIColor(named: "main")
        self.btAddEdit.alpha = 0
        self.loading.stopAnimating()
    }
    enum CarOperationAction {
        case add_car
        case edit_car
        case get_brands
    }
    
    func showAlert(withTitle titleMessage: String, withMessage message: String, isTryAgain hasRetry: Bool, operation oper: CarOperationAction) {
        
        if oper != .get_brands {
            DispatchQueue.main.async {
                // ?
                self.startLoadingAnimation()
            }
            
        }
        
        let alert = UIAlertController(title: titleMessage, message: message, preferredStyle: .actionSheet)
        
        if hasRetry {
            let tryAgainAction = UIAlertAction(title: "Tentar novamente", style: .default, handler: {(action: UIAlertAction) in
                
                switch oper {
                case .add_car:
                    self.addCar()
                    
                case .edit_car:
                break
                    
                case .get_brands:
                break
                }
                
            })
            alert.addAction(tryAgainAction)
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: {(action: UIAlertAction) in
                self.goBack()
            })
            alert.addAction(cancelAction)
        }
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func loadBrands() {
        
        REST.loadBrands { (brands) in
            guard let brands = brands else {return}
            
            self.showAlert(withTitle: "Ops.!", withMessage: "Não foi possivel carregar!", isTryAgain: true, operation: .get_brands)
            
            // ascending order
            self.brands = brands.sorted(by: {$0.fipe_name < $1.fipe_name})
            
            DispatchQueue.main.async {
                
                self.pickerView.reloadAllComponents()
                
            }
            
        }
    }
    
    // MARK: - IBActions
    @IBAction func addEdit(_ sender: UIButton) {
    
        
        if car == nil {
            // adicionar carro novo
            car = Car()
        }
        
        car.name = (tfName?.text)!
        car.brand = (tfBrand?.text)!
        if tfPrice.text!.isEmpty {
            tfPrice.text = "0"
        }
        car.price = Double(tfPrice.text!)!
        car.gasType = scGasType.selectedSegmentIndex
        
        if car._id == nil {
            // new car
            REST.save(car: car) { (success) in
                self.goBack()
            }
        } else {
            REST.update(car: car) { (success) in
                self.goBack()
            }
            
        }

        
        REST.save(car: car) { (success) in
            self.goBack()
        }
    }
    func goBack() {
        
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    fileprivate func addCar()
    {
        REST.save(car: car) {(success) in
            
            if success {
                self.goBack()
                
            }else{
                self.showAlert(withTitle: "Ops. :(", withMessage: "Não foi possível adicionar.", isTryAgain: true, operation: .add_car)
            }
        }
    }
    fileprivate func editCar(){
        
        REST.update(car: car) {(success) in
            
            if success {
                self.goBack()
                
            }else{
                self.showAlert(withTitle: "Ops. :(", withMessage: "Não foi possível editar.", isTryAgain: true, operation: .edit_car)
            }
        }
    }
    fileprivate func deleteCar(){
        REST.loadBrands(onComplete: <#T##([Brand]?) -> Void#>)(car: car) {(success) in
            
            if success {
                self.goBack()
                
            }else{
                self.showAlert(withTitle: "Ops. :(", withMessage: "Não foi possível deletar.", isTryAgain: true, operation: )
            }
        }
    }
    }

extension AddEditViewController:UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let brand = brands[row]
        return brand.fipe_name
    }
    
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return brands.count
    }
}
