/*
 Copyright 2019 New Vector Ltd

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

#import "MXWellKnown.h"

static NSString *const kMXNodeKey = @"m.node";
static NSString *const kMXIdentityServerKey = @"m.identity_server";
static NSString *const kMXIntegrationsKey = @"m.integrations";

static NSString *const kMXTileServerKey = @"m.tile_server";
static NSString *const kMXTileServerMSC3488Key = @"org.sdn.msc3488.tile_server";

@interface MXWellKnown()
{
    // The original dictionary to store extented data
    NSDictionary *JSONDictionary;
}

@end

@implementation MXWellKnown

+ (instancetype)modelFromJSON:(NSDictionary *)JSONDictionary
{
    MXWellKnown *wellknown;

    MXWellKnownBaseConfig *nodeBaseConfig;
    MXJSONModelSetMXJSONModel(nodeBaseConfig, MXWellKnownBaseConfig, JSONDictionary[kMXNodeKey]);
    if (nodeBaseConfig)
    {
        wellknown = [MXWellKnown new];
        wellknown.node = nodeBaseConfig;

        MXJSONModelSetMXJSONModel(wellknown.identityServer, MXWellKnownBaseConfig, JSONDictionary[kMXIdentityServerKey]);
        MXJSONModelSetMXJSONModel(wellknown.integrations, MXWellknownIntegrations, JSONDictionary[kMXIntegrationsKey]);
        
        if (JSONDictionary[kMXTileServerKey])
        {
            MXJSONModelSetMXJSONModel(wellknown.tileServer, MXWellKnownTileServerConfig, JSONDictionary[kMXTileServerKey]);
        }
        else if (JSONDictionary[kMXTileServerMSC3488Key])
        {
            MXJSONModelSetMXJSONModel(wellknown.tileServer, MXWellKnownTileServerConfig, JSONDictionary[kMXTileServerMSC3488Key]);
        }
        
        wellknown->JSONDictionary = JSONDictionary;
    }

    return wellknown;
}

- (NSDictionary *)JSONDictionary
{
    return JSONDictionary;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<MXWellKnown: %p> node: %@ - identityServer: %@", self, _node.baseUrl, _identityServer.baseUrl];
}


#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _node = [aDecoder decodeObjectForKey:kMXNodeKey];
        _identityServer = [aDecoder decodeObjectForKey:kMXIdentityServerKey];
        _integrations = [aDecoder decodeObjectForKey:kMXIntegrationsKey];
        _tileServer = [aDecoder decodeObjectForKey:kMXTileServerKey];
        JSONDictionary = [aDecoder decodeObjectForKey:@"JSONDictionary"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_node forKey:kMXNodeKey];
    [aCoder encodeObject:_identityServer forKey:kMXIdentityServerKey];
    [aCoder encodeObject:_integrations forKey:kMXIntegrationsKey];
    [aCoder encodeObject:_tileServer forKey:kMXTileServerKey];
    [aCoder encodeObject:JSONDictionary forKey:@"JSONDictionary"];
}

@end
