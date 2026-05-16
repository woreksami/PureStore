#import <Foundation/Foundation.h>
#import "PSAppDelegate.h"
#import "PSUtil.h"

NSUserDefaults* pureStoreUserDefaults(void)
{
	return [[NSUserDefaults alloc] initWithSuiteName:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/Preferences/%@.plist", APP_ID]]];
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		chineseWifiFixup();
		return UIApplicationMain(argc, argv, nil, NSStringFromClass(PSAppDelegate.class));
	}
}
