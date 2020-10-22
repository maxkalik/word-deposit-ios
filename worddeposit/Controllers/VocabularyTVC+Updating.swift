import UIKit

extension VocabularyTVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString = searchController.searchBar.text!.trimmingCharacters(in: whitespaceCharacterSet).lowercased()
        
        let searchResults = words.filter { (word) -> Bool in
            word.example.lowercased().range(of: strippedString) != nil ||
            word.translation.lowercased().range(of: strippedString) != nil
        }
        
        if let resultsController = searchController.searchResultsController as? VocabularyResultsTVC {
            resultsController.filteredWords = searchResults
            resultsController.tableView.reloadData()
            
            resultsController.resultsLabel.text = resultsController.filteredWords.isEmpty ? "No found" : "Items found: \(resultsController.filteredWords.count)"
        }        
    }
}
