import UIKit

protocol CheckmarkListTVCDelegate: AnyObject {
    func getCheckmared(index: Int)
}

class CheckmarkListTVC: SearchableTVC {

    var data: [String]!
    var selected: Int? {
        didSet {
            tableView.reloadData()
        }
    }
    weak var delegate: CheckmarkListTVCDelegate?
    
    /// Search results table view
    private var resultsTableController: CheckmarkListTVCResults!
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupResultsTableController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let selected = self.selected else { return }
        tableView.scrollToRow(at: IndexPath(item: selected, section: 0), at: .middle, animated: false)
        tableView.backgroundColor = Colors.silver
    }

    // MARK: - Local methods
    
    func setupResultsTableController() {
        resultsTableController = storyboard?.instantiateViewController(withIdentifier: Storyboards.CheckmarkListTVCResults) as? CheckmarkListTVCResults
 
        resultsTableController.tableView.delegate = self
        if selected != nil {
            guard let index = selected else { return }
            resultsTableController.selected = data[index]
        }
        
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self // Monitor when the search button is tapped
        
        // Place the search bar in the nav bar
        navigationItem.searchController = searchController

        // Make the search bar always visible
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifiers.CheckedCell, for: indexPath) as? CheckmarkListTVCell {
            cell.configure(title: data[indexPath.row], isMarked: indexPath.row == selected)
            return cell
        }

        return UITableViewCell()
    }
    
    private func selectCell(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: IndexPath(row: selected ?? indexPath.row, section: 0))?.accessoryType = .none
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        selected = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.getCheckmared(index: indexPath.row)
        navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive {
            let selectedString = resultsTableController.filteredData[indexPath.row]
            guard let index = data.firstIndex(of: selectedString) else { return }
            let indexPath = IndexPath(row: index, section: 0)
            selectCell(tableView, didSelectRowAt: indexPath)
        } else {
            selectCell(tableView, didSelectRowAt: indexPath)
        }
    }
    
    // MARK: - Outlets
    
    @IBAction func addBarButtonTapped(_ sender: UIBarButtonItem) {
        delegate?.getCheckmared(index: data.count - 1)
        navigationController?.popViewController(animated: true)
    }
    
}

extension CheckmarkListTVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResults(for: searchController)
    }
}
