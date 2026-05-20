//
//  SGSettingsViewController.swift
//  SoberGarden
//

import UIKit
import SafariServices

final class SGSettingsViewController: BaseViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStackView = UIStackView()
    private let introHeaderView = SGSectionHeaderView(
        title: "Settings",
        subtitle: "Manage reminders, privacy, and local data."
    )

    private let privacyPolicyURL = URL(string: "https://example.com/privacy-policy")!
    private let termsURL = URL(string: "https://example.com/terms")!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
    }

    override func setupSubviews() {
        setupScrollView()
        reloadContent()
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
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

        contentStackView.addArrangedSubview(introHeaderView)
        contentStackView.setCustomSpacing(20, after: introHeaderView)

        contentStackView.addArrangedSubview(makeSectionCard(
            title: "Habit",
            subtitle: "Review your current recovery goal and the baseline you set during onboarding.",
            rows: buildHabitRows(habit: habit)
        ))

        contentStackView.addArrangedSubview(makeSectionCard(
            title: "Notifications",
            subtitle: "Keep reminders gentle and predictable.",
            rows: buildNotificationRows(settings: settings)
        ))

        contentStackView.addArrangedSubview(makeSectionCard(
            title: "Privacy & Safety",
            subtitle: "Read the policy, terms, and care boundaries.",
            rows: buildPrivacyRows()
        ))

        contentStackView.addArrangedSubview(makeSectionCard(
            title: "Data Management",
            subtitle: "Local data stays on this device unless you remove it.",
            rows: buildDataRows()
        ))

        contentStackView.addArrangedSubview(makeSectionCard(
            title: "About",
            subtitle: "Small product details and the current app build.",
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
        let habitType = habit?.displayName ?? "Not set"
        let startDate = habit.map { Self.displayDateFormatter.string(from: $0.startDate) } ?? "Not set"
        let dailyCost = Self.currencyString(for: habit?.dailyCost)
        let dailyMinutes = habit?.dailyMinutes.map { "\($0) min/day" } ?? "Not set"
        let reasons = habit?.reasons.isEmpty == false ? "\(habit?.reasons.count ?? 0) reasons" : "Not set"

        let editRow = SGSettingsRowView()
        editRow.configure(
            title: "Edit habit",
            subtitle: habitType,
            value: "Update goal details",
            accessory: .disclosure
        )
        editRow.onTap = { [weak self] in
            self?.showComingSoonAlert(
                title: "Edit habit",
                message: "Habit editing will be added in the next task."
            )
        }

        let startDateRow = SGSettingsRowView()
        startDateRow.configure(title: "Start date", value: startDate, accessory: .none)

        let costRow = SGSettingsRowView()
        costRow.configure(title: "Daily cost", value: dailyCost, accessory: .none)

        let timeRow = SGSettingsRowView()
        timeRow.configure(title: "Daily time", value: dailyMinutes, accessory: .none)

        let reasonsRow = SGSettingsRowView()
        reasonsRow.configure(title: "Reasons", value: reasons, accessory: .none)

        return [editRow, startDateRow, costRow, timeRow, reasonsRow]
    }

    private func buildNotificationRows(settings: SoberGardenSettings) -> [SGSettingsRowView] {
        let dailyReminder = SGSettingsRowView()
        dailyReminder.configure(
            title: "Daily reminder",
            subtitle: "A gentle check-in at \(Self.timeString(for: settings.dailyReminderTime)).",
            accessory: .toggle(settings.dailyReminderEnabled)
        )
        dailyReminder.onToggleChanged = { [weak self] isOn in
            SoberGardenStore.shared.updateSettings { state in
                state.dailyReminderEnabled = isOn
            }
            self?.view.endEditing(true)
        }

        let milestoneRow = SGSettingsRowView()
        milestoneRow.configure(
            title: "Milestone notifications",
            subtitle: "Celebrate important streak points.",
            accessory: .toggle(settings.milestoneNotificationsEnabled)
        )
        milestoneRow.onToggleChanged = { [weak self] isOn in
            SoberGardenStore.shared.updateSettings { state in
                state.milestoneNotificationsEnabled = isOn
            }
            self?.view.endEditing(true)
        }

        let nightReminder = SGSettingsRowView()
        nightReminder.configure(
            title: "Night reminder",
            subtitle: "A softer nudge if the evening gets hard.",
            accessory: .toggle(settings.nightReminderEnabled)
        )
        nightReminder.onToggleChanged = { [weak self] isOn in
            SoberGardenStore.shared.updateSettings { state in
                state.nightReminderEnabled = isOn
            }
            self?.view.endEditing(true)
        }

        let rescueReminder = SGSettingsRowView()
        rescueReminder.configure(
            title: "Rescue delay reminder",
            subtitle: "Remind me when I choose to wait.",
            accessory: .toggle(settings.rescueDelayReminderEnabled)
        )
        rescueReminder.onToggleChanged = { [weak self] isOn in
            SoberGardenStore.shared.updateSettings { state in
                state.rescueDelayReminderEnabled = isOn
            }
            self?.view.endEditing(true)
        }

        return [dailyReminder, milestoneRow, nightReminder, rescueReminder]
    }

    private func buildPrivacyRows() -> [SGSettingsRowView] {
        let privacyPolicy = SGSettingsRowView()
        privacyPolicy.configure(
            title: "Privacy Policy",
            subtitle: "How local data is stored and used.",
            accessory: .disclosure
        )
        privacyPolicy.onTap = { [weak self] in
            self?.open(url: self?.privacyPolicyURL)
        }

        let terms = SGSettingsRowView()
        terms.configure(
            title: "Terms of Use",
            subtitle: "Usage terms and expectations.",
            accessory: .disclosure
        )
        terms.onTap = { [weak self] in
            self?.open(url: self?.termsURL)
        }

        let disclaimer = SGSettingsRowView()
        disclaimer.configure(
            title: "Non-medical disclaimer",
            subtitle: "This app supports reflection, not diagnosis or treatment.",
            accessory: .disclosure
        )
        disclaimer.onTap = { [weak self] in
            self?.showComingSoonAlert(
                title: "Non-medical disclaimer",
                message: "SoberGarden is a support tool and does not replace professional medical advice."
            )
        }

        return [privacyPolicy, terms, disclaimer]
    }

    private func buildDataRows() -> [SGSettingsRowView] {
        let resetRow = SGSettingsRowView()
        resetRow.configure(
            title: "Reset current streak",
            subtitle: "Start fresh without removing the whole app history.",
            accessory: .disclosure,
            isDestructive: true
        )
        resetRow.onTap = { [weak self] in
            self?.showComingSoonAlert(
                title: "Reset current streak",
                message: "The reset flow will land in the next task."
            )
        }

        let deleteRow = SGSettingsRowView()
        deleteRow.configure(
            title: "Delete all data",
            subtitle: "Remove the habit, entries, sessions, and reminders from this device.",
            accessory: .disclosure,
            isDestructive: true
        )
        deleteRow.onTap = { [weak self] in
            self?.confirmDeleteAllData()
        }

        return [resetRow, deleteRow]
    }

    private func buildAboutRows() -> [SGSettingsRowView] {
        let versionRow = SGSettingsRowView()
        versionRow.configure(
            title: "App version",
            value: appVersionText,
            accessory: .none
        )
        return [versionRow]
    }

    private func open(url: URL?) {
        guard let url else { return }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true)
    }

    private func showComingSoonAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func confirmDeleteAllData() {
        let alert = UIAlertController(
            title: "Delete all data?",
            message: "This removes the habit, progress history, journal entries, rescue sessions, and local settings from this device.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
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
        guard let value else { return "Not set" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
