
#import "SKYBigTransfersManagerImplementation.h"

#import "SKYItem+Extras.h"
#import "SKYNotificationNames.h"
#import "SKYConfig.h"

#import <AFNetworking/AFNetworkReachabilityManager.h>

@interface SKYBigTransfersManagerImplementation ()

@property (nonatomic, strong) NSMutableArray *deniedBigFiles;

@end

@implementation SKYBigTransfersManagerImplementation

- (NSMutableArray *)deniedBigFiles
{
	if (_deniedBigFiles == nil) {
		_deniedBigFiles = [NSMutableArray array];
	}
	
	return _deniedBigFiles;
}

- (void)manageDownloadForFile:(SKYItem *)item completion:(void (^)(BOOL download))completion
{
	
	if (item.isFavourite.boolValue == YES) {
		completion(YES);
	}
	else if ([AFNetworkReachabilityManager sharedManager].reachableViaWiFi == YES) {
		completion(YES);
	}
	else if ([self.deniedBigFiles containsObject:item.fullPath] == YES) {
		completion(NO);
	}
    else if (item.fileSize.unsignedLongLongValue > 20 * 1024 * 1024 && [SKYConfig bigFilesWarningEnabled]) {
        NSString *message = NSLocalizedString(@"You are about to download 20MB over mobile network. Depending on your data plan this might be expensive.", @"Confirmation to download big file over cellular.");
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Generic cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            [self.deniedBigFiles addObject:item.fullPath];
            
            // so it remembers the decision for some time
            [self.deniedBigFiles performSelector:@selector(removeObject:) withObject:item.fullPath afterDelay:5.f];
            
            completion(NO);
        }]];
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Continue", @"Generic continue") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            completion(YES);
        }]];
        
        // so any interaction can finish
        [self performSelector:@selector(displayAlertController:) withObject:controller afterDelay:0.1];
    } else {
        completion(YES);
    }
}

- (void)manageUploadForFileWithSize:(unsigned long long)size completion:(void (^)(BOOL upload))completion
{
	if ([AFNetworkReachabilityManager sharedManager].reachableViaWiFi == YES) {
		completion(YES);
	}
    else if (size > 20 * 1024 * 1024 && [SKYConfig bigFilesWarningEnabled]) {
        NSString *message = NSLocalizedString(@"You are about to upload 20MB over mobile network. Depending on your data plan this might be expensive.", @"Confirmation to upload big file over cellular.");
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Generic cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            completion(NO);
        }]];
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Continue", @"Generic continue") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            completion(YES);
        }]];
        
        // so any interaction can finish
        [self performSelector:@selector(displayAlertController:) withObject:controller afterDelay:0.1];
    } else {
        completion(YES);
    }
}

- (BOOL)canDownloadFavouriteFile:(SKYItem *)item
{
	if ([AFNetworkReachabilityManager sharedManager].reachableViaWiFi == YES) {
		return YES;
	}
	else if (item.fileSize.unsignedLongLongValue > 20 * 1024 * 1024) {
		return NO;
	}
	else {
		return YES;
	}
}

- (void)displayAlertController:(UIAlertController *)controller
{
	[[NSNotificationCenter defaultCenter] postNotificationName:SKYDisplayAlertVCNotification object:controller];
}

@end
