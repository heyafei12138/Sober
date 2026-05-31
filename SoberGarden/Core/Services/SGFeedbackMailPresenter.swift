//
//  SGFeedbackMailPresenter.swift
//  SoberGarden
//

import MessageUI
import UIKit

final class SGFeedbackMailPresenter: NSObject {

    static let shared = SGFeedbackMailPresenter()

    private override init() {
        super.init()
    }

    func presentFeedback(from presenter: UIViewController) {
        guard MFMailComposeViewController.canSendMail() else {
            showMailUnavailableAlert(from: presenter)
            return
        }

        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        mailViewController.setToRecipients([SGAppConstants.feedbackEmail])
        mailViewController.setSubject("feedback.mail.subject".localized())
        mailViewController.setMessageBody(feedbackBody(), isHTML: false)
        presenter.present(mailViewController, animated: true)
    }

    private func feedbackBody() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
        let language = SGAppLanguage.current.code
        let systemVersion = UIDevice.current.systemVersion
        let device = UIDevice.current.model

        return "feedback.mail.bodyFormat".localizedFormat(version, build, language, device, systemVersion)
    }

    private func showMailUnavailableAlert(from presenter: UIViewController) {
        let alert = UIAlertController(
            title: "feedback.mailUnavailable.title".localized(),
            message: "feedback.mailUnavailable.message".localizedFormat(SGAppConstants.feedbackEmail),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "common.ok".localized(), style: .default))
        presenter.present(alert, animated: true)
    }
}

extension SGFeedbackMailPresenter: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true)
    }
}
