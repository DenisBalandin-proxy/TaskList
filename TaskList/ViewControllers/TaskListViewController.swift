//
//  TaskListViewController.swift
//  TaskList
//
//  Created by Alexey Efimov on 17.11.2022.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private let viewContext = StoreManager.shared.persistentContainer.viewContext
    
    private let cellID = "task"
    private var taskList: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        fetchData()
    }
    
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor(named: "MilkBlue")
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert(
            withTitle: "New Task",
            andMessage: "What do you want to do?",
            andCellText: nil,
            andCellIndex: nil
        )
    }
    
    private func fetchData() {
        let fetchRequest = Task.fetchRequest()
        
        do {
            taskList = try viewContext.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func showAlert(withTitle title: String, andMessage message: String, andCellText text: String?, andCellIndex: Int?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            save(task, andCellIndex)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            
            if text == nil {
                textField.placeholder = "New task"
            } else {
                textField.text = text
                self.tableView.reloadData()
            }
        }
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String, _ CellIndex: Int?) {
        
        if CellIndex == nil {
            let task = Task(context: viewContext)
            task.title = taskName
            taskList.append(task)
            let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
            tableView.insertRows(at: [cellIndex], with: .automatic)
        } else {
            let editingTask = taskList[CellIndex ?? 0]
            editingTask.title = taskName
            tableView.reloadData()
        }
        
        StoreManager.shared.saveContext()
    }
}

// MARK: - UITableView Data Source
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let task = taskList[indexPath.row]
        showAlert(
            withTitle: "Editing Mode!",
            andMessage: "Make some changes.",
            andCellText: task.title,
            andCellIndex: indexPath.row
        )
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let row = indexPath.row
        
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete") { [unowned self] (_,_,_)  in
                let delitingTask = taskList[row]
                
                taskList.remove(at: row)
                viewContext.delete(delitingTask)
                
                StoreManager.shared.saveContext()
                tableView.deleteRows(at: [indexPath], with: .left)
            }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
