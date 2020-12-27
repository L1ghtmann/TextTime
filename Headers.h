#import <UIKit/UIKit.h>

@interface SBUILegibilityLabel : UILabel
-(void)setString:(NSString *)arg1 ;
@property (nonatomic,copy) NSString * string;       
@end

@interface SBFLockScreenDateSubtitleView : UIView
@property (nonatomic,retain) NSString * string; 
@property (nonatomic,retain) UIFont * font; 
@end

@interface SBFLockScreenDateSubtitleDateView : SBFLockScreenDateSubtitleView
@property (assign,nonatomic) double alignmentPercent;                                          
@end

@interface SBFLockScreenDateView : UIView {
	SBFLockScreenDateSubtitleDateView* _dateSubtitleView;
	SBUILegibilityLabel* _timeLabel;
	SBFLockScreenDateSubtitleView* _customSubtitleView;
}
@property (assign,nonatomic) double alignmentPercent;         
- (CGFloat)getLabelHeight; 
@end

@interface CSCombinedListViewController : UIViewController //iOS 13
-(void)_updateListViewContentInset;
-(void)layoutListView;
-(UIEdgeInsets)_listViewDefaultContentInsets;
@end

@interface SBDashBoardCombinedListViewController : UIViewController //iOS 12
-(void)_updateListViewContentInset;
-(void)layoutListView;
-(UIEdgeInsets)_listViewDefaultContentInsets;
@end

@interface CSCoverSheetView : UIView  //iOS 13
@property(assign,nonatomic) BOOL dateViewIsVibrant;                                                       
-(void)setDateViewIsVibrant:(BOOL)arg1 ;
@end

@interface SBDashBoardView : UIView  //iOS 12
@property(assign,nonatomic) BOOL dateViewIsVibrant;                                                       
-(void)setDateViewIsVibrant:(BOOL)arg1 ;
@end

@interface BSUICAPackageView : UIView
@end

@interface SBUIProudLockIconView : UIView{
	BSUICAPackageView* _lockView;
}
@end

@interface SBUIFaceIDCoachingView : UIView
@end

@interface SpringBoard : UIApplication
+(id)sharedApplication;
-(NSInteger)activeInterfaceOrientation;
@end

//local
NSString *textTime;
CGFloat dateHeight;
CGFloat timeHeight;
CGFloat containerHeight;

#define kHeight [UIScreen mainScreen].bounds.size.height 
#define kWidth [UIScreen mainScreen].bounds.size.width 

//prefs
static BOOL isEnabled;

static int customAlignment;

static int fontStyle;

static int fontWeight;

static CGFloat fontSize;

static BOOL vibrancy;
static BOOL hideDate;
static BOOL compactDate;
static BOOL hideLock;
