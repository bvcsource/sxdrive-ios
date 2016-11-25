//
//  SKYSetupWizardController.m
//  SXDrive
//
//  Created by Skylable on 4/21/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYSetupWizardController.h"
#import "SKYInfoKeys.h"
#import "SKYNotificationNames.h"
#import "SKYSetupWizardInputCell.h"
#import "SKYSetupWizardToggleCell.h"
#import "SKYSXKeyManager.h"
#import "UIColor+SKYColor.h"
#import <SSKeychain/SSKeychain.h>
#import "SKYUserImplementation.h"
#import "SKYConfig.h"

typedef enum {
    kModePlain,
    kModeAdvanced
} SKYSetupWizardMode;

NSString *const kInputCellReuseIdentifier = @"inputCell";
NSString *const kToggleCellReuseIdentifier = @"toggleCell";

#define kDefaultPortForSSLOn @"443"
#define kDefaultPortForSSLOff @"80"

#define kSection1TitleForHeader @"sx server"
#define kSection2TitleForHeader @"advanced settings"
#define kSection3TitleForHeader @"credentials"

#define kServerAddressTitle @"Server address"
#define kAdvancedSettingsTitle @"Advanced settings"
#define kSSLEncryptionTitle @"SSL encryption"
#define kPortTitle @"Port"
#define kIPAddressTitle @"IP address"
#define kUsernameTitle @"User"
#define kPasswordTitle @"Password"
#define kShowPasswordTitle @"Show password"

@interface SKYSetupWizardResult : NSObject

@property (nonatomic, strong) NSString *serverAddress;
@property (nonatomic, assign) BOOL advancedSettings;
@property (nonatomic, assign) BOOL SSLEncryption;
@property (nonatomic, strong) NSString *port;
@property (nonatomic, strong) NSString *IPAddress;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *key;

- (NSString *)host;

- (void)log;

@end

@implementation SKYSetupWizardResult

- (id)init {
    self = [super init];
    if (self) {
        self.advancedSettings = NO;
        self.SSLEncryption = YES;
        self.port = kDefaultPortForSSLOn;
        
        NSString *serverAddress = [SSKeychain passwordForService:SKYUserKeychainSXDriveService account:SKYUserKeychainHostAccount];
        NSString *IPAddress = [SSKeychain passwordForService:SKYUserKeychainSXDriveService account:SKYUserKeychainServerAccount];
        NSString *port = [SSKeychain passwordForService:SKYUserKeychainSXDriveService account:SKYUserKeychainPortAccount];
        BOOL SSLEncryption = [SSKeychain passwordForService:SKYUserKeychainSXDriveService account:SKYUserKeychainSSLAccount].boolValue;
        
        if ([serverAddress length] > 0) {
            self.serverAddress = serverAddress;
            if (![serverAddress isEqualToString:IPAddress] || !SSLEncryption || ![port isEqualToString:kDefaultPortForSSLOn]) {
                self.advancedSettings = YES;
                self.SSLEncryption = SSLEncryption;
                self.port = port;
                if (![serverAddress isEqualToString:IPAddress]) {
                    self.IPAddress = IPAddress;
                }
            }
        }
    }
    return self;
}

#pragma mark - Auxiliary

- (NSString *)host {
    NSString *prefix = self.SSLEncryption ? @"https":@"http";
    NSString *result = [NSString stringWithFormat:@"%@://%@:%@", prefix, [self.IPAddress length] > 0 ? self.IPAddress:self.serverAddress, self.port];
    
    return result;
}

- (void)log {
    NSLog(@"%@\n%@\n%@\n%@\n%@\n%@\n%@",self.serverAddress, self.advancedSettings ? @"YES":@"NO", self.SSLEncryption ? @"YES":@"NO", self.port, self.IPAddress, self.username, self.password);
}

@end

@interface SKYSetupWizardController ()

/**
 * Property for accessing the setup wizard behaviour.
 */
@property (weak, nonatomic, readonly) id <SKYSetupWizardBehaviour> setupWizardBehaviour;

@property (nonatomic, assign) SKYSetupWizardMode mode;
@property (nonatomic, strong) SKYSetupWizardResult *result;
@property (nonatomic, weak) UITextField *activeTextField;

- (void)_initBarButtonItems;
- (void)_registerCellNibs;
- (SKYSetupWizardCellType)_cellTypeForIndexPath:(NSIndexPath *)indexPath;
- (void)_updateMode:(SKYSetupWizardMode)mode;
- (BOOL)_canProceed;
- (void)_updateControls;
- (NSURL *)_resultURL;
- (void)_startLogIn;

@end

@implementation SKYSetupWizardController

@synthesize logInInProgress = _logInInProgress;

#pragma mark - View life

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.result = [[SKYSetupWizardResult alloc] init];
    [self _updateMode:self.result.advancedSettings ? kModeAdvanced:kModePlain];
    
    [self _initBarButtonItems];
    [self _registerCellNibs];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Convenience accessors

- (id <SKYSetupWizardBehaviour>)setupWizardBehaviour
{
    return (id <SKYSetupWizardBehaviour>)self.baseBehaviour;
}

#pragma mark - Base controller

- (SKYViewType)viewType {
    return SKYViewTypeSetupWizard;
}

#pragma mark - Setup wizard behaviour presenter

- (void)stopLogin {
    self.logInInProgress = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log In" style:UIBarButtonItemStylePlain target:self action:@selector(LogInAction:)];
}

- (void)loginDidFinish {
    [self.setupWizardBehaviour.viewNavigator closeViewController:self];
}

#pragma mark - Actions

- (void)cancelAction:(id)sender {
    [self stopLogin];
    [self.setupWizardBehaviour.viewNavigator closeViewController:self];
}

- (void)LogInAction:(id)sender {
//    [self.result log];
//    NSLog(@"url: %@", [self _resultURL]);
//    return;
    
    [self _startLogIn];
    SKYSXKeyManager *manager = [SKYSXKeyManager manager];
    
//    NSLog(@"HOST: %@", [self.result host]);
//    [self stopLogin];
//    return;
    
    [manager retrieveClusterUUIDForHost:[self.result host] success:^(NSString *uuid) {
        [manager generateKeyForClusterUUID:uuid username:self.result.username password:self.result.password completion:^(BOOL status, NSString *key) {
            if (status) {
                [SSKeychain setPassword:self.result.username
                             forService:SKYUserKeychainSXDriveService
                                account:SKYUserKeychainUsernameAccount];
                self.result.key = key;
                NSURL *url = [self _resultURL];
                [self.setupWizardBehaviour loginUserWithURL:url];
            } else {
                // basically sx key generating should never fails for non empty cluster uuid, username, and password
                [self stopLogin];
            }
        }];
    } failure:^(NSString *errorMessage) {
        [self stopLogin];
        [self.setupWizardBehaviour applicationDidFailToRetrieveClusterUUID];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.mode == kModeAdvanced ? 3:2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
        case 1:
        case 2:
            return 3;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SKYSetupWizardCellType type = [self _cellTypeForIndexPath:indexPath];
    SKYSetupWizardBaseCell *cell  = (SKYSetupWizardBaseCell *)[tableView dequeueReusableCellWithIdentifier:(type == kCellAdvancedSettings || type == kCellSSLEncryption || type == kCellShowPassword) ? kToggleCellReuseIdentifier:kInputCellReuseIdentifier forIndexPath:indexPath];
    cell.cellType = type;
    cell.delegate = self;
    switch (type) {
        case kCellServerAddress: {
            cell.mainTitleLabel.text = kServerAddressTitle;
            UITextField *textField = ((SKYSetupWizardInputCell *)cell).textField;
            textField.text = self.result.serverAddress;
            textField.placeholder = @"sx.foo.coo";
            textField.keyboardType = UIKeyboardTypeURL;
            textField.secureTextEntry = NO;
            
            break;
        }
        case kCellAdvancedSettings: {
            cell.mainTitleLabel.text = kAdvancedSettingsTitle;
            ((SKYSetupWizardToggleCell *)cell).switchControl.on = self.result.advancedSettings;
            
            break;
        }
        case kCellSSLEncryption: {
            cell.mainTitleLabel.text = kSSLEncryptionTitle;
            ((SKYSetupWizardToggleCell *)cell).switchControl.on = self.result.SSLEncryption;
            break;
        }
        case kCellPort: {
            cell.mainTitleLabel.text = kPortTitle;
            UITextField *textField = ((SKYSetupWizardInputCell *)cell).textField;
            textField.text = self.result.port;
            textField.placeholder = @"";
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            textField.secureTextEntry = NO;
            
            break;
        }
        case kCellIPAddress: {
            cell.mainTitleLabel.text = kIPAddressTitle;
            UITextField *textField = ((SKYSetupWizardInputCell *)cell).textField;
            textField.text = self.result.IPAddress;
            textField.placeholder = @"";
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            textField.secureTextEntry = NO;
            
            break;
        }
        case kCellUsername: {
            cell.mainTitleLabel.text = kUsernameTitle;
            UITextField *textField = ((SKYSetupWizardInputCell *)cell).textField;
            textField.text = self.result.username;
            textField.placeholder = @"";
            textField.keyboardType = UIKeyboardTypeEmailAddress;
            textField.secureTextEntry = NO;
            
            break;
        }
        case kCellPassword: {
            cell.mainTitleLabel.text = kPasswordTitle;
            UITextField *textField = ((SKYSetupWizardInputCell *)cell).textField;
            textField.text = self.result.password;
            textField.placeholder = @"";
            textField.keyboardType = UIKeyboardTypeDefault;
            textField.secureTextEntry = ![SKYConfig showPasswordEnabled];
            
            break;
        }
        case kCellShowPassword: {
            cell.mainTitleLabel.text = kShowPasswordTitle;
            ((SKYSetupWizardToggleCell *)cell).switchControl.on = [SKYConfig showPasswordEnabled];
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return kSection1TitleForHeader;
        case 1:
            return self.mode == kModeAdvanced ? kSection2TitleForHeader:kSection3TitleForHeader;
        case 2:
            return kSection3TitleForHeader;
        default:
            return @"";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1 && self.mode == kModeAdvanced) {
        return @"Initial IP address is required for clusters without a DNS name";
    }
    return @"";
}

#pragma mark - Table view delegate

#pragma mark - Setup wizard cell delegate

- (void)cell:(SKYSetupWizardToggleCell *)cell toggleValueDidChange:(BOOL)on {
    if (cell.cellType == kCellAdvancedSettings) {
        self.result.advancedSettings = on;
        self.result.SSLEncryption = YES;
        self.result.port = kDefaultPortForSSLOn;
        self.result.IPAddress = @"";
        [self _updateMode:on ? kModeAdvanced:kModePlain];
    } else if (cell.cellType == kCellSSLEncryption) {
        self.result.SSLEncryption = on;
        self.result.port = on ? kDefaultPortForSSLOn:kDefaultPortForSSLOff;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    } else if (cell.cellType == kCellShowPassword) {
        [SKYConfig setShowPasswordEnabled:on];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:self.mode == kModeAdvanced ? 2:1]] withRowAnimation:UITableViewRowAnimationNone];
    }
    [self _updateControls];
}

- (void)cellDidBeginEditing:(SKYSetupWizardInputCell *)cell {
    self.activeTextField = cell.textField;
}

- (void)cell:(SKYSetupWizardInputCell *)cell textValueDidChange:(NSString *)text {
    switch (cell.cellType) {
        case kCellServerAddress:
            if ([[text componentsSeparatedByString:@"://"] count] > 1) {
                text = [[text componentsSeparatedByString:@"://"] objectAtIndex:1];
            }
            self.result.serverAddress = text;
            break;
        case kCellPort:
            self.result.port = text;
            break;
        case kCellIPAddress:
            self.result.IPAddress = text;
            break;
        case kCellUsername:
            self.result.username = text;
            break;
        case kCellPassword:
            self.result.password = text;
            break;
        default:
            break;
    }
    [self _updateControls];
}

#pragma mark - Private

- (void)_initBarButtonItems {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log In" style:UIBarButtonItemStylePlain target:self action:@selector(LogInAction:)];
    [self _updateControls];
}

- (void)_registerCellNibs {
    UINib *nib = [UINib nibWithNibName:@"SKYSetupWizardInputCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:kInputCellReuseIdentifier];
    nib = [UINib nibWithNibName:@"SKYSetupWizardToggleCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:kToggleCellReuseIdentifier];
}

- (SKYSetupWizardCellType)_cellTypeForIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    switch (section) {
        case 0: {
            switch (row) {
                case 0:
                    return kCellServerAddress;
                case 1:
                    return kCellAdvancedSettings;
                default:
                    return kCellUnknown;
            }
        }
        case 1: {
            if (self.mode == kModeAdvanced) {
                switch (row) {
                    case 0:
                        return kCellSSLEncryption;
                    case 1:
                        return kCellPort;
                    case 2:
                        return kCellIPAddress;
                    default:
                        return kCellUnknown;
                }
            } else {
                switch (row) {
                    case 0:
                        return kCellUsername;
                    case 1:
                        return kCellPassword;
                    case 2:
                        return kCellShowPassword;
                    default:
                        return kCellUnknown;
                }
            }
        }
        case 2: {
            switch (row) {
                case 0:
                    return kCellUsername;
                case 1:
                    return kCellPassword;
                case 2:
                    return kCellShowPassword;
                default:
                    return kCellUnknown;
            }
        }
        default:
            return kCellUnknown;
    }
}

- (void)_updateMode:(SKYSetupWizardMode)mode {
    if (self.mode != mode) {
        self.mode = mode;
        [self.tableView beginUpdates];
        if (mode == kModeAdvanced) {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationTop];
        } else {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        }
        [self.tableView endUpdates];
    }
}

- (BOOL)_canProceed {
    if ([self.result.serverAddress length] > 0 &&
        [self.result.username length] > 0 &&
        [self.result.password length] > 0) {
        if (self.result.advancedSettings) {
            return [self.result.port length] > 0 ? YES:NO;
        }
        return YES;
    }
    return NO;
}

- (void)_updateControls {
    self.navigationItem.rightBarButtonItem.enabled = [self _canProceed];
}

- (NSURL *)_resultURL {
    NSString *string = [NSString stringWithFormat:@"sx://%@;token=%@", self.result.serverAddress, self.result.key];
    if (self.result.advancedSettings) {
        if ([self.result.IPAddress length] > 0) {
            string = [string stringByAppendingString:[NSString stringWithFormat:@",ip=%@", self.result.IPAddress]];
        }
        string = [string stringByAppendingString:[NSString stringWithFormat:@",port=%@", self.result.port]];
        string = [string stringByAppendingString:[NSString stringWithFormat:@",ssl=%@", self.result.SSLEncryption ? @"y":@"n"]];
        
    }
    NSURL *url = [NSURL URLWithString:string];
    return url;
}

- (void)_startLogIn {
    self.logInInProgress = YES;
    if (self.activeTextField.isFirstResponder) {
        [self.activeTextField resignFirstResponder];
    }
    [[UIActivityIndicatorView appearance] setColor:[UIColor whiteColor]];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    spinner.tintColor = self.navigationController.navigationBar.tintColor;
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    [[UIActivityIndicatorView appearance] setColor:[UIColor skyMainColor]];

}

@end
