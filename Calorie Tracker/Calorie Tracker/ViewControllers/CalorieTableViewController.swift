//
//  CalorieTableViewController.swift
//  Calorie Tracker
//
//  Created by Jonathan T. Miles on 9/21/18.
//  Copyright © 2018 Jonathan T. Miles. All rights reserved.
//

import UIKit
import SwiftChart

extension NSNotification.Name {
    static let newCalorieInput = NSNotification.Name("NewCalorieInput")
}

class CalorieTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(newCalorieInput(_:)), name: .newCalorieInput, object: nil)
        
        configureChart()
    }
    
    // MARK: - Chart
    
    @IBOutlet weak var calorieChart: Chart!
    
    func configureChart() {
        let chart = calorieChart!
        chart.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: 300.0, height: 200.0))
        chart.showXLabelsAndGrid = true
        chart.showYLabelsAndGrid = true
        var calorieCounts = calorieController.calorieCounts
        var data: [Double] = []
        while !calorieCounts.isEmpty {
            guard let last = calorieCounts.popLast() else { continue }
            data.insert(last.calories, at: 0)
        }
        let series = ChartSeries(data)
        series.color = ChartColors.cyanColor()
        series.area = true
        chart.add(series)
    }
    
    // MARK: - Notifications
    
    @objc func newCalorieInput(_ notification: Notification) {
        tableView.reloadData()
        configureChart()
    }

    // MARK: - Table view data source

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calorieController.calorieCounts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalorieCell", for: indexPath)
        let calorieCount = calorieController.calorieCounts[indexPath.row]
        guard let date = calorieCount.date else { return cell }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy 'at' hh:mm:ss a"
        
        cell.textLabel?.text = "Calories: \(calorieCount.calories)"
        cell.detailTextLabel?.text = "\(dateFormatter.string(from: date))"
        return cell
    }
    
    // MARK: - Buttons

    @IBAction func addCalorieCount(_ sender: Any) {
        configureAlert()
    }
    
    func configureAlert() {
        let alert = UIAlertController(title: "Add Calorie Input", message: "Add the amount of calories in the field", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField { (textField) in
            textField.placeholder = "Calories:"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let caloriesString = alert.textFields?.first?.text {
                guard let calories = Double(caloriesString) else { return }
                self.calorieController.createCalorieCount(with: calories)
            }
//            self.tableView.reloadData()
//            self.configureChart()
            let nc = NotificationCenter.default
            nc.post(name: .newCalorieInput, object: self)
        }))
        self.present(alert, animated: true)
    }
    
    // MARK: - Properties
    
    let calorieController = CalorieController()

}
