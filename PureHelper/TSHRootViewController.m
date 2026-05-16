#import "PSHRootViewController.h"
#import <PSUtil.h>
#import <PSPresentationDelegate.h>

@implementation PSHRootViewController

- (BOOL)isPureStore
{
	return NO;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	PSPresentationDelegate.presentationViewController = self;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSpecifiers) name:UIApplicationWillEnterForegroundNotification object:nil];

	fetchLatestPureStoreVersion(^(NSString* latestVersion)
	{
		NSString* currentVersion = [self getPureStoreVersion];
		NSComparisonResult result = [currentVersion compare:latestVersion options:NSNumericSearch];
		if(result == NSOrderedAscending)
		{
			_newerVersion = latestVersion;
			dispatch_async(dispatch_get_main_queue(), ^
			{
				[self reloadSpecifiers];
			});
		}
	});
}

- (NSMutableArray*)specifiers
{
	if(!_specifiers)
	{
		_specifiers = [NSMutableArray new];

		#ifdef LEGACY_CT_BUG
		NSString* credits = @"Powered by Fugu15 CoreTrust & installd bugs, thanks to @LinusHenze\n\n© 2022-2026 Lars Fröder (opa334)";
		#else
		NSString* credits = @"Powered by CVE-2023-41991, originally discovered by Google TAG, rediscovered via patchdiffing by @alfiecg_dev\n\n© 2022-2026 Lars Fröder (opa334)";
		#endif

		PSSpecifier* infoGroupSpecifier = [PSSpecifier emptyGroupSpecifier];
		infoGroupSpecifier.name = @"Info";
		[_specifiers addObject:infoGroupSpecifier];

		PSSpecifier* infoSpecifier = [PSSpecifier preferenceSpecifierNamed:@"PureStore"
											target:self
											set:nil
											get:@selector(getPureStoreInfoString)
											detail:nil
											cell:PSTitleValueCell
											edit:nil];
		infoSpecifier.identifier = @"info";
		[infoSpecifier setProperty:@YES forKey:@"enabled"];

		[_specifiers addObject:infoSpecifier];

		BOOL isInstalled = trollStoreAppPath();

		if(_newerVersion && isInstalled)
		{
			// Update PureStore
			PSSpecifier* updatePureStoreSpecifier = [PSSpecifier preferenceSpecifierNamed:[NSString stringWithFormat:@"Update PureStore to %@", _newerVersion]
										target:self
										set:nil
										get:nil
										detail:nil
										cell:PSButtonCell
										edit:nil];
			updatePureStoreSpecifier.identifier = @"updatePureStore";
			[updatePureStoreSpecifier setProperty:@YES forKey:@"enabled"];
			updatePureStoreSpecifier.buttonAction = @selector(updatePureStorePressed);
			[_specifiers addObject:updatePureStoreSpecifier];
		}

		PSSpecifier* lastGroupSpecifier;

		PSSpecifier* utilitiesGroupSpecifier = [PSSpecifier emptyGroupSpecifier];
		[_specifiers addObject:utilitiesGroupSpecifier];

		lastGroupSpecifier = utilitiesGroupSpecifier;

		if(isInstalled || trollStoreInstalledAppContainerPaths().count)
		{
			PSSpecifier* refreshAppRegistrationsSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Refresh App Registrations"
												target:self
												set:nil
												get:nil
												detail:nil
												cell:PSButtonCell
												edit:nil];
			refreshAppRegistrationsSpecifier.identifier = @"refreshAppRegistrations";
			[refreshAppRegistrationsSpecifier setProperty:@YES forKey:@"enabled"];
			refreshAppRegistrationsSpecifier.buttonAction = @selector(refreshAppRegistrationsPressed);
			[_specifiers addObject:refreshAppRegistrationsSpecifier];
		}
		if(isInstalled)
		{
			PSSpecifier* uninstallPureStoreSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Uninstall PureStore"
										target:self
										set:nil
										get:nil
										detail:nil
										cell:PSButtonCell
										edit:nil];
			uninstallPureStoreSpecifier.identifier = @"uninstallPureStore";
			[uninstallPureStoreSpecifier setProperty:@YES forKey:@"enabled"];
			[uninstallPureStoreSpecifier setProperty:NSClassFromString(@"PSDeleteButtonCell") forKey:@"cellClass"];
			uninstallPureStoreSpecifier.buttonAction = @selector(uninstallPureStorePressed);
			[_specifiers addObject:uninstallPureStoreSpecifier];
		}
		else
		{
			PSSpecifier* installPureStoreSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Install PureStore"
												target:self
												set:nil
												get:nil
												detail:nil
												cell:PSButtonCell
												edit:nil];
			installPureStoreSpecifier.identifier = @"installPureStore";
			[installPureStoreSpecifier setProperty:@YES forKey:@"enabled"];
			installPureStoreSpecifier.buttonAction = @selector(installPureStorePressed);
			[_specifiers addObject:installPureStoreSpecifier];
		}

		NSString* backupPath = [getExecutablePath() stringByAppendingString:@"_TROLLSTORE_BACKUP"];
		if([[NSFileManager defaultManager] fileExistsAtPath:backupPath])
		{
			PSSpecifier* uninstallHelperGroupSpecifier = [PSSpecifier emptyGroupSpecifier];
			[_specifiers addObject:uninstallHelperGroupSpecifier];
			lastGroupSpecifier = uninstallHelperGroupSpecifier;

			PSSpecifier* uninstallPersistenceHelperSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Uninstall Persistence Helper"
												target:self
												set:nil
												get:nil
												detail:nil
												cell:PSButtonCell
												edit:nil];
			uninstallPersistenceHelperSpecifier.identifier = @"uninstallPersistenceHelper";
			[uninstallPersistenceHelperSpecifier setProperty:@YES forKey:@"enabled"];
			[uninstallPersistenceHelperSpecifier setProperty:NSClassFromString(@"PSDeleteButtonCell") forKey:@"cellClass"];
			uninstallPersistenceHelperSpecifier.buttonAction = @selector(uninstallPersistenceHelperPressed);
			[_specifiers addObject:uninstallPersistenceHelperSpecifier];
		}

		#ifdef EMBEDDED_ROOT_HELPER
		LSApplicationProxy* persistenceHelperProxy = findPersistenceHelperApp(PERSISTENCE_HELPER_TYPE_ALL);
		BOOL isRegistered = [persistenceHelperProxy.bundleIdentifier isEqualToString:NSBundle.mainBundle.bundleIdentifier];

		if((isRegistered || !persistenceHelperProxy) && ![[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/PureStorePersistenceHelper.app"])
		{
			PSSpecifier* registerUnregisterGroupSpecifier = [PSSpecifier emptyGroupSpecifier];
			lastGroupSpecifier = nil;

			NSString* bottomText;
			PSSpecifier* registerUnregisterSpecifier;

			if(isRegistered)
			{
				bottomText = @"This app is registered as the PureStore persistence helper and can be used to fix PureStore app registrations in case they revert back to \"User\" state and the apps say they're unavailable.";
				registerUnregisterSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Unregister Persistence Helper"
												target:self
												set:nil
												get:nil
												detail:nil
												cell:PSButtonCell
												edit:nil];
				registerUnregisterSpecifier.identifier = @"registerUnregisterSpecifier";
				[registerUnregisterSpecifier setProperty:@YES forKey:@"enabled"];
				[registerUnregisterSpecifier setProperty:NSClassFromString(@"PSDeleteButtonCell") forKey:@"cellClass"];
				registerUnregisterSpecifier.buttonAction = @selector(unregisterPersistenceHelperPressed);
			}
			else if(!persistenceHelperProxy)
			{
				bottomText = @"If you want to use this app as the PureStore persistence helper, you can register it here.";
				registerUnregisterSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Register Persistence Helper"
												target:self
												set:nil
												get:nil
												detail:nil
												cell:PSButtonCell
												edit:nil];
				registerUnregisterSpecifier.identifier = @"registerUnregisterSpecifier";
				[registerUnregisterSpecifier setProperty:@YES forKey:@"enabled"];
				registerUnregisterSpecifier.buttonAction = @selector(registerPersistenceHelperPressed);
			}

			[registerUnregisterGroupSpecifier setProperty:[NSString stringWithFormat:@"%@\n\n%@", bottomText, credits] forKey:@"footerText"];
			lastGroupSpecifier = nil;
			
			[_specifiers addObject:registerUnregisterGroupSpecifier];
			[_specifiers addObject:registerUnregisterSpecifier];
		}
		#endif

		if(lastGroupSpecifier)
		{
			[lastGroupSpecifier setProperty:credits forKey:@"footerText"];
		}
	}
	
	[(UINavigationItem *)self.navigationItem setTitle:@"PureStore Helper"];
	return _specifiers;
}

- (NSString*)getPureStoreInfoString
{
	NSString* version = [self getPureStoreVersion];
	if(!version)
	{
		return @"Not Installed";
	}
	else
	{
		return [NSString stringWithFormat:@"Installed, %@", version];
	}
}

- (void)handleUninstallation
{
	_newerVersion = nil;
	[super handleUninstallation];
}

- (void)registerPersistenceHelperPressed
{
	int ret = spawnRoot(rootHelperPath(), @[@"register-user-persistence-helper", NSBundle.mainBundle.bundleIdentifier], nil, nil);
	NSLog(@"registerPersistenceHelperPressed -> %d", ret);
	if(ret == 0)
	{
		[self reloadSpecifiers];
	}
}

- (void)unregisterPersistenceHelperPressed
{
	int ret = spawnRoot(rootHelperPath(), @[@"uninstall-persistence-helper"], nil, nil);
	if(ret == 0)
	{
		[self reloadSpecifiers];
	}
}

@end
