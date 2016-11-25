//
//  SKYImportFileController.m
//  SXDrive
//
//  Created by Skylable on 5/21/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYImportFileController.h"

#import "SKYInfoKeys.h"
#import "UIImage+SKYImage.h"
#import "SKYImportFileNameCell.h"
#import "UIFont+SKYFont.h"
#import "UIColor+SKYColor.h"
#import "SKYConfig.h"

NSString *const kImportFileNameCellReuseIdentifier = @"fileNameCell";
NSString *const kImportFilePathReuseIdentifier = @"filePathCell";

@interface SKYImportFileController () <SKYImportFileNameCellDelegate>

- (void)userDidSaveFile;
- (void)userDidCancelImportFile;
- (NSString *)fileNameWithExtension;
- (NSString *)destinationPath;

@end

@implementation SKYImportFileController

@synthesize fileSourceURL = _fileSourceURL;
@synthesize fileName = _fileName;
@synthesize fileExtension = _fileExtension;
@synthesize currentItems = _currentItems;
@synthesize updatedItems = _updatedItems;

#pragma mark - View life

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Save to SXDrive", @"Import File view controller title");
    
    UINib *nib = [UINib nibWithNibName:@"SKYImportFileNameCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:kImportFileNameCellReuseIdentifier];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(userDidCancelImportFile)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(userDidSaveFile)];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self.importFileBehaviour cancelImportFile];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.updatedItems = [NSMutableArray arrayWithArray:self.currentItems];
    
    [self.navigationController setToolbarHidden:YES];
    self.navigationItem.rightBarButtonItem.enabled = [self.currentItems count] > 0;
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Convenience accessors

- (id <SKYImportFileBehaviour>)importFileBehaviour
{
    return (id <SKYImportFileBehaviour>)self.baseBehaviour;
}

#pragma mark - Base controller

- (SKYViewType)viewType {
    return SKYViewTypeImportFile;
}

#pragma mark - Actions

- (void)userDidSaveFile {
    [self.importFileBehaviour saveFile:@{SKYInfoKeyForFileURL: self.fileSourceURL, SKYInfoKeyForFileName: [self fileNameWithExtension]} atDirectory:self.currentItems];
}

- (void)userDidCancelImportFile {
    [self.importFileBehaviour cancelImportFile];
}

#pragma mark - Auxiliary

- (NSString *)fileNameWithExtension {
    return [NSString stringWithFormat:@"%@.%@", self.fileName, self.fileExtension];
}

- (NSString *)destinationPath {
    NSString *result = @"";
    for (SKYItem *item in self.currentItems) {
        result = [result stringByAppendingString:item.name];
        if (item != [self.currentItems lastObject]) {
            result = [result stringByAppendingString:@"/"];
        }
    }
    return result;
}

#pragma mark - Import file behaviour presenter

- (void)updateImportFileDirectory:(SKYItem *)item {
    if ([item.path isEqualToString:@"/"]) {
        [self.updatedItems removeAllObjects];
    }
    
    if ([self.updatedItems containsObject:item]) {
        for (NSInteger index = [self.updatedItems indexOfObject:item] + 1; index < [self.updatedItems count]; index++) {
            [self.updatedItems removeObjectAtIndex:index];
        }
    } else {
        [self.updatedItems addObject:item];
    }
}

- (void)userDidChooseDirectory {
    self.currentItems = [NSArray arrayWithArray:self.updatedItems];
    [self.tableView reloadData];
}

- (void)userDidCancelChoosingDirectory {
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
    
    if (section == 0) {
        return 1;
    } else if ([self.currentItems count] > 1) {
        return 3;
    } else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        SKYImportFileNameCell *cell = [tableView dequeueReusableCellWithIdentifier:kImportFileNameCellReuseIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        cell.textField.text = [self fileNameWithExtension];
        cell.fileIconImageView.image = [UIImage iconImageForFileWithName:[self fileNameWithExtension]];
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kImportFilePathReuseIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kImportFilePathReuseIdentifier];
            cell.textLabel.font = [UIFont fontForDetailCellLabels];
            cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        }
        cell.textLabel.textColor = [UIColor blackColor];
        NSInteger row = indexPath.row;
        if (row == 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
            cell.imageView.image = [UIImage imageNamed:@"folder"];
            cell.textLabel.text = ((SKYItem *)[self.currentItems lastObject]).name;
        }
        
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 0 ? NSLocalizedString(@"File:", @"Import file view controller table view section header"):NSLocalizedString(@"Destination:", @"Import file view controller table view section header");
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Saving to:", @"Import file view controller table view section footer"), [self destinationPath]];
    return section == 1 ? text:nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.importFileBehaviour chooseDifferentDirectory];
    }
}

#pragma mark - SKYImportFileNameCellDelegate

- (void)cellTextFieldDidBeginEditing:(SKYImportFileNameCell *)cell {
    NSRange range = [cell.textField.text rangeOfString:self.fileName];
    UITextPosition *beginning = cell.textField.beginningOfDocument;
    UITextPosition *start = [cell.textField positionFromPosition:beginning offset:range.location];
    UITextPosition *end = [cell.textField positionFromPosition:start offset:range.length];
    UITextRange *textRange = [cell.textField textRangeFromPosition:start toPosition:end];
    [cell.textField setSelectedTextRange:textRange];
}

- (void)cellTextFieldDidEndEditing:(SKYImportFileNameCell *)cell {
    if (![[cell.textField.text pathExtension] isEqualToString:self.fileName]) {
        cell.textField.text = [NSString stringWithFormat:@"%@.%@", self.fileName, self.fileExtension];
    }
}

- (void)cell:(SKYImportFileNameCell *)cell textValueDidChange:(NSString *)text {
    NSString *pathExtension = [text pathExtension];
    if ([pathExtension isEqualToString:self.fileExtension]) {
    self.fileName = [NSString stringWithString:[text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", pathExtension] withString:@""]];
    } else if ([text hasSuffix:@"."]){
        self.fileName = [text substringToIndex:[text length] - 1];
    } else {
        self.fileName = text;
    }
}

@end
