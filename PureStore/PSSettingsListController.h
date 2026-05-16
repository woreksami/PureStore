#import "PSListControllerShared.h"

@interface PSSettingsListController : PSListControllerShared
{
    PSSpecifier* _installPersistenceHelperSpecifier;
    NSString* _newerVersion;
    NSString* _newerLdidVersion;
    BOOL _devModeEnabled;
}
@end