//
//  TeamDetailsViewController.swift
//  MyFootball
//
//  Created by Raphaël Merrot on 26/05/2022.
//

import UIKit



/** Controller of team detais view */
final class TeamDetailsViewController: UIViewController {

    /// No data label
    @IBOutlet private weak var noDataLabel: UILabel!

    /// Stack view
    @IBOutlet private weak var stackView: UIStackView!

    /// Banner image view
    @IBOutlet private weak var bannerImageView: UIImageView!

    /// Country label
    @IBOutlet private weak var countryLabel: UILabel!

    /// League label
    @IBOutlet private weak var leagueLabel: UILabel!

    /// Team description label
    @IBOutlet private weak var descriptionTextView: UITextView!

    /// Spinner
    @IBOutlet private weak var spinner: UIActivityIndicatorView!

    /// Presenter
    var presenter: TeamDetailsPresenter?
    

    /** View did load */
    override func viewDidLoad() {
        super.viewDidLoad()

        self.presenter?.viewDidLoad()
    }


    /** View will appear */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.title = self.presenter?.titleView
    }


    /** Update user interface */
    private func updateUI(team: Team?, _ isNoDataLabelVisible: Bool) {
        DispatchQueue.main.async {
            self.updateNoDataLabel(isNoDataLabelVisible)
            self.updateStackView(team: team, !isNoDataLabelVisible)
        }
    }


    /** Update no data label */
    private func updateNoDataLabel(_ isVisible: Bool) {
        self.noDataLabel.text = self.presenter?.noDataText
        self.noDataLabel.isHidden = !isVisible
    }


    /** Update stack view elements */
    private func updateStackView(team: Team?, _ isVisible: Bool) {
        self.stackView.isHidden = !isVisible
        self.countryLabel.text = team?.strCountry
        self.leagueLabel.text = self.presenter?.leagueTitle
        self.descriptionTextView.text = team?.strDescriptionEN
        self.bannerImageView.isHidden = true
    }


    private func updateImageView(data: Data) {
        DispatchQueue.main.async {
            self.bannerImageView.isHidden = false
            self.bannerImageView.image = UIImage(data: data)
        }
    }
}



// MARK: Presenter Delegate

extension TeamDetailsViewController: TeamDetailsViewPresenter {

    /** On view did load */
    func onViewDidLoad(team: Team?, isNoDataLabelVisible: Bool) {
        self.updateUI(team: team, isNoDataLabelVisible)
    }


    /** On banner image downloaded */
    func onBannerDownloaded(data: Data) {
        self.updateImageView(data: data)
    }


    /** Start spinner animation */
    func startSpinnerAnimation() {
        DispatchQueue.main.async {
            self.spinner.startAnimating()
            self.spinner.isHidden = false
        }
    }


    /** Stop spinner annimation */
    func stopSpinnerAnimation() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.spinner.isHidden = true
        }
    }
}

