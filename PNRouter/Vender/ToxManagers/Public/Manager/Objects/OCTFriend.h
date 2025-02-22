// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

#import "OCTObject.h"
#import "OCTToxConstants.h"

/**
 * Class that represents friend (or just simply contact).
 *
 * Please note that all properties of this object are readonly.
 * You can change some of them only with appropriate method in OCTSubmanagerObjects.
 */
@interface OCTFriend : OCTObject

/**
 * Friend number that is unique for Tox.
 * In case if friend will be deleted, old id may be reused on new friend creation.
 */
@property OCTToxFriendNumber friendNumber;

/**
 * Nickname of friend.
 *
 * When friend is created it is set to the publicKey.
 * It is set to name when obtaining name for the first time.
 * After that name is unchanged (unless it is changed explicitly).
 *
 * To change please use OCTSubmanagerObjects method.
 */
@property (nonnull) NSString *nickname;

/**
 * Public key of a friend, is kOCTToxPublicKeyLength length.
 * Is constant, cannot be changed.
 */
@property (nonnull) NSString *publicKey;

/**
 * Name of a friend.
 *
 * May be empty.
 */
@property (nullable) NSString *name;

/**
 * Status message of a friend.
 *
 * May be empty.
 */
@property (nullable) NSString *statusMessage;

/**
 * Status message of a friend.
 */
@property OCTToxUserStatus status;

/**
 * Property specifies if friend is connected. For type of connection you can check
 * connectionStatus property.
 */
@property BOOL isConnected;

/**
 * Connection status message of a friend.
 */
@property OCTToxConnectionStatus connectionStatus;

/**
 * The date interval when friend was last seen online.
 * Contains actual information in case if friend has connectionStatus offline.
 */
@property NSTimeInterval lastSeenOnlineInterval;

/**
 * Whether friend is typing now in current chat. 现在朋友是否正在打字聊天。
 */
@property BOOL isTyping;

/**
 * Data representation of friend's avatar.朋友头像的数据表示。
 */
@property (nullable) NSData *avatarData;

/**
 * The date when friend was last seen online.
 * Contains actual information in case if friend has connectionStatus offline.  朋友最后一次出现在网上的日期。
 */
- (nullable NSDate *)lastSeenOnline;

@end

RLM_ARRAY_TYPE(OCTFriend)
