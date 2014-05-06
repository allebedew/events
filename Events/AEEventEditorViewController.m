//
//  AEEventEditorViewController.m
//  Events
//
//  Created by Lebedev Aleksey on 2/4/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import "AEEventEditorViewController.h"
#import "AEEvent.h"

@interface AEEventEditorViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;

@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) IBOutlet UITextField *titleTextField;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;

@property (nonatomic, assign) BOOL datePickerShown;
@property (nonatomic, strong) NSIndexPath *lastSelectedRow;

@end

@implementation AEEventEditorViewController

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
  [self.titleTextField resignFirstResponder];

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

#pragma mark - User Actions

- (void)cancelButtonPressed:(id)sender {
  if (self.completion) {
    self.completion(YES);
  }
}

- (void)saveButtonPressed:(id)sender {
  if (self.completion) {
    self.completion(NO);
  }
}

- (void)doneButtonPressed:(id)sender {
  if ([self.titleTextField isFirstResponder]) {
    self.event.title = self.titleTextField.text;
    [self.titleTextField resignFirstResponder];
  }
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

#pragma mark - Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  switch (section) {
    case 0: return 1;
    case 1: return self.datePickerShown ? 3 : 2;
  }
  return 0;
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
