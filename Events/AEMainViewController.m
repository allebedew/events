//
//  AEMainViewController.m
//  Events
//
//  Created by Lebedev Aleksey on 23/3/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import "AEMainViewController.h"
#import "AEAppDelegate.h"
#import "AEEventCell.h"
#import "AEEvent.h"

#define UPDATE_INTERVAL 1.0f

@interface AEMainViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, weak) NSTimer *updateTimer;

@end

@implementation AEMainViewController

- (void)dealloc {
  [self stopUpdateTimer];
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

  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
  request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES] ];
  self.resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                               managedObjectContext:[AEAppDelegate delegate].managedObjectContext
                                                                 sectionNameKeyPath:nil
                                                                          cacheName:nil];
  self.resultsController.delegate = self;
  [self.resultsController performFetch:nil];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self startUpdateTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self stopUpdateTimer];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma - Private

- (void)startUpdateTimer {
  [self.updateTimer invalidate];
  self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_INTERVAL target:self
                                                    selector:@selector(updateCells) userInfo:nil repeats:YES];
}

- (void)stopUpdateTimer {
  [self.updateTimer invalidate];
}

- (void)updateCells {
  for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
    if ([cell isKindOfClass:[AEEventCell class]]) {
      [(AEEventCell*)cell updateContent];
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
  return indexPath.row == [self collectionView:self.collectionView numberOfItemsInSection:0] - 1;
}

#pragma mark - Actions

- (void)addNewEvent {

  UIViewController *editor = [self.storyboard instantiateViewControllerWithIdentifier:@"EventEditor"];
  [self presentViewController:editor animated:YES completion:nil];

//  [NSEntityDescription insertNewObjectForEntityForName:@"Event"
//                                inManagedObjectContext:[AEAppDelegate delegate].managedObjectContext];
//  [[AEAppDelegate delegate] saveContext];
}

- (void)recognizerAction:(UIGestureRecognizer*)recognizer {
  NSIndexPath *indexPath =
    [self.collectionView indexPathForItemAtPoint:[recognizer locationInView:self.collectionView]];
  AEEvent *event = [self eventAtIndexPath:indexPath];
  if (event) {
    [[AEAppDelegate delegate].managedObjectContext deleteObject:event];
    [[AEAppDelegate delegate].managedObjectContext save:nil];
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
  [collectionView deselectItemAtIndexPath:indexPath animated:YES];
  UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
  if ([cell.reuseIdentifier isEqual:AEAddEventCellIdentifier]) {
    [self addNewEvent];
  }
}



@end
