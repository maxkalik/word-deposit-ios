import UIKit

extension VocabularyTVC: UISearchResultsUpdating {
    
    private func normalizeString(str: String) -> String {
        let pattern = "[^A-Za-z0-9]+"
        let result = str.replacingOccurrences(of: pattern, with: "", options: [.regularExpression])
        return result
    }
    
   
    func updateSearchResults(for searchController: UISearchController) {
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString = searchController.searchBar.text!.trimmingCharacters(in: whitespaceCharacterSet)
        
        let preparedString = normalizeString(str: strippedString)
        
        let searchResults = words.filter { (word) -> Bool in
            word.example.range(of: preparedString) != nil ||
            word.translation.range(of: preparedString) != nil
        }
        
        if let resultsController = searchController.searchResultsController as? VocabularyResultsTVC {
            resultsController.filteredWords = searchResults
            resultsController.tableView.reloadData()
            
            resultsController.resultsLabel.text = resultsController.filteredWords.isEmpty ? "No found" : "Items found: \(resultsController.filteredWords.count)"
        }
        
    }
}
