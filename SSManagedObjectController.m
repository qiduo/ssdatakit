//
//  SSManagedObjectController.m
//  SSDataKit
//
//  Created by Sam Soffes on 1/24/12.
//  Copyright (c) 2012 Sam Soffes. All rights reserved.
//

#import "SSManagedObjectController.h"
#import "SSManagedObject.h"
#import "SSManagedObjectContext.h"
#import "SSManagedObjectContextObserver.h"

@implementation SSManagedObjectController {
	SSManagedObjectContextObserver *_observer;
}

@synthesize processingQueue = _processingQueue;

#pragma mark - NSObject

- (id)init {
	if ((self = [super init])) {
		_processingQueue = dispatch_queue_create("es.samsoff.ssdatakit.object-controller-processing-queue", DISPATCH_QUEUE_SERIAL);
		
		[self setup];
		
		_observer = [[SSManagedObjectContextObserver alloc] init];
		_observer.entity = self.entity;
		_observer.observationBlock = ^(NSSet *insertedObjectIDs, NSSet *updatedObjectIDs) {
			dispatch_async(self.processingQueue, ^{
				NSSet *updateSet = [insertedObjectIDs setByAddingObjectsFromSet:updatedObjectIDs];
				for (NSManagedObjectID *objectID in updateSet) {
					[self processObjectID:objectID];
				}
			});
		};
		[self.managedObjectContext addObjectObserver:_observer];
		[_observer release];
	}
	return self;
}


- (void)dealloc {
	[self.managedObjectContext removeObjectObserver:_observer];
	[_observer release];
	dispatch_release(_processingQueue);
	[super dealloc];	
}


#pragma mark - Callbacks

- (SSManagedObjectContext *)managedObjectContext {
	return (SSManagedObjectContext *)[SSManagedObject mainContext];
}


- (NSEntityDescription *)entity {
	[[NSException exceptionWithName:@"SSManagedObjectControllerInvalidEntityException"
							 reason:@"You must override and provide a valid NSEntityDescription in `-[SSManagedObjectController entity]`."
						   userInfo:nil] raise];
	return nil;
}


- (void)setup {
	// Subclasses may override this method
}


- (void)processObjectID:(NSManagedObjectID *)objectID {
	// Subclasses may override this method
}

@end
