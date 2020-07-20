import UIKit

protocol ProfileTVCCheckmarkDelegate: ProfileTVC {
    func getCheckmared(checkmarked: Int)
}

class ProfileTVCCheckmark: UITableViewController {

    var data: [String]!
    var selected: Int!
    weak var delegate: ProfileTVCCheckmarkDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.scrollToRow(at: IndexPath(item: selected, section: 0), at: .middle, animated: false)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifiers.CheckedCell, for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        if indexPath.row == selected {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selected != nil {
            tableView.cellForRow(at: IndexPath(row: selected, section: 0))?.accessoryType = .none
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            selected = indexPath.row
            tableView.deselectRow(at: indexPath, animated: true)
            delegate?.getCheckmared(checkmarked: indexPath.row)
        }
    }
    
    
}
