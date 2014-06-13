//
//  AEColorSelectorViewControllerTableViewController.m
//  Events
//
//  Created by Lebedev Aleksey on 13/6/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import "AEColorSelectorViewController.h"

#import "AEItemColor.h"
#import "AEColorSelectorCell.h"

@interface AEColorSelectorViewController ()

@end

@implementation AEColorSelectorViewController

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
}

- (id)init {
  self = [super initWithStyle:UITableViewStyleGrouped];
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[AEItemColor availableColors] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *identifier = @"ColorSelectorCell";
  AEColorSelectorCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
  AEItemColor *color = [AEItemColor availableColors][indexPath.row];
  cell.color = color;
  BOOL isSelected = [color isEqual:self.selectedColor];
  cell.accessoryType = isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  AEItemColor *color = [AEItemColor availableColors][indexPath.row];
  self.selectedColor = color;
  if (self.colorSelectedBlock) {
      self.colorSelectedBlock();
  }
}

@end
