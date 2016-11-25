//
//  SKYBaseController.m
//  SXDrive
//
//  Created by Skylable on 17/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseController.h"

#define PublicLinkGeneratingProgressMessage                         NSLocalizedString(@"Creating link...", @"Public link generating progress popup message")
#define PublicLinkGeneratedSuccessMessage                           NSLocalizedString(@"Link copied to clipboard.", @"Public link generated popup message")
#define PublicLinkGeneratedFailedMessage                            NSLocalizedString(@"Failed to create the link. Try again later.", @"Public link generated popup message")
#define PublicLinkGeneratedFailedDismissButtonTitle                 NSLocalizedString(@"Dismiss", @"Generic dismiss")

static const NSTimeInterval publicLinkGeneratedPopupDelay           = 0.5;
static const NSTimeInterval publicLinkGeneratedPopupAutoDismiss     = 2.0;

@interface SKYBaseControllerImplementation ()

/*
 * Alert indicating that public link is being generated.
 */
@property (nonatomic, strong) UIAlertView *publicLinkGeneratingProgressAlertView;

/*
 * Dismisses alert view with animation.
 */
- (void)_dismissAlertView:(UIAlertView *)alertView;

@end

@implementation SKYBaseControllerImplementation

@synthesize info = _info;
@synthesize swipeToPopGestureEnabled = _swipeToPopGestureEnabled;
@synthesize baseView = _baseView;
@synthesize baseBehaviour = _baseBehaviour;

- (instancetype)initWithView:(UIView <SKYBaseView> *)baseView behaviour:(id <SKYBaseBehaviour>)baseBehaviour
{
	self = [super init];
	
	if (self) {
		_swipeToPopGestureEnabled = YES;
		_baseView = baseView;
		_baseBehaviour = baseBehaviour;
		self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
	}
	
	return self;
}

- (SKYViewType)viewType
{
	return SKYViewTypeNone;
}

- (void)loadView
{
	self.view = self.baseView;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if ([self.baseView respondsToSelector:@selector(createSubviews)] == YES) {
		[self.baseView createSubviews];
	}
	if ([self.baseBehaviour respondsToSelector:@selector(processInfo:)] == YES) {
		[self.baseBehaviour processInfo:self.info];
	}
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (UIViewController *)viewControler
{
	return self;
}

#pragma mark - Private

- (void)_dismissAlertView:(UIAlertView *)alertView {
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark - SKYBaseBehaviourPresenter

- (void)showPublicLinkGeneratingProgressPopup {
    self.publicLinkGeneratingProgressAlertView = [[UIAlertView alloc] initWithTitle:nil message:PublicLinkGeneratingProgressMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [self.publicLinkGeneratingProgressAlertView show];
}

- (void)showPublicLinkGeneratedPopup:(BOOL)success {
    [self.publicLinkGeneratingProgressAlertView dismissWithClickedButtonIndex:0 animated:YES];
    
    NSString *message = success ? PublicLinkGeneratedSuccessMessage:PublicLinkGeneratedFailedMessage;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:success ? nil:PublicLinkGeneratedFailedDismissButtonTitle otherButtonTitles:nil];
    [alertView performSelector:@selector(show) withObject:nil afterDelay:publicLinkGeneratedPopupDelay];
    if (success) {
        [self performSelector:@selector(_dismissAlertView:) withObject:alertView afterDelay:publicLinkGeneratedPopupAutoDismiss];
    }
}

@end

@interface SKYBaseNibControllerImplementation ()

/*
 * Alert indicating that public link is being generated.
 */
@property (nonatomic, strong) UIAlertView *publicLinkGeneratingProgressAlertView;

/*
 * Dismisses alert view with animation.
 */
- (void)_dismissAlertView:(UIAlertView *)alertView;

@end

@implementation SKYBaseNibControllerImplementation

@synthesize info = _info;
@synthesize swipeToPopGestureEnabled = _swipeToPopGestureEnabled;
@synthesize baseBehaviour = _baseBehaviour;

- (instancetype)initWithBehaviour:(id <SKYBaseBehaviour>)baseBehaviour {
    self = [super init];
    if (self) {
        _swipeToPopGestureEnabled = YES;
        _baseBehaviour = baseBehaviour;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    
    return self;
}

- (SKYViewType)viewType {
    return SKYViewTypeNone;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.baseBehaviour respondsToSelector:@selector(processInfo:)] == YES) {
        [self.baseBehaviour processInfo:self.info];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIViewController *)viewControler {
    return self;
}

#pragma mark - Private

- (void)_dismissAlertView:(UIAlertView *)alertView {
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark - SKYBaseBehaviourPresenter

- (void)showPublicLinkGeneratingProgressPopup {
    self.publicLinkGeneratingProgressAlertView = [[UIAlertView alloc] initWithTitle:nil message:PublicLinkGeneratingProgressMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [self.publicLinkGeneratingProgressAlertView show];
}

- (void)showPublicLinkGeneratedPopup:(BOOL)success {
    [self.publicLinkGeneratingProgressAlertView dismissWithClickedButtonIndex:0 animated:YES];
    
    NSString *message = success ? PublicLinkGeneratedSuccessMessage:PublicLinkGeneratedFailedMessage;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:success ? nil:PublicLinkGeneratedFailedDismissButtonTitle otherButtonTitles:nil];
    [alertView performSelector:@selector(show) withObject:nil afterDelay:publicLinkGeneratedPopupDelay];
    if (success) {
        [self performSelector:@selector(_dismissAlertView:) withObject:alertView afterDelay:publicLinkGeneratedPopupAutoDismiss];
    }
}

@end

@interface SKYBaseTableControllerImplementation ()

/*
 * Alert indicating that public link is being generated.
 */
@property (nonatomic, strong) UIAlertView *publicLinkGeneratingProgressAlertView;

/*
 * Dismisses alert view with animation.
 */
- (void)_dismissAlertView:(UIAlertView *)alertView;

@end

@implementation SKYBaseTableControllerImplementation

@synthesize info = _info;
@synthesize swipeToPopGestureEnabled = _swipeToPopGestureEnabled;
@synthesize baseView = _baseView;
@synthesize baseBehaviour = _baseBehaviour;

- (instancetype)initWithView:(UIView <SKYBaseView> *)baseView behaviour:(id <SKYBaseBehaviour>)baseBehaviour
{
	self = [super init];
	
	if (self) {
		_swipeToPopGestureEnabled = YES;
		_baseView = baseView;
		_baseBehaviour = baseBehaviour;
		self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
	}
	
	return self;
}

- (SKYViewType)viewType
{
	return SKYViewTypeNone;
}

- (void)loadView
{
	self.view = self.baseView;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if ([self.baseView respondsToSelector:@selector(createSubviews)] == YES) {
		[self.baseView createSubviews];
	}
	
	if ([self.baseBehaviour respondsToSelector:@selector(processInfo:)] == YES) {
		[self.baseBehaviour processInfo:self.info];
	}
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (UIViewController *)viewControler
{
	return self;
}

#pragma mark - Private

- (void)_dismissAlertView:(UIAlertView *)alertView {
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark - SKYBaseBehaviourPresenter

- (void)showPublicLinkGeneratingProgressPopup {
    self.publicLinkGeneratingProgressAlertView = [[UIAlertView alloc] initWithTitle:nil message:PublicLinkGeneratingProgressMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [self.publicLinkGeneratingProgressAlertView show];
}

- (void)showPublicLinkGeneratedPopup:(BOOL)success {
    [self.publicLinkGeneratingProgressAlertView dismissWithClickedButtonIndex:0 animated:YES];
    
    NSString *message = success ? PublicLinkGeneratedSuccessMessage:PublicLinkGeneratedFailedMessage;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:success ? nil:PublicLinkGeneratedFailedDismissButtonTitle otherButtonTitles:nil];
    [alertView performSelector:@selector(show) withObject:nil afterDelay:publicLinkGeneratedPopupDelay];
    if (success) {
        [self performSelector:@selector(_dismissAlertView:) withObject:alertView afterDelay:publicLinkGeneratedPopupAutoDismiss];
    }
}

@end

@interface SKYBaseNibTableControllerImplementation ()

/*
 * Alert indicating that public link is being generated.
 */
@property (nonatomic, strong) UIAlertView *publicLinkGeneratingProgressAlertView;

/*
 * Dismisses alert view with animation.
 */
- (void)_dismissAlertView:(UIAlertView *)alertView;

@end

@implementation SKYBaseNibTableControllerImplementation

@synthesize info = _info;
@synthesize swipeToPopGestureEnabled = _swipeToPopGestureEnabled;
@synthesize baseBehaviour = _baseBehaviour;

- (instancetype)initWithBehaviour:(id <SKYBaseBehaviour>)baseBehaviour {
    self = [super init];
    if (self) {
        _swipeToPopGestureEnabled = YES;
        _baseBehaviour = baseBehaviour;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    
    return self;
}

- (SKYViewType)viewType {
    return SKYViewTypeNone;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.baseBehaviour respondsToSelector:@selector(processInfo:)] == YES) {
        [self.baseBehaviour processInfo:self.info];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIViewController *)viewControler {
    return self;
}

#pragma mark - Private

- (void)_dismissAlertView:(UIAlertView *)alertView {
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark - SKYBaseBehaviourPresenter

- (void)showPublicLinkGeneratingProgressPopup {
    self.publicLinkGeneratingProgressAlertView = [[UIAlertView alloc] initWithTitle:nil message:PublicLinkGeneratingProgressMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [self.publicLinkGeneratingProgressAlertView show];
}

- (void)showPublicLinkGeneratedPopup:(BOOL)success {
    [self.publicLinkGeneratingProgressAlertView dismissWithClickedButtonIndex:0 animated:YES];
    
    NSString *message = success ? PublicLinkGeneratedSuccessMessage:PublicLinkGeneratedFailedMessage;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:success ? nil:PublicLinkGeneratedFailedDismissButtonTitle otherButtonTitles:nil];
    [alertView performSelector:@selector(show) withObject:nil afterDelay:publicLinkGeneratedPopupDelay];
    if (success) {
        [self performSelector:@selector(_dismissAlertView:) withObject:alertView afterDelay:publicLinkGeneratedPopupAutoDismiss];
    }
}

@end