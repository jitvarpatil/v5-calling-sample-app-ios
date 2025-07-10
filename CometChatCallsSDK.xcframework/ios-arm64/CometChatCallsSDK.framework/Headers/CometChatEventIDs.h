// CometChatEventIDs.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CometChatEventIDs : NSObject

// Session status events
extern NSString * const onConnectionLost;
extern NSString * const onConnectionRestored;
extern NSString * const onSessionJoined;
extern NSString * const onSessionLeft;

// Participant events
extern NSString * const onParticipantListChanged;
extern NSString * const onParticipantJoined;
extern NSString * const onParticipantLeft;
extern NSString * const onParticipantAudioMuted;
extern NSString * const onParticipantAudioUnmuted;
extern NSString * const onParticipantVideoPaused;
extern NSString * const onParticipantVideoUnPaused;
extern NSString * const onParticipantHandRaised;
extern NSString * const onParticipantHandLowered;
extern NSString * const onParticipantStartedScreenSharing;
extern NSString * const onParticipantStoppedScreenSharing;
extern NSString * const onParticipantStartedRecording;
extern NSString * const onParticipantStoppedRecording;

// Media events
extern NSString * const onRecordingStarted;
extern NSString * const onRecordingStopped;
extern NSString * const onAudioModeChanged;
extern NSString * const onVideoSourceChanged;
extern NSString * const onAudioMuted;
extern NSString * const onAudioUnMuted;
extern NSString * const onVideoPaused;
extern NSString * const onVideoUnPaused;

// Button click events
extern NSString * const onEndCallButtonClicked;
extern NSString * const onRaiseHandButtonClicked;
extern NSString * const onChangeLayoutButtonClicked;
extern NSString * const onParticipantListButtonClicked;
extern NSString * const onMuteAudioButtonClicked;
extern NSString * const onPauseVideoButtonClicked;
extern NSString * const onCameraSourceToggleButtonClicked;
extern NSString * const onRecordingToggleButtonClicked;
extern NSString * const onCameraFacingChanged;
extern NSString * const onToggleAudioButtonClicked;
extern NSString * const onToggleVideoButtonClicked;
extern NSString * const onLeaveSessionButtonClicked;
extern NSString * const onVideoResumed;

@end

NS_ASSUME_NONNULL_END
