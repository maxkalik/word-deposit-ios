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
    
    var filteredData = [String]()
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.definesPresentationContext = true
        searchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let selected = self.selected else { return }
        tableView.scrollToRow(at: IndexPath(item: selected, section: 0), at: .middle, animated: false)
        tableView.backgroundColor = Colors.silver
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredData.count
        }
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifiers.CheckedCell, for: indexPath)
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.font = UIFont(name: Fonts.regular, size: 16)
        
        if searchController.isActive && searchController.searchBar.text != "" {
            cell.textLabel?.text = filteredData[indexPath.row]
            if indexPath.row == selected {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        } else {
            cell.textLabel?.text = data[indexPath.row]
            if indexPath.row == selected {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: IndexPath(row: selected ?? indexPath.row, section: 0))?.accessoryType = .none
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        self.selected = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.getCheckmared(index: indexPath.row)
        navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        return tableView.sectionHeaderHeight
    }
}

extension CheckmarkListTVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredData = data.filter { it in
            return it.lowercased().contains(searchController.searchBar.text ?? "")
        }
        tableView.reloadData()
    }
}
