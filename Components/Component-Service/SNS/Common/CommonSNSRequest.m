//
//  CommonSNSRequest.m
//  Dipan
//
//  Created by qqn_pipi on 11-6-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "CommonSNSRequest.h"
#import "OAuthCore.h"
#import "NetworkUtil.h"
#import "StringUtil.h"

@implementation CommonSNSRequest

@synthesize callbackURL;
@synthesize appKey;
@synthesize appSecret;
@synthesize oauthToken;
@synthesize oauthTokenSecret;
@synthesize userInfoCache;

- (id)initWithAppKey:(NSString*)key
           appSecret:(NSString*)secret
         callbackURL:(NSString*)callback
          oauthToken:token
    oauthTokenSecret:tokenSecret
{
    self = [super init];
    self.appKey = key;
    self.appSecret = secret;
    self.callbackURL = callback;
    self.oauthTokenSecret = tokenSecret;
    self.oauthToken = token;
    
    return self;
}

- (void)dealloc
{
    [userInfoCache release];
    [callbackURL release];
    [appKey release];
    [appSecret release];
    [oauthToken release];
    [oauthTokenSecret release];
    [super dealloc];
}

- (NSURL*)getOAuthTokenAndSecretURL
{
    NSURL *url = [NSURL URLWithString:[self getRequestTokenURLMain]];
    if (url == nil){
        NSLog(@"<getRequestTokenURL> fail to generate initial URL");        
        return nil;
    }

    NSDictionary* dict = nil;
    if (callbackURL == nil){
        dict = nil;
    }
    else{
        dict = [NSDictionary dictionaryWithObject:callbackURL forKey:@"oauth_callback"];
    }
    
    NSString *queryString = [OAuthCore queryStringWithUrl:url
                                                   method:@"GET"
                                               parameters:dict
                                              consumerKey:self.appKey  
                                           consumerSecret:self.appSecret
                                                    token:nil
                                              tokenSecret:nil];
    
    if (queryString == nil){
        NSLog(@"<getRequestTokenURL> fail to generate query string");
        return nil;
    }
    
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [self getRequestTokenURLMain], queryString]];
    return url;
}    

- (BOOL)parseRequestTokenURLResult:(NSString*)resultData
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *pairs = [resultData componentsSeparatedByString:@"&"];
    for(NSString *pair in pairs) {
        NSArray *keyValue = [pair componentsSeparatedByString:@"="];
        if([keyValue count] == 2) {
            NSString *key = [keyValue objectAtIndex:0];
            NSString *value = [keyValue objectAtIndex:1];
            [dict setObject:value forKey:key];
        }
    }
    self.oauthToken = [dict objectForKey:@"oauth_token"];
    self.oauthTokenSecret = [dict objectForKey:@"oauth_token_secret"];
    
    if (self.oauthToken != nil && self.oauthTokenSecret != nil)
        return YES;
    else
        return NO;
}

- (NSURL*)getAuthorizeURL
{
    NSURL* url = [NSURL URLWithString:[self getAuthorizeURLMain]];
    if (url == nil)
        return nil;
    
    NSString* queryString = [OAuthCore queryStringWithUrl:url
                                                   method:@"GET"
                                               parameters:nil
                                              consumerKey:self.appKey
                                           consumerSecret:self.appSecret
                                                    token:self.oauthToken
                                              tokenSecret:self.oauthTokenSecret];
    if (queryString == nil)
        return nil;
    
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [self getAuthorizeURLMain], queryString]];    
    return url;
}

- (NSString*)getAuthorizeURLMain
{
    return nil;
}

- (NSString*)getRequestTokenURLMain
{
    return nil;
}

- (void)safeSetKeyFrom:(NSDictionary*)fromDict toDict:(NSMutableDictionary*)toDict fromKey:(NSString*)fromKey toKey:(NSString*)toKey
{
    if (fromKey == nil || toKey == nil)
        return;
    
    NSObject* value = [fromDict objectForKey:fromKey];
    if (value == nil)
        return;
    
    if ([value isKindOfClass:[NSString class]]){    
        [toDict setObject:value forKey:toKey];
    }
    else{
        [toDict setObject:[value description] forKey:toKey];
    }
}

- (BOOL)hasUserInfoCache
{
    return (userInfoCache != nil && 
            [[userInfoCache objectForKey:SNS_USER_ID] length] > 0 &&
            [[userInfoCache objectForKey:SNS_OAUTH_TOKEN] length] > 0 &&
            [[userInfoCache objectForKey:SNS_OAUTH_TOKEN_SECRET] length] > 0);
}



@end
