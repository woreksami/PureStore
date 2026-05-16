#import <UIKit/UIKit.h>
#import "PSTheme.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const PSThemeChangedNotification;

@interface PSThemeManager : NSObject

+ (instancetype)shared;

@property (nonatomic, strong, readonly) PSTheme *currentTheme;
@property (nonatomic, strong, readonly) NSArray<PSTheme *> *allThemes;
@property (nonatomic, strong, readonly) NSArray<PSTheme *> *builtinThemes;
@property (nonatomic, strong, readonly) NSArray<PSTheme *> *customThemes;

- (void)applyTheme:(PSTheme *)theme;
- (BOOL)importThemeFromURL:(NSURL *)url error:(NSError **)error;
- (void)deleteCustomTheme:(PSTheme *)theme;
- (void)saveThemes;

@end

NS_ASSUME_NONNULL_END
