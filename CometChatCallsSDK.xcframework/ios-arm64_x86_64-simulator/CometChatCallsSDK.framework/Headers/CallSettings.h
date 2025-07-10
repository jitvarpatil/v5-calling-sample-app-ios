#import <Foundation/Foundation.h>
#import "AudioModeType.h"

NS_ASSUME_NONNULL_BEGIN

@interface CallSettings : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy, nullable) NSString *displayName;
@property (nonatomic, assign) BOOL startVideoPaused;
@property (nonatomic, assign) BOOL startAudioMuted;
@property (nonatomic, assign) NSInteger idleTimeoutPeriod;

@property (nonatomic, assign) BOOL audioOnlyMode;
@property (nonatomic, assign) BOOL lowBandwidthMode;
@property (nonatomic, assign) BOOL raiseHand;
@property (nonatomic, assign) BOOL recording;
@property (nonatomic, assign) BOOL autoStartRecording;

@property (nonatomic, assign) BOOL hideControlPanel;
@property (nonatomic, assign) BOOL hideHeaderPanel;
@property (nonatomic, assign) BOOL hideEndCallButton;
@property (nonatomic, assign) BOOL hideToggleAudioButton;
@property (nonatomic, assign) BOOL hideToggleVideoButton;
@property (nonatomic, assign) BOOL hideParticipantListButton;
@property (nonatomic, assign) BOOL hideLayoutToggleButton;
@property (nonatomic, assign) BOOL hideCameraSourceToggleButton;
@property (nonatomic, assign) BOOL hideSettings;
@property (nonatomic, assign) BOOL hideChatButton;

@property (nonatomic, copy) NSString *devSessionId;

- (instancetype)init;
- (NSDictionary *)asProps;

@end

NS_ASSUME_NONNULL_END
