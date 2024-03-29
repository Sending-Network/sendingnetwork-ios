/*
 Copyright 2016 OpenMarket Ltd
 
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

#import "NSData+SDNSDK.h"

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (SDNSDK)

- (NSString*)mx_MD5
{
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
 
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(self.bytes, (CC_LONG)self.length, md5Buffer);
    
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x",md5Buffer[i]];
    }
    
    return output;
}

- (NSString*)mx_SHA256
{
    // Create byte array of unsigned chars
    unsigned char sha256Buffer[CC_SHA256_DIGEST_LENGTH];
    
    // Create 32 byte SHA256 hash value, store in buffer
    CC_SHA256(self.bytes, (CC_LONG)self.length, sha256Buffer);
    
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x",sha256Buffer[i]];
    }
    
    return output;
}

- (NSString*)mx_SHA256AsHexString
{
    // Create byte array of unsigned chars
    unsigned char sha256Buffer[CC_SHA256_DIGEST_LENGTH];
    
    // Create 32 byte SHA256 hash value, store in buffer
    CC_SHA256(self.bytes, (CC_LONG)self.length, sha256Buffer);
    
    // Convert unsigned char buffer to NSString of hex values by adding a white space between each value.
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 3];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02X ",sha256Buffer[i]];
    }
    
    return output;
}

@end
