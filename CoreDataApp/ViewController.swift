//
//  ViewController.swift
//  CoreDataApp
//
//  Created by Ahmet GÜVENDİK on 2.03.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var selectedName = ""
    var selectedId : UUID?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableview = UITableViewCell()
        tableview.textLabel?.text = nameArray[indexPath.row]
        return tableview
    }
    
    var nameArray = [String]()
    var idArray = [UUID]()
    
    @IBAction func toSavePageButton(_ sender: Any) {
        selectedName = ""

        performSegue(withIdentifier: "toSavePage", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSavePage" {
        let detailVC = segue.destination as! DetailViewController
            detailVC.selectedName = selectedName
            detailVC.selectedId = selectedId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedName = nameArray[indexPath.row]
        selectedId =   idArray[indexPath.row]
        performSegue(withIdentifier: "toSavePage", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "saveData"), object: nil) //Diger taraftan gelen durumu yakalamak icin. Selector ile cektigimiz veri ile ne yapacagimizi yazdiririz.
    }

    @objc func getData(){
        
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false) //islemi baslarken her seyi silmek icin
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
        fetchRequest.returnsObjectsAsFaults = false //Buyuk veriler icin 
        
        do{
            let data = try context.fetch(fetchRequest)
            for datas in data as! [NSManagedObject]{
                if let name = datas.value(forKey: "name") as? String {
                    nameArray.append(name)
                }
                
                if let id = datas.value(forKey: "id") as? UUID{
                    idArray.append(id)
                }
              
                tableView.reloadData()
            }
        } catch {
            print("Hata")
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
            let stringUuid = idArray[indexPath.row].uuidString
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.predicate = NSPredicate(format: "id = %@", stringUuid)
            
            do{
                let datas = try context.fetch(fetchRequest)
                if datas.count > 0 {
                    for data in datas as! [NSManagedObject] {
                        if let id = data.value(forKey: "id") as? UUID {
                            if id == idArray[indexPath.row]{
                                context.delete(data)
                                idArray.remove(at: indexPath.row)
                                nameArray.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                
                                do{
                                   try context.save()
                                }catch{
                                    print("Hata")
                                }
                                
                                
                            }
                        }
                    }
                }
            }catch{
                print("Error")
            }
        }
    }

}

