import UIKit

extension VocabularyTVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let keyword = searchController.searchBar.text!.trimmingCharacters(in: whitespaceCharacterSet).lowercased()
        
        let searchResults = words.filter { (word) -> Bool in
            word.example.lowercased().range(of: keyword) != nil ||
            word.translation.lowercased().range(of: keyword) != nil
        }
        
        if let resultsController = searchController.searchResultsController as? VocabularyResultsTVC {
            resultsController.filteredWords = searchResults
            resultsController.tableView.reloadData()
            
            resultsController.resultsLabel.text = resultsController.filteredWords.isEmpty ? "No found" : "Items found: \(resultsController.filteredWords.count)"
        }        
    }
}
