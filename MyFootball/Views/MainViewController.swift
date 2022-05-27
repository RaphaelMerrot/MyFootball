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
        case leagueCellId
        case teamCellId
        case detailsSegueId
    }

    /// Search leagues bar
    @IBOutlet private weak var searchBar: UISearchBar!

    /// Leagues table view
    @IBOutlet private weak var leaguesTableView: UITableView!

    /// No data label
    @IBOutlet private weak var noDataLabel: UILabel!

    /// Teams collection view
    @IBOutlet private weak var teamsCollectionView: UICollectionView!

    /// Refresh control
    private lazy var refreshControl = UIRefreshControl()

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
        self.leaguesTableView.keyboardDismissMode = .onDrag
        self.leaguesTableView.addSubview(self.refreshControl)
        self.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

        // Configure collection view
        self.teamsCollectionView.delegate = self
        self.teamsCollectionView.dataSource = self
        self.teamsCollectionView.keyboardDismissMode = .onDrag

        // Configure search bar
        self.searchBar.delegate = self
        self.searchBar.placeholder = self.presenter.searchBarPlaceholder

        // Keyboard
        self.hideKeyboardWhenUnfocused()
    }


    /** Update user interface */
    private func updateUI(
        isLabelVisible: Bool = false,
        isTableViewVisible: Bool = false,
        isCollectionViewVisible: Bool = false
    ) {
        DispatchQueue.main.async {
            self.updateLabel(isLabelVisible)
            self.updateTableView(isTableViewVisible)
            self.updateCollectionView(isCollectionViewVisible)
        }
    }


    /** Update no data label */
    private func updateLabel(_ isVisible: Bool) {
        self.noDataLabel.isHidden = !isVisible
        self.noDataLabel.text = self.presenter.textLabel
    }


    /** Update leagues table view */
    private func updateTableView(_ isVisible: Bool) {
        self.refreshControl.endRefreshing()
        self.leaguesTableView.reloadData()
        self.leaguesTableView.isHidden = !isVisible
    }


    /** Update teams collection view */
    private func updateCollectionView(_ isVisible: Bool) {
        self.teamsCollectionView.isHidden = !isVisible
        self.teamsCollectionView.reloadData()
    }


    @objc private func refresh() {
        self.searchBar.text = nil
        self.presenter.refresh()
    }
}



// MARK: UISearchBarDelegate

extension MainViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.presenter.search(searchText: searchText)
    }


    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.onDismissKeyboard()
    }
}



// MARK: UITableViewDataSource

extension MainViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.numberOfRows
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.leaguesTableView.dequeueReusableCell(withIdentifier: Identifier.leagueCellId.rawValue, for: indexPath)
        cell.textLabel?.text = self.presenter.leagueName(for: indexPath.row)
        return cell
    }
}



// MARK: UITableViewDelegate

extension MainViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let text = self.presenter.searchBarText(for: indexPath.row)
        self.searchBar.text = text
        self.presenter.didSelectRow(at: indexPath.row)
    }
}



// MARK: UICollectionViewDelegate

extension MainViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.presenter.numberOfItems
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.teamsCollectionView.dequeueReusableCell(
            withReuseIdentifier: Identifier.teamCellId.rawValue,
            for: indexPath
        ) as? TeamCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.presenter = TeamCellPresenter(view: cell, team: self.presenter.teamData(for: indexPath.row))
        return cell
    }
}



// MARK: UICollectionViewDelegate

extension MainViewController: UICollectionViewDelegate {

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard identifier == Identifier.detailsSegueId.rawValue else { return true }
        guard let cell = sender as? TeamCollectionViewCell else { return false }
        let index = self.teamsCollectionView.indexPath(for: cell)?.row
        return self.presenter.shouldPerformSegue(for: index)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Identifier.detailsSegueId.rawValue else { return }
        guard let controller = segue.destination as? TeamDetailsViewController else { return }
        guard let cell = sender as? TeamCollectionViewCell else { return }
        let team = self.presenter.teamData(for: self.teamsCollectionView.indexPath(for: cell)?.row)
        controller.presenter = TeamDetailsPresenter(view: controller, team: team)
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.dismissKeyboard()
    }
}



// MARK: Presenter Delegate

extension MainViewController: MainPresenterView {

    /** On view did load */
    func onViewDidLoad() {
        self.updateUI(isTableViewVisible: true)
    }


    /** On search */
    func onSearch(_ isLabelVisible: Bool, _ isTableViewVisible: Bool, _ isCollectionViewVisible: Bool) {
        self.updateUI(
            isLabelVisible: isLabelVisible,
            isTableViewVisible: isTableViewVisible,
            isCollectionViewVisible: isCollectionViewVisible
        )
    }


    /** On badge image downloaded */
    func onBadgeDownloaded(index: Int) {
        DispatchQueue.main.async {
            self.teamsCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
    }


    /** On dismiss the keyboard */
    func onDismissKeyboard() {
        DispatchQueue.main.async {
            self.searchBar.endEditing(true)
        }
    }


    /** On remove multiple cells */
    func onRemoveCells(indexes: [IndexPath]) {
        self.teamsCollectionView.performBatchUpdates {
            self.teamsCollectionView.deleteItems(at: indexes)
        } completion: { isFinished in
            self.presenter.removeCellCompleted(isFinished: isFinished)
        }
    }


    /** On error */
    func onError(_ error: Error, title: String, actionTitle: String) {
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: actionTitle, style: .cancel)
        alert.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
