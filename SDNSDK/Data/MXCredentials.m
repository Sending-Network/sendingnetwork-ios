/*
 Copyright 2019 New Vector Ltd
 Copyright 2021 The Matrix.org Foundation C.I.C

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MXCredentials.h"

#import "MXJSONModels.h"

#import "MXTools.h"
#import "MXRestClient.h"
#import "MXRefreshTokenData.h"

@implementation MXCredentials

- (instancetype)initWithNode:(NSString *)node userId:(NSString *)userId accessToken:(NSString *)accessToken
{
    self = [super init];
    if (self)
    {
        _node = [node copy];
        _userId = [userId copy];
        _accessToken = [accessToken copy];
        
        [self registerRestClientWillRefreshTokensNotification];
    }
    return self;
}

- (instancetype)initWithLoginResponse:(MXLoginResponse*)loginResponse
                andDefaultCredentials:(MXCredentials*)defaultCredentials
{
    self = [super init];
    if (self)
    {
        _userId = loginResponse.userId;
        _accessToken = loginResponse.accessToken;
        _accessTokenExpiresAt = ((uint64_t)[NSDate date].timeIntervalSince1970 * 1000) + loginResponse.expiresInMs;
        _refreshToken = loginResponse.refreshToken;
        _deviceId = loginResponse.deviceId;
        _loginOthers = loginResponse.others;

        // Use wellknown data first
        _node = loginResponse.wellknown.node.baseUrl;
        _identityServer = loginResponse.wellknown.identityServer.baseUrl;

        if (!_node)
        {
            // Workaround: HS does not return the right URL in wellknown.
            // Use the passed one instead
            _node = [defaultCredentials.node copy];
        }
        
        if (!_node)
        {
            // Attempt to derive node from userId.
            NSString *serverName = [MXTools serverNameInSDNIdentifier:_userId];
            if (serverName)
            {
                _node = [NSString stringWithFormat:@"https://%@", serverName];
            }
        }
        
        if (!_node)
        {
            // Attempt to get node from loginResponse.node
            // Using loginResponse.node as the last option, because it's deprecated
            NSString *serverName = loginResponse.node;
            if (serverName)
            {
                //  check serverName is a full url
                NSURL *url = [NSURL URLWithString:serverName];
                if (url.scheme && url.host)
                {
                    _node = serverName;
                }
                else
                {
                    _node = [NSString stringWithFormat:@"https://%@", serverName];
                }
            }
        }

        if (!_identityServer)
        {
            _identityServer = [defaultCredentials.identityServer copy];
        }
        [self registerRestClientWillRefreshTokensNotification];
    }
    return self;
}

- (void)dealloc
{
    [self unregisterRestClientWillRefreshTokensNotification];
}

+ (instancetype)initialSyncCacheCredentialsFrom:(MXCredentials *)credentials
{
    MXCredentials *result = [credentials copy];
    result.userId = [result.userId stringByAppendingString:@"-initial"];
    return result;
}

- (NSString *)nodeName
{
    return [NSURL URLWithString:_node].host;
}

- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;

    if (![other isKindOfClass:MXCredentials.class])
        return NO;

    MXCredentials *otherCredentials = (MXCredentials *)other;

    return [_node isEqualToString:otherCredentials.node]
        && [_userId isEqualToString:otherCredentials.userId]
        && [_accessToken isEqualToString:otherCredentials.accessToken]
        && _accessTokenExpiresAt == otherCredentials.accessTokenExpiresAt
        && ((_refreshToken == nil && otherCredentials.refreshToken == nil) || [_refreshToken isEqualToString:otherCredentials.refreshToken]);
}

- (NSUInteger)hash
{
    NSUInteger prime = 31;
    NSUInteger result = 1;
    
    result = prime * result + [_node hash];
    result = prime * result + [_userId hash];
    result = prime * result + [_accessToken hash];
    result = prime * result + (NSUInteger)_accessTokenExpiresAt;
    result = prime * result + [_refreshToken hash];

    return result;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MXCredentials *credentials = [[[self class] allocWithZone:zone] init];
    
    credentials.userId = [_userId copyWithZone:zone];
    credentials.node = [_node copyWithZone:zone];
    credentials.accessToken = [_accessToken copyWithZone:zone];
    credentials.accessTokenExpiresAt = _accessTokenExpiresAt;
    credentials.refreshToken = [_refreshToken copyWithZone:zone];
    credentials.accessToken = [_accessToken copyWithZone:zone];
    credentials.identityServer = [_identityServer copyWithZone:zone];
    credentials.identityServerAccessToken = [_identityServerAccessToken copyWithZone:zone];
    credentials.deviceId = [_deviceId copyWithZone:zone];
    credentials.allowedCertificate = [_allowedCertificate copyWithZone:zone];
    credentials.ignoredCertificate = [_ignoredCertificate copyWithZone:zone];

    return credentials;
}

#pragma mark - Node Access/Refresh Token updates

- (void)registerRestClientWillRefreshTokensNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRestClientWillRefreshTokensNotification:) name:MXCredentialsUpdateTokensNotification object:nil];
}

- (void)unregisterRestClientWillRefreshTokensNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MXCredentialsUpdateTokensNotification object:nil];
}

- (void)handleRestClientWillRefreshTokensNotification:(NSNotification*)notification
{
    MXRefreshTokenData *tokenData = notification.userInfo[kMXCredentialsNewRefreshTokenDataKey];
    
    if(tokenData && tokenData.userId && self.userId && [self.userId isEqualToString:tokenData.userId]
       && tokenData.node && self.node && [tokenData.node isEqualToString:self.node])
    {
        if (tokenData.refreshToken) {
            self.refreshToken = tokenData.refreshToken;
        }
        self.accessToken = tokenData.accessToken;
        self.accessTokenExpiresAt = tokenData.accessTokenExpiresAt;
    }
}

@end
