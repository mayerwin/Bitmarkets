//
//  MKBidMsg.m
//  BitMarkets
//
//  Created by Steve Dekorte on 5/2/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import <FoundationCategoriesKit/FoundationCategoriesKit.h>
#import "MKBidMsg.h"
#import "MKRootNode.h"

@implementation MKBidMsg

- (NSArray *)modelActions
{
    return @[@"accept"];
}

- (NSString *)nodeTitle
{
    return @"Bid";
}

- (NSString *)nodeSubtitle
{
    return [NSString stringWithFormat:@"from %@", self.sellerAddress];
}

- (void)setupForPost:(MKPost *)mkPost
{
    [self.dict removeAllObjects];
    [self.dict addEntriesFromDictionary:mkPost.propertiesDict];
    
    [self.dict setObject:self.classNameSansPrefix forKey:@"_type"];
    [self.dict setObject:mkPost.postUuid          forKey:@"postUuid"];
    [self.dict setObject:mkPost.sellerAddress     forKey:@"sellerAddress"];
    [self.dict setObject:self.myAddress           forKey:@"buyerAddress"];
}

- (BOOL)send
{
    NSString *message = self.dict.asJsonString;
    
    BMMessage *m = [[BMMessage alloc] init];
    [m setFromAddress:self.buyerAddress];
    [m setToAddress:self.sellerAddress];
    [m setSubject:self.subject];
    [m setMessage:message];
    [m send];
    
    [MKRootNode.sharedMKRootNode.markets handleMsg:self];
    
    return YES;
}

- (void)accept
{
    
}

@end
