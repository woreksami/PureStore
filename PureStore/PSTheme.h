#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PSTheme : NSObject <NSCoding, NSSecureCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *themeDescription;
@property (nonatomic, strong) NSString *author;

// Colors (stored as hex strings)
@property (nonatomic, strong) NSString *accentColorHex;
@property (nonatomic, strong) NSString *backgroundColorHex;
@property (nonatomic, strong) NSString *cardColorHex;
@property (nonatomic, strong) NSString *textColorHex;
@property (nonatomic, strong) NSString *subtitleColorHex;

// Computed UIColors
@property (nonatomic, readonly) UIColor *accentColor;
@property (nonatomic, readonly) UIColor *backgroundColor;
@property (nonatomic, readonly) UIColor *cardColor;
@property (nonatomic, readonly) UIColor *textColor;
@property (nonatomic, readonly) UIColor *subtitleColor;

// Style
@property (nonatomic, assign) BOOL useBlurredBackground;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, strong) NSString *iconStyle; // "rounded", "squircle", "circle"

// Unique ID
@property (nonatomic, strong) NSString *identifier;

+ (instancetype)defaultTheme;
+ (instancetype)oceanTheme;
+ (instancetype)sakuraTheme;
+ (instancetype)midnightTheme;
+ (nullable instancetype)themeFromDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
