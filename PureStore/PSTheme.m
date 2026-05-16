#import "PSTheme.h"

static UIColor *colorFromHex(NSString *hex) {
    if (!hex || hex.length < 6) return UIColor.systemBlueColor;
    NSString *clean = [hex stringByReplacingOccurrencesOfString:@"#" withString:@""];
    unsigned int rgb = 0;
    [[NSScanner scannerWithString:clean] scanHexInt:&rgb];
    return [UIColor colorWithRed:((rgb >> 16) & 0xFF)/255.0
                           green:((rgb >> 8)  & 0xFF)/255.0
                            blue:( rgb        & 0xFF)/255.0
                           alpha:1.0];
}

static NSString *hexFromColor(UIColor *color) {
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [NSString stringWithFormat:@"#%02X%02X%02X",
            (int)(r*255), (int)(g*255), (int)(b*255)];
}

@implementation PSTheme

+ (BOOL)supportsSecureCoding { return YES; }

- (instancetype)init {
    self = [super init];
    if (self) {
        _identifier = [[NSUUID UUID] UUIDString];
        _cornerRadius = 14.0;
        _iconStyle = @"squircle";
        _useBlurredBackground = NO;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [self init];
    if (self) {
        _name              = [coder decodeObjectOfClass:[NSString class] forKey:@"name"];
        _themeDescription  = [coder decodeObjectOfClass:[NSString class] forKey:@"themeDescription"];
        _author            = [coder decodeObjectOfClass:[NSString class] forKey:@"author"];
        _accentColorHex    = [coder decodeObjectOfClass:[NSString class] forKey:@"accentColorHex"];
        _backgroundColorHex= [coder decodeObjectOfClass:[NSString class] forKey:@"backgroundColorHex"];
        _cardColorHex      = [coder decodeObjectOfClass:[NSString class] forKey:@"cardColorHex"];
        _textColorHex      = [coder decodeObjectOfClass:[NSString class] forKey:@"textColorHex"];
        _subtitleColorHex  = [coder decodeObjectOfClass:[NSString class] forKey:@"subtitleColorHex"];
        _iconStyle         = [coder decodeObjectOfClass:[NSString class] forKey:@"iconStyle"];
        _identifier        = [coder decodeObjectOfClass:[NSString class] forKey:@"identifier"];
        _useBlurredBackground = [coder decodeBoolForKey:@"useBlurredBackground"];
        _cornerRadius      = [coder decodeDoubleForKey:@"cornerRadius"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_name              forKey:@"name"];
    [coder encodeObject:_themeDescription  forKey:@"themeDescription"];
    [coder encodeObject:_author            forKey:@"author"];
    [coder encodeObject:_accentColorHex    forKey:@"accentColorHex"];
    [coder encodeObject:_backgroundColorHex forKey:@"backgroundColorHex"];
    [coder encodeObject:_cardColorHex      forKey:@"cardColorHex"];
    [coder encodeObject:_textColorHex      forKey:@"textColorHex"];
    [coder encodeObject:_subtitleColorHex  forKey:@"subtitleColorHex"];
    [coder encodeObject:_iconStyle         forKey:@"iconStyle"];
    [coder encodeObject:_identifier        forKey:@"identifier"];
    [coder encodeBool:_useBlurredBackground forKey:@"useBlurredBackground"];
    [coder encodeDouble:_cornerRadius      forKey:@"cornerRadius"];
}

- (UIColor *)accentColor     { return colorFromHex(_accentColorHex); }
- (UIColor *)backgroundColor { return colorFromHex(_backgroundColorHex); }
- (UIColor *)cardColor       { return colorFromHex(_cardColorHex); }
- (UIColor *)textColor       { return colorFromHex(_textColorHex); }
- (UIColor *)subtitleColor   { return colorFromHex(_subtitleColorHex); }

#pragma mark - Built-in Themes

+ (instancetype)defaultTheme {
    PSTheme *t = [PSTheme new];
    t.name = @"Pure";
    t.themeDescription = @"The default PureStore look — clean, crisp, and minimal.";
    t.author = @"PureStore";
    t.accentColorHex     = @"#3B82F6";
    t.backgroundColorHex = @"#F0F4FF";
    t.cardColorHex       = @"#FFFFFF";
    t.textColorHex       = @"#1E1E2E";
    t.subtitleColorHex   = @"#6B7280";
    t.useBlurredBackground = NO;
    t.cornerRadius = 14;
    t.iconStyle = @"squircle";
    t.identifier = @"builtin.pure";
    return t;
}

+ (instancetype)oceanTheme {
    PSTheme *t = [PSTheme new];
    t.name = @"Ocean";
    t.themeDescription = @"Deep blues and teals, calm like the sea.";
    t.author = @"PureStore";
    t.accentColorHex     = @"#06B6D4";
    t.backgroundColorHex = @"#0A1628";
    t.cardColorHex       = @"#0F2240";
    t.textColorHex       = @"#E0F2FE";
    t.subtitleColorHex   = @"#7DD3FC";
    t.useBlurredBackground = YES;
    t.cornerRadius = 16;
    t.iconStyle = @"rounded";
    t.identifier = @"builtin.ocean";
    return t;
}

+ (instancetype)sakuraTheme {
    PSTheme *t = [PSTheme new];
    t.name = @"Sakura";
    t.themeDescription = @"Soft pinks and blossoms for a gentle vibe.";
    t.author = @"PureStore";
    t.accentColorHex     = @"#F472B6";
    t.backgroundColorHex = @"#FFF0F6";
    t.cardColorHex       = @"#FFE4EF";
    t.textColorHex       = @"#3D1A2E";
    t.subtitleColorHex   = @"#BE185D";
    t.useBlurredBackground = NO;
    t.cornerRadius = 18;
    t.iconStyle = @"circle";
    t.identifier = @"builtin.sakura";
    return t;
}

+ (instancetype)midnightTheme {
    PSTheme *t = [PSTheme new];
    t.name = @"Midnight";
    t.themeDescription = @"Pure black OLED-friendly darkness.";
    t.author = @"PureStore";
    t.accentColorHex     = @"#A78BFA";
    t.backgroundColorHex = @"#000000";
    t.cardColorHex       = @"#0D0D0D";
    t.textColorHex       = @"#F8F8FF";
    t.subtitleColorHex   = @"#6D6D80";
    t.useBlurredBackground = YES;
    t.cornerRadius = 12;
    t.iconStyle = @"squircle";
    t.identifier = @"builtin.midnight";
    return t;
}

#pragma mark - JSON Import/Export

+ (nullable instancetype)themeFromDictionary:(NSDictionary *)dict {
    if (!dict[@"name"]) return nil;
    PSTheme *t = [PSTheme new];
    t.name              = dict[@"name"] ?: @"Custom Theme";
    t.themeDescription  = dict[@"description"] ?: @"";
    t.author            = dict[@"author"] ?: @"Unknown";
    t.accentColorHex    = dict[@"accentColor"]     ?: @"#3B82F6";
    t.backgroundColorHex= dict[@"backgroundColor"] ?: @"#F0F4FF";
    t.cardColorHex      = dict[@"cardColor"]       ?: @"#FFFFFF";
    t.textColorHex      = dict[@"textColor"]       ?: @"#1E1E2E";
    t.subtitleColorHex  = dict[@"subtitleColor"]   ?: @"#6B7280";
    t.useBlurredBackground = [dict[@"blurredBackground"] boolValue];
    t.cornerRadius      = dict[@"cornerRadius"] ? [dict[@"cornerRadius"] doubleValue] : 14.0;
    t.iconStyle         = dict[@"iconStyle"] ?: @"squircle";
    t.identifier        = dict[@"identifier"] ?: [[NSUUID UUID] UUIDString];
    return t;
}

- (NSDictionary *)toDictionary {
    return @{
        @"name":               _name ?: @"",
        @"description":        _themeDescription ?: @"",
        @"author":             _author ?: @"",
        @"accentColor":        _accentColorHex ?: @"#3B82F6",
        @"backgroundColor":    _backgroundColorHex ?: @"#F0F4FF",
        @"cardColor":          _cardColorHex ?: @"#FFFFFF",
        @"textColor":          _textColorHex ?: @"#1E1E2E",
        @"subtitleColor":      _subtitleColorHex ?: @"#6B7280",
        @"blurredBackground":  @(_useBlurredBackground),
        @"cornerRadius":       @(_cornerRadius),
        @"iconStyle":          _iconStyle ?: @"squircle",
        @"identifier":         _identifier ?: @"",
    };
}

@end
