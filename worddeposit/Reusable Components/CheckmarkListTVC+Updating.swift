import UIKit

extension CheckmarkListTVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let keyword = searchController.searchBar.text!.trimmingCharacters(in: .whitespaces).lowercased()
        
        let searchResults = data.filter {
            $0.lowercased().range(of: keyword) != nil
        }.sortBy(keyword: keyword)
        
        if let resultsController = searchController.searchResultsController as? CheckmarkListTVCResults {
            resultsController.filteredData = searchResults
            resultsController.tableView.reloadData()
        }
    }
}

