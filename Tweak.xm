#import "Tweak.h"
#import <notify.h>

// Lightmann
// Made During COVID
// TextTime

%group Main
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
	return is24h;
}

%hook SpringBoard
// grab the orientation, so we don't need to in the various methods where it's used
-(int)activeInterfaceOrientation{
	int orig = %orig;
	orientation = orig;
	return orig;
}
%end

%hook SBFLockScreenDateView
// get a value to be used later
-(void)setFrame:(CGRect)frame{		
	%orig;
	
	containerHeight = frame.size.height;
}

// grab the views we're going to be working with, so we don't need to in the various methods where it's used 
-(void)setDate:(NSDate *)arg1 {
	%orig;

	timeLabel = MSHookIvar<SBUILegibilityLabel*>(self, "_timeLabel");	
	dateView = MSHookIvar<SBFLockScreenDateSubtitleDateView*>(self, "_dateSubtitleView");	
	dateLabel = MSHookIvar<SBUILegibilityLabel*>(dateView, "_label");	

	[self updateFormat]; // make sure to apply user preferences at initial loading of labels
}

// generate text and then change label to display said text instead of #s
-(void)_updateLabels{
	%orig;
	
	// time label
	// if !length it will crash
	if(timeLabel.string.length){ 
		// get the time excluding ":" -- thanks to u/w4llyb3ar on Reddit for the initial direction here
		NSString *hourString = [timeLabel.string substringWithRange:NSMakeRange(0, [timeLabel.string rangeOfString:@":"].location)];//for some reason the method used for finding the minutes' location doesn't work for hours (location - 1) so instead I grab the string from the range (0 - :), which produces the same thing
		NSString *minString = [timeLabel.string substringFromIndex:([timeLabel.string rangeOfString:@":"].location + 1)];

		//convert ^ to nsnumbers and then to text 
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		NSNumber *hourValue = [numberFormatter numberFromString:hourString]; 
		NSNumber *minValue = [numberFormatter numberFromString:minString]; 
		[numberFormatter setNumberStyle:NSNumberFormatterSpellOutStyle];
		NSString *hourText = [numberFormatter stringFromNumber:hourValue];
		NSString *minText = [numberFormatter stringFromNumber:minValue];

		// make it colloquial  
		if(twentyfourHourTime()){
			// reason for doubleValue conversions (https://stackoverflow.com/a/6605285)
			if(([hourValue doubleValue] > [[NSNumber numberWithInt:0] doubleValue]) && ([hourValue doubleValue] < [[NSNumber numberWithInt:10] doubleValue])) // "oh + hourText" for hour < 10, but > 0
				hourText = [@"oh " stringByAppendingString:hourText];

			else if([hourString isEqualToString:@"00"]) 
				hourText = @"twenty four";

			else if([minValue doubleValue] > [[NSNumber numberWithInt:0] doubleValue] && [minValue doubleValue] < [[NSNumber numberWithInt:10] doubleValue]) // "oh + minText" for min < 10, but > 0
				minText = [@"oh " stringByAppendingString:minText];
				
			else if([minString isEqualToString:@"00"])  
				minText = @"hundred";
		}
		else{
			if([minValue doubleValue] > [[NSNumber numberWithInt:0] doubleValue] && [minValue doubleValue] < [[NSNumber numberWithInt:10] doubleValue]) // "o' + minText" for min < 10, but > 0
				minText = [@"o' " stringByAppendingString:minText];

			else if([minString isEqualToString:@"00"]) 
				minText = @"o' clock";
		}

		// make one string from hours and minutes 
		NSString *baseString = [NSString stringWithFormat:@"%@ %@", hourText, minText];

		// remove any instances of "-" from the string that were created by the formatter
		NSString *timeText = [baseString stringByReplacingOccurrencesOfString:@"-" withString:@" "];

		// using an NSMutableAttributedString as opposed to the standard NSString because I wanted to change the line spacing 
		NSMutableAttributedString* attrString = [[NSMutableAttributedString  alloc] initWithString:timeText];
		NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];		
		[style setMaximumLineHeight:timeLabel.font.pointSize]; // limits line spacing (effectively shrinking it)
		[attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, timeText.length)];
		
		// sets the new text string as label string
		[timeLabel setAttributedText:attrString];
	}

	// date label
	// if !length it will crash
	if(dateView.string.length && dateAsText){
		NSScanner *scanner = [NSScanner scannerWithString:dateView.string];
		NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];

		//get day, month, and day number 
		NSString *dayAndMonthString;
		NSString *numberString;
		[scanner scanUpToCharactersFromSet:numbers intoString:&dayAndMonthString];
		[scanner scanCharactersFromSet:numbers intoString:&numberString];

		//convert ^ day number to nsnumber and then to text 
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		NSNumber *dateValue = [numberFormatter numberFromString:numberString]; 
		[numberFormatter setNumberStyle:NSNumberFormatterSpellOutStyle];
		NSString *dateText = [numberFormatter stringFromNumber:dateValue];

		// make it colloquial  
		if([dateText containsString:@"one"])  
			dateText = [dateText stringByReplacingOccurrencesOfString: @"one" withString:@"first"];

		else if([dateText containsString:@"two"])  
			dateText = [dateText stringByReplacingOccurrencesOfString: @"two" withString:@"second"];
		
		else if([dateText containsString:@"three"])  
			dateText = [dateText stringByReplacingOccurrencesOfString: @"three" withString:@"third"];

		else if([dateValue doubleValue] == [[NSNumber numberWithInt:12] doubleValue]) 
			dateText = @"twelfth";

		else if([dateValue doubleValue] == [[NSNumber numberWithInt:20] doubleValue] || [dateValue doubleValue] == [[NSNumber numberWithInt:30] doubleValue]) 
			dateText = [[dateText substringToIndex:[dateText length]-1] stringByAppendingString:@"ieth"];

		else
			dateText = [dateText stringByAppendingString:@"th"];

		//set date label string as stock day and month string plus the new text string
		[dateView setString:[NSString stringWithFormat:@"%@%@", dayAndMonthString, dateText]];
	}

		// some style stuff that won't work in the format method below
		if(fontStyle == 0){
			[timeLabel setString:[timeLabel.attributedText.string lowercaseString]];
			[dateView setString:[dateView.string lowercaseString]];
		}
		else if(fontStyle == 1){
			[timeLabel setString:[timeLabel.attributedText.string capitalizedString]];
			[dateView setString:[dateView.string capitalizedString]];
		}
		else if(fontStyle == 2){
			[timeLabel setString:[timeLabel.attributedText.string uppercaseString]];
			[dateView setString:[dateView.string uppercaseString]];
		}

	//set time label height dynamically based on text (https://stackoverflow.com/a/27376578)
	[timeLabel setFrame:CGRectMake(timeLabel.frame.origin.x, timeLabel.frame.origin.y+10, self.bounds.size.width, [timeLabel sizeThatFits:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)].height)];

	// prevent date label from getting clipped										
	[dateView setFrame:CGRectMake(dateView.frame.origin.x, dateView.frame.origin.y, [dateLabel sizeThatFits:CGSizeMake(dateLabel.frame.size.height, CGFLOAT_MAX)].width, dateView.frame.size.height)];
}

// style stuff
-(void)updateFormat{
	%orig;

	// allow for word wrapping
	[timeLabel setNumberOfLines:0];

	//prevent date label (font) from shrinking 
	[dateLabel setAdjustsFontSizeToFitWidth:NO];

	if(fontSize == 0)
		timeLabel.font = [UIFont systemFontOfSize:int((kHeight*.1)-10) weight:tfontWeight]; 
	else 
		timeLabel.font = [UIFont systemFontOfSize:int((kHeight*.1)-10)+fontSize weight:tfontWeight]; 

	dateView.font = [UIFont systemFontOfSize:int(timeLabel.font.pointSize*.367) weight:dfontWeight]; 
}

// alignment and position for time label 
-(CGRect)_timeLabelFrameForAlignmentPercent:(double)arg1 {							
	CGRect x = %orig;
	timeHeight = x.size.height;

	if(arg1 >= .75){
		// fix alignment of time when switching to today view 
		[UIView animateWithDuration:.1 animations:^{
			[timeLabel setTextAlignment:NSTextAlignmentRight];     
		}];
		return CGRectMake((arg1*100)-92, x.origin.y+10, x.size.width, x.size.height);
	}
	else{
		// portrait orientation 
		if(orientation == 1 || orientation == 2){
			[UIView animateWithDuration:.1 animations:^{
				if(customAlignment == 0)
					[timeLabel setTextAlignment:NSTextAlignmentLeft];
				else if(customAlignment == 1)
					[timeLabel setTextAlignment:NSTextAlignmentCenter]; 
				else if(customAlignment == 2)
					[timeLabel setTextAlignment:NSTextAlignmentRight];    
			}];
			if(customAlignment == 1)
				return CGRectMake((arg1*100), x.origin.y+10, x.size.width, x.size.height);
			else
				return CGRectMake((arg1*10), x.origin.y+10, x.size.width, x.size.height);
		} 
		// landscape orientation 
    	if (orientation == 3 || orientation == 4){
			[UIView animateWithDuration:.1 animations:^{
				[timeLabel setTextAlignment:NSTextAlignmentLeft];   
			}];
			return CGRectMake(x.origin.x, x.origin.y, x.size.width, x.size.height);
		}
	}
	return x; 
}

// alignment and position for date/charging labels
-(CGRect)_subtitleViewFrameForView:(UIView*)arg1 alignmentPercent:(double)arg2 {		
	CGRect x = %orig;
	dateHeight = x.size.height;

	// fix alignment of date when switching to today view 	
	if(arg2 >= .75 && (orientation == 1 || orientation == 2)){
		return CGRectMake(x.origin.x+5, (timeLabel.frame.origin.y+timeLabel.frame.size.height-(x.size.height*.2)), x.size.width, x.size.height);
	}
	else{
		// portrait orientation 
		if(orientation == 1 || orientation == 2){
			[UIView animateWithDuration:.1 animations:^{
				if(customAlignment == 0)
					[dateLabel setTextAlignment:NSTextAlignmentLeft];
				else if(customAlignment == 1)
					[dateLabel setTextAlignment:NSTextAlignmentCenter]; 
				else if(customAlignment == 2)
					[dateLabel setTextAlignment:NSTextAlignmentRight];    
			}];
			if(customAlignment == 1)
				return CGRectMake(x.origin.x, (timeLabel.frame.origin.y+timeLabel.frame.size.height-(x.size.height*.2)), x.size.width, x.size.height);
			else
				return CGRectMake((arg2*10), (timeLabel.frame.origin.y+timeLabel.frame.size.height-(x.size.height*.2)), x.size.width, x.size.height);
		} 
		// landscape orientation 
    	if (orientation == 3 || orientation == 4){
			[UIView animateWithDuration:.1 animations:^{
				[dateLabel setTextAlignment:NSTextAlignmentLeft];   
			}];
			return CGRectMake(x.origin.x, (timeLabel.frame.origin.y+timeLabel.frame.size.height-(x.size.height*.2)), x.size.width, x.size.height);
		}
	}
	return x;
}

// custom alignment  
-(void)setAlignmentPercent:(double)arg1 {
	if(arg1 < .75 && (orientation == 1 || orientation == 2)){
		if (customAlignment == 0)
			%orig(-1.0);
		else if (customAlignment == 1)
			%orig(0.0); 
		else if (customAlignment == 2)
			%orig(1.0);
	}
	else{
		%orig;
	}
}

// compact + hide date 
-(void)setUseCompactDateFormat:(BOOL)arg1 {	
	%orig(compactDate);

	if(hideDate)
		[dateView setHidden:YES];
	else
		[dateView setHidden:NO];
}
%end

// alignment and position + hiding of lock glyph
%hook SBUIProudLockIconView
-(void)setFrame:(CGRect)frame{
	UIView *lockGlyph = MSHookIvar<BSUICAPackageView*>(self, "_lockView");

	if(customAlignment == 0)
		%orig(CGRectMake(-(kWidth/2)+lockGlyph.frame.size.width+5, frame.origin.y ,frame.size.width ,frame.size.height));
	else if(customAlignment == 2)
		%orig(CGRectMake((kWidth/2)-lockGlyph.frame.size.width-10, frame.origin.y, frame.size.width, frame.size.height));
	else
		%orig;

	if(hideLock)
		[self setHidden:YES];	
}
%end

// post notification when screen turns on (used for positioning below)
%hook SBBacklightController
-(void)turnOnScreenFullyWithBacklightSource:(long long)arg1 {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.texttime/reposition"), nil, nil, true);
	%orig;
}
%end

// hide facedID coaching label
%hook SBUIFaceIDCoachingView
-(id)_label{	
	return nil;
}
%end
// end of main group 
%end


%group VersionSpecific
// adjust nclist (notifications & music player) based on height of time+date -- modified from Lower by s1ris (https://github.com/s1ris/Lower/blob/master/Tweak.xm)
%hook CombinedListViewController 
-(id)initWithNibName:(id)arg1 bundle:(id)arg2 {
	int notify_token2;
    // Respond to posted notification (when screen turns on) 
 	notify_register_dispatch("me.lightmann.texttime/reposition", &notify_token2, dispatch_get_main_queue(), ^(int token) {
        [self layoutListView];
    });
	return %orig;
}

-(UIEdgeInsets)_listViewDefaultContentInsets {
    UIEdgeInsets originalInsets = %orig;
    float yOffset;

    if (orientation == 1 || orientation == 2)
       yOffset = (timeHeight+(dateHeight/2))-containerHeight+5;
    
    else
        yOffset = 0;

    // update the insets
    originalInsets.top += yOffset;
    return originalInsets;
}

-(void)layoutListView {
    %orig;
    [self _updateListViewContentInset];
}

-(double)_minInsetsToPushDateOffScreen {
    double orig = %orig;
    float yOffset;

    if (orientation == 1 || orientation == 2)
        yOffset = (timeHeight+(dateHeight/2))-containerHeight+5;
	else
		yOffset = 0;

    return orig + yOffset;
}
%end
// end of version specific group
%end


%group VersionSpecific2
// toggle vibrancy effect 
%hook MainView 
-(void)setDateViewIsVibrant:(BOOL)arg1 {
	%orig(vibrancy);
}
%end
// end of version specific 2 group
%end


//	PREFERENCES 
void preferencesChanged(){
	NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"me.lightmann.texttimeprefs"];
	isEnabled = (prefs && [prefs objectForKey:@"isEnabled"] ? [[prefs valueForKey:@"isEnabled"] boolValue] : YES );
	customAlignment = (prefs && [prefs objectForKey:@"customAlignment"] ? [[prefs valueForKey:@"customAlignment"] integerValue] : 1 );
	fontStyle = (prefs && [prefs objectForKey:@"fontStyle"] ? [[prefs valueForKey:@"fontStyle"] integerValue] : 0 );
	fontSize = (prefs && [prefs objectForKey:@"fontSize"] ? [[prefs valueForKey:@"fontSize"] floatValue] : 0 );
	tfontWeight = (prefs && [prefs objectForKey:@"tfontWeight"] ? [[prefs valueForKey:@"tfontWeight"] floatValue] : 0 );
	dfontWeight = (prefs && [prefs objectForKey:@"dfontWeight"] ? [[prefs valueForKey:@"dfontWeight"] floatValue] : 0 );
	dateAsText = (prefs && [prefs objectForKey:@"dateAsText"] ? [[prefs valueForKey:@"dateAsText"] boolValue] : NO );
	compactDate = (prefs && [prefs objectForKey:@"compactDate"] ? [[prefs valueForKey:@"compactDate"] boolValue] : NO );
	hideDate = (prefs && [prefs objectForKey:@"hideDate"] ? [[prefs valueForKey:@"hideDate"] boolValue] : NO );
	hideLock = (prefs && [prefs objectForKey:@"hideLock"] ? [[prefs valueForKey:@"hideLock"] boolValue] : NO );
	vibrancy = (prefs && [prefs objectForKey:@"vibrancy"] ? [[prefs valueForKey:@"vibrancy"] boolValue] : NO );
}

%ctor {
	preferencesChanged();

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)preferencesChanged, CFSTR("me.lightmann.texttimeprefs-updated"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	if(isEnabled){
		%init(Main);

		NSString *combinedListViewControllerClass = @"SBDashBoardCombinedListViewController";
		NSString *mainViewClass = @"SBDashBoardView";

		if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13")) {
			combinedListViewControllerClass = @"CSCombinedListViewController";
			mainViewClass = @"CSCoverSheetView";
		}

	    %init(VersionSpecific, CombinedListViewController = NSClassFromString(combinedListViewControllerClass));
		%init(VersionSpecific2, MainView = NSClassFromString(mainViewClass));
	}
}
