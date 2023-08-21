/*
 Copyright 2014 OpenMarket Ltd

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

#import "MXFileStoreMetaData.h"

static NSString* const kEncodingKeyCapabilities = @"capabilities";
static NSString* const kEncodingKeySupportedSDNVersions = @"supportedSDNVersions";

@implementation MXFileStoreMetaData

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self)
    {
        NSDictionary *dict = [aDecoder decodeObjectForKey:@"dict"];
        _node = dict[@"node"];
        _userId = dict[@"userId"];
        _eventStreamToken = dict[@"eventStreamToken"];
        _syncFilterId = dict[@"syncFilterId"];
        _userAccountData = dict[@"userAccountData"];
        
        NSNumber *areAllTermsAgreed = dict[@"areAllIdentityServerTermsAgreed"];
        _areAllIdentityServerTermsAgreed = [areAllTermsAgreed boolValue];

        NSNumber *version = dict[@"version"];
        _version = [version unsignedIntegerValue];

        _nodeWellknown = dict[@"wellknown"];
        _nodeCapabilities = dict[kEncodingKeyCapabilities];
        _supportedSDNVersions = dict[kEncodingKeySupportedSDNVersions];
        
        NSNumber *maxUploadSize = dict[@"maxUploadSize"];
        _maxUploadSize = [maxUploadSize integerValue] ?: -1;
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    // Mandatory, non-null, properties
    NSMutableDictionary *dict =[NSMutableDictionary dictionaryWithDictionary:
                                @{
                                  @"node": _node,
                                  @"userId": _userId,
                                  @"version": @(_version),
                                  @"maxUploadSize": @(_maxUploadSize),
                                  @"areAllIdentityServerTermsAgreed": [NSNumber numberWithBool:_areAllIdentityServerTermsAgreed]
                                  }];

    // Nullable properties
    if (_eventStreamToken)
    {
        dict[@"eventStreamToken"] = _eventStreamToken;
    }
    if (_syncFilterId)
    {
        dict[@"syncFilterId"] = _syncFilterId;
    }
    if (_userAccountData)
    {
        dict[@"userAccountData"] = _userAccountData;
    }
    if (_nodeWellknown)
    {
        dict[@"wellknown"] = _nodeWellknown;
    }
    if (_nodeCapabilities)
    {
        dict[kEncodingKeyCapabilities] = _nodeCapabilities;
    }
    if (_supportedSDNVersions)
    {
        dict[kEncodingKeySupportedSDNVersions] = _supportedSDNVersions;
    }

    [aCoder encodeObject:dict forKey:@"dict"];
}

- (id)copyWithZone:(NSZone *)zone
{
    MXFileStoreMetaData *metaData = [[MXFileStoreMetaData allocWithZone:zone] init];

    metaData->_node = [_node copyWithZone:zone];
    metaData->_userId = [_userId copyWithZone:zone];
    metaData->_version = _version;
    metaData->_eventStreamToken = [_eventStreamToken copyWithZone:zone];
    metaData->_userAccountData = [_userAccountData copyWithZone:zone];
    metaData->_areAllIdentityServerTermsAgreed = _areAllIdentityServerTermsAgreed;
    metaData->_maxUploadSize = _maxUploadSize;
    metaData->_nodeCapabilities = _nodeCapabilities;
    metaData->_supportedSDNVersions = _supportedSDNVersions;
 
    return metaData;
}

@end
