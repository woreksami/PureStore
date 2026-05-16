#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface PSListControllerShared : PSListController
- (BOOL)isPureStore;
- (NSString*)getPureStoreVersion;
- (void)downloadPureStoreAndRun:(void (^)(NSString* localPureStoreTarPath))doHandler;
- (void)installPureStorePressed;
- (void)updatePureStorePressed;
- (void)rebuildIconCachePressed;
- (void)refreshAppRegistrationsPressed;
- (void)uninstallPersistenceHelperPressed;
- (void)handleUninstallation;
- (NSMutableArray*)argsForUninstallingPureStore;
- (void)uninstallPureStorePressed;
@end