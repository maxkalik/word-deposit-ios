import UIKit
import FirebaseFirestore

class VocabulariesTVC: UITableViewController {

    var vocabularies = [Vocabulary]()
    var selectedVocabularyIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        vocabularies = [Vocabulary(id: "0001", title: "Atkal majas Latvija!", language: "Latvian", words: [], timestamp: Timestamp()), Vocabulary(id: "0002", title: "Atkal majas Latvija2!", language: "Latvian", words: [], timestamp: Timestamp())]
        
        setupTableView()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }
    
    func setupTableView() {
        let nib = UINib(nibName: XIBs.VocabulariesTVCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: XIBs.VocabulariesTVCell)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return vocabularies.count
    }

    @objc func switchChaged(sender: UISwitch) {
        if sender.tag != selectedVocabularyIndex {
            selectedVocabularyIndex = sender.tag
            tableView.reloadData()
        } else {
            sender.isOn = true
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: XIBs.VocabulariesTVCell, for: indexPath) as? VocabulariesTVCell {
            let vocabulary = vocabularies[indexPath.row]
            cell.configureCell(title: vocabulary.title, language: vocabulary.language, amount: vocabulary.words.count)
            
            if indexPath.row == selectedVocabularyIndex {
                cell.isSelectedVocabulary = true
            }
            
            cell.selectionSwitch.tag = indexPath.row
            cell.selectionSwitch.addTarget(self, action: #selector(switchChaged(sender:)), for: .valueChanged)
            
            return cell
        }
        return UITableViewCell()
    }


    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }


    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print(indexPath.row)
            // Delete the row from the data source
            vocabularies.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }


    // MARK: - Navigation

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Segues.VocabularyDetails, sender: indexPath.row)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vocabularyDetailsVC = segue.destination as? VocabularyDetailsVC {
            if let index = sender as? Int {
                vocabularyDetailsVC.vocabularyTitle = vocabularies[index].title
                vocabularyDetailsVC.vocabularyLanguage = vocabularies[index].language
            }
        }
    }
}
