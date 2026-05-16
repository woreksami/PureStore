#import "PSScriptsViewController.h"
#import "PSScriptManager.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface PSScriptsViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<PSScript *> *scripts;
@end

@implementation PSScriptsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Scripts";
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];

    UIBarButtonItem *importBtn = [[UIBarButtonItem alloc]
        initWithTitle:@"Import"
                style:UIBarButtonItemStylePlain
               target:self
               action:@selector(importScriptTapped)];
    self.navigationItem.rightBarButtonItem = importBtn;

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    _tableView.delegate   = self;
    _tableView.dataSource = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableView];

    [self reloadData];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:PSScriptsChangedNotification object:nil];
}

- (void)reloadData {
    _scripts = [PSScriptManager shared].scripts;
    [_tableView reloadData];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 2; }

- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section {
    return section == 0 ? @"User Scripts" : nil;
}

- (NSString *)tableView:(UITableView *)tv titleForFooterInSection:(NSInteger)section {
    if (section == 0) return @"Import .psscript or .sh files. Scripts run in a sandboxed environment.";
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return MAX(_scripts.count, 1);
    return 1; // Info row
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = @"Script File Format Guide";
        cell.textLabel.textColor = [UIColor systemBlueColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }

    if (_scripts.count == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.textLabel.text = @"No scripts imported";
        cell.detailTextLabel.text = @"Tap Import to add a script";
        cell.textLabel.textColor = [UIColor secondaryLabelColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }

    PSScript *script = _scripts[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScriptCell"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ScriptCell"];

    cell.textLabel.text = script.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ • v%@ by %@",
                                 script.type.uppercaseString, script.version, script.author];

    // Toggle switch
    UISwitch *sw = [[UISwitch alloc] init];
    sw.on = script.enabled;
    sw.tag = indexPath.row;
    [sw addTarget:self action:@selector(toggleScript:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = sw;

    // Type badge color
    UIColor *badgeColor;
    if ([script.type isEqualToString:@"python"])      badgeColor = [UIColor systemYellowColor];
    else if ([script.type isEqualToString:@"js"])     badgeColor = [UIColor systemOrangeColor];
    else                                               badgeColor = [UIColor systemGreenColor];

    UIView *badge = [[UIView alloc] initWithFrame:CGRectMake(0,0,8,8)];
    badge.backgroundColor = badgeColor;
    badge.layer.cornerRadius = 4;
    badge.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:badge];
    [NSLayoutConstraint activateConstraints:@[
        [badge.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
        [badge.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:16],
        [badge.widthAnchor constraintEqualToConstant:8],
        [badge.heightAnchor constraintEqualToConstant:8],
    ]];
    cell.separatorInset = UIEdgeInsetsMake(0, 34, 0, 0);

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        [self showFormatGuide];
        return;
    }
    if (_scripts.count == 0) return;
    PSScript *script = _scripts[indexPath.row];
    [self showScriptDetail:script];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0 || _scripts.count == 0) return nil;
    PSScript *script = _scripts[indexPath.row];
    UIContextualAction *del = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
        title:@"Delete" handler:^(UIContextualAction *a, UIView *v, void(^done)(BOOL)) {
            [[PSScriptManager shared] deleteScript:script];
            [self reloadData];
            done(YES);
        }];
    return [UISwipeActionsConfiguration configurationWithActions:@[del]];
}

- (void)toggleScript:(UISwitch *)sw {
    if ((NSInteger)sw.tag >= (NSInteger)_scripts.count) return;
    PSScript *script = _scripts[sw.tag];
    [[PSScriptManager shared] setEnabled:sw.isOn forScript:script];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - Script Detail

- (void)showScriptDetail:(PSScript *)script {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:script.name
        message:[NSString stringWithFormat:@"Type: %@\nAuthor: %@\nVersion: %@\n\n%@",
                 script.type, script.author, script.version, script.scriptDescription]
        preferredStyle:UIAlertControllerStyleAlert];

    [ac addAction:[UIAlertAction actionWithTitle:@"View Content" style:UIAlertActionStyleDefault handler:^(id _) {
        UIAlertController *view = [UIAlertController alertControllerWithTitle:@"Script Content"
            message:([script.content length] > 500 ?
                     [[script.content substringToIndex:500] stringByAppendingString:@"\n…(truncated)"]
                     : script.content)
            preferredStyle:UIAlertControllerStyleAlert];
        [view addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:view animated:YES completion:nil];
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

#pragma mark - Format Guide

- (void)showFormatGuide {
    NSString *guide = @"PureStore accepts .psscript or .sh files.\n\n"
    @"JSON Format (recommended):\n"
    @"{\n"
    @"  \"name\": \"My Script\",\n"
    @"  \"description\": \"Does cool stuff\",\n"
    @"  \"author\": \"You\",\n"
    @"  \"version\": \"1.0\",\n"
    @"  \"type\": \"bash\",\n"
    @"  \"content\": \"#!/bin/bash\\necho Hello\"\n"
    @"}\n\n"
    @"Frontmatter Format:\n"
    @"Paste JSON metadata, then a line with --- alone, then your script content.";

    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Script Format" message:guide
        preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"Got it" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

#pragma mark - Import

- (void)importScriptTapped {
    UTType *psscript = [UTType typeWithIdentifier:@"public.data"];
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc]
        initForOpeningContentTypes:@[psscript, UTTypeShellScript, UTTypePlainText] asCopy:YES];
    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *url = urls.firstObject;
    if (!url) return;
    NSError *err;
    BOOL ok = [[PSScriptManager shared] importScriptFromURL:url error:&err];
    NSString *title = ok ? @"Script Imported!" : @"Import Failed";
    NSString *msg   = ok ? @"Script added to PureStore." : (err.localizedDescription ?: @"Unknown error.");
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:msg
        preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
    if (ok) [self reloadData];
}

@end
