//
//  MainViewController.swift
//  MyFootball
//
//  Created by Raphaël Merrot on 26/05/2022.
//

import UIKit


/** Controller of Main view */
final class MainViewController: UIViewController {

    /// Identifiers
    private enum Identifier: String {
        case leagueCell
    }

    /// Search leagues bar
    @IBOutlet private weak var searchBar: UISearchBar!

    /// Leagues table view
    @IBOutlet private weak var leaguesTableView: UITableView!

    /// No data label
    @IBOutlet weak var noDataLabel: UILabel!

    /// Presenter
    private lazy var presenter = MainPresenter(view: self)


    /** View did load */
    override func viewDidLoad() {
        super.viewDidLoad()

        // Main view configuration
        self.mainViewConfiguration()

        // Execute presenter view did load
        self.presenter.viewDidLoad()
    }
}


// MARK: User Interface

extension MainViewController {

    /** Configure the view */
    private func mainViewConfiguration() {
        // Configure navigation title
        self.title = self.presenter.titleView

        // Configure table view
        self.leaguesTableView.delegate = self
        self.leaguesTableView.dataSource = self

        // Configure search bar
        self.searchBar.delegate = self
        self.searchBar.placeholder = self.presenter.searchBarPlaceholder
    }


    /** Update user interface */
    private func updateUI(isLabelVisible: Bool = false, isTableViewVisible: Bool = false) {
        DispatchQueue.main.async {
            self.updateLabel(isLabelVisible)
            self.updateTableView(isTableViewVisible)
        }
    }


    /** Update no data label */
    private func updateLabel(_ isVisible: Bool) {
        self.noDataLabel.isHidden = !isVisible
        self.noDataLabel.text = self.presenter.textLabel
    }


    /** Update leagues table view */
    private func updateTableView(_ isVisible: Bool) {
        self.leaguesTableView.isHidden = !isVisible
        self.leaguesTableView.reloadData()
    }
}



// MARK: UISearchBarDelegate

extension MainViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.presenter.search(searchText: searchText)
    }
}



// MARK: UITableViewDataSource

extension MainViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.numberOfRows
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.leaguesTableView.dequeueReusableCell(withIdentifier: Identifier.leagueCell.rawValue, for: indexPath)
        cell.textLabel?.text = self.presenter.leagueName(for: indexPath.row)
        return cell
    }
}



// MARK: UITableViewDelegate

extension MainViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let text = self.presenter.searchBarText(for: indexPath.row)
        self.searchBar.text = text
        self.searchBar(self.searchBar, textDidChange: text)
    }
}



// MARK: Presenter Delegate

extension MainViewController: MainPresenterView {

    func onViewDidLoad() {
        self.updateUI()
    }


    func onSearch(_ isLabelVisible: Bool, _ isTableViewVisible: Bool) {
        self.updateUI(isLabelVisible: isLabelVisible, isTableViewVisible: isTableViewVisible)
    }


    func onError(_ error: Error, title: String, actionTitle: String) {
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default)
        alert.addAction(action)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}

