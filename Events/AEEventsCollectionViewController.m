  //
//  AEMainViewController.m
//  Events
//
//  Created by Lebedev Aleksey on 23/3/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import "AEEventsCollectionViewController.h"

#import "AEAppDelegate.h"
#import "AEEventCell.h"
#import "AEEvent.h"
#import "AEEventEditorViewController.h"
#import "Flurry.h"

#define COUNTERS_UPDATE_INTERVAL 1.0f

@interface AEEventsCollectionViewController ()
  <NSFetchedResultsControllerDelegate, UIActionSheetDelegate, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, weak) NSTimer *countersUpdateTimer;

@end

@implementation AEEventsCollectionViewController

- (void)dealloc {
  [self stopCountersUpdateTimer];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [self.resultsController performFetch:nil];
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

#pragma mark - Properties

- (NSFetchedResultsController*)resultsController {
  if (!_resultsController) {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES] ];
    _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                             managedObjectContext:[AEAppDelegate delegate].managedObjectContext
                                                               sectionNameKeyPath:nil
                                                                        cacheName:nil];
    _resultsController.delegate = self;
  }
  return _resultsController;
}

#pragma mark - Private

- (void)startCountersUpdateTimer {
  [self.countersUpdateTimer invalidate];
  self.countersUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:COUNTERS_UPDATE_INTERVAL target:self
                                                            selector:@selector(updateCountersOnVisibleCells) userInfo:nil repeats:YES];
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

- (AEEvent*)eventAtIndexPath:(NSIndexPath*)indexPath {
  if (!indexPath || [self isIndexPathForAddNewCell:indexPath]) {
    return nil;
  }
  return (AEEvent*)[self.resultsController objectAtIndexPath:indexPath];
}

- (BOOL)isIndexPathForAddNewCell:(NSIndexPath*)indexPath {
  return (indexPath.row == ([self collectionView:self.collectionView numberOfItemsInSection:indexPath.section] - 1));
}

- (void)deselectSelectedCell {
  [self.collectionView deselectItemAtIndexPath:self.collectionView.indexPathsForSelectedItems.firstObject
                                      animated:YES];
}

- (void)showEditorForEvent:(AEEvent*)event completion:(void(^)(BOOL cancelled))completion {
  UINavigationController *eventNavigationController =
    [self.storyboard instantiateViewControllerWithIdentifier:@"EventEditor"];
  AEEventEditorViewController *eventEditor = (AEEventEditorViewController*)eventNavigationController.topViewController;
  eventEditor.event = event;
  eventEditor.doneEditingBlock = ^(BOOL cancelled) {
    [self dismissViewControllerAnimated:YES completion:nil];
    completion(cancelled);
  };
  eventNavigationController.modalPresentationStyle = UIModalPresentationCustom;
  eventNavigationController.transitioningDelegate = self;
  
  
  [self presentViewController:eventNavigationController animated:YES completion:nil];
}

#pragma mark - Actions

- (void)createEventPressed {
  AEEvent *event = [AEEvent eventWithTitle:nil date:nil color:nil context:nil insert:NO];
  
  [self showEditorForEvent:event completion:^(BOOL cancelled) {
    if (cancelled) {
      return;
    }
    NSDictionary *flurryParams = @{ @"title": event.title,
                                    @"date":  @([event.date timeIntervalSince1970]),
                                    @"color": event.colorIdentifier };
    [Flurry logEvent:@"event_create" withParameters:flurryParams];
    
    [[AEAppDelegate delegate].managedObjectContext insertObject:event];
    [[AEAppDelegate delegate] saveContext];
  }];
}

- (void)deleteSelectedEvent {
  AEEvent *event = [self eventAtIndexPath:self.collectionView.indexPathsForSelectedItems.firstObject];
  if (!event) {
    return;
  }
  
  [Flurry logEvent:@"event_delete"];
  
  [[AEAppDelegate delegate].managedObjectContext deleteObject:event];
  [[AEAppDelegate delegate] saveContext];
}

- (void)editSelectedEvent {
  AEEvent *event = [self eventAtIndexPath:self.collectionView.indexPathsForSelectedItems.firstObject];
  if (!event) {
    return;
  }
  
  [Flurry logEvent:@"event_edit"];
  
  [self showEditorForEvent:event completion:^(BOOL cancelled) {
    if (cancelled) {
      [[AEAppDelegate delegate].managedObjectContext rollback];
      return;
    }
    [[AEAppDelegate delegate] saveContext];
  }];
}

#pragma mark - Fetched Results Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
      break;
    case NSFetchedResultsChangeDelete:
      [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
      break;
  }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [self.collectionView insertItemsAtIndexPaths:@[ newIndexPath ]];
      break;
    case NSFetchedResultsChangeDelete:
      [self.collectionView deleteItemsAtIndexPaths:@[ indexPath ]];
      break;
    case NSFetchedResultsChangeUpdate: {
      AEEventCell *cell = (AEEventCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
      [self configureEventCell:cell atIndexPath:indexPath];
      break;
    }
    case NSFetchedResultsChangeMove:
      [self.collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
      break;
  }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
}

#pragma mark - Collection View Delegate

static NSString *AEEventCellIdentifier = @"EventCell";
static NSString *AEAddEventCellIdentifier = @"AddEventCell";

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  id <NSFetchedResultsSectionInfo> sectionInfo = self.resultsController.sections.firstObject;
  return [sectionInfo numberOfObjects] + 1;
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
  AEEvent *event = [self.resultsController objectAtIndexPath:indexPath];
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

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
  return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
  return 3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
  
}

@end
