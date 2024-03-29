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

#import <Foundation/Foundation.h>

#import "MXJSONModel.h"
#import "MXEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface MXAggregationPaginatedResponse : MXJSONModel

@property (nonatomic, readonly) NSArray<MXEvent*> *chunk;
@property (nonatomic, readonly, nullable) NSString *nextBatch;

// TODO: Make it non null when nodes support it
@property (nonatomic, readonly, nullable) MXEvent *originalEvent;

- (instancetype)initWithOriginalEvent:(MXEvent*)originalEvent
                                chunk:(NSArray<MXEvent*> *)chunk
                            nextBatch:(nullable NSString *)nextBatch;

@end

NS_ASSUME_NONNULL_END
