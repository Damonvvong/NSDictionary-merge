

#import "NSMutableDictionary-merge.h"
#import "Merge.h"

#define MERGE_DEBUG 1

#if MERGE_DEBUG
#   define MERGE_LOG(fmt, ...) NSLog(fmt, ##__VA_ARGS__)
#else
#   define MERGE_LOG(...)
#endif

@implementation NSMutableDictionary (merge)

- (void)mergeWithObj:(NSObject*)obj
{
	if (![obj isKindOfClass:[NSDictionary class]]) {
		NSAssert(@"Attempted to merge objects of different types: %@\n,\n %@", [self description], [obj description]);
	}
	[self mergeWithDictionary:(NSDictionary*)obj];
}

- (BOOL)canMergeWithObj:(NSObject*)obj
{
	if (![obj isKindOfClass:[NSDictionary class]]) {
		return NO;
	}
	return YES;
}

- (void)mergeWithDictionary:(NSDictionary*)dict
{
	NSEnumerator* ke = [dict keyEnumerator];
	
	for (id<NSCopying> key in ke) {
		id myObj = [self objectForKey:key];
		id obj = [dict objectForKey:key];
		if (!myObj) {
			// The key was not already in self, so simply add it.
			MERGE_LOG(@"inserted new object for key: %@", key);
			
			[self setObject:obj forKey:key];
		} else {
			id result = nil;
			if ([Merge mergeObj:myObj withObj:obj result:&result]) {
				[self setObject:result forKey:key];
				MERGE_LOG(@"merged objects for key: %@", key);
			} else {
				MERGE_LOG(@"could not merge objects for key: %@", key);
			}
		}
	}
}

@end