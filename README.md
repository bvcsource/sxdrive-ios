# SXDrive readme

Follow this readme to learn how to properly set up your machine, build, run and test the SXDrive project.

## Getting Started

### Xcode

Use the Xcode 6.0.1 or newer.

You can download it for free from the [App Store for Mac](https://itunes.apple.com/us/app/objective-clean/id713910413?ls=1&mt=12).

### Objective-Clean

Objective-Clean is used to maintain the code readable and in the proper style. It's not required but usable.

You can purchase it directly from the 
[App Store for Mac](https://itunes.apple.com/us/app/objective-clean/id713910413?ls=1&mt=12).

Once downloaded make sure it's in default applications directory:

_/Applications/Objective-Clean.app_

If you want to disable the syntax check:

1. Open the _SXDrive.xcworkspace_ in Xcode.
2. Select _SXDrive_ project.
3. Select _SXDrive_ target.
4. Switch to _Build phases_ tab.
5. Remove the _Objective-Clean_ phase.

### appledoc

Appledoc is used to generate the documentation for the classes, function, constants and other key elements of the project.

To install appledoc clone this [repository](https://github.com/tomaz/appledoc) and run the installation script with the following command in Terminal:

`sudo sh install-appledoc.sh`

If you want to disable the appledoc:

1. Open the _SXDrive.xcworkspace_ in Xcode.
2. Select _SXDrive_ project.
3. Select _SXDrive_ target.
4. Switch to _Build phases_ tab.
5. Remove the _Generate Documentation_ phase.

### CocoaPods

CocoaPods is the dependency manager for this project.

To install CocoaPods run the following command in Terminal:

`sudo gem install cocoapods`

To download the dependencies navigate to the project and run the following command in Terminal:

`pod install`

#### Troubleshooting known issues with CocoaPods

- Close Xcode, delete the Pods folder and run `pod install` again, relaunch Xcode.
- Remove the _~/.cocoapods_ directory and run the `pod install` command again.

## Building SXDrive

To build the application use the Xcode. Make sure the _SXDrive_ target is selected in the top left corner.

1. Open the _SXDrive.xcworkspace_ in Xcode.
2. Select _Product_.
3. Select _Build_.

Or just press _⌘+B_ as a step 2.

## Running SXDrive

To run the application use the Xcode. Make sure the _SXDrive_ target is selected in the top left corner and the appropriate device or simulator.

1. Open the _SXDrive.xcworkspace_ in Xcode.
2. Select _Product_.
3. Select _Run_.

Or just press _⌘+R_ as a step 2.

## Testing SXDrive

To perform unit tests use the Xcode. Make sure the _SXDrive_ target is selected in the top left corner and any simulator.

Code Coverage raport should automatically open in Browser once tests suite finishes.

1. Open the _SXDrive.xcworkspace_ in Xcode.
2. Select _Product_.
3. Select _Test_.

Or press _⌘+U_ as a step 2.

#### Troubleshooting issues with Code Coverage

Run the following command on repository top directory:

`sudo chmod -R 755 'XcodeCoverage'`
