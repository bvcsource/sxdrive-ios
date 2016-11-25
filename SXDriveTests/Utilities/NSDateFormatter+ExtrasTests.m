//
//  NSDateFormatter+ExtrasTests.m
//  SXDrive
//
//  Created by Skylable on 03/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "NSDateFormatter+Extras.h"

#import <Kiwi/Kiwi.h>

SPEC_BEGIN(NSDateFormatter_ExtrasTests)

describe(@"NSDateFormatter_ExtrasTests", ^{
	
	context(@"dateFormatterForLastModificationDate", ^{
		it(@"should be properly configured", ^{
			NSDateFormatter *df = [NSDateFormatter dateFormatterForLastModificationDate];
			
			[[theValue(df.dateStyle) should] equal:theValue(NSDateFormatterMediumStyle)];
			[[theValue(df.timeStyle) should] equal:theValue(NSDateFormatterShortStyle)];
		});
		
		it(@"should be singleton instance", ^{
			NSDateFormatter *df1 = [NSDateFormatter dateFormatterForLastModificationDate];
			NSDateFormatter *df2 = [NSDateFormatter dateFormatterForLastModificationDate];
			
			[[df1 should] equal:df2];
		});
	});
});

SPEC_END
