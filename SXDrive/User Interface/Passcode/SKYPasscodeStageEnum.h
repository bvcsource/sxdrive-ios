//
//  SKYPasscodeStageEnum.h
//  SXDrive
//
//  Created by Skylable on 01/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

/**
 * Enumeration of passcode type.
 */
typedef NS_ENUM(NSUInteger, SKYPasscodeStage) {

	/**
	 * Stage for enter.
	 */
	SKYPasscodeStageEnter,
	
	/**
	 * Stage for create.
	 */
	SKYPasscodeStageCreate,
	
	/**
	 * Stage for confirm passcode (after creation or change).
	 */
	SKYPasscodeStageConfirm,
	
	/**
	 * Stage for change passcode.
	 */
	SKYPasscodeStageChange,
	
	/**
	 * Stage for delete passcode.
	 */
	SKYPasscodeStageDelete,
};
