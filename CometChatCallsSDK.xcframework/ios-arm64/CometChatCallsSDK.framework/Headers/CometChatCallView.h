
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class CallSettings;

@interface CometChatCallView : UIView


/**
* Joins the conference specified by the given options. The given options will
* be merged with the defaultConferenceOptions (if set) in JitsiMeet. If there
* is an already active conference it will be automatically left prior to
* joining the new one.
*/
- (void)join:(NSDictionary *)settings;
/**
* Leaves the currently active conference.
*/
- (void)leave;

@end
