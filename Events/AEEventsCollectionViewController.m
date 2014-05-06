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

#define COUNTERS_UPDATE_INTERVAL 1.0f

@interface AEEventsCollectionViewController () <NSFetchedResultsControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, weak) NSTimer *countersUpdateTimer;

@end

@implementation AEEventsCollectionViewController

- (void)dealloc {
  [self stopCountersUpdateTimer];
}

- (void)viewDidLoad {
  [super viewDidLoad];
/*
  UILongPressGestureRecognizer *longPressRecognizer =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(recognizerAction:)];
  [self.view addGestureRecognizer:longPressRecognizer];
 */
  UITapGestureRecognizer *doubleTapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recognizerAction:)];
  doubleTapRecognizer.numberOfTapsRequired = 2;
  [self.view addGestureRecognizer:doubleTapRecognizer];

  [self.resultsController performFetch:nil];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self startCountersUpdateTimer];
  [[AEAppDelegate delegate] showStatusBarShader:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self stopCountersUpdateTimer];
  [[AEAppDelegate delegate] showStatusBarShader:NO animated:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma - Properties

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

#pragma - Private

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

- (void)configureEventCell:(AEEventCell*)cell atIndexPath:(NSIndexPath*)indexPath {
  AEEvent *event = [self.resultsController objectAtIndexPath:indexPath];
  cell.event = event;
}

- (BOOL)isIndexPathForAddNewCell:(NSIndexPath*)indexPath {
  return (indexPath.row == ([self collectionView:self.collectionView numberOfItemsInSection:indexPath.section] - 1));
}

- (void)showEditorForEvent:(AEEvent*)event {
  UINavigationController *eventNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"EventEditor"];
  AEEventEditorViewController *eventEditor = (AEEventEditorViewController*)eventNavigationController.topViewController;
  eventEditor.event = event;
  eventEditor.completion = ^(BOOL cancelled) {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (!cancelled) {
      [[AEAppDelegate delegate] saveContext];
    }
  };
  [self presentViewController:eventNavigationController animated:YES completion:nil];
}

#pragma mark - Actions

- (void)createEventPressed {
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event"
                                            inManagedObjectContext:[AEAppDelegate delegate].managedObjectContext];
  AEEvent *event = [[AEEvent alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
  event.date = [NSDate date];
  [self showEditorForEvent:event];
}

- (void)deleteSelectedEvent {
  AEEvent *event = [self eventAtIndexPath:self.collectionView.indexPathsForSelectedItems.firstObject];
  if (!event) {
    return;
  }
  [[AEAppDelegate delegate].managedObjectContext deleteObject:event];
  [[AEAppDelegate delegate] saveContext];
}

- (void)editSelectedEvent {
  AEEvent *event = [self eventAtIndexPath:self.collectionView.indexPathsForSelectedItems.firstObject];
  if (!event) {
    return;
  }
  [self showEditorForEvent:event];
}

#pragma mark - Recognizer Delegate

- (void)recognizerAction:(UIGestureRecognizer*)recognizer {
  NSIndexPath *indexPath =
    [self.collectionView indexPathForItemAtPoint:[recognizer locationInView:self.collectionView]];
  AEEvent *event = [self eventAtIndexPath:indexPath];
  if (event) {
  }
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
    case NSFetchedResultsChangeUpdate:
      [self configureEventCell:(AEEventCell*)[self.collectionView cellForItemAtIndexPath:indexPath]
                   atIndexPath:indexPath];
      break;
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
    [self.collectionView deselectItemAtIndexPath:self.collectionView.indexPathsForSelectedItems.firstObject
                                        animated:YES];
  } else if (buttonIndex == actionSheet.destructiveButtonIndex) {
    [self deleteSelectedEvent];
  } else {
    [self editSelectedEvent];
  }
}

@end