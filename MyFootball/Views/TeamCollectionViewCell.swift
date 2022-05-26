//
//  TeamCollectionViewCell.swift
//  MyFootball
//
//  Created by Raphaël Merrot on 26/05/2022.
//

import UIKit


/** Team cell */
final class TeamCollectionViewCell: UICollectionViewCell {

    /// team logo
    @IBOutlet private weak var logo: UIImageView!

    /// Placeholder label (if team don't have logo)
    @IBOutlet private weak var placeholder: UILabel!

    /// Spinner
    @IBOutlet private weak var spinner: UIActivityIndicatorView!

    /// Presenter
    var presenter: TeamCellPresenter? {
        didSet {
            self.presenter?.viewDidLoad()
        }
    }


    /** Update user interface */
    private func updateUI(team: Team, isPlaceholderVisible: Bool) {
        DispatchQueue.main.async {
            self.spinner.isHidden = !self.spinner.isAnimating
            self.placeholder.text = team.strTeam
            self.placeholder.isHidden = !isPlaceholderVisible
            self.logo.isHidden = isPlaceholderVisible
            self.logo.image = team.badge
        }
    }
}


// MARK: Presenter Delegate

extension TeamCollectionViewCell: TeamCellViewPresenter {

    /** On view did load */
    func viewDidLoad(team: Team, isPlaceholderVisible: Bool) {
        self.updateUI(team: team, isPlaceholderVisible: isPlaceholderVisible)
    }


    /** Start the spinner animation*/
    func startSpinnerAnimation() {
        self.spinner.startAnimating()
    }


    /** Stop the spinner animation */
    func stopSpinnerAnimation() {
        self.spinner.stopAnimating()
    }

}
