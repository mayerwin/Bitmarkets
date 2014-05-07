//
//  MKPost.m
//  BitMarkets
//
//  Created by Steve Dekorte on 5/1/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import "MKPost.h"
#import "MKPostMsg.h"
#import "MKBidMsg.h"
#import "MKSell.h"
#import "MKRootNode.h"

@implementation MKPost

- (id)init
{
    self = [super init];
    self.date = [NSDate date];
    
    self.postUuid = [[NSUUID UUID] UUIDString];
    
    self.title = @"";
    self.price = @0;
    self.description = @"";
    
    self.regionPath = @[];
    self.categoryPath = @[];
    self.sellerAddress = BMClient.sharedBMClient.identities.firstIdentity.address; // make this tx specific later
    
    self.status = @"draft";
    self.shouldSortChildren = NO;
    
    self.nodeSuggestedWidth = 150;
    
    [self.dictPropertyNames addObjectsFromArray:@[
     @"postUuid",
     @"status",
     @"title",
     @"price",
     @"description",
     @"regionPath",
     @"categoryPath",
     @"sellerAddress"]
     ];
    
    return self;
}

- (NSString *)nodeNote
{
    if (!self.isEditable && !self.canBuy)
    {
        return @"✓";
    }
    
    return nil;
}

// equality

- (NSUInteger)hash
{
    return self.postUuid.hash;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:self.class])
    {
        MKPost *otherPost = object;
        BOOL isEqual = [self.postUuid isEqualToString:otherPost.postUuid];
        return isEqual;
    }
    
    return YES;
}


- (BOOL)isEditable
{
    return [self.status isEqualToString:@"draft"];
}

- (BOOL)canBuy
{
    NavNode *parent = self.nodeParent;
    
    if ([parent isKindOfClass:MKCategory.class])
    {
        return YES;
    }
    
    return NO;
}

- (NSString *)nodeTitle
{
    if (self.canBuy)
    {
        return self.titleOrDefault;
    }
    
    return @"Post";
}

- (NSString *)nodeSubtitle
{
    if (self.canBuy)
    {
        return [NSString stringWithFormat:@"%@BTC", self.price];
    }
    
    return nil;
}

- (NSString *)titleOrDefault
{
    if (self.title && self.title.length)
    {
        return self.title;
    }
    
    return @"Untitled Post";
}

// ----------

- (void)setPropertiesDict:(NSDictionary *)dict
{
    [super setPropertiesDict:dict];
    NSLog(@"");
}

- (NSDictionary *)propertiesDict
{
    return [super propertiesDict];
}

- (NSArray *)fullPath
{
    NSMutableArray *path = [NSMutableArray array];
    [path addObjectsFromArray:self.regionPath];
    [path addObjectsFromArray:self.categoryPath];
    return path;
}

- (BOOL)placeInMarketsPath
{
    NavNode *root = MKRootNode.sharedMKRootNode.markets.rootRegion;
    NSArray *fullPath = self.fullPath;
    //NSLog(@"fullPath = '%@'", fullPath);
    
    if (fullPath.count == 0)
    {
        NSLog(@"Warning: empty full path for post");
        return NO;
    }
    
    NSArray *nodePath = [root nodeTitlePath:fullPath];
    
    
    if (nodePath)
    {
        //NSLog(@"placing sell in path '%@'", self.fullPath);
        MKCategory *cat = nodePath.lastObject;
        [cat addChild:self];
        return YES;
    }
    else
    {
        NSLog(@"---- unable to find node for path '%@'", self.fullPath);
        return NO;
    }
}

// -----------------------------

- (void)copy:(MKPost *)aPost
{
    [self setPropertiesDict:aPost.propertiesDict];
}

- (NSView *)nodeView
{
    return [super nodeView];
}

// actions

- (void)sendPostMsg
{
    MKPostMsg *postMsg = [[MKPostMsg alloc] init];
    [postMsg sendPost:self];
    
    [self setStatus:@"posted"];
    [self postParentChanged];
}

- (void)sendBidMsg
{
    MKBidMsg *bidMsg = [[MKBidMsg alloc] init];
    [bidMsg setupForPost:self];
    [bidMsg send];
    [MKRootNode.sharedMKRootNode.markets handleMsg:bidMsg];
}

@end
