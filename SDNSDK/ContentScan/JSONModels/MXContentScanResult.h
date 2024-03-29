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

#import "MXJSONModel.h"

/**
 `MXContentScanResult` contains the antivirus scan result of a sdn content.
 */
@interface MXContentScanResult : MXJSONModel

/**
 If true, the script ran with an exit code of 0. Otherwise it ran with a non-zero exit code.
 */
@property (nonatomic) BOOL clean;

/**
 Human-readable information about the result.
 */
@property (nonatomic) NSString *info;

@end
