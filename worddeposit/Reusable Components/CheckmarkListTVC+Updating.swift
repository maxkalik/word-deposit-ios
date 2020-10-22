import UIKit

extension CheckmarkListTVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString = searchController.searchBar.text!.trimmingCharacters(in: whitespaceCharacterSet).lowercased()
        
        let searchResults = data.filter { str -> Bool in
            str.lowercased().range(of: strippedString) != nil
        }
        
        if let resultsController = searchController.searchResultsController as? CheckmarkListTVCResults {
            resultsController.filteredData = searchResults
            resultsController.tableView.reloadData()
        }
    }
}
