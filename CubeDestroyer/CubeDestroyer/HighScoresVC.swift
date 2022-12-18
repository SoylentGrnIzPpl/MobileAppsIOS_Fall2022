//
//  HighScoresVC.swift
//  CubeDestroyer
//
//  Created by Patrick Rode on 12/16/22.
//

import UIKit

class HighScoresVC: UITableViewController {
    
    private let numberOfRows = 10
    private let numberOfSections = 1
    var index:Int = 0
    var hsScoreArray:[Int]?
    var hsNameArray:[String]?

    override func viewDidLoad() {
        //print(self.navigationController?.viewControllers.count)
        super.viewDidLoad()
        hsScoreArray = UserDefaults.standard.array(forKey: "hsScoreArray") as? [Int] ?? Array(repeating: Int(0), count:10)
        hsNameArray = UserDefaults.standard.array(forKey: "hsNameArray") as? [String] ?? Array(repeating: String("None"), count:10)
        index = 0
        
        //tableView(tableView, cellForRowAt: IndexPath(row:1,section:1)).textLabel?.text = "test"
        // Do any additional setup after loading the view.
        //tableView.cellForRow(at: IndexPath(row:0,section: 0))?.textLabel?.largeContentTitle = "test"
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    @IBAction func swipeRightAction(_ sender: UISwipeGestureRecognizer){
        if sender.state == .ended{
            if let navController = self.navigationController{
                navController.popViewController(animated: true)
            }
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HighScoresVC{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //cell.textLabel?.text = "foo"
        cell.textLabel?.text = hsNameArray![index]
        cell.detailTextLabel?.text = String(hsScoreArray![index])
        index += 1
//        print(indexPath.row)
//        print(indexPath.section)
//        print("test")
        //tableView.headerView(forSection: 0)?.textLabel?.text = "High Scores"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame:CGRect.init(x:0, y:0, width: tableView.frame.width, height: 50))
        let label = UILabel()
        label.frame = CGRect.init(x:5,y:5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = "High Scores"
        label.textAlignment = .center
        //label.style = .bold
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .black
        
        headerView.addSubview(label)
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 50
    }
    
}
