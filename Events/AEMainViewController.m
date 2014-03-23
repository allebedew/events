//
//  AEMainViewController.m
//  Events
//
//  Created by Lebedev Aleksey on 23/3/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import "AEMainViewController.h"

@interface AEMainViewController ()

- (IBAction)new:(id)sender;

@end

@implementation AEMainViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  NSLog(@"%@", self.collectionViewLayout);

}

#pragma mark - Actions

- (IBAction)new:(id)sender {

}

#pragma mark - Collection Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return 5;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
  NSLog(@"suppl el %@ %@", kind, indexPath);
  return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  NSLog(@"cell %@", indexPath);
  return [collectionView dequeueReusableCellWithReuseIdentifier:@"event" forIndexPath:indexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
  NSLog(@"should show");
  return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action
    forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
  NSLog(@"action? %@ %@", NSStringFromSelector(action), indexPath);
  return YES;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action
    forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
  NSLog(@"action");
}

@end
