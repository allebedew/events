//
//  AEMainViewController.m
//  Events
//
//  Created by Lebedev Aleksey on 23/3/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import "AEEventsCollectionController.h"

#import "AEAppDelegate.h"
#import "AEEventCell.h"
#import "AEEvent.h"
#import "AEEventEditorViewController.h"
#import <Realm/Realm.h>

#define COUNTERS_UPDATE_INTERVAL 1.0f

@interface AEEventsCollectionController () <UIActionSheetDelegate>

@property (nonatomic, weak) NSTimer *countersUpdateTimer;
@property (nonatomic, assign) BOOL ignoreNextUpdate;

@property (nonatomic, strong) RLMResults *events;
@property (nonatomic, strong) RLMNotificationToken *updateToken;

@end

@implementation AEEventsCollectionController

- (void)dealloc {
    [self.updateToken stop];
    [self stopCountersUpdateTimer];
}

- (instancetype)init {
    if ((self = [super init])) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.installsStandardGestureForInteractiveMovement = YES;
    [self initializeRealm];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([AEEventCell class]) bundle:nil]
          forCellWithReuseIdentifier:AEEventCellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startCountersUpdateTimer];
    [[AEAppDelegate delegate] showStatusBarShader:YES animated:animated];
    [self deselectSelectedCell];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopCountersUpdateTimer];
    [[AEAppDelegate delegate] showStatusBarShader:NO animated:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Private

- (void)initializeRealm {
    self.events = [[AEEvent allObjects] sortedResultsUsingProperty:@"order" ascending:YES];

    __weak typeof (self) weakSelf = self;
    self.updateToken = [self.events addNotificationBlock:^(RLMResults *results, RLMCollectionChange *change, NSError *error) {
        __strong typeof (self) strongSelf = weakSelf;
        if (error) {
            NSLog(@"Realm update error: %@", error);
            return;
        }
        if (strongSelf.ignoreNextUpdate) {
            strongSelf.ignoreNextUpdate = NO;
            NSLog(@"Ignoring update");
            return;
        }
        NSLog(@"UPD: %@\nCH: %@\nERR: %@", results, change, error);

        UICollectionView *collectionView = strongSelf.collectionView;
        if (!change) {
            [collectionView reloadData];
            return;
        }
        if (change.deletions.count > 0) {
            [collectionView deleteItemsAtIndexPaths:[change deletionsInSection:0]];
        }
        if (change.insertions.count > 0) {
            [collectionView insertItemsAtIndexPaths:[change insertionsInSection:0]];
        }
        if (change.modifications.count > 0) {
            [collectionView reloadItemsAtIndexPaths:[change modificationsInSection:0]];
        }
    }];
    NSLog(@"%@", [RLMRealm defaultRealm].configuration.fileURL);
}

- (void)startCountersUpdateTimer {
    [self.countersUpdateTimer invalidate];
    self.countersUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:COUNTERS_UPDATE_INTERVAL target:self
                                                              selector:@selector(updateCountersOnVisibleCells) userInfo:nil repeats:YES];
    [self updateCountersOnVisibleCells];
}

- (void)stopCountersUpdateTimer {
    [self.countersUpdateTimer invalidate];
}

- (void)updateCountersOnVisibleCells {
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        if ([cell isKindOfClass:[AEEventCell class]]) {
            [(AEEventCell*)cell updateCounterLabels];
        }
    }
}

- (AEEvent *)eventAtIndexPath:(NSIndexPath*)indexPath {
    if (!indexPath || [self isIndexPathForAddNewCell:indexPath]) {
        return nil;
    }
    return (AEEvent *)[self.events objectAtIndex:indexPath.row];
}

- (BOOL)isIndexPathForAddNewCell:(NSIndexPath*)indexPath {
    return (indexPath.row == ([self collectionView:self.collectionView numberOfItemsInSection:indexPath.section] - 1));
}

- (void)deselectSelectedCell {
    [self.collectionView deselectItemAtIndexPath:self.collectionView.indexPathsForSelectedItems.firstObject
                                        animated:YES];
}

- (void)presentEditorForEvent:(AEEvent *)event {
    AEEventEditorViewController *editorController = event ?
        [[AEEventEditorViewController alloc] initWithEvent:event] :
        [[AEEventEditorViewController alloc] initWithCreatingNewEvent];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:editorController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Actions

- (void)createEventPressed {
    [self presentEditorForEvent:nil];
}

- (void)deleteSelectedEvent {
    AEEvent *event = [self eventAtIndexPath:self.collectionView.indexPathsForSelectedItems.firstObject];
    if (!event) {
        return;
    }
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        [[RLMRealm defaultRealm] deleteObject:event];
    }];
}

- (void)editSelectedEvent {
    AEEvent *event = [self eventAtIndexPath:self.collectionView.indexPathsForSelectedItems.firstObject];
    if (!event) {
        return;
    }
    [self presentEditorForEvent:event];
}

#pragma mark - Collection View Delegate

static NSString *AEAddEventCellIdentifier = @"AddEventCell";

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.events.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    if ([self isIndexPathForAddNewCell:indexPath]) {
        return [collectionView dequeueReusableCellWithReuseIdentifier:AEAddEventCellIdentifier forIndexPath:indexPath];
    }

    AEEventCell *cell = (AEEventCell*)[collectionView dequeueReusableCellWithReuseIdentifier:AEEventCellIdentifier forIndexPath:indexPath];
    [self configureEventCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureEventCell:(AEEventCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    AEEvent *event = [self.events objectAtIndex:indexPath.row];
    cell.event = event;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isIndexPathForAddNewCell:indexPath]) {
        [self createEventPressed];
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    } else {
        AEEvent *event = [self eventAtIndexPath:indexPath];
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:event.title
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                             destructiveButtonTitle:NSLocalizedString(@"Delete", nil)
                                                  otherButtonTitles:NSLocalizedString(@"Edit", nil), nil];
        [sheet showInView:self.view];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self isIndexPathForAddNewCell:indexPath] ? NO : YES;
}

- (void)collectionView:(UICollectionView *)collectionView
    moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath
            toIndexPath:(NSIndexPath *)destinationIndexPath {

    if ([self isIndexPathForAddNewCell:destinationIndexPath]) {
        [collectionView moveItemAtIndexPath:destinationIndexPath toIndexPath:sourceIndexPath];
        return;
    }

    AEEvent *sourceEvent = [self.events objectAtIndex:sourceIndexPath.row];
    AEEvent *destEvent = [self.events objectAtIndex:destinationIndexPath.row];

    self.ignoreNextUpdate = YES;
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        NSInteger destOrder = destEvent.order;
        if (sourceEvent.order < destEvent.order) {
            for (AEEvent *event in [self.events objectsWhere:@"order > %d AND order <= %d", sourceEvent.order, destEvent.order]) {
                event.order --;
            }
        } else {
            for (AEEvent *event in [self.events objectsWhere:@"order >= %d AND order < %d", destEvent.order, sourceEvent.order]) {
                event.order ++;
            }
        }
        sourceEvent.order = destOrder;
    }];
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self deselectSelectedCell];
    } else if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self deleteSelectedEvent];
    } else {
        [self editSelectedEvent];
    }
}

@end
