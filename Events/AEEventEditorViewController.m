//
//  AEEventEditorViewController.m
//  Events
//
//  Created by Lebedev Aleksey on 2/4/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import "AEEventEditorViewController.h"

#import "AEEvent.h"
#import "AEColorSelectorViewController.h"
#import "AEColorSelectorCell.h"

#define UPDATE_INTERVAL 1.0f

@interface AEEventEditorViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;

@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) IBOutlet UITextField *titleTextField;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *intervalLabel;
@property (nonatomic, weak) IBOutlet AEColorSelectorCell *colorCell;

@property (nonatomic, assign) BOOL datePickerShown;
@property (nonatomic, strong) NSIndexPath *lastSelectedRow;
@property (nonatomic, weak) NSTimer *updateTimer;

@end

@implementation AEEventEditorViewController

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc {

}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                  target:self action:@selector(doneButtonPressed:)];
  self.saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                  target:self action:@selector(saveButtonPressed:)];
  self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                    target:self action:@selector(cancelButtonPressed:)];
  [self fillViewsWithEventData];
  [self updateNavigationButtonsAnimated:NO];
  [self updateSaveButtonState];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self startUpdateTimer];
  [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self stopUpdateTimer];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"SelectColor"]) {
    [self hideDatePicker];

    __weak AEEventEditorViewController *weakSelf = self;
    __weak AEColorSelectorViewController *colorSelector =
      (AEColorSelectorViewController*)segue.destinationViewController;
    colorSelector.selectedColor = self.event.color;
    colorSelector.colorSelectedBlock = ^{
      weakSelf.event.color = colorSelector.selectedColor;
      [weakSelf fillViewsWithEventData];
      [weakSelf.navigationController popViewControllerAnimated:YES];
    };
  }
}

- (void)startUpdateTimer {
  [self.updateTimer invalidate];
  self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_INTERVAL target:self
                                                    selector:@selector(updateIntervalLabel)
                                                    userInfo:nil repeats:YES];
}

- (void)stopUpdateTimer {
  [self.updateTimer invalidate];
}

- (void)updateIntervalLabel {
  self.intervalLabel.text = self.event.intervalString;
}

- (void)updateNavigationButtonsAnimated:(BOOL)animated {
  if ([self.titleTextField isFirstResponder]) {
    [self.navigationItem setLeftBarButtonItem:nil animated:animated];
    [self.navigationItem setRightBarButtonItem:self.doneButton animated:animated];
  } else {
    [self.navigationItem setLeftBarButtonItem:self.cancelButton animated:animated];
    [self.navigationItem setRightBarButtonItem:self.saveButton animated:animated];
  }
}

- (void)updateSaveButtonState {
  self.saveButton.enabled = [self.event validateForUpdate:nil];
}

- (void)fillViewsWithEventData {
  self.titleTextField.text = self.event.title;
  if (self.event.date) {
    self.datePicker.date = self.event.date;
  }
  self.colorCell.color = self.event.color;
  [self fillDateCellsWithEventData];
}

- (void)fillDateCellsWithEventData {
  self.dateLabel.text = [NSDateFormatter localizedStringFromDate:self.event.date
                                                       dateStyle:NSDateFormatterLongStyle
                                                       timeStyle:NSDateFormatterNoStyle];
  self.timeLabel.text = [NSDateFormatter localizedStringFromDate:self.event.date
                                                       dateStyle:NSDateFormatterNoStyle
                                                       timeStyle:NSDateFormatterShortStyle];
  for (UITableViewCell *cell in self.tableView.visibleCells) {
    [cell setNeedsLayout];
  }
  self.intervalLabel.text = self.event.intervalString;
}

- (BOOL)isDateCellSelected {
  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
  return [cell.reuseIdentifier isEqual:@"DateCell"];
}

- (BOOL)isTimeCellSelected {
  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
  return [cell.reuseIdentifier isEqual:@"TimeCell"];
}

- (void)showDatePicker {
  [self saveTitleAndHideKeyboard];

  if (self.datePickerShown) {
    return;
  }
  self.datePickerShown = YES;
  NSIndexPath *pickerIndexPath = [NSIndexPath indexPathForRow:2 inSection:1];
  [self.tableView insertRowsAtIndexPaths:@[ pickerIndexPath ]
                        withRowAnimation:UITableViewRowAnimationMiddle];
}

- (void)hideDatePicker {
  if (!self.datePickerShown) {
    return;
  }
  self.datePickerShown = NO;
  NSIndexPath *pickerIndexPath = [NSIndexPath indexPathForRow:2 inSection:1];
  [self.tableView deleteRowsAtIndexPaths:@[ pickerIndexPath ]
                        withRowAnimation:UITableViewRowAnimationMiddle];
}

- (void)saveTitleAndHideKeyboard {
  if ([self.titleTextField isFirstResponder]) {
    self.event.title = self.titleTextField.text;
    [self.titleTextField resignFirstResponder];
  }
}

#pragma mark - User Actions

- (void)cancelButtonPressed:(id)sender {
  if (self.doneEditingBlock) {
    self.doneEditingBlock(YES);
  }
}

- (void)saveButtonPressed:(id)sender {
  if (self.doneEditingBlock) {
    self.doneEditingBlock(NO);
  }
}

- (void)doneButtonPressed:(id)sender {
  [self saveTitleAndHideKeyboard];
}

- (void)dateCellSelected {
  self.datePicker.datePickerMode = UIDatePickerModeDate;
  [self showDatePicker];
}

- (void)timeCellSelected {
  self.datePicker.datePickerMode = UIDatePickerModeTime;
  [self showDatePicker];
}

- (void)dateOrTimeCellDeselected {
  [self hideDatePicker];
}

#pragma mark Picker Delagate

- (IBAction)datePickerChanged:(id)sender {
  self.event.date = self.datePicker.date;
  [self fillDateCellsWithEventData];
}

#pragma mark Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  [self updateNavigationButtonsAnimated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  [self updateNavigationButtonsAnimated:YES];
  [self updateSaveButtonState];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self saveTitleAndHideKeyboard];
  return NO;
}

#pragma mark - Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 1) {
    return self.datePickerShown ? 3 : 2;
  }
  return [super tableView:tableView numberOfRowsInSection:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  for (NSIndexPath *selectedIndexPath in self.tableView.indexPathsForSelectedRows) {
    if (![selectedIndexPath isEqual:indexPath]) {
      [tableView deselectRowAtIndexPath:selectedIndexPath animated:NO];
    }
  }

  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  if ([cell.reuseIdentifier isEqualToString:@"DateCell"]) {
    [self dateCellSelected];
  } else if ([cell.reuseIdentifier isEqualToString:@"TimeCell"]) {
    [self timeCellSelected];
  }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  if ([cell.reuseIdentifier isEqualToString:@"DateCell"] || [cell.reuseIdentifier isEqualToString:@"TimeCell"]) {
    [self dateOrTimeCellDeselected];
  }
}

@end
