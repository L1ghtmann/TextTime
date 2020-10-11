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

	NSUInteger count = timeLabel.string.length;

	if(count == 4){ //single digit hour
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterSpellOutStyle];

		//HOUR
		NSString *firstChar = [NSString stringWithFormat:@"%c" , [timeLabel.string characterAtIndex:0]];
		int firstCharInt = [firstChar intValue];
		NSNumber *numberValue1 = [NSNumber numberWithInt:firstCharInt]; 

			NSString *wordNumber1 = [numberFormatter stringFromNumber:numberValue1];

		//MINUTE p1
		NSString *thirdChar = [NSString stringWithFormat:@"%c" , [timeLabel.string characterAtIndex:2]];
		int thirdCharInt = [thirdChar intValue];
		NSNumber *numberValue2 = [NSNumber numberWithInt:thirdCharInt]; 

			NSString *wordNumber2 = [numberFormatter stringFromNumber:numberValue2];
		
		//MINUTE p2
		NSString *forthChar = [NSString stringWithFormat:@"%c" , [timeLabel.string characterAtIndex:3]];
		int forthCharInt = [forthChar intValue];
		NSNumber *numberValue3 = [NSNumber numberWithInt:forthCharInt]; 

			NSString *wordNumber3 = [numberFormatter stringFromNumber:numberValue3];

			//special cases
			if([wordNumber2 isEqualToString:@"zero"] && [wordNumber3 isEqualToString:@"zero"]) {// on the hour -- o' clock
				wordNumber2 = @"o'";
				wordNumber3 = @"clock";
			}

			if([wordNumber2 isEqualToString:@"zero"] && ![wordNumber3 isEqualToString:@"zero"]){//for first minute being 0 its o'
				wordNumber2 = @"o'";
			} 

			if([wordNumber2 isEqualToString:@"one"] && [wordNumber3 isEqualToString:@"one"]){//weird tens
				wordNumber2 = @"eleven";
				wordNumber3 = @"";
			} 
			if([wordNumber2 isEqualToString:@"one"] && [wordNumber3 isEqualToString:@"two"]){
				wordNumber2 = @"twelve";
				wordNumber3 = @"";
			} 
			if([wordNumber2 isEqualToString:@"one"] && [wordNumber3 isEqualToString:@"three"]){
				wordNumber2 = @"thirteen";
				wordNumber3 = @"";
			} 
			if([wordNumber2 isEqualToString:@"one"] && [wordNumber3 isEqualToString:@"four"]){
				wordNumber2 = @"fourteen";
				wordNumber3 = @"";
			} 
			if([wordNumber2 isEqualToString:@"one"] && [wordNumber3 isEqualToString:@"five"]){
				wordNumber2 = @"fifteen";
				wordNumber3 = @"";
			} 
			if([wordNumber2 isEqualToString:@"one"] && [wordNumber3 isEqualToString:@"six"]){
				wordNumber2 = @"sixteen";
				wordNumber3 = @"";
			} 
			if([wordNumber2 isEqualToString:@"one"] && [wordNumber3 isEqualToString:@"seven"]){
				wordNumber2 = @"seventeen";
				wordNumber3 = @"";
			} 
			if([wordNumber2 isEqualToString:@"one"] && [wordNumber3 isEqualToString:@"eight"]){
				wordNumber2 = @"eighteen";
				wordNumber3 = @"";
			} 
			if([wordNumber2 isEqualToString:@"one"] && [wordNumber3 isEqualToString:@"nine"]){
				wordNumber2 = @"nineteen";
				wordNumber3 = @"";
			} 

			//general corrections
			if([wordNumber2 isEqualToString:@"one"] && [wordNumber3 isEqualToString:@"zero"]){
				wordNumber2 = @"ten";
				wordNumber3 = @"";
			} 
			if([wordNumber2 isEqualToString:@"two"] && [wordNumber3 isEqualToString:@"zero"]){
				wordNumber2 = @"twenty";
				wordNumber3 = @"";
			} 
			if([wordNumber2 isEqualToString:@"two"] && ![wordNumber3 isEqualToString:@"zero"]){
				wordNumber2 = @"twenty";
			} 
			if([wordNumber2 isEqualToString:@"three"] && [wordNumber3 isEqualToString:@"zero"]){
				wordNumber2 = @"thirty";
				wordNumber3 = @"";
			} 
			if([wordNumber2 isEqualToString:@"three"] && ![wordNumber3 isEqualToString:@"zero"]){
				wordNumber2 = @"thirty";
			} 
			if([wordNumber2 isEqualToString:@"four"] && [wordNumber3 isEqualToString:@"zero"]){
				wordNumber2 = @"forty";
				wordNumber3 = @"";
			} 
			if([wordNumber2 isEqualToString:@"four"] && ![wordNumber3 isEqualToString:@"zero"]){
				wordNumber2 = @"forty";
			} 
			if([wordNumber2 isEqualToString:@"five"] && [wordNumber3 isEqualToString:@"zero"]) {
				wordNumber2 = @"fifty";
				wordNumber3 = @"";
			}
			if([wordNumber2 isEqualToString:@"five"] && ![wordNumber3 isEqualToString:@"zero"]) {
				wordNumber2 = @"fifty";
			}

		//generate string 
		baseString = [NSString stringWithFormat:@"%@ %@ %@", wordNumber1, wordNumber2, wordNumber3];
		
		if(fontStyle == 0){
			textTime = baseString;
			newlyFormattedDate = [dateLabel.string lowercaseString]; 
			[dateLabel setString:newlyFormattedDate];
		}
		if(fontStyle == 1){
			textTime = [baseString capitalizedString];
			newlyFormattedDate = [dateLabel.string capitalizedString]; 
			[dateLabel setString:newlyFormattedDate];
		}
		if(fontStyle == 2){
			textTime = [baseString uppercaseString];
			newlyFormattedDate = [dateLabel.string uppercaseString]; 
			[dateLabel setString:newlyFormattedDate];
		}

		//using an NSMutableAttributedString as opposed to the standard NSString because I wanted to change the line spacing 
		NSMutableAttributedString* attrString = [[NSMutableAttributedString  alloc] initWithString:textTime];
		NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
		
		if(customAlignment == 0)
			style.alignment = NSTextAlignmentLeft;
		if(customAlignment == 1)
			style.alignment = NSTextAlignmentCenter;
		if(customAlignment == 2)
			style.alignment = NSTextAlignmentRight;
		
		[style setMaximumLineHeight:timeLabel.font.pointSize]; // limits line spacing (effectively shrinking it)
		[attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, textTime.length)];
		
		// sets my word string as label string
		timeLabel.attributedText = attrString;
	}

	if(count == 5){ //double digit hour
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterSpellOutStyle];

		//HOUR p1
		NSString *firstChar = [NSString stringWithFormat:@"%c" , [timeLabel.string characterAtIndex:0]];
		int firstCharInt = [firstChar intValue];
		NSNumber *numberValue1 = [NSNumber numberWithInt:firstCharInt]; 

			NSString *wordNumber1 = [numberFormatter stringFromNumber:numberValue1];

		//HOUR p2
		NSString *secondChar = [NSString stringWithFormat:@"%c" , [timeLabel.string characterAtIndex:1]];
		int secondCharInt = [secondChar intValue];
		NSNumber *numberValue2 = [NSNumber numberWithInt:secondCharInt]; 

			NSString *wordNumber2 = [numberFormatter stringFromNumber:numberValue2];
		
		//MINUTE p1
		NSString *thirdChar = [NSString stringWithFormat:@"%c" , [timeLabel.string characterAtIndex:3]];
		int thirdCharInt = [thirdChar intValue];
		NSNumber *numberValue3 = [NSNumber numberWithInt:thirdCharInt]; 

			NSString *wordNumber3 = [numberFormatter stringFromNumber:numberValue3];

		//MINUTE p2
		NSString *forthChar = [NSString stringWithFormat:@"%c" , [timeLabel.string characterAtIndex:4]];
		int forthCharInt = [forthChar intValue];
		NSNumber *numberValue4 = [NSNumber numberWithInt:forthCharInt]; 

			NSString *wordNumber4 = [numberFormatter stringFromNumber:numberValue4];

		//24-hour time (always 4 digits/words)
		if(twentyfourHourTime()){
			//hour corrections
			if([wordNumber1 isEqualToString:@"zero"] && [wordNumber2 isEqualToString:@"one"]) {
				wordNumber1 = @"oh";
				wordNumber2 = @"one";
			}
			if([wordNumber1 isEqualToString:@"zero"] && [wordNumber2 isEqualToString:@"two"]) {
				wordNumber1 = @"oh";
				wordNumber2 = @"two";
			}
			if([wordNumber1 isEqualToString:@"zero"] && [wordNumber2 isEqualToString:@"three"]) {
				wordNumber1 = @"oh";
				wordNumber2 = @"three";
			}
			if([wordNumber1 isEqualToString:@"zero"] && [wordNumber2 isEqualToString:@"four"]) {
				wordNumber1 = @"oh";
				wordNumber2 = @"four";
			}
			if([wordNumber1 isEqualToString:@"zero"] && [wordNumber2 isEqualToString:@"five"]) {
				wordNumber1 = @"oh";
				wordNumber2 = @"five";
			}
			if([wordNumber1 isEqualToString:@"zero"] && [wordNumber2 isEqualToString:@"six"]) {
				wordNumber1 = @"oh";
				wordNumber2 = @"six";
			}
			if([wordNumber1 isEqualToString:@"zero"] && [wordNumber2 isEqualToString:@"seven"]) {
				wordNumber1 = @"oh";
				wordNumber2 = @"seven";
			}
			if([wordNumber1 isEqualToString:@"zero"] && [wordNumber2 isEqualToString:@"eight"]) {
				wordNumber1 = @"oh";
				wordNumber2 = @"eight";
			}
			if([wordNumber1 isEqualToString:@"zero"] && [wordNumber2 isEqualToString:@"nine"]) {
				wordNumber1 = @"oh";
				wordNumber2 = @"nine";
			}
			if([wordNumber1 isEqualToString:@"one"] && [wordNumber2 isEqualToString:@"zero"]) {
				wordNumber1 = @"ten";
				wordNumber2 = @"";
			}
			if([wordNumber1 isEqualToString:@"one"] && [wordNumber2 isEqualToString:@"one"]) {
				wordNumber1 = @"eleven";
				wordNumber2 = @"";
			}
			if([wordNumber1 isEqualToString:@"one"] && [wordNumber2 isEqualToString:@"two"]) {
				wordNumber1 = @"twelve";
				wordNumber2 = @"";
			}
			if([wordNumber1 isEqualToString:@"one"] && [wordNumber2 isEqualToString:@"three"]) {
				wordNumber1 = @"thirteen";
				wordNumber2 = @"";
			}
			if([wordNumber1 isEqualToString:@"one"] && [wordNumber2 isEqualToString:@"four"]) {
				wordNumber1 = @"fourteen";
				wordNumber2 = @"";
			}
			if([wordNumber1 isEqualToString:@"one"] && [wordNumber2 isEqualToString:@"five"]) {
				wordNumber1 = @"fifteen";
				wordNumber2 = @"";
			}
			if([wordNumber1 isEqualToString:@"one"] && [wordNumber2 isEqualToString:@"six"]) {
				wordNumber1 = @"sixteen";
				wordNumber2 = @"";
			}
			if([wordNumber1 isEqualToString:@"one"] && [wordNumber2 isEqualToString:@"seven"]) {
				wordNumber1 = @"seventeen";
				wordNumber2 = @"";
			}
			if([wordNumber1 isEqualToString:@"one"] && [wordNumber2 isEqualToString:@"eight"]) {
				wordNumber1 = @"eighteen";
				wordNumber2 = @"";
			}
			if([wordNumber1 isEqualToString:@"one"] && [wordNumber2 isEqualToString:@"nine"]) {
				wordNumber1 = @"nineteen";
				wordNumber2 = @"";
			}
			if([wordNumber1 isEqualToString:@"two"] && [wordNumber2 isEqualToString:@"zero"]) {
				wordNumber1 = @"twenty";
				wordNumber2 = @"";
			}
			if([wordNumber1 isEqualToString:@"two"] && [wordNumber2 isEqualToString:@"one"]) {
				wordNumber1 = @"twenty";
				wordNumber2 = @"one";
			}
			if([wordNumber1 isEqualToString:@"two"] && [wordNumber2 isEqualToString:@"two"]) {
				wordNumber1 = @"twenty";
				wordNumber2 = @"two";
			}
			if([wordNumber1 isEqualToString:@"two"] && [wordNumber2 isEqualToString:@"three"]) {
				wordNumber1 = @"twenty";
				wordNumber2 = @"three";
			}
			if([wordNumber1 isEqualToString:@"two"] && [wordNumber2 isEqualToString:@"four"]) {
				wordNumber1 = @"twenty";
				wordNumber2 = @"four";
			}

			//special cases
			if([wordNumber3 isEqualToString:@"zero"] && [wordNumber4 isEqualToString:@"zero"]) {// on the hour -- hundred
				wordNumber3 = @"hundred'";
				wordNumber4 = @"";
			}

			if([wordNumber3 isEqualToString:@"zero"] && ![wordNumber4 isEqualToString:@"zero"]){//for first minute being 0 its oh
				wordNumber3 = @"oh";
			} 

			if([wordNumber3 isEqualToString:@"one"] && [wordNumber4 isEqualToString:@"one"]){//weird tens
				wordNumber3 = @"eleven";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"one"] && [wordNumber4 isEqualToString:@"two"]){
				wordNumber3 = @"twelve";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"one"] && [wordNumber4 isEqualToString:@"three"]){
				wordNumber3 = @"thirteen";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"one"] && [wordNumber4 isEqualToString:@"four"]){
				wordNumber3 = @"fourteen";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"one"] && [wordNumber4 isEqualToString:@"five"]){
				wordNumber3 = @"fifteen";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"one"] && [wordNumber4 isEqualToString:@"six"]){
				wordNumber3 = @"sixteen";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"one"] && [wordNumber4 isEqualToString:@"seven"]){
				wordNumber3 = @"seventeen";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"one"] && [wordNumber4 isEqualToString:@"eight"]){
				wordNumber3 = @"eighteen";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"one"] && [wordNumber4 isEqualToString:@"nine"]){
				wordNumber3 = @"nineteen";
				wordNumber4 = @"";
			} 

			//general corrections
			if([wordNumber3 isEqualToString:@"one"] && [wordNumber4 isEqualToString:@"zero"]){
				wordNumber3 = @"ten";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"two"] && [wordNumber4 isEqualToString:@"zero"]){
				wordNumber3 = @"twenty";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"two"] && ![wordNumber4 isEqualToString:@"zero"]){
				wordNumber3 = @"twenty";
			} 
			if([wordNumber3 isEqualToString:@"three"] && [wordNumber4 isEqualToString:@"zero"]){
				wordNumber3 = @"thirty";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"three"] && ![wordNumber4 isEqualToString:@"zero"]){
				wordNumber3 = @"thirty";
			} 
			if([wordNumber3 isEqualToString:@"four"] && [wordNumber4 isEqualToString:@"zero"]){
				wordNumber3 = @"forty";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"four"] && ![wordNumber4 isEqualToString:@"zero"]){
				wordNumber3 = @"forty";
			} 
			if([wordNumber3 isEqualToString:@"five"] && [wordNumber4 isEqualToString:@"zero"]) {
				wordNumber3 = @"fifty";
				wordNumber4 = @"";
			}
			if([wordNumber3 isEqualToString:@"five"] && ![wordNumber4 isEqualToString:@"zero"]) {
				wordNumber3 = @"fifty";
			}
		}

		//12-hour time
		else{
			//special cases
			if([wordNumber1 isEqualToString:@"one"] && [wordNumber2 isEqualToString:@"zero"]) {// double digit hours
				wordNumber1 = @"ten";
				wordNumber2 = @"";
			}
			if([wordNumber1 isEqualToString:@"one"] && [wordNumber2 isEqualToString:@"one"]) {
				wordNumber1 = @"eleven";
				wordNumber2 = @"";
			}
			if([wordNumber1 isEqualToString:@"one"] && [wordNumber2 isEqualToString:@"two"]) {
				wordNumber1 = @"twelve";
				wordNumber2 = @"";
			}

			if([wordNumber3 isEqualToString:@"zero"] && [wordNumber4 isEqualToString:@"zero"]) {// on the hour -- o' clock
				wordNumber3 = @"o'";
				wordNumber4 = @"clock";
			}

			if([wordNumber3 isEqualToString:@"zero"] && ![wordNumber4 isEqualToString:@"zero"]){//for first minute being 0 its o'
				wordNumber3 = @"o'";
			} 

			if([wordNumber3 isEqualToString:@"one"] && [wordNumber4 isEqualToString:@"one"]){//weird tens
				wordNumber3 = @"eleven";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"one"] && [wordNumber4 isEqualToString:@"two"]){
				wordNumber3 = @"twelve";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"one"] && [wordNumber4 isEqualToString:@"three"]){
				wordNumber3 = @"thirteen";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"one"] && [wordNumber4 isEqualToString:@"four"]){
				wordNumber3 = @"fourteen";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"one"] && [wordNumber4 isEqualToString:@"five"]){
				wordNumber3 = @"fifteen";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"one"] && [wordNumber4 isEqualToString:@"six"]){
				wordNumber3 = @"sixteen";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"one"] && [wordNumber4 isEqualToString:@"seven"]){
				wordNumber3 = @"seventeen";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"one"] && [wordNumber4 isEqualToString:@"eight"]){
				wordNumber3 = @"eighteen";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"one"] && [wordNumber4 isEqualToString:@"nine"]){
				wordNumber3 = @"nineteen";
				wordNumber4 = @"";
			} 

			//general corrections
			if([wordNumber3 isEqualToString:@"one"] && [wordNumber4 isEqualToString:@"zero"]){
				wordNumber3 = @"ten";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"two"] && [wordNumber4 isEqualToString:@"zero"]){
				wordNumber3 = @"twenty";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"two"] && ![wordNumber4 isEqualToString:@"zero"]){
				wordNumber3 = @"twenty";
			} 
			if([wordNumber3 isEqualToString:@"three"] && [wordNumber4 isEqualToString:@"zero"]){
				wordNumber3 = @"thirty";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"three"] && ![wordNumber4 isEqualToString:@"zero"]){
				wordNumber3 = @"thirty";
			} 
			if([wordNumber3 isEqualToString:@"four"] && [wordNumber4 isEqualToString:@"zero"]){
				wordNumber3 = @"forty";
				wordNumber4 = @"";
			} 
			if([wordNumber3 isEqualToString:@"four"] && ![wordNumber4 isEqualToString:@"zero"]){
				wordNumber3 = @"forty";
			} 
			if([wordNumber3 isEqualToString:@"five"] && [wordNumber4 isEqualToString:@"zero"]) {
				wordNumber3 = @"fifty";
				wordNumber4 = @"";
			}
			if([wordNumber3 isEqualToString:@"five"] && ![wordNumber4 isEqualToString:@"zero"]) {
				wordNumber3 = @"fifty";
			}
		}

		//generate string
		baseString = [NSString stringWithFormat:@"%@ %@ %@ %@", wordNumber1, wordNumber2, wordNumber3, wordNumber4];

		if(fontStyle == 0){
			textTime = baseString;
			newlyFormattedDate = [dateLabel.string lowercaseString]; 
			[dateLabel setString:newlyFormattedDate];
		}
		if(fontStyle == 1){
			textTime = [baseString capitalizedString];
			newlyFormattedDate = [dateLabel.string capitalizedString]; 
			[dateLabel setString:newlyFormattedDate];
		}
		if(fontStyle == 2){
			textTime = [baseString uppercaseString];
			newlyFormattedDate = [dateLabel.string uppercaseString]; 
			[dateLabel setString:newlyFormattedDate];
		}

		//using an NSMutableAttributedString as opposed to the standard NSString because I wanted to change the line spacing 
		NSMutableAttributedString* attrString = [[NSMutableAttributedString  alloc] initWithString:textTime];
		NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
		
		if(customAlignment == 0)
			style.alignment = NSTextAlignmentLeft;
		if(customAlignment == 1)
			style.alignment = NSTextAlignmentCenter;
		if(customAlignment == 2)
			style.alignment = NSTextAlignmentRight;
		
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
