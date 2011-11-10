//
//  Created by dean on 11/8/11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "CheckregDatabase.h"


@implementation CheckregDatabase 

- (id)initWithFilename:(NSString *)filename {
	if (self = [super initWithFileName:filename]) {
		[ISModel setDatabase:self];
		self.logging = YES;
	}
	return self;
}

@end