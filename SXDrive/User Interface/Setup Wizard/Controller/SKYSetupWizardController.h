//
//  SKYSetupWizardController.h
//  SXDrive
//
//  Created by Skylable on 4/21/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYBaseController.h"
#import "SKYSetupWizardBehaviour.h"
#import "SKYSetupWizardBaseCell.h"

@interface SKYSetupWizardController : SKYBaseNibTableControllerImplementation <SKYSetupWizardBehaviourPresenter, SKYSetupWizardCellDelegate>

@end
