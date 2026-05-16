#import "PSThemesViewController.h"
#import "PSThemeManager.h"

@interface PSThemesViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<PSTheme *> *builtins;
@property (nonatomic, strong) NSArray<PSTheme *> *customs;
@end

@implementation PSThemesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Themes";
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];

    // Import button
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Import"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(importThemeTapped)];

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    _tableView.delegate   = self;
    _tableView.dataSource = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableView];

    [self reloadData];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:PSThemeChangedNotification object:nil];
}

- (void)reloadData {
    _builtins = [PSThemeManager shared].builtinThemes;
    _customs  = [PSThemeManager shared].customThemes;
    [_tableView reloadData];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 2; }

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 0 ? @"Built-in Themes" : @"Custom Themes";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) return @"Import a .pstheme JSON file to add custom themes.";
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? _builtins.count : MAX(_customs.count, 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThemeCell"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ThemeCell"];

    if (indexPath.section == 1 && _customs.count == 0) {
        cell.textLabel.text = @"No custom themes yet";
        cell.detailTextLabel.text = @"Tap Import to add one";
        cell.textLabel.textColor = [UIColor secondaryLabelColor];
        cell.detailTextLabel.textColor = [UIColor tertiaryLabelColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self configureSwatchView:nil forCell:cell color:nil];
        return cell;
    }

    PSTheme *theme = indexPath.section == 0 ? _builtins[indexPath.row] : _customs[indexPath.row];
    cell.textLabel.text = theme.name;
    cell.detailTextLabel.text = theme.themeDescription;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.textLabel.textColor = [UIColor labelColor];
    cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
    BOOL active = [[PSThemeManager shared].currentTheme.identifier isEqualToString:theme.identifier];
    cell.accessoryType = active ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    [self configureSwatchView:theme forCell:cell color:theme.accentColor];
    return cell;
}

- (void)configureSwatchView:(nullable PSTheme *)theme forCell:(UITableViewCell *)cell color:(nullable UIColor *)color {
    // Remove old swatch
    for (UIView *v in cell.contentView.subviews) {
        if (v.tag == 999) { [v removeFromSuperview]; break; }
    }
    if (!color) return;
    UIView *swatch = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    swatch.backgroundColor = color;
    swatch.layer.cornerRadius = 8;
    swatch.tag = 999;
    cell.imageView.image = nil;
    // Place as imageView replacement
    swatch.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:swatch];
    [NSLayoutConstraint activateConstraints:@[
        [swatch.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
        [swatch.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:16],
        [swatch.widthAnchor constraintEqualToConstant:28],
        [swatch.heightAnchor constraintEqualToConstant:28],
    ]];
    cell.separatorInset = UIEdgeInsetsMake(0, 60, 0, 0);
    cell.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [cell.textLabel.leadingAnchor constraintEqualToAnchor:swatch.trailingAnchor constant:12],
    ]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && _customs.count == 0) return;
    PSTheme *theme = indexPath.section == 0 ? _builtins[indexPath.row] : _customs[indexPath.row];
    [[PSThemeManager shared] applyTheme:theme];
    [self reloadData];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Theme Applied"
        message:[NSString stringWithFormat:@""%@" is now active. Some changes may require relaunch.", theme.name]
        preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || _customs.count == 0) return nil;
    PSTheme *theme = _customs[indexPath.row];
    UIContextualAction *del = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
        title:@"Delete" handler:^(UIContextualAction *a, UIView *v, void(^done)(BOOL)) {
            [[PSThemeManager shared] deleteCustomTheme:theme];
            [self reloadData];
            done(YES);
        }];
    return [UISwipeActionsConfiguration configurationWithActions:@[del]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - Import

- (void)importThemeTapped {
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc]
        initForOpeningContentTypes:@[UTTypeJSON] asCopy:YES];
    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *url = urls.firstObject;
    if (!url) return;
    NSError *err;
    BOOL ok = [[PSThemeManager shared] importThemeFromURL:url error:&err];
    NSString *title = ok ? @"Theme Imported!" : @"Import Failed";
    NSString *msg   = ok ? @"Your custom theme was added successfully." : (err.localizedDescription ?: @"Unknown error.");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg
        preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    if (ok) [self reloadData];
}

@end
