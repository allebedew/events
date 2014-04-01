//
//  AEAppDelegate.m
//  Events
//
//  Created by Lebedev Aleksey on 23/3/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import "AEAppDelegate.h"
#import "AEEvent.h"

@interface AEAppDelegate ()

@property (nonatomic, strong) UIView *statusBarBacking;

@end

@implementation AEAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static NSString *AEFirstLaunchDefaultsKey = @"AEFirstLaunch";

+ (AEAppDelegate*)delegate {
  return [UIApplication sharedApplication].delegate;
}

#pragma mark - App Delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  [self prefillDatabaseIfNeeded];

  [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:AEFirstLaunchDefaultsKey];
  [[NSUserDefaults standardUserDefaults] synchronize];

  self.window.backgroundColor = [UIColor blackColor];
  [self performSelector:@selector(updateStatusBarBacking) withObject:nil afterDelay:0.0f];

  return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
  [self saveContext];
}

- (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation {
  [self performSelector:@selector(updateStatusBarBacking) withObject:nil afterDelay:0.0f];
}

#pragma mark - Private

- (void)updateStatusBarBacking {
  if (!self.statusBarBacking) {
    self.statusBarBacking = [[UIView alloc] init];
    self.statusBarBacking.backgroundColor = [UIColor colorWithWhite:0.205f alpha:0.75f];
    [self.window addSubview:self.statusBarBacking];
  }
  self.statusBarBacking.frame = [UIApplication sharedApplication].statusBarFrame;
}

- (void)prefillDatabaseIfNeeded {
  BOOL firstLaunch = ([[NSUserDefaults standardUserDefaults] doubleForKey:AEFirstLaunchDefaultsKey] == 0);
  if (firstLaunch) {

    // Prefill database
    NSString *prefillFilePath = [[NSBundle mainBundle] pathForResource:@"DatabasePrefill" ofType:@"plist"];
    NSArray *prefillData = [NSArray arrayWithContentsOfFile:prefillFilePath];
    for (NSDictionary *eventInfo in prefillData) {
      AEEvent *event = (AEEvent*)[NSEntityDescription insertNewObjectForEntityForName:@"Event"
                                                               inManagedObjectContext:self.managedObjectContext];
      event.title = eventInfo[@"title"];
      event.date = eventInfo[@"date"];
      event.order = eventInfo[@"order"];
    }
    [self saveContext];
  }
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

@end
