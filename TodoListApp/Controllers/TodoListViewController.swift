//
//  ViewController.swift
//  TodoListApp
//
//  Created by José Villanueva Rojas on 12/24/18.
//  Copyright © 2018 PedroWC. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    var itemArray = [Item]()
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    //let defaults = UserDefaults.standard
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //print(dataFilePath)
        
       // let newItem = Item()
       // newItem.title = "Find Mike"
       // itemArray.append(newItem)

       // let newItem2 = Item()
       // newItem2.title = "Buy Eggs"
       // itemArray.append(newItem2)
        
       // let newItem3 = Item()
       // newItem3.title = "Destroy Demogorgon"
       // itemArray.append(newItem3)
        
    //    if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
    //       itemArray = items
    //    }
        
        //loadItems()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title

        cell.accessoryType = item.done ? .checkmark : .none
        
    //    if itemArray[indexPath.row].done == true {
    //        cell.accessoryType = .checkmark
    //    }else{
    //        cell.accessoryType = .none
    //    }
        
        return cell
    }
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 //       print(indexPath.row)
 //       print(itemArray[indexPath.row])
        
//        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        //itemArray[indexPath.row].done
        
        //context.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row)
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        
 //       if itemArray[indexPath.row].done == false {
 //          itemArray[indexPath.row].done = true
 //       }else{
 //          itemArray[indexPath.row].done = false
 //       }
        
        //tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
//        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark{
//           tableView.cellForRow(at: indexPath)?.accessoryType = .none
//        }else{
//           tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//        }
        

    }
    
    
   //MARK - New Items
    
    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title:"Add Item", style: .default) { (action) in
            //what will happen once the user clicks the Add item button on our UIalert
            //print(textField.text)
            
            //let newItem = Item()
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done  = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            
            //self.defaults.set(self.itemArray, forKey: "TodoListArray")
            self.saveItems()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField

         //   print(alertTextField.text)
         //   print("Now")
        }
        
        alert.addAction(action)
        present(alert,animated: true, completion: nil)
    }

    //MARK - Model Manipulation Methods
    func saveItems(){
        //let encoder = PropertyListEncoder()
        
        //do {
           // let data = try encoder.encode(itemArray)
           // try data.write(to: dataFilePath!)
          
        //}catch {
            //print("Error encoding item array , \(error)")
       // }

        do{
            try context.save()
        }catch{
         print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){
  //      if let data = try? Data(contentsOf: dataFilePath!){,
  //         let decoder = PropertyListDecoder()
  //          do{
  //          itemArray = try decoder.decode([Item].self, from: data)
  //          } catch{
  //              print("Error decoding item array, \(error)")
  //          }
  //      }

//        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)

        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
        }else{
            request.predicate = categoryPredicate
        }
        
//        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate])
//
//        request.predicate = compoundPredicate
        
        do {
            itemArray = try context.fetch(request)
        }catch{
          print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
}

//MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate  = NSPredicate(format: "title CONTAINS %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        loadItems(with: request, predicate: predicate)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}




