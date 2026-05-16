#import "PSScriptManager.h"

NSString *const PSScriptsChangedNotification = @"PSScriptsChangedNotification";

// ---- PSScript ----

@implementation PSScript

- (instancetype)init {
    self = [super init];
    if (self) {
        _identifier = [[NSUUID UUID] UUIDString];
        _importedAt = [NSDate date];
        _enabled = YES;
        _type = @"bash";
    }
    return self;
}

+ (nullable instancetype)scriptFromDictionary:(NSDictionary *)dict content:(NSString *)content {
    PSScript *s = [PSScript new];
    s.name              = dict[@"name"] ?: @"Unnamed Script";
    s.scriptDescription = dict[@"description"] ?: @"";
    s.author            = dict[@"author"] ?: @"Unknown";
    s.version           = dict[@"version"] ?: @"1.0";
    s.identifier        = dict[@"identifier"] ?: [[NSUUID UUID] UUIDString];
    s.type              = dict[@"type"] ?: @"bash";
    s.content           = content;
    return s;
}

- (NSDictionary *)toDictionary {
    return @{
        @"name":        _name ?: @"",
        @"description": _scriptDescription ?: @"",
        @"author":      _author ?: @"",
        @"version":     _version ?: @"1.0",
        @"identifier":  _identifier ?: @"",
        @"type":        _type ?: @"bash",
        @"enabled":     @(_enabled),
    };
}

@end

// ---- PSScriptManager ----

@interface PSScriptManager ()
@property (nonatomic, strong) NSMutableArray<PSScript *> *mutableScripts;
@end

@implementation PSScriptManager

+ (instancetype)shared {
    static PSScriptManager *s;
    static dispatch_once_t t;
    dispatch_once(&t, ^{ s = [PSScriptManager new]; });
    return s;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _mutableScripts = [NSMutableArray new];
        [self ensureScriptsDirectory];
        [self loadScripts];
    }
    return self;
}

- (NSArray<PSScript *> *)scripts { return [_mutableScripts copy]; }

- (NSURL *)scriptsDirectory {
    NSURL *docs = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    return [docs URLByAppendingPathComponent:@"PureScripts" isDirectory:YES];
}

- (void)ensureScriptsDirectory {
    NSError *err;
    [NSFileManager.defaultManager createDirectoryAtURL:self.scriptsDirectory
                           withIntermediateDirectories:YES attributes:nil error:&err];
}

- (BOOL)importScriptFromURL:(NSURL *)url error:(NSError **)error {
    // Expect a .psscript file: JSON frontmatter + "---" separator + script content
    NSString *raw = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:error];
    if (!raw) return NO;

    // Try JSON-only first (just a dict with a "content" key)
    NSData *rawData = [raw dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:rawData options:0 error:nil];
    NSString *content = nil;
    NSDictionary *meta = nil;

    if (jsonDict) {
        meta    = jsonDict;
        content = jsonDict[@"content"] ?: @"";
    } else {
        // Try "---" separator format
        NSRange sep = [raw rangeOfString:@"\n---\n"];
        if (sep.location == NSNotFound) {
            // Plain script file, no metadata
            meta    = @{@"name": url.lastPathComponent, @"type": @"bash"};
            content = raw;
        } else {
            NSString *jsonPart = [raw substringToIndex:sep.location];
            content  = [raw substringFromIndex:sep.location + sep.length];
            NSData *jsonData = [jsonPart dataUsingEncoding:NSUTF8StringEncoding];
            meta = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil] ?: @{@"name": url.lastPathComponent};
        }
    }

    PSScript *script = [PSScript scriptFromDictionary:meta content:content];
    if (!script) {
        if (error) *error = [NSError errorWithDomain:@"PSScript" code:1
            userInfo:@{NSLocalizedDescriptionKey: @"Could not parse script file."}];
        return NO;
    }

    // Remove duplicate
    [_mutableScripts filterUsingPredicate:
        [NSPredicate predicateWithFormat:@"identifier != %@", script.identifier]];
    [_mutableScripts addObject:script];

    // Save content file
    NSURL *destURL = [self.scriptsDirectory URLByAppendingPathComponent:
                      [NSString stringWithFormat:@"%@.script", script.identifier]];
    [content writeToURL:destURL atomically:YES encoding:NSUTF8StringEncoding error:nil];

    [self saveScripts];
    [[NSNotificationCenter defaultCenter] postNotificationName:PSScriptsChangedNotification object:script];
    return YES;
}

- (void)deleteScript:(PSScript *)script {
    [_mutableScripts removeObject:script];
    NSURL *file = [self.scriptsDirectory URLByAppendingPathComponent:
                   [NSString stringWithFormat:@"%@.script", script.identifier]];
    [NSFileManager.defaultManager removeItemAtURL:file error:nil];
    [self saveScripts];
    [[NSNotificationCenter defaultCenter] postNotificationName:PSScriptsChangedNotification object:nil];
}

- (void)setEnabled:(BOOL)enabled forScript:(PSScript *)script {
    script.enabled = enabled;
    [self saveScripts];
}

- (void)saveScripts {
    NSMutableArray *arr = [NSMutableArray new];
    for (PSScript *s in _mutableScripts) [arr addObject:[s toDictionary]];
    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"PSScripts"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadScripts {
    NSArray *saved = [[NSUserDefaults standardUserDefaults] objectForKey:@"PSScripts"];
    for (NSDictionary *dict in saved) {
        // Load content from file
        NSString *ident = dict[@"identifier"];
        if (!ident) continue;
        NSURL *file = [self.scriptsDirectory URLByAppendingPathComponent:
                       [NSString stringWithFormat:@"%@.script", ident]];
        NSString *content = [NSString stringWithContentsOfURL:file encoding:NSUTF8StringEncoding error:nil] ?: @"";
        PSScript *s = [PSScript scriptFromDictionary:dict content:content];
        if (s) {
            s.enabled = [dict[@"enabled"] boolValue];
            [_mutableScripts addObject:s];
        }
    }
}

@end
