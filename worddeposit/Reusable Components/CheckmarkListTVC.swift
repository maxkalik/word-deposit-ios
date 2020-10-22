import UIKit

protocol CheckmarkListTVCDelegate: AnyObject {
    func getCheckmared(index: Int)
}

class CheckmarkListTVC: UITableViewController {

    var data: [String]!
    var selected: Int? {
        didSet {
            tableView.reloadData()
        }
    }
    weak var delegate: CheckmarkListTVCDelegate?
    
    /// Search controller to help us with filtering items in the table view
    var searchController: UISearchController!
    
    /// Search results table view
    private var resultsTableController: CheckmarkListTVCResults!
    
    /// Restoration state for UISearchController
    var restoredState = SearchControllerRestorableState()
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Restore the searchController's active state.
        if restoredState.wasActive {
            searchController.isActive = restoredState.wasActive
            restoredState.wasActive = false
            
            if restoredState.wasFirstResponder {
                searchController.searchBar.becomeFirstResponder()
                restoredState.wasFirstResponder = false
            }
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifiers.CheckedCell, for: indexPath)
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.font = UIFont(name: Fonts.regular, size: 16)
        cell.textLabel?.text = data[indexPath.row]
        if indexPath.row == selected {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        return tableView.sectionHeaderHeight
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
