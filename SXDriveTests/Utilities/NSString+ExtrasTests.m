//
//  NSString+ExtrasTests.m
//  SXDrive
//
//  Created by Skylable on 20/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "NSString+Extras.h"

#import <Kiwi/Kiwi.h>

SPEC_BEGIN(NSString_ExtrasTests)

describe(@"NSString_ExtrasTests", ^{
	
	context(@"SHA1", ^{
		it(@"should return valid hash (test1)", ^{
			[[[@"abc" SHA1] should] equal:@"a9993e364706816aba3e25717850c26c9cd0d89d"];
		});
		it(@"should return valid hash (test2)", ^{
			[[[@"objective-c" SHA1] should] equal:@"ed702b05a18bb4c499170940e07e484e56e66a04"];
		});
		it(@"should return valid hash (test3)", ^{
			[[[@"%#<>:.,[}['" SHA1] should] equal:@"9e3903e141ead4a65c4ef8fef89bc77338a63c8a"];
		});
		it(@"should return valid hash (test4)", ^{
			[[[@"" SHA1] should] equal:@"da39a3ee5e6b4b0d3255bfef95601890afd80709"];
		});
	});
	
	context(@"HMAC_SHA1WithKey:", ^{
		it(@"should return valid hash (test1)", ^{
			[[[@"abc" HMAC_SHA1WithKey:@"dummy-key"] should] equal:@"cf19a3e5f25cbc33a92006df7f9f230b3f350885"];
		});
		it(@"should return valid hash (test2)", ^{
			[[[@"abc" HMAC_SHA1WithKey:@"dummy-key-2"] should] equal:@"4afbe6999a19a7d6c8914ea12ad94a5f776c8b6d"];
		});
		it(@"should return valid hash (test3)", ^{
			[[[@"abc" HMAC_SHA1WithKey:@"%#<>:.,[}['"] should] equal:@"1ec3bd12063f4a648c4e799b80e066ba44e7fa89"];
		});
		it(@"should return valid hash (test4)", ^{
			[[[@"%#<>:.,[}['" HMAC_SHA1WithKey:@"dummy-key"] should] equal:@"c2594c5f80a2b1945b27efe816a9f7b927bb0bd8"];
		});
		it(@"should return valid hash (test5)", ^{
			[[[@"%#<>:.,[}['" HMAC_SHA1WithKey:@"dummy-key-2"] should] equal:@"02e4eb9ef2ceb8de89ff4c7923c090becd23052e"];
		});
		it(@"should return valid hash (test6)", ^{
			[[[@"%#<>:.,[}['" HMAC_SHA1WithKey:@"%#<>:.,[}['"] should] equal:@"07ff01b9d7b55236872fd50302bc00c14310c7a7"];
		});
		it(@"should throw exception for nil key", ^{
			[[theBlock(^{
				[@"abc" HMAC_SHA1WithKey:nil];
			}) should] raise];
		});
	});
	
	context(@"randomString", ^{
		it(@"should use randomStringOfLength: (32)", ^{
			KWMock *mock = [KWMock mock];
			[NSString stub:@selector(randomStringOfLength:) andReturn:mock withArguments:theValue(32)];
			
			[[[NSString randomString] should] equal:mock];
		});
	});
	
	context(@"randomStringOfLength:", ^{
		it(@"should return random strings of 32 length", ^{
			NSMutableArray *randomStrings = [NSMutableArray array];
			
			for (int i = 0; i < 10; i++) {
				NSUInteger length = arc4random_uniform(arc4random_uniform(100));
				NSString *randomString = [NSString randomStringOfLength:length];
				
				[[theValue(randomString.length) should] equal:theValue(length)];

				if ([randomStrings containsObject:randomString] == NO) {
					[randomStrings addObject:randomString];
				}
			}
			
			[[theValue(randomStrings.count) should] equal:theValue(10)];
		});
	});
	
	context(@"stringWithName:withAvoidingNameClashWithExistingNames:", ^{
		it(@"should return the same name if no name clash exists", ^{
			NSString *result = [NSString stringWithName:@"dummy-name" withAvoidingNameClashWithExistingNames:@[@"another-name-1", @"another-name-2"]];
			
			[[result should] equal:@"dummy-name"];
		});
		
		it(@"should add _1 to the name if the same file already exist test_1", ^{
			NSString *result = [NSString stringWithName:@"dummy-name" withAvoidingNameClashWithExistingNames:@[@"dummy-name", @"another-name-1"]];
			
			[[result should] equal:@"dummy-name_1"];
		});
		
		it(@"should add _1 to the name if the same file already exist test_2", ^{
			NSString *result = [NSString stringWithName:@"dummy-name.png" withAvoidingNameClashWithExistingNames:@[@"dummy-name.png", @"another-name-1.png"]];
			
			[[result should] equal:@"dummy-name_1.png"];
		});
		
		it(@"should add _2 to the name if the same file already exist and also the file with the _1 suffix test_1", ^{
			NSString *result = [NSString stringWithName:@"dummy-name.png" withAvoidingNameClashWithExistingNames:@[@"dummy-name.png", @"dummy-name_1.png", @"another-name-1.png"]];
			
			[[result should] equal:@"dummy-name_2.png"];
		});
		
		it(@"should add _2 to the name if the same file already exist and also the file with the _1 suffix test_2", ^{
			NSString *result = [NSString stringWithName:@"dummy-name" withAvoidingNameClashWithExistingNames:@[@"dummy-name", @"dummy-name_1", @"dummy-name_3", @"another-name-1"]];
			
			[[result should] equal:@"dummy-name_2"];
		});
		
		it(@"should return the same name for empty array", ^{
			NSString *result = [NSString stringWithName:@"dummy-name" withAvoidingNameClashWithExistingNames:@[]];
			
			[[result should] equal:@"dummy-name"];
		});
		
		it(@"should return the same name for nil names", ^{
			NSString *result = [NSString stringWithName:@"dummy-name" withAvoidingNameClashWithExistingNames:nil];
			
			[[result should] equal:@"dummy-name"];
		});
	});
});

SPEC_END
