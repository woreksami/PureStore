#import <UIKit/UIKit.h>
#import "PSAppInfo.h"
#import <CoreServices.h>

@interface PSAppTableViewController : UITableViewController <UISearchResultsUpdating, UIDocumentPickerDelegate, LSApplicationWorkspaceObserverProtocol>
{
    UIImage* _placeholderIcon;
    NSArray<PSAppInfo*>* _cachedAppInfos;
    NSMutableDictionary* _cachedIcons;
    UISearchController* _searchController;
	NSString* _searchKey;
}

@end