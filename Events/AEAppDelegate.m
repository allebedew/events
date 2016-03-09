
//  AEAppDelegate.m
//  Events
//
//  Created by Lebedev Aleksey on 23/3/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import "AEAppDelegate.h"

#import "AEEvent.h"
#import "AEItemColor.h"

@interface AEAppDelegate ()

@property (nonatomic, strong) UIView *statusBarShader;
@property (nonatomic, assign) BOOL isFirstLaunch;

@end

@implementation AEAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (AEAppDelegate*)delegate {
  return [UIApplication sharedApplication].delegate;
}

#pragma mark - App Delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  static NSString *AEFirstLaunchDefaultsKey = @"AEFirstLaunch";
  if ([[NSUserDefaults standardUserDefaults] doubleForKey:AEFirstLaunchDefaultsKey] == 0.0) {
    self.isFirstLaunch = YES;
    [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:AEFirstLaunchDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
  
  if (self.isFirstLaunch) {
    [self addDefaultEvents];
  }

  [self performSelector:@selector(updateStatusBarShaderFrame) withObject:nil afterDelay:0.0f];

  return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation {
  [self performSelector:@selector(updateStatusBarShaderFrame) withObject:nil afterDelay:0.0f];
}

#pragma mark - Private

- (void)addALotOfRandomEvents {
  for (int i = 0; i < 500; ++i) {
    NSString *title = [NSString stringWithFormat:@"Random Event #%d", i];
    
    UInt32 range = 1000000000;
    NSTimeInterval interval = (range / 2) - arc4random_uniform(range);
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:interval];

    [AEEvent eventWithTitle:title date:date color:nil context:self.managedObjectContext insert:YES];
  }
  [self saveContext];
}

- (NSDate*)nextChristmassDate {
  NSCalendar *georgian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  NSDateComponents *components = [georgian components:NSCalendarUnitYear
                                             fromDate:[NSDate date]];
  components.day = 25;
  components.month = 12;
  NSDate *date = [georgian dateFromComponents:components];
  
  if ([date compare:[NSDate date]] == NSOrderedAscending) {
    components.year++;
    date = [georgian dateFromComponents:components];
  }
  
  return date;
}

- (NSDate*)nextNewYearDate {
  NSCalendar *georgian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  NSDateComponents *components = [georgian components:NSCalendarUnitYear
                                             fromDate:[NSDate date]];
  components.day = 1;
  components.month = 1;
  components.year++;
  NSDate *date = [georgian dateFromComponents:components];
  return date;
}

- (NSDate*)iphoneReleaseDate {
  NSCalendar *georgian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  NSDateComponents *components = [[NSDateComponents alloc] init];
  components.day = 29;
  components.month = 6;
  components.year = 2007;
  NSDate *date = [georgian dateFromComponents:components];
  return date;
}

- (void)addDefaultEvents {
  
  [AEEvent eventWithTitle:NSLocalizedString(@"Christmas", @"event title")
                     date:[self nextChristmassDate]
                    color:[AEItemColor colorWithIdentifier:@"indigo"]
                  context:self.managedObjectContext insert:YES];

  [AEEvent eventWithTitle:NSLocalizedString(@"New Year", @"event title")
                     date:[self nextNewYearDate]
                    color:[AEItemColor colorWithIdentifier:@"blue"]
                  context:self.managedObjectContext insert:YES];
  
  [AEEvent eventWithTitle:NSLocalizedString(@"First iPhone Release", @"event title")
                     date:[self iphoneReleaseDate]
                    color:[AEItemColor colorWithIdentifier:@"red"]
                  context:self.managedObjectContext insert:YES];
  
  [self saveContext];
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

- (NSNumber*)fetchLastOrderValue {
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event"
                                            inManagedObjectContext:self.managedObjectContext];

  NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:entity.name];
  req.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO] ];
  req.fetchLimit = 1;
  NSError *error = nil;
  NSArray *result = [self.managedObjectContext executeFetchRequest:req error:&error];
  NSNumber *maxOrder = ((AEEvent*)[result firstObject]).order;
  if (error) {
    NSLog(@"max order fetch error: %@", error);
    return nil;
  }
  return maxOrder;
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Events" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Events.sqlite"];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Public

- (UIView*)statusBarShader {
  if (!_statusBarShader) {
    _statusBarShader = [[UIView alloc] init];
    _statusBarShader.backgroundColor = [UIColor colorWithWhite:0.205f alpha:0.75f];
  }
  return _statusBarShader;
}

- (void)updateStatusBarShaderFrame {
  self.statusBarShader.frame = [UIApplication sharedApplication].statusBarFrame;
}

- (void)showStatusBarShader:(BOOL)show animated:(BOOL)animated {
  if (show && !self.statusBarShader.superview) {
    [self.window addSubview:self.statusBarShader];
    [self.window performSelector:@selector(bringSubviewToFront:)
                      withObject:self.statusBarShader
                      afterDelay:0.0f]; // dirty
  }
  dispatch_block_t animations = ^{
    self.statusBarShader.alpha = show ? 1.0f : 0.0f;
  };
  if (animated) {
    [UIView animateWithDuration:0.3f animations:animations];
  } else {
    animations();
  }
}

@end

@implementation UINavigationController (Rotation)

- (NSUInteger)supportedInterfaceOrientations {
  if (self.topViewController.presentedViewController) {
    return self.topViewController.presentedViewController.supportedInterfaceOrientations;
  }
  return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
  return self.topViewController.preferredInterfaceOrientationForPresentation;
}

@end
