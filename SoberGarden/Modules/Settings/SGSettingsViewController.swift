//
//  SGSettingsViewController.swift
//  SoberGarden
//

import UIKit
import MessageUI
import SafariServices

final class SGSettingsViewController: BaseViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStackView = UIStackView()
    private let introHeaderView = SGSectionHeaderView(
        title: "settings.title".localized(),
        subtitle: "settings.subtitle".localized()
    )
    private let subscriptionCardView = SGSettingsSubscriptionCardView()
    private let checkInStatsView = SGCheckInStatsView()

    private let privacyPolicyURL = URL(string: "https://sites.google.com/view/sober-privacy")!
    private let termsURL = URL(string: "https://sites.google.com/view/sober-termsofus")!
    private let disclaimerURL = URL(string: "https://sites.google.com/view/sober-disclaimer")!
    override func viewDidLoad() {
        super.viewDidLoad()
//        title = "Settings"
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLanguageChanged),
            name: Notification.Name(rawValue: LCLLanguageChangeNotification),
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadContent()
    }

    override func setupSubviews() {
        setupScrollView()
        bindSubscriptionCard()
        checkInStatsView.onPremiumTap = { [weak self] in
            self?.requirePlusAccess()
        }
        reloadContent()
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.bounces = false
        scrollView.alwaysBounceVertical = false

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            make.left.right.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }

        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.spacing = 18
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 8, left: 20, bottom: 28, right: 20)

        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func reloadContent() {
        contentStackView.arrangedSubviews.forEach { view in
            contentStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let state = SoberGardenStore.shared.state
        let habit = state.habit
        let settings = state.settings

        introHeaderView.configure(
            title: "settings.title".localized(),
            subtitle: "settings.subtitle".localized()
        )
        contentStackView.addArrangedSubview(introHeaderView)
        contentStackView.setCustomSpacing(16, after: introHeaderView)

        subscriptionCardView.configure(isPlus: SGSubscriptionManager.shared.isPlus)
        contentStackView.addArrangedSubview(subscriptionCardView)
        contentStackView.setCustomSpacing(22, after: subscriptionCardView)

        let cleanStreakDays = habit.map {
            SGProgressCalculator.currentStreakDays(startDate: $0.startDate, now: Date())
        }
        checkInStatsView.configure(
            cleanStreakDays: cleanStreakDays,
            checkInStreakDays: state.checkIn.checkInStreakDays
        )
        checkInStatsView.setLocked(!SGSubscriptionManager.shared.isPlus)
        contentStackView.addArrangedSubview(checkInStatsView)

        contentStackView.addArrangedSubview(makeSectionCard(
            title: "settings.section.habit.title".localized(),
            subtitle: "settings.section.habit.subtitle".localized(),
            rows: buildHabitRows(habit: habit)
        ))

        contentStackView.addArrangedSubview(makeSectionCard(
            title: "settings.section.preferences.title".localized(),
            subtitle: "settings.section.preferences.subtitle".localized(),
            rows: buildPreferenceRows()
        ))

        contentStackView.addArrangedSubview(makeSectionCard(
            title: "settings.section.notifications.title".localized(),
            subtitle: "settings.section.notifications.subtitle".localized(),
            rows: buildNotificationRows(settings: settings)
        ))

        contentStackView.addArrangedSubview(makeSectionCard(
            title: "settings.section.privacy.title".localized(),
            subtitle: "settings.section.privacy.subtitle".localized(),
            rows: buildPrivacyRows(settings: settings)
        ))

        contentStackView.addArrangedSubview(makeSectionCard(
            title: "settings.section.data.title".localized(),
            subtitle: "settings.section.data.subtitle".localized(),
            rows: buildDataRows()
        ))

        contentStackView.addArrangedSubview(makeSectionCard(
            title: "settings.section.widget.title".localized(),
            subtitle: "settings.section.widget.subtitle".localized(),
            rows: buildWidgetRows()
        ))

        contentStackView.addArrangedSubview(makeSectionCard(
            title: "settings.section.about.title".localized(),
            subtitle: "settings.section.about.subtitle".localized(),
            rows: buildAboutRows())
        )
    }

    private func makeSectionCard(title: String, subtitle: String?, rows: [SGSettingsRowView]) -> UIView {
        let sectionStackView = UIStackView()
        sectionStackView.axis = .vertical
        sectionStackView.alignment = .fill
        sectionStackView.spacing = 10

        let headerView = SGSectionHeaderView(title: title, subtitle: subtitle)
        sectionStackView.addArrangedSubview(headerView)

        let cardView = SGCardView()
        cardView.setContentInsets(.zero)
        cardView.contentView.backgroundColor = UIColor.hexString("#FBFDF8")

        let rowsStackView = UIStackView()
        rowsStackView.axis = .vertical
        rowsStackView.alignment = .fill
        rowsStackView.spacing = 0

        rows.enumerated().forEach { index, row in
            row.showsSeparator = index < rows.count - 1
            rowsStackView.addArrangedSubview(row)
        }

        cardView.contentView.addSubview(rowsStackView)
        rowsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        sectionStackView.addArrangedSubview(cardView)
        return sectionStackView
    }

    private func buildHabitRows(habit: Habit?) -> [SGSettingsRowView] {
        let habitType = habit?.displayName ?? "common.notSet".localized()
        let startDate = habit.map { Self.displayDateFormatter.string(from: $0.startDate) } ?? "common.notSet".localized()
        let dailyCost = Self.currencyString(for: habit?.dailyCost)
        let dailyMinutes = habit?.dailyMinutes.map { "settings.habit.minutesPerDayFormat".localizedFormat($0) } ?? "common.notSet".localized()
        let reasons = habit?.reasons.isEmpty == false ? "settings.habit.reasonsFormat".localizedFormat(habit?.reasons.count ?? 0) : "common.notSet".localized()

        let editRow = SGSettingsRowView()
        editRow.configure(
            title: "settings.habit.editTitle".localized(),
            subtitle: habitType,
            value: "settings.habit.editValue".localized(),
            accessory: .disclosure
        )
        editRow.onTap = { [weak self] in
            self?.openHabitEditor()
        }

        let startDateRow = SGSettingsRowView()
        startDateRow.configure(title: "settings.habit.startDate".localized(), value: startDate, accessory: .none)

        let costRow = SGSettingsRowView()
        costRow.configure(title: "settings.habit.dailyCost".localized(), value: dailyCost, accessory: .none)

        let timeRow = SGSettingsRowView()
        timeRow.configure(title: "settings.habit.dailyTime".localized(), value: dailyMinutes, accessory: .none)

        let reasonsRow = SGSettingsRowView()
        reasonsRow.configure(title: "settings.habit.reasons".localized(), value: reasons, accessory: .none)

        let additionalHabitRow = SGSettingsRowView()
        additionalHabitRow.configure(
            title: "settings.habit.additional.title".localized(),
            subtitle: "settings.habit.additional.subtitle".localized(),
            value: "subscription.plus".localized(),
            accessory: .disclosure
        )
        additionalHabitRow.onTap = { [weak self] in
            guard let self else { return }
            if self.requirePlusAccess() {
                self.showComingSoonAlert(title: "settings.habit.additional.comingSoonTitle".localized(), message: "settings.habit.additional.comingSoonMessage".localized())
            }
        }

        return [editRow, startDateRow, costRow, timeRow, reasonsRow, additionalHabitRow]
    }

    private func bindSubscriptionCard() {
        subscriptionCardView.onPrimaryAction = { [weak self] in
            self?.presentSubscriptionPaywall()
        }
    }

    private func presentSubscriptionPaywall() {
        let paywallViewController = SGSubscriptionPaywallViewController()
        presentController(paywallViewController)
    }

    private func buildNotificationRows(settings: SoberGardenSettings) -> [SGSettingsRowView] {
        let dailyReminder = SGSettingsRowView()
        dailyReminder.configure(
            title: "settings.notifications.daily.title".localized(),
            subtitle: "settings.notifications.daily.subtitle".localizedFormat(Self.timeString(for: settings.dailyReminderTime)),
            accessory: .toggle(settings.dailyReminderEnabled)
        )
        dailyReminder.onToggleChanged = { [weak self] isOn in
            self?.updateNotificationSetting(isOn: isOn) { settings in
                settings.dailyReminderEnabled = isOn
            }
        }

        let milestoneRow = SGSettingsRowView()
        milestoneRow.configure(
            title: "settings.notifications.milestone.title".localized(),
            subtitle: "settings.notifications.milestone.subtitle".localized(),
            accessory: .toggle(SGSubscriptionManager.shared.isPlus && settings.milestoneNotificationsEnabled)
        )
        milestoneRow.onToggleChanged = { [weak self] isOn in
            self?.updatePremiumNotificationSetting(isOn: isOn) { settings in
                settings.milestoneNotificationsEnabled = isOn
            }
        }

        let nightReminder = SGSettingsRowView()
        nightReminder.configure(
            title: "settings.notifications.night.title".localized(),
            subtitle: "settings.notifications.night.subtitle".localized(),
            accessory: .toggle(SGSubscriptionManager.shared.isPlus && settings.nightReminderEnabled)
        )
        nightReminder.onToggleChanged = { [weak self] isOn in
            self?.updatePremiumNotificationSetting(isOn: isOn) { settings in
                settings.nightReminderEnabled = isOn
            }
        }

        let rescueReminder = SGSettingsRowView()
        rescueReminder.configure(
            title: "settings.notifications.rescue.title".localized(),
            subtitle: "settings.notifications.rescue.subtitle".localized(),
            accessory: .toggle(SGSubscriptionManager.shared.isPlus && settings.rescueDelayReminderEnabled)
        )
        rescueReminder.onToggleChanged = { [weak self] isOn in
            self?.updatePremiumNotificationSetting(isOn: isOn) { settings in
                settings.rescueDelayReminderEnabled = isOn
            }
        }

        return [dailyReminder, milestoneRow, nightReminder, rescueReminder]
    }

    private func buildPreferenceRows() -> [SGSettingsRowView] {
        let languageRow = SGSettingsRowView()
        languageRow.configure(
            title: "settings.language.title".localized(),
            subtitle: "settings.language.row.subtitle".localized(),
            value: SGAppLanguage.current.nativeName,
            accessory: .disclosure
        )
        languageRow.onTap = { [weak self] in
            let languageViewController = SGLanguageSelectionViewController()
            languageViewController.onLanguageChanged = { [weak self] in
                self?.reloadContent()
            }
            self?.pushController(languageViewController)
        }

        return [languageRow]
    }

    private func updateNotificationSetting(isOn: Bool, update: @escaping (inout SoberGardenSettings) -> Void) {
        view.endEditing(true)

        guard isOn else {
            SoberGardenStore.shared.updateSettings(update)
            return
        }

        SGNotificationService.shared.requestAuthorization { [weak self] granted in
            guard let self else { return }
            guard granted else {
                self.showNotificationPermissionAlert()
                self.reloadContent()
                return
            }

            SoberGardenStore.shared.updateSettings(update)
        }
    }

    private func updatePremiumNotificationSetting(isOn: Bool, update: @escaping (inout SoberGardenSettings) -> Void) {
        guard isOn else {
            updateNotificationSetting(isOn: false, update: update)
            return
        }

        guard requirePlusAccess() else {
            reloadContent()
            return
        }

        updateNotificationSetting(isOn: true, update: update)
    }

    private func buildPrivacyRows(settings: SoberGardenSettings) -> [SGSettingsRowView] {
        let appLock = SGSettingsRowView()
        appLock.configure(
            title: "settings.privacy.appLock.title".localized(),
            subtitle: "settings.privacy.appLock.subtitle".localized(),
            accessory: .toggle(settings.appLockEnabled)
        )
        appLock.onToggleChanged = { [weak self] isOn in
            self?.updateAppLockSetting(isOn: isOn)
        }

        let privacyPolicy = SGSettingsRowView()
        privacyPolicy.configure(
            title: "settings.privacy.policy.title".localized(),
            subtitle: "settings.privacy.policy.subtitle".localized(),
            accessory: .disclosure
        )
        privacyPolicy.onTap = { [weak self] in
            self?.open(url: self?.privacyPolicyURL)
        }

        let terms = SGSettingsRowView()
        terms.configure(
            title: "settings.privacy.terms.title".localized(),
            subtitle: "settings.privacy.terms.subtitle".localized(),
            accessory: .disclosure
        )
        terms.onTap = { [weak self] in
            self?.open(url: self?.termsURL)
        }

        let disclaimer = SGSettingsRowView()
        disclaimer.configure(
            title: "settings.privacy.disclaimer.title".localized(),
            subtitle: "settings.privacy.disclaimer.subtitle".localized(),
            accessory: .disclosure
        )
        disclaimer.onTap = { [weak self] in
            self?.pushController(SGNonMedicalDisclaimerViewController(mode: .settings))
        }

        return [appLock, privacyPolicy, terms, disclaimer]
    }

    private func updateAppLockSetting(isOn: Bool) {
        view.endEditing(true)

        guard isOn else {
            SoberGardenStore.shared.updateSettings { settings in
                settings.appLockEnabled = false
            }
            return
        }

        SGAppLockService.shared.authenticateForEnable { [weak self] success in
            guard let self else { return }

            guard success else {
                self.showAppLockAuthenticationAlert()
                self.reloadContent()
                return
            }

            SoberGardenStore.shared.updateSettings { settings in
                settings.appLockEnabled = true
            }
            self.reloadContent()
        }
    }

    private func buildDataRows() -> [SGSettingsRowView] {
        let resetRow = SGSettingsRowView()
        resetRow.configure(
            title: "settings.data.reset.title".localized(),
            subtitle: "settings.data.reset.subtitle".localized(),
            accessory: .disclosure,
            isDestructive: true
        )
        resetRow.onTap = { [weak self] in
            self?.confirmResetCurrentStreak()
        }

        let deleteRow = SGSettingsRowView()
        deleteRow.configure(
            title: "settings.data.delete.title".localized(),
            subtitle: "settings.data.delete.subtitle".localized(),
            accessory: .disclosure,
            isDestructive: true
        )
        deleteRow.onTap = { [weak self] in
            self?.confirmDeleteAllData()
        }

        return [resetRow, deleteRow]
    }

    private func buildWidgetRows() -> [SGSettingsRowView] {
        let widgetGuideRow = SGSettingsRowView()
        widgetGuideRow.configure(
            title: "settings.widget.title".localized(),
            subtitle: "settings.widget.subtitle".localized(),
            accessory: .disclosure
        )
        widgetGuideRow.onTap = { [weak self] in
            let guideViewController = SGWidgetGuideViewController()
            guideViewController.modalPresentationStyle = .pageSheet
            if let sheet = guideViewController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 24
            }
            self?.present(guideViewController, animated: true)
        }

        return [widgetGuideRow]
    }

    private func buildAboutRows() -> [SGSettingsRowView] {
        let feedbackRow = SGSettingsRowView()
        feedbackRow.configure(
            title: "settings.feedback.title".localized(),
            subtitle: "settings.feedback.subtitle".localized(),
            accessory: .disclosure
        )
        feedbackRow.onTap = { [weak self] in
            guard let self else { return }
            SGFeedbackMailPresenter.shared.presentFeedback(from: self)
        }

        let versionRow = SGSettingsRowView()
        versionRow.configure(
            title: "settings.about.version".localized(),
            value: appVersionText,
            accessory: .none
        )
        return [feedbackRow, versionRow]
    }

    private func open(url: URL?) {
        guard let url else { return }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true)
    }

    private func showComingSoonAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "common.ok".localized(), style: .default))
        present(alert, animated: true)
    }

    private func showNotificationPermissionAlert() {
        let alert = UIAlertController(
            title: "settings.alert.notificationsOff.title".localized(),
            message: "settings.alert.notificationsOff.message".localized(),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "common.ok".localized(), style: .default))
        alert.addAction(UIAlertAction(title: "settings.alert.openSettings".localized(), style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        })
        present(alert, animated: true)
    }

    private func showAppLockAuthenticationAlert() {
        let alert = UIAlertController(
            title: "settings.alert.appLockFailed.title".localized(),
            message: "settings.alert.appLockFailed.message".localized(),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "common.ok".localized(), style: .default))
        present(alert, animated: true)
    }

    private func openHabitEditor() {
        guard let habit = SoberGardenStore.shared.state.habit else { return }
        let editViewController = SGEditHabitViewController(habit: habit)
        editViewController.onSave = { [weak self] in
            self?.reloadContent()
        }
        pushController(editViewController)
    }

    private func confirmResetCurrentStreak() {
        let alert = UIAlertController(
            title: "settings.alert.reset.title".localized(),
            message: "settings.alert.reset.message".localized(),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "common.cancel".localized(), style: .cancel))
        alert.addAction(UIAlertAction(title: "settings.alert.reset.confirm".localized(), style: .destructive) { [weak self] _ in
            SoberGardenStore.shared.resetCurrentStreak()
            self?.reloadContent()
            self?.showResetCompleteAlert()
        })

        present(alert, animated: true)
    }

    private func showResetCompleteAlert() {
        let alert = UIAlertController(
            title: "settings.alert.reset.completeTitle".localized(),
            message: "settings.alert.reset.completeMessage".localized(),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "common.ok".localized(), style: .default))
        present(alert, animated: true)
    }

    private func confirmDeleteAllData() {
        let alert = UIAlertController(
            title: "settings.alert.delete.title".localized(),
            message: "settings.alert.delete.message".localized(),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "common.cancel".localized(), style: .cancel))
        alert.addAction(UIAlertAction(title: "settings.alert.delete.confirm".localized(), style: .destructive) { [weak self] _ in
            SoberGardenStore.shared.deleteAllData()
            self?.returnToOnboarding()
        })

        present(alert, animated: true)
    }

    private func returnToOnboarding() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return
        }

        window.rootViewController = SGOnboardingViewController()
        window.makeKeyAndVisible()
    }

    @objc private func handleLanguageChanged() {
        reloadContent()
    }

    private var appVersionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }

    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    private static func timeString(for components: DateComponents) -> String {
        let calendar = Calendar.current
        var fullComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        fullComponents.hour = components.hour
        fullComponents.minute = components.minute
        let date = calendar.date(from: fullComponents) ?? Date()
        return timeFormatter.string(from: date)
    }

    private static func currencyString(for value: Double?) -> String {
        guard let value else { return "common.notSet".localized() }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

private final class SGSettingsSubscriptionCardView: UIControl {

    private let gradientLayer = CAGradientLayer()
    private let badgeBackgroundView = UIView()
    private let badgeLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let featureStackView = UIStackView()
    private let actionButton = UIButton(type: .system)
    private let bloomImageView = UIImageView(image: UIImage(named: GardenStage.flower.gardenImageName))

    var onPrimaryAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    func configure(isPlus: Bool) {
        badgeLabel.text = isPlus ? "settings.plus.activeBadge".localized() : "settings.plus.brandBadge".localized()
        titleLabel.text = isPlus ? "settings.plus.activeTitle".localized() : "settings.plus.inactiveTitle".localized()
        subtitleLabel.text = isPlus
            ? "settings.plus.activeSubtitle".localized()
            : "settings.plus.inactiveSubtitle".localized()
        actionButton.setTitle(isPlus ? "settings.plus.manage".localized() : "settings.plus.viewPlans".localized(), for: .normal)
    }

    private func setupView() {
        clipsToBounds = false
        layer.cornerRadius = 24
        layer.cornerCurve = .continuous
        layer.shadowColor = SGColor.textDark.cgColor
        layer.shadowOpacity = 0.14
        layer.shadowRadius = 18
        layer.shadowOffset = CGSize(width: 0, height: 10)

        backgroundColor = .clear
        layer.masksToBounds = false

        gradientLayer.colors = [
            SGColor.primaryDark.cgColor,
            UIColor.hexString("#789A55").cgColor,
            UIColor.hexString("#E89B5C").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 24
        layer.insertSublayer(gradientLayer, at: 0)

        badgeBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        badgeBackgroundView.layer.cornerRadius = 13
        badgeBackgroundView.layer.cornerCurve = .continuous

        badgeLabel.font = .systemFont(ofSize: 11, weight: .heavy)
        badgeLabel.textColor = UIColor.white.withAlphaComponent(0.92)
        badgeLabel.textAlignment = .center

        titleLabel.font = .systemFont(ofSize: 25, weight: .heavy)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.82

        subtitleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.78)
        subtitleLabel.numberOfLines = 0

        featureStackView.axis = .horizontal
        featureStackView.alignment = .fill
        featureStackView.distribution = .fillProportionally
        featureStackView.spacing = 8
        ["settings.plus.feature.trends".localized(), "settings.plus.feature.garden".localized(), "settings.plus.feature.reflection".localized()].forEach { feature in
            featureStackView.addArrangedSubview(makeFeaturePill(text: feature))
        }

        actionButton.backgroundColor = .white
        actionButton.setTitleColor(SGColor.primaryDark, for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .heavy)
        actionButton.layer.cornerRadius = 18
        actionButton.layer.cornerCurve = .continuous
        actionButton.addTarget(self, action: #selector(handlePrimaryAction), for: .touchUpInside)

        bloomImageView.contentMode = .scaleAspectFit
        bloomImageView.alpha = 0.22

        addTarget(self, action: #selector(handlePrimaryAction), for: .touchUpInside)

        addSubview(bloomImageView)
        addSubview(badgeBackgroundView)
        badgeBackgroundView.addSubview(badgeLabel)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(featureStackView)
        addSubview(actionButton)

        bloomImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-6)
            make.width.height.equalTo(132)
        }

        badgeBackgroundView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(18)
        }

        badgeLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10))
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(badgeBackgroundView.snp.bottom).offset(15)
            make.left.right.equalToSuperview().inset(18)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(18)
        }

        featureStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(18)
            make.right.lessThanOrEqualToSuperview().offset(-18)
        }

        actionButton.snp.makeConstraints { make in
            make.top.equalTo(featureStackView.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(18)
            make.bottom.equalToSuperview().offset(-18)
            make.height.equalTo(38)
            make.width.greaterThanOrEqualTo(104)
        }
    }

    private func makeFeaturePill(text: String) -> UILabel {
        let label = SGSettingsPaddingLabel()
        label.text = text
        label.font = .systemFont(ofSize: 11, weight: .heavy)
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        label.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        label.layer.cornerRadius = 14
        label.layer.cornerCurve = .continuous
        label.clipsToBounds = true
        return label
    }

    @objc private func handlePrimaryAction() {
        onPrimaryAction?()
    }
}

private final class SGSettingsPaddingLabel: UILabel {

    var insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right, height: size.height + insets.top + insets.bottom)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
}
