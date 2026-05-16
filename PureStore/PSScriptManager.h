#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// ---- PSScript model ----

@interface PSScript : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *scriptDescription;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *content;   // raw script text
@property (nonatomic, strong) NSString *type;       // "bash", "python", "js"
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong) NSDate   *importedAt;

+ (nullable instancetype)scriptFromDictionary:(NSDictionary *)dict content:(NSString *)content;
- (NSDictionary *)toDictionary;

@end

// ---- PSScriptManager singleton ----

extern NSString *const PSScriptsChangedNotification;

@interface PSScriptManager : NSObject

+ (instancetype)shared;

@property (nonatomic, strong, readonly) NSArray<PSScript *> *scripts;
@property (nonatomic, strong, readonly) NSURL *scriptsDirectory;

- (BOOL)importScriptFromURL:(NSURL *)url error:(NSError **)error;
- (void)deleteScript:(PSScript *)script;
- (void)setEnabled:(BOOL)enabled forScript:(PSScript *)script;
- (void)saveScripts;

@end

NS_ASSUME_NONNULL_END
