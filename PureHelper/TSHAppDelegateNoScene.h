#import <UIKit/UIKit.h>

@interface PSHAppDelegateNoScene : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UINavigationController *rootViewController;
@end