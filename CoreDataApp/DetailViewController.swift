//
//  DetailViewController.swift
//  CoreDataApp
//
//  Created by Ahmet GÜVENDİK on 3.03.2023.
//

import UIKit
import CoreData

class DetailViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var productSize: UITextField!
    @IBOutlet weak var productStock: UITextField!
    @IBOutlet weak var saveButtonOutlet: UIButton!
    var selectedName = ""
    var selectedId : UUID?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBAction func saveButton(_ sender: Any) {
        let context = appDelegate.persistentContainer.viewContext
        let shopping = NSEntityDescription.insertNewObject(forEntityName: "Shopping", into: context)
        shopping.setValue(productName.text, forKey: "name")
        shopping.setValue(productSize.text, forKey: "size")
        if let stock = Int(productStock.text!){
            shopping.setValue(stock, forKey: "stock")
        }
        
        shopping.setValue(UUID(), forKey: "id")
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        shopping.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("Kaydedildi")
        } catch {
            print("ERROR")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "saveData"), object: nil) //Diger tarafa bildirim yollamak icin
        self.navigationController?.popViewController(animated: true) //Geri donmek icin
    }
    
    func getData (){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping") //Entity tanimlamasi
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "id=%@", selectedId!.uuidString) //Filtreleme islemleri icin
        
        do{
            let datas = try context.fetch(fetchRequest)
            
            if datas.count > 0 {
                for data in datas as! [NSManagedObject]{
                    if let name = data.value(forKey: "name") as? String{
                        productName.text = name
                    }
                    
                    if let stock = data.value(forKey: "stock") as? Int{
                        productStock.text = String(stock)
                    }
                    
                    if let size = data.value(forKey: "size") as? String{
                        productSize.text = size
                    }
                }
            }
            
        } catch {
            print("HATA")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if selectedName != ""{
            //Cekilen veriler icin
                getData()
            saveButtonOutlet.isEnabled = false
        }
        else {
            saveButtonOutlet.isEnabled = false
            saveButtonOutlet.isHidden = false
            productName.text = ""
            productSize.text = ""
            productStock.text = ""
        }
        
        let gestureImage = UITapGestureRecognizer(target: self, action: #selector(changeImage))
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(gestureImage)
        
        let closeKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        
        view.addGestureRecognizer(closeKeyboardGesture)
    
        
    }
    
    @objc func changeImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        saveButtonOutlet.isEnabled = true
        self.dismiss(animated: true)
    }

    @objc func closeKeyboard(){
        view.endEditing(true)
    }
   

}
