import SwiftUI
import UIKit

enum MomentMapApp {
    static func configureAppearance() {
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(AppColors.background)
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(AppColors.secondaryAccent),
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(AppColors.secondaryAccent),
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(AppColors.background)
        tabAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppColors.accent)
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(AppColors.accent)
        ]
        tabAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppColors.secondaryText)
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(AppColors.secondaryText)
        ]
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}
