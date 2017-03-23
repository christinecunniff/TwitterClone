import UIKit

class UsersVC: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var users = [AnyObject]()

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.barTintColor = .white
        searchBar.tintColor = brandBlueColor
        searchBar.showsCancelButton = false
    }
    
    // MARK: SearchBar methods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // search php request
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(false)
        searchBar.showsCancelButton = false
        searchBar.text = ""
    }
    
    
    // MARK: TableView methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UsersCell
        
        return cell
    }



}
