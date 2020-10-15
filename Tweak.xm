#import "Headers.h"
#import <notify.h>

//TextTime
//Made During COVID
//Lightmann

%group tweak
// determine if device is set to 24-hour time (https://stackoverflow.com/a/7538489)
static BOOL twentyfourHourTime(){
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setLocale:[NSLocale currentLocale]];
	[formatter setDateStyle:NSDateFormatterNoStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	NSString *dateString = [formatter stringFromDate:[NSDate date]];
	NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
	NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
	BOOL is24h = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
	if(is24h) //changed from here down
		return YES;
	else 
		return NO;
}

%hook SBFLockScreenDateView
//generate words and then change label to display said words instead of #s
-(void)_updateLabels{
	%orig;

	SBUILegibilityLabel *timeLabel = MSHookIvar<SBUILegibilityLabel*>(self, "_timeLabel");	
	SBFLockScreenDateSubtitleDateView *dateLabel = MSHookIvar<SBFLockScreenDateSubtitleDateView*>(self, "_dateSubtitleView");	
	
	//if length == 0 it will crash
	if(timeLabel.string.length){
		//get the time excluding ":" -- thanks to u/w4llyb3ar on Reddit (https://www.reddit.com/user/w4llyb3ar/) for the initial direction here
		NSString *hourString = [timeLabel.string substringWithRange:NSMakeRange(0, [timeLabel.string rangeOfString:@":"].location)];//for some reason the method used for finding the minutes' location doesn't work for hours (location - 1) so instead I grab the string from the range (0 - :), which produces the same thing
		NSString *minString = [timeLabel.string substringFromIndex:([timeLabel.string rangeOfString:@":"].location + 1)];

		//convert ^ to nsnumbers and then to words 
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		NSNumber *hourValue = [numberFormatter numberFromString:hourString]; 
		NSNumber *minValue = [numberFormatter numberFromString:minString]; 
		[numberFormatter setNumberStyle:NSNumberFormatterSpellOutStyle];
		NSString *hourWord = [numberFormatter stringFromNumber:hourValue];
		NSString *minWord = [numberFormatter stringFromNumber:minValue];

		//special cases 
		if(twentyfourHourTime()){
			// reason for doubleValue conversions (https://stackoverflow.com/a/6605285)
			if(([hourValue doubleValue] > [[NSNumber numberWithInt:0] doubleValue]) && ([hourValue doubleValue] < [[NSNumber numberWithInt:10] doubleValue])) // "oh + hourWord" for hour < 10, but > 0
				hourWord = [@"oh " stringByAppendingString:hourWord];

			if([hourString isEqualToString:@"00"]) // "twenty four" for 00 hours 
				hourWord = @"twenty four";

			if([minValue doubleValue] > [[NSNumber numberWithInt:0] doubleValue] && [minValue doubleValue] < [[NSNumber numberWithInt:10] doubleValue]) // "oh + minWord" for min < 10, but > 0
				minWord = [@"oh " stringByAppendingString:minWord];
				
			if([minString isEqualToString:@"00"])  // "hundred" for 00 min 
				minWord = @"hundred";
		}
		else{
			if([minValue doubleValue] > [[NSNumber numberWithInt:0] doubleValue] && [minValue doubleValue] < [[NSNumber numberWithInt:10] doubleValue]) // "o' + minWord" for min < 10, but > 0
				minWord = [@"o' " stringByAppendingString:minWord];

			if([minString isEqualToString:@"00"]) // "o' clock" for 00 min
				minWord = @"o' clock";
		}

		//make one string from hours and minutes 
		NSString *baseBaseString = ([NSString stringWithFormat:@"%@ %@",hourWord,minWord]);

		//remove any instances of "-" from the string that were created by the formatter
		NSString *baseString = [baseBaseString stringByReplacingOccurrencesOfString:@"-" withString:@" "];

		//some style stuff that requires access to the new string 
		if(fontStyle == 0){
			textTime = baseString;
			[dateLabel setString:[dateLabel.string lowercaseString]];
		}
		if(fontStyle == 1){
			textTime = [baseString capitalizedString];
			[dateLabel setString:[dateLabel.string capitalizedString]];
		}
		if(fontStyle == 2){
			textTime = [baseString uppercaseString];
			[dateLabel setString:[dateLabel.string uppercaseString]];
		}

		//using an NSMutableAttributedString as opposed to the standard NSString because I wanted to change the line spacing 
		NSMutableAttributedString* attrString = [[NSMutableAttributedString  alloc] initWithString:textTime];
		NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];		
		[style setMaximumLineHeight:timeLabel.font.pointSize]; // limits line spacing (effectively shrinking it)
		[attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, textTime.length)];
		
		// sets my word string as label string
		timeLabel.attributedText = attrString;
	}

	//set my label's height to the dynamic one calculated below 
	timeLabel.frame = CGRectMake(timeLabel.frame.origin.x, timeLabel.frame.origin.y+10, self.bounds.size.width, [self getLabelHeight]);
}

//style stuff
-(void)updateFormat{
	%orig;

	SBUILegibilityLabel *timeLabel = MSHookIvar<SBUILegibilityLabel*>(self, "_timeLabel");	
	SBFLockScreenDateSubtitleDateView *dateLabel = MSHookIvar<SBFLockScreenDateSubtitleDateView*>(self, "_dateSubtitleView");	

	//allow for word wrapping
	timeLabel.numberOfLines = 0;

	if(fontSize == 0)
		timeLabel.font = [timeLabel.font fontWithSize:int((kHeight*.1)-10)];

	if(fontSize != 0)
		timeLabel.font = [timeLabel.font fontWithSize:int(((kHeight*.1)-10)+fontSize)];

	dateLabel.font = [dateLabel.font fontWithSize:int(timeLabel.font.pointSize*.367)];

	if(fontWeight == 0)
		timeLabel.font = [timeLabel.font fontWithSize:timeLabel.font.pointSize];

	if(fontWeight == 1)
		timeLabel.font = [UIFont systemFontOfSize:timeLabel.font.pointSize weight:UIFontWeightUltraLight];

	if(fontWeight == 2)
		timeLabel.font = [UIFont systemFontOfSize:timeLabel.font.pointSize weight:UIFontWeightThin];

	if(fontWeight == 3)
		timeLabel.font = [UIFont systemFontOfSize:timeLabel.font.pointSize weight:UIFontWeightLight];

	if(fontWeight == 4)
		timeLabel.font = [UIFont systemFontOfSize:timeLabel.font.pointSize weight:UIFontWeightRegular]; 
		
	if(fontWeight == 5)
		timeLabel.font = [UIFont systemFontOfSize:timeLabel.font.pointSize weight:UIFontWeightMedium]; 

	if(fontWeight == 6)
		timeLabel.font = [UIFont systemFontOfSize:timeLabel.font.pointSize weight:UIFontWeightSemibold]; 
		
	if(fontWeight == 7)
		timeLabel.font = [UIFont systemFontOfSize:timeLabel.font.pointSize weight:UIFontWeightBold];

	if(fontWeight == 8)
		timeLabel.font = [UIFont systemFontOfSize:timeLabel.font.pointSize weight:UIFontWeightHeavy];
}

//positioning of time/date
-(void)setFrame:(CGRect)frame{		
	//make sure time stays at or below the standard position
	if(frame.origin.y < 96)
		%orig(CGRectMake(frame.origin.x, 96, frame.size.width, frame.size.height));

	//if single line due to either of the reasons checked in the if, lower the label 
	if(timeHeight < containerHeight && fontSize < 0)
		%orig(CGRectMake(frame.origin.x, frame.origin.y+dateHeight, frame.size.width, frame.size.height));

	else
		%orig;

	//get a value to be used later
	containerHeight = frame.size.height;
}

//alignment and position of time label 
-(CGRect)_timeLabelFrameForAlignmentPercent:(double)arg1 {							
	CGRect x = %orig;
	SBUILegibilityLabel *timeLabel = MSHookIvar<SBUILegibilityLabel*>(self, "_timeLabel");	
	int orientation = [[%c(SpringBoard) sharedApplication] activeInterfaceOrientation];

	if(arg1 >= .75){
		//fix alignment of time when switching to today view 
		[UIView animateWithDuration:.1 animations:^{
			timeLabel.textAlignment = NSTextAlignmentRight;     
		}];
		return CGRectMake((arg1*100)-92, x.origin.y, x.size.width, x.size.height);
	}
	else{
		//default time
		if(orientation == 1 || orientation == 2){
			[UIView animateWithDuration:.1 animations:^{
				if(customAlignment == 0)
					timeLabel.textAlignment = NSTextAlignmentLeft;
				if(customAlignment == 1)
					timeLabel.textAlignment = NSTextAlignmentCenter; 
				if(customAlignment == 2)
					timeLabel.textAlignment = NSTextAlignmentRight;    
			}];
			if(customAlignment == 1)
				return CGRectMake((arg1*100), x.origin.y, x.size.width, x.size.height);
			else
				return CGRectMake((arg1*10), x.origin.y, x.size.width, x.size.height);
		} 
		// fix alignment of time when horizontal
    	if (orientation == 3 || orientation == 4){
			[UIView animateWithDuration:.1 animations:^{
				timeLabel.textAlignment = NSTextAlignmentLeft;   
			}];
			return CGRectMake(x.origin.x, x.origin.y, x.size.width, x.size.height);
		}
	}

	return x; 
}

//adjust date and charging labels' frames to be relative to time label
-(CGRect)_subtitleViewFrameForView:(UIView*)arg1 alignmentPercent:(double)arg2 {		
	CGRect x = %orig;
	dateHeight = x.size.height;
	SBUILegibilityLabel *timeLabel = MSHookIvar<SBUILegibilityLabel*>(self, "_timeLabel");		
	int orientation = [[%c(SpringBoard) sharedApplication] activeInterfaceOrientation];

	//fix alignment of time when switching to today view 	
	if(arg2 >= .75 && (orientation == 1 || orientation == 2)){
		return CGRectMake(x.origin.x+5, (timeLabel.frame.origin.y+timeLabel.frame.size.height-(x.size.height*.5)), x.size.width, x.size.height);
	}
	else{
		//left aligned when normal
		if(customAlignment == 0 && (orientation == 1 || orientation == 2))
			return CGRectMake(x.origin.x-6.5, (timeLabel.frame.origin.y+timeLabel.frame.size.height-(x.size.height*.5)), x.size.width, x.size.height);
		// default and horizontal  
		else
			return CGRectMake(x.origin.x, (timeLabel.frame.origin.y+timeLabel.frame.size.height-(x.size.height*.5)), x.size.width, x.size.height);
	}
	return x;
}

//custom alignment  
- (void)setAlignmentPercent:(double)arg1 {
	int orientation = [[%c(SpringBoard) sharedApplication] activeInterfaceOrientation];
	if(arg1 < .75 && (orientation == 1 || orientation == 2)){
		if (customAlignment == 0)
			%orig(-1.0);
		if (customAlignment == 1)
			%orig(0.0); 
		if (customAlignment == 2)
			%orig(1.0);
	}
	else{
		%orig;
	}
}

//compact/hide date 
- (void)setUseCompactDateFormat:(BOOL)arg1 {
	SBFLockScreenDateSubtitleDateView *dateLabel = MSHookIvar<SBFLockScreenDateSubtitleDateView*>(self, "_dateSubtitleView");		
	
	if(compactDate)
		arg1 = YES;
	if(hideDate)
		[dateLabel setHidden:YES];
	else
	 	%orig;
}

%new
//get label height dynamically based on text (https://stackoverflow.com/a/27374760)
- (CGFloat)getLabelHeight{
	SBUILegibilityLabel *timeLabel = MSHookIvar<SBUILegibilityLabel*>(self, "_timeLabel");	

    CGSize constraint = CGSizeMake(self.frame.size.width, CGFLOAT_MAX);

    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [textTime boundingRectWithSize:constraint
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:timeLabel.font}
                                                  context:context].size;

    CGSize size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
	timeHeight = size.height;//added
    return size.height;
}
%end


// adjust nclist (notifications & music player) based on height of time+date -- modified from Lower by s1ris (https://github.com/s1ris/Lower/blob/master/Tweak.xm)
%hook CSCombinedListViewController 
-(id)initWithNibName:(id)arg1 bundle:(id)arg2 {
    int notify_token2;
    // Relayout on lockState change
    notify_register_dispatch("me.lightmann.texttime/notif", &notify_token2, dispatch_get_main_queue(), ^(int token) {
        [self layoutListView];
    });
    return %orig;
}

-(UIEdgeInsets)_listViewDefaultContentInsets {
    UIEdgeInsets originalInsets = %orig;
	int orientation = [[%c(SpringBoard) sharedApplication] activeInterfaceOrientation];
    float yOffset;

    if (orientation == 1 || orientation == 2)
       yOffset = (timeHeight+(dateHeight/2))-containerHeight+5;
    
    else
        yOffset = 0;

    // Updates the insets
    originalInsets.top += yOffset;
    return originalInsets;
}

-(void)layoutListView {
    %orig;
    [self _updateListViewContentInset];
}

-(double)_minInsetsToPushDateOffScreen {
    double orig = %orig;
	int orientation = [[%c(SpringBoard) sharedApplication] activeInterfaceOrientation];
    float yOffset;

    if (orientation == 1 || orientation == 2)
        yOffset = (timeHeight+(dateHeight/2))-containerHeight+5;
	else
		yOffset = 0;

    return orig + yOffset;
}
%end


//make change when device lockState changes -- modified from Lower by s1ris (https://github.com/s1ris/Lower/blob/master/Tweak.xm)
%hook SBLockStateAggregator
-(void)_updateLockState {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.texttime/notif"), nil, nil, true);
    %orig;
}
%end


//toggle vibrancy effect 
%hook CSCoverSheetView
-(void)setDateViewIsVibrant:(BOOL)arg1 {
	if(vibrancy)
		%orig(YES);
	else	
		%orig;
}
%end


//alignment and position of lock icon/hide lock icon
%hook SBUIProudLockIconView
-(void)setFrame:(CGRect)frame{
	UIView *lockGlyph = MSHookIvar<BSUICAPackageView*>(self, "_lockView");

	if(customAlignment == 0)
		%orig(CGRectMake(-(kWidth/2)+lockGlyph.frame.size.width+5, frame.origin.y ,frame.size.width ,frame.size.height));
	if(customAlignment == 1)
		%orig;
	if(customAlignment == 2)
		%orig(CGRectMake((kWidth/2)-lockGlyph.frame.size.width-10, frame.origin.y, frame.size.width, frame.size.height));

	if(hideLock)
		[self setHidden:YES];
}
%end


//hide coaching view 
%hook SBUIFaceIDCoachingView
-(id)_label{	
	return nil;
}
%end
%end


//	PREFERENCES 
static void loadPrefs() {
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/me.lightmann.texttimeprefs.plist"];

  if(prefs){
    isEnabled = ( [prefs objectForKey:@"isEnabled"] ? [[prefs objectForKey:@"isEnabled"] boolValue] : YES );
	customAlignment = ( [prefs valueForKey:@"customAlignment"] ? [[prefs valueForKey:@"customAlignment"] integerValue] : 1 );
	fontStyle = ( [prefs valueForKey:@"fontStyle"] ? [[prefs valueForKey:@"fontStyle"] integerValue] : 0 );
	fontWeight = ( [prefs objectForKey:@"fontWeight"] ? [[prefs objectForKey:@"fontWeight"] integerValue] : 0 );
	fontSize = ( [prefs valueForKey:@"fontSize"] ? [[prefs valueForKey:@"fontSize"] floatValue] : 0 );
	vibrancy = ( [prefs objectForKey:@"vibrancy"] ? [[prefs objectForKey:@"vibrancy"] boolValue] : NO );
	hideDate = ( [prefs objectForKey:@"hideDate"] ? [[prefs objectForKey:@"hideDate"] boolValue] : NO );
	compactDate = ( [prefs objectForKey:@"compactDate"] ? [[prefs objectForKey:@"compactDate"] boolValue] : NO );
	hideLock = ( [prefs objectForKey:@"hideLock"] ? [[prefs objectForKey:@"hideLock"] boolValue] : NO );
  }
}

static void initPrefs() {
  // Copy the default preferences file when the actual preference file doesn't exist
  NSString *path = @"/User/Library/Preferences/me.lightmann.texttimeprefs.plist";
  NSString *pathDefault = @"/Library/PreferenceBundles/TextTimePrefs.bundle/defaults.plist";
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if(![fileManager fileExistsAtPath:path]) {
    [fileManager copyItemAtPath:pathDefault toPath:path error:nil];
  }
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("me.lightmann.texttimeprefs-updated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	initPrefs();
	loadPrefs();

	if(isEnabled)
		%init(tweak)
}
