/*
 Copyright 2018 New Vector Ltd

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

#import <Foundation/Foundation.h>
#import "MXJSONModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 SDN Client-Server API versions.
 */
struct MXSDNClientServerAPIVersionStruct
{
    __unsafe_unretained NSString * const r0_0_1;
    __unsafe_unretained NSString * const r0_1_0;
    __unsafe_unretained NSString * const r0_2_0;
    __unsafe_unretained NSString * const r0_3_0;
    __unsafe_unretained NSString * const r0_4_0;
    __unsafe_unretained NSString * const r0_5_0;
    __unsafe_unretained NSString * const r0_6_0;
    __unsafe_unretained NSString * const r0_6_1;
    __unsafe_unretained NSString * const v1_1;
    __unsafe_unretained NSString * const v1_2;
    __unsafe_unretained NSString * const v1_3;
};
extern const struct MXSDNClientServerAPIVersionStruct MXSDNClientServerAPIVersion;

/**
 Features declared in the sdn specification.
 */
struct MXSDNVersionsFeatureStruct
{
    // Room members lazy loading
    __unsafe_unretained NSString * const lazyLoadMembers;
    __unsafe_unretained NSString * const requireIdentityServer;
    __unsafe_unretained NSString * const idAccessToken;
    __unsafe_unretained NSString * const separateAddAndBind;
};
extern const struct MXSDNVersionsFeatureStruct MXSDNVersionsFeature;

/**
 `MXSDNVersions` represents the versions of the SDN specification supported
 by the home server.
 It is returned by the /versions API.
 */
@interface MXSDNVersions : MXJSONModel<NSCoding>

/**
 The versions supported by the server.
 */
@property (nonatomic, readonly) NSArray<NSString *> *versions;

/**
 The unstable features supported by the server.
 
 */
@property (nonatomic, nullable, readonly) NSDictionary<NSString*, NSNumber*> *unstableFeatures;

/**
 Check whether the server supports the room members lazy loading.
 */
@property (nonatomic, readonly) BOOL supportLazyLoadMembers;

/**
 Indicate if the `id_server` parameter is required when registering with an 3pid,
 adding a 3pid or resetting password.
 */
@property (nonatomic, readonly) BOOL doesServerRequireIdentityServerParam;

/**
 Indicate if the `id_access_token` parameter can be safely passed to the node.
 Some nodes may trigger errors if they are not prepared for the new parameter.
 */
@property (nonatomic, readonly) BOOL doesServerAcceptIdentityAccessToken;

/**
 Indicate if the server supports separate 3PID add and bind functions.
 This affects the sequence of API calls clients should use for these operations,
 so it's helpful to be able to check for support.
 */
@property (nonatomic, readonly) BOOL doesServerSupportSeparateAddAndBind;

/**
 Indicate if the server supports threads via MSC3440.
 */
@property (nonatomic, readonly) BOOL supportsThreads;

/**
 Indicate if the server supports Remotely toggling push notifications via MSC3881.
 */
@property (nonatomic, readonly) BOOL supportsRemotelyTogglingPushNotifications;

/**
 Indicate if the server supports logging in via a QR
 */
@property (nonatomic, readonly) BOOL supportsQRLogin;

/**
 Indicate if the server supports notifications for threads (MSC3773)
 */
@property (nonatomic, readonly) BOOL supportsNotificationsForThreads;

/**
 Indicate if the server supports redactions with relations (MSC3912)
 */
@property (nonatomic, readonly) BOOL supportsRedactionWithRelations;

/**
 Indicate if the server supports redactions with relations (MSC3912 - Unstable)
 */
@property (nonatomic, readonly) BOOL supportsRedactionWithRelationsUnstable;

@end

NS_ASSUME_NONNULL_END
