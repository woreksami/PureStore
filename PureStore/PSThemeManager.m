#import "PSThemeManager.h"

NSString *const PSThemeChangedNotification = @"PSThemeChangedNotification";

@interface PSThemeManager ()
@property (nonatomic, strong) PSTheme *currentTheme;
@property (nonatomic, strong) NSMutableArray<PSTheme *> *mutableCustomThemes;
@end

@implementation PSThemeManager

+ (instancetype)shared {
    static PSThemeManager *s;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ s = [PSThemeManager new]; });
    return s;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _mutableCustomThemes = [NSMutableArray new];
        [self loadThemes];
    }
    return self;
}

- (NSArray<PSTheme *> *)builtinThemes {
    return @[
        [PSTheme defaultTheme],
        [PSTheme oceanTheme],
        [PSTheme sakuraTheme],
        [PSTheme midnightTheme],
    ];
}

- (NSArray<PSTheme *> *)customThemes {
    return [_mutableCustomThemes copy];
}

- (NSArray<PSTheme *> *)allThemes {
    return [self.builtinThemes arrayByAddingObjectsFromArray:_mutableCustomThemes];
}

- (void)applyTheme:(PSTheme *)theme {
    _currentTheme = theme;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:theme.identifier forKey:@"PSActiveThemeID"];
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:PSThemeChangedNotification object:theme];
}

- (BOOL)importThemeFromURL:(NSURL *)url error:(NSError **)error {
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:error];
    if (!data) return NO;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    if (!dict) return NO;
    PSTheme *theme = [PSTheme themeFromDictionary:dict];
    if (!theme) {
        if (error) *error = [NSError errorWithDomain:@"PSTheme" code:1
            userInfo:@{NSLocalizedDescriptionKey: @"Invalid theme file — missing required 'name' field."}];
        return NO;
    }
    // Prevent duplicates
    for (PSTheme *existing in _mutableCustomThemes) {
        if ([existing.identifier isEqualToString:theme.identifier]) {
            [_mutableCustomThemes removeObject:existing];
            break;
        }
    }
    [_mutableCustomThemes addObject:theme];
    [self saveThemes];
    return YES;
}

- (void)deleteCustomTheme:(PSTheme *)theme {
    [_mutableCustomThemes removeObject:theme];
    [self saveThemes];
    if ([_currentTheme.identifier isEqualToString:theme.identifier]) {
        [self applyTheme:[PSTheme defaultTheme]];
    }
}

- (void)saveThemes {
    NSMutableArray *arr = [NSMutableArray new];
    for (PSTheme *t in _mutableCustomThemes) {
        [arr addObject:[t toDictionary]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"PSCustomThemes"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadThemes {
    // Load custom themes
    NSArray *saved = [[NSUserDefaults standardUserDefaults] objectForKey:@"PSCustomThemes"];
    for (NSDictionary *dict in saved) {
        PSTheme *t = [PSTheme themeFromDictionary:dict];
        if (t) [_mutableCustomThemes addObject:t];
    }
    // Load active theme
    NSString *activeID = [[NSUserDefaults standardUserDefaults] objectForKey:@"PSActiveThemeID"];
    _currentTheme = [PSTheme defaultTheme];
    for (PSTheme *t in self.allThemes) {
        if ([t.identifier isEqualToString:activeID]) {
            _currentTheme = t;
            break;
        }
    }
}

@end
