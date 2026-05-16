#import "PSRootViewController.h"
#import "PSAppTableViewController.h"
#import "PSSettingsListController.h"
#import "PSScriptsViewController.h"
#import "PSThemesViewController.h"
#import "PSThemeManager.h"
#import <TSPresentationDelegate.h>

@implementation PSRootViewController

- (void)loadView {
    [super loadView];

    // Apps tab
    PSAppTableViewController *appTableVC = [[PSAppTableViewController alloc] init];
    appTableVC.title = @"Apps";
    UINavigationController *appNav = [[UINavigationController alloc] initWithRootViewController:appTableVC];
    appNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Apps"
        image:[UIImage systemImageNamed:@"square.stack.3d.up.fill"] tag:0];

    // Themes tab
    PSThemesViewController *themesVC = [[PSThemesViewController alloc] init];
    UINavigationController *themesNav = [[UINavigationController alloc] initWithRootViewController:themesVC];
    themesNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Themes"
        image:[UIImage systemImageNamed:@"paintpalette.fill"] tag:1];

    // Scripts tab
    PSScriptsViewController *scriptsVC = [[PSScriptsViewController alloc] init];
    UINavigationController *scriptsNav = [[UINavigationController alloc] initWithRootViewController:scriptsVC];
    scriptsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Scripts"
        image:[UIImage systemImageNamed:@"terminal.fill"] tag:2];

    // Settings tab
    PSSettingsListController *settingsVC = [[PSSettingsListController alloc] init];
    settingsVC.title = @"Settings";
    UINavigationController *settingsNav = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    settingsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings"
        image:[UIImage systemImageNamed:@"gear"] tag:3];

    self.viewControllers = @[appNav, themesNav, scriptsNav, settingsNav];
    [self applyCurrentTheme];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyCurrentTheme)
        name:PSThemeChangedNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    PSPresentationDelegate.presentationViewController = self;
}

- (void)applyCurrentTheme {
    PSTheme *theme = [PSThemeManager shared].currentTheme;
    self.tabBar.tintColor = theme.accentColor;
    for (UINavigationController *nav in self.viewControllers) {
        if ([nav isKindOfClass:[UINavigationController class]]) {
            nav.navigationBar.tintColor = theme.accentColor;
        }
    }
}

@end
