SDN iOS SDK
==============

This open-source library allows you to build iOS apps compatible with SDN
 an open standard for interoperable Instant Messaging

This SDK implements an interface to communicate with the SDN Client/Server



Use the SDK in your app
=======================


If you want to use the develop version of the SDK, use instead:

    pod 'SDNSDK', :git => https://github.com/Sending-Network/sendingnetwork-ios.git',
    :branch => 'main'


Overview
========

As a quick overview, there are the classes to know to use the SDK.



  

# login interface

#### 1. DID interface

##### Call order

1. Determine whether there is a did in the current address



    ```objective-c
    - (MXHTTPOperation *)getDIDList:(NSString *)address
                                  success:(void (^) (MXDIDListResponse *response))success
                            failure:(void (^)(NSError *error))failure
    ```

   





    Entry parameters:

| Name | Type | Description | Required |
| ---------- | :----- | :----------- | :------- |
| node | String | edgenode address | true |
| address | String | wallet address | True |

    Out of parameters:
    
    MXDIDListResponse

| Name | Type | Description | Required |
| ----- | :------ | :---------- | :------- |
| array | NSArray | user did list | true |


2. Select did or use address to log in. When the interface array is empty, use address to log in, otherwise use the first element of the array as the did parameter

    ```objective-c
    - (MXHTTPOperation *)postPreLoginDID:(NSString *)did
                             address:(NSString*)address
                              success:(void (^) (MXPreLoginResponse *response))success;
    ```
   
    Entry parameters:
   
    | Name | Type | Description | Required |
    | :------- | :----- | :------ | :------- |
    | did | string | did string, choose one of did and address | False |
    | address | String | Wallet address, choose one of did and address | False |
   
    Out of parameters:
   
    MXPreLoginResponse

    | Name | Type | Description | Required |
    | ------------- | ------ | ------------- | ---- |
    | did | string | user did | true |
    | message | string | message to be signed | true |
    | updated | string | updated time | true |
    | random_server | string | update time | true |
   
3. Sign the message return value of 2 with appServiceSign

    ```objective-c
    - (void)appServiceSign:(NSString *)message
                   success:(void (^) (NSDictionary *dic))success
                   failure:(void (^)(NSError *error))failure;
    ```
   
    Entry parameters:
   
    | Name | Type | Description | Required |
    | :------- | :----- | :------------ | :------- |
    | message | string | returned message | True |
    | | | | |
   
    Out of parameters:
   
    NSDictionary
   
    | Name | Type | Description |Required|
    | --------- | ------ | ----------- | ------- |
    | signature | string | message to be signed | true |
   
    The `signature` returned by the interface is used as the app_token parameter of the fourth step interface to log in


4. Perform wallet signature on the return value message of 2

   ```dart
   NSString *hexMessage = [self convertStringToHexStr:message];
   [WrapParticleAuthService signMessageWithMessage:hexMessage successHandler:^(NSString *signMessage)
   ```


Entry parameters:

LoginRequest

| Name | Type | Description | Required |
| :---------- | :------------- | :----------------------- | :------- |
| type | string | login type (currently m.login.did.identity) | true |
| updated | string | time, updated | true | returned by pre_login
| identifier | IdentifierModel | login info | true |
| `device_id` | string | device id, new device login does not need to pass this field | false |

IdentifierModel type:

| Name | Type | Description |
| :-------- | :----- | :--------------------------- |
| did | string | user did |
| token | string | Sign the message returned by pre_login. The signature method is `Sign directly with the private key: You can directly call EthSigUtil.signPersonalMessage in the did class to sign |
| app_token | string | Sign the message returned by pre_login. The signature method is to use the interface "appServiceSign" to sign |


Out of parameters:

MXDIDLoginResponse

| Name | Type | Description | Required |
| :----------- | :----- | :---------- | :------- |
| access_token | string | access token | true |
| user_id | string | user id | true |
| device_id | string | device id | true |


> For the complete login process of 1 2 3 4 refer to `MXKAuthenticationViewController` in `sendingnetwork-ios-demo`



# message interface

```objective-c
- (MXHTTPOperation*)sendEventOfType:(MXEventTypeString)eventTypeString
                             content:(NSDictionary<NSString*, id>*)content
                            threadId:(NSString*)threadId
                           localEcho:(MXEvent**)localEcho
                             success:(void (^)(NSString *eventId))success
                             failure:(void (^)(NSError *error))failure NS_REFINED_FOR_SWIFT;
```

Entry parameters:

LoginRequest

| Name            | Type                           | Description                                                  | Required |
| :-------------- | :----------------------------- | ------------------------------------------------------------ | :------- |
| eventTypeString | MXEventTypeString              | the type of the event. @see MXEventType                      | true     |
| content         | NSDictionary                   | the content that will be sent to the server as a JSON object. | true     |
| threadId        | NSString                       | the identifier of thread to send the event.                  | true     |
| `localEcho`     | MXEvent                        | a pointer to a MXEvent object                                | true     |
| `success`       | MXAggregationPaginatedResponse |                                                              | true     |
| `failure`       | **void** (^)(NSError *error)   |                                                              | true     |

SDN API level
----------------

:``MXRestClient``:
    Exposes the SDN Client-Server API as specified by the SDN standard to
    make requests to a node.


Business logic and data model
-----------------------------
These classes are higher level tools to handle responses from a node.
They contain logic to maintain consistent chat room data.

:``MXSession``:
    This class handles all data arriving from the node. It uses a
    MXRestClient instance to fetch data from the node, forwarding it to
    MXRoom, MXRoomState, MXRoomMember and MXUser objects.

:``MXRoom``:
     This class provides methods to get room data and to interact with the room
     (join, leave...).

:``MXRoomState``:
     This is the state of room at a certain point in time: its name, topic,
     visibility (public/private), members, etc.

:``MXRoomMember``:
     Represents a member of a room.

:``MXUser``:
     This is a user known by the current user, outside of the context of a
     room. MXSession exposes and maintains the list of MXUsers. It provides
     the user id, displayname and the current presence state.



Usage
=====


demonstrates how to build a chat app on top of SDN. You can refer to it,
play with it, hack it to understand the full integration of the SDN SDK.
This section comes back to the basics with sample codes for basic use cases.

One file to import:

**Obj-C**::

    #import <SDNSDK/SDNSDK.h>

**Swift**::

    import SDNSDK

Use case #1: Get public rooms of an node
-----------------------------------------------
This API does not require the user to be authenticated. So, MXRestClient
instantiated with initWithNode does the job:

**Obj-C**::

    MXRestClient *mxRestClient = [[MXRestClient alloc] initWithNode:@"http://sdn.org"];
    [mxRestClient publicRooms:^(NSArray *rooms) {
    
        // rooms is an array of MXPublicRoom objects containing information like room id
        MXLogDebug(@"The public rooms are: %@", rooms);
    
    } failure:^(MXError *error) {
    }];

**Swift**::

    let nodeUrl = URL(string: "http://sdn.org")!
    let mxRestClient = MXRestClient(node: nodeUrl, unrecognizedCertificateHandler: nil)
    mxRestClient.publicRooms { response in
        switch response {
        case .success(let rooms):
    
            // rooms is an array of MXPublicRoom objects containing information like room id
            print("The public rooms are: \(rooms)")
    
        case .failure: break
        }
    }


Use case #2: Get the rooms the user has interacted with
-------------------------------------------------------
Here the user needs to be authenticated. We will use
[MXRestClient initWithCredentials].
You'll normally create and initialise these two objects once the user has
logged in, then keep them throughout the app's lifetime or until the user logs
out:

**Obj-C**::

    MXCredentials *credentials = [[MXCredentials alloc] initWithNode:@"http://sdn.org"
                                                                    userId:@"@your_user_id:sdn.org"
                                                               accessToken:@"your_access_token"];
    
    // Create a sdn client
    MXRestClient *mxRestClient = [[MXRestClient alloc] initWithCredentials:credentials];
    
    // Create a sdn session
    MXSession *mxSession = [[MXSession alloc] initWithSDNRestClient:mxRestClient];
    
    // Launch mxSession: it will first make an initial sync with the node
    // Then it will listen to new coming events and update its data
    [mxSession start:^{
    
        // mxSession is ready to be used
        // Now we can get all rooms with:
        mxSession.rooms;
    
    } failure:^(NSError *error) {
    }];

**Swift**::

    let credentials = MXCredentials(node: "http://sdn.org",
                                    userId: "@your_user_id:sdn.org",
                                    accessToken: "your_access_token")
    
    // Create a sdn client
    let mxRestClient = MXRestClient(credentials: credentials, unrecognizedCertificateHandler: nil)
    
    // Create a sdn session
    let mxSession = MXSession(sdnRestClient: mxRestClient)
    
    // Launch mxSession: it will first make an initial sync with the node
    mxSession.start { response in
        guard response.isSuccess else { return }
    
        // mxSession is ready to be used
        // now wer can get all rooms with:
        mxSession.rooms
    }


Use case #2 (bis): Get the rooms the user has interacted with (using a permanent MXStore)
-----------------------------------------------------------------------------------------
We use the same code as above but we add a MXFileStore that will be in charge of
storing user's data on the file system. This will avoid to do a full sync with the
node each time the app is resumed. The app will be able to resume quickly.
Plus, it will be able to run in offline mode while syncing with the node:

**Obj-C**::

    MXCredentials *credentials = [[MXCredentials alloc] initWithNode:@"http://sdn.org"
                                                                    userId:@"@your_user_id:sdn.org"
                                                               accessToken:@"your_access_token"];
    
    // Create a sdn client
    MXRestClient *mxRestClient = [[MXRestClient alloc] initWithCredentials:credentials];
    
    // Create a sdn session
    MXSession *mxSession = [[MXSession alloc] initWithSDNRestClient:mxRestClient];
    
    // Make the sdn session open the file store
    // This will preload user's messages and other data
    MXFileStore *store = [[MXFileStore alloc] init];
    [mxSession setStore:store success:^{
    
        // Launch mxSession: it will sync with the node from the last stored data
        // Then it will listen to new coming events and update its data
        [mxSession start:^{
    
            // mxSession is ready to be used
            // Now we can get all rooms with:
            mxSession.rooms;
    
        } failure:^(NSError *error) {
        }];
    } failure:^(NSError *error) {
    }];

**Swift**::

    let credentials = MXCredentials(node: "http://sdn.org",
                                    userId: "@your_user_id:sdn.org",
                                    accessToken: "your_access_token")
    
    // Create a sdn client
    let mxRestClient = MXRestClient(credentials: credentials, unrecognizedCertificateHandler: nil)
    
    // Create a sdn session
    let mxSession = MXSession(sdnRestClient: mxRestClient)
    
    // Make the sdn session open the file store
    // This will preload user's messages and other data
    let store = MXFileStore()
    mxSession.setStore(store) { response in
        guard response.isSuccess else { return }
    
        // Launch mxSession: it will sync with the node from the last stored data
        // Then it will listen to new coming events and update its data
        mxSession.start { response in
            guard response.isSuccess else { return }
    
            // mxSession is ready to be used
            // now we can get all rooms with:
            mxSession.rooms()
        }
    }




Use case #3: Get messages of a room
-----------------------------------
We reuse the mxSession instance created before:

**Obj-C**::

    // Retrieve the room from its room id
    MXRoom *room = [mxSession room:@"!room_id:sdn.org"];
    
    // Add a listener on events related to this room
    [room.liveTimeline listenToEvents:^(MXEvent *event, MXEventDirection direction, MXRoomState *roomState) {
    
        if (direction == MXTimelineDirectionForwards) {
            // Live/New events come here
        }
        else if (direction == MXTimelineDirectionBackwards) {
            // Events that occurred in the past will come here when requesting pagination.
            // roomState contains the state of the room just before this event occurred.
        }
    }];

**Swift**::

    // Retrieve the room from its room id
    let room = mxSession.room(withRoomId: "!room_id:sdn.org")
    
    // Add a listener on events related to this room
    _ = room?.liveTimeline.listenToEvents { (event, direction, roomState) in
        switch direction {
        case .forwards:
            // Live/New events come here
            break
    
        case .backwards:
            // Events that occurred in the past will come here when requesting pagination.
            // roomState contains the state of the room just before this event occurred.
            break
        }
    }


Let's load a bit of room history using paginateBackMessages:

**Obj-C**::

    // Reset the pagination start point to now
    [room.liveTimeline resetPagination];
    
    [room.liveTimeline paginate:10 direction:MXTimelineDirectionBackwards onlyFromStore:NO complete:^{
    
        // At this point, the SDK has finished to enumerate the events to the attached listeners
    
    } failure:^(NSError *error) {
    }];

**Swift**::

    // Reset the pagination start point to now
    room?.liveTimeline.resetPagination()
    
    room?.liveTimeline.paginate(10, direction: .backwards, onlyFromStore: false) { _ in
        // At this point, the SDK has finished to enumerate the events to the attached listeners
    }



Use case #4: Post a text message to a room
------------------------------------------
This action does not require any business logic from MXSession: We can use
MXRestClient directly:

**Obj-C**::

    [mxRestClient sendTextMessageToRoom:@"the_room_id" text:@"Hello world!" success:^(NSString *event_id) {
    
        // event_id is for reference
        // If you have registered events listener like in the previous use case, you will get
        // a notification for this event coming down from the node events stream and
        // now handled by MXSession.
    
    } failure:^(NSError *error) {
    }];

**Swift**::

    client.sendTextMessage(toRoom: "the_room_id", text: "Hello World!") { (response) in
        if case .success(let eventId) = response {
            // eventId is for reference
            // If you have registered events listener like in the previous use case, you will get
            // a notification for this event coming down from the node events stream and
            // now handled by MXSession.
        }
    }

Push Notifications
==================


for the specification on the HTTP Push Notification protocol. Your push
gateway can listen for notifications on any path (as long as your app knows
that path in order to inform the node) but SDN strongly recommends
that the path of this URL be
'/_api/push/v1/notify'.

In your application, you will first register for APNS in the normal way
(assuming iOS 8 or above)::

    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                         |UIRemoteNotificationTypeSound
                                                                                         |UIRemoteNotificationTypeAlert)
                                                                                         categories:nil];
    [...]
    
    - (void)application:(UIApplication *)application
            didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
    {
        [application registerForRemoteNotifications];
    }

When you receive the APNS token for this particular application instance, you
then encode this into text and use it as the 'pushkey' to call
setPusherWithPushkey in order to tell the node to send pushes to this
device via your push gateway's URL. SDN recommends base 64
encoding for APNS tokens (as this is what sygnal uses)::

    - (void)application:(UIApplication*)app
      didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
        NSString *b64Token = [self.deviceToken base64EncodedStringWithOptions:0];
        NSDictionary *pushData = @{
            @"url": @"https://example.com/_api/push/v1/notify" // your push gateway URL
        };
        NSString *deviceLang = [NSLocale preferredLanguages][0];
        NSString *profileTag = makeProfileTag(); // more about this later
        MXRestClient *restCli = [SDNSDKHandler sharedHandler].mxRestClient;
        [restCli
            setPusherWithPushkey:b64Token
            kind:@"http"
            appId:@"com.example.supercoolsdnapp.prod"
            appDisplayName:@"My Super Cool SDN iOS App"
            deviceDisplayName:[[UIDevice currentDevice] name]
            profileTag:profileTag
            lang:deviceLang
            data:pushData
            success:^{
                // Hooray!
            } failure:^(NSError *error) {
                // Some super awesome error handling goes here
            }
        ];
    }

When you call setPusherWithPushkey, this creates a pusher on the node
that your session is logged in to. This will send HTTP notifications to a URL
you supply as the 'url' key in the 'data' argument to setPusherWithPushkey.



appId
  This has two purposes: firstly to form the namespace in which your pushkeys
  exist on a node, which means you should use something unique to your
  application: a reverse-DNS style identifier is strongly recommended. Its
  second purpose is to identify your application to your Push Gateway, such that
  your Push Gateway knows which private key and certificate to use when talking
  to the APNS gateway. You should therefore use different app IDs depending on
  whether your application is in production or sandbox push mode so that your
  Push Gateway can send the APNS accordingly. SDN recommends suffixing your
  appId with '.dev' or '.prod' accordingly.



Development
===========

The repository contains a Xcode project in order to develop. This project does
not build an app but a test suite. See the next section to set the test
environment.

Before opening the SDN SDK Xcode workspace, you need to build it.

The project has some third party library dependencies declared in a pod file.
You need to run the CocoaPods command to download them and to set up the SDN
SDK workspace::

        $ pod install

Then, open ``SDNSDK.xcworkspace``.

>

Copyright & License
==================

Copyright (c) 2014-2017 OpenMarket Ltd
Copyright (c) 2017 Vector Creations Ltd
Copyright (c) 2017-2018 New Vector Ltd

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
