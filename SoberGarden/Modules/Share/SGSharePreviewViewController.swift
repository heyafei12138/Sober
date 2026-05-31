//
//  SGSharePreviewViewController.swift
//  SoberGarden
//

import Photos
import UIKit

final class SGSharePreviewViewController: UIViewController {

    private var package: SGShareProgressService.ProgressSharePackage
    private var selectedStyle: SGSharePosterStyle

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStackView = UIStackView()
    private let headerView = UIView()
    private let closeButton = UIButton(type: .system)
    private let headerTextStackView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let styleSegmentedControl = UISegmentedControl(items: SGSharePosterStyle.allCases.map(\.title))
    private let previewContainerView = UIView()
    private let imageView = UIImageView()
    private let actionStackView = UIStackView()
    private let saveButton = SGPrimaryButton(title: "common.save".localized(), style: .secondary)
    private let shareButton = SGPrimaryButton(title: "common.share".localized(), style: .primary)

    init(package: SGShareProgressService.ProgressSharePackage) {
        self.package = package
        self.selectedStyle = package.style
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheetPresentationController {
            sheetPresentationController.detents = [.large()]
            sheetPresentationController.prefersGrabberVisible = true
            sheetPresentationController.preferredCornerRadius = 24
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        view.backgroundColor = SGColor.background

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }

        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.spacing = 16
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 24, right: 20)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = SGColor.textSecondary
        closeButton.accessibilityLabel = "common.close".localized()
        closeButton.addTarget(self, action: #selector(handleCloseTapped), for: .touchUpInside)

        headerTextStackView.axis = .vertical
        headerTextStackView.alignment = .fill
        headerTextStackView.spacing = 6

        titleLabel.text = "share.preview.title".localized()
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textColor = SGColor.textDark

        subtitleLabel.text = "share.preview.subtitle".localized()
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        subtitleLabel.textColor = SGColor.textSecondary
        subtitleLabel.numberOfLines = 0

        styleSegmentedControl.selectedSegmentIndex = SGSharePosterStyle.allCases.firstIndex(of: selectedStyle) ?? 0
        styleSegmentedControl.backgroundColor = UIColor.hexString("#E7EEDC")
        styleSegmentedControl.selectedSegmentTintColor = SGColor.primaryDark
        styleSegmentedControl.layer.cornerRadius = 18
        styleSegmentedControl.layer.borderWidth = 1
        styleSegmentedControl.layer.borderColor = UIColor.white.withAlphaComponent(0.74).cgColor
        styleSegmentedControl.setTitleTextAttributes(
            [
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
                .foregroundColor: SGColor.primaryDark.withAlphaComponent(0.72)
            ],
            for: .normal
        )
        styleSegmentedControl.setTitleTextAttributes(
            [
                .font: UIFont.systemFont(ofSize: 13, weight: .bold),
                .foregroundColor: UIColor.white
            ],
            for: .selected
        )
        styleSegmentedControl.addTarget(self, action: #selector(handleStyleChanged(_:)), for: .valueChanged)

        previewContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.72)
        previewContainerView.layer.cornerRadius = 22
        previewContainerView.layer.shadowColor = UIColor.hexString("#8DA67B").cgColor
        previewContainerView.layer.shadowOpacity = 0.14
        previewContainerView.layer.shadowRadius = 20
        previewContainerView.layer.shadowOffset = CGSize(width: 0, height: 12)

        imageView.image = package.image
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true

        actionStackView.axis = .horizontal
        actionStackView.alignment = .fill
        actionStackView.distribution = .fillEqually
        actionStackView.spacing = 12

        saveButton.addTarget(self, action: #selector(handleSaveTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(handleShareTapped), for: .touchUpInside)

        contentStackView.addArrangedSubview(headerView)
        headerView.addSubview(closeButton)
        headerView.addSubview(headerTextStackView)
        headerTextStackView.addArrangedSubview(titleLabel)
        headerTextStackView.addArrangedSubview(subtitleLabel)
        contentStackView.addArrangedSubview(styleSegmentedControl)
        contentStackView.addArrangedSubview(previewContainerView)
        previewContainerView.addSubview(imageView)
        contentStackView.addArrangedSubview(actionStackView)
        actionStackView.addArrangedSubview(saveButton)
        actionStackView.addArrangedSubview(shareButton)

        headerView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(58)
        }

        closeButton.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.width.height.equalTo(34)
        }

        headerTextStackView.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.left.equalTo(closeButton.snp.right).offset(12)
        }

        styleSegmentedControl.snp.makeConstraints { make in
            make.height.equalTo(38)
        }

        previewContainerView.snp.makeConstraints { make in
            make.height.equalTo(previewContainerView.snp.width).multipliedBy(1.25)
        }

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(14)
        }

        actionStackView.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }

    @objc private func handleSaveTapped() {
        guard requirePlusAccess() else { return }
        saveButton.isEnabled = false
        saveImageToPhotoLibrary()
    }

    @objc private func handleCloseTapped() {
        dismiss(animated: true)
    }

    @objc private func handleShareTapped() {
        guard requirePlusAccess() else { return }
        let activity = UIActivityViewController(activityItems: package.activityItems, applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = shareButton
        activity.popoverPresentationController?.sourceRect = shareButton.bounds
        activity.completionWithItemsHandler = { [weak self] _, completed, _, _ in
            guard completed, let self else { return }
            SGReviewPromptCoordinator.shared.promptIfNeeded(trigger: .posterShared, from: self)
        }
        present(activity, animated: true)
    }

    @objc private func handleStyleChanged(_ sender: UISegmentedControl) {
        let styles = SGSharePosterStyle.allCases
        guard styles.indices.contains(sender.selectedSegmentIndex) else { return }

        selectedStyle = styles[sender.selectedSegmentIndex]
        guard let updatedPackage = SGShareProgressService.shared.makeProgressSharePackage(style: selectedStyle) else { return }

        package = updatedPackage
        imageView.image = updatedPackage.image
    }

    private func saveImageToPhotoLibrary() {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            DispatchQueue.main.async {
                guard let self else { return }

                switch status {
                case .authorized, .limited:
                    self.performPhotoSave()
                case .denied, .restricted:
                    self.saveButton.isEnabled = true
                    self.showAlert(
                        title: "share.alert.photos.title".localized(),
                        message: "share.alert.photos.message".localized()
                    )
                case .notDetermined:
                    self.saveButton.isEnabled = true
                @unknown default:
                    self.saveButton.isEnabled = true
                    self.showAlert(title: "share.alert.saveFailed.title".localized(), message: "share.alert.saveFailed.message".localized())
                }
            }
        }
    }

    private func performPhotoSave() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: self.package.image)
        }, completionHandler: { [weak self] success, error in
            DispatchQueue.main.async {
                guard let self else { return }
                self.saveButton.isEnabled = true

                if success {
                    self.showAlert(title: "share.alert.saved.title".localized(), message: "share.alert.saved.message".localized()) {
                        SGReviewPromptCoordinator.shared.promptIfNeeded(trigger: .posterShared, from: self)
                    }
                } else {
                    let message = error?.localizedDescription ?? "share.alert.saveFailed.message".localized()
                    self.showAlert(title: "share.alert.saveFailed.title".localized(), message: message)
                }
            }
        })
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "common.ok".localized(), style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}
