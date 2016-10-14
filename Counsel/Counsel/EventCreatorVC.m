//
//  EventCreatorVC.m
//
//  Created by Sudhansu Singh on 10/14/16.
//

#import "EventCreatorVC.h"
#import "IGLDropDownMenu.h"
#import "RMDateSelectionViewController.h"

@interface EventCreatorVC () <IGLDropDownMenuDelegate>
@property (nonatomic, strong) IGLDropDownMenu *priority;
@property (nonatomic, strong) IGLDropDownMenu *status;
@property (nonatomic, strong) IGLDropDownMenu *type;
@property (weak, nonatomic) IBOutlet UIButton *endDateButton;
@property (weak, nonatomic) IBOutlet UIButton *dueDateButton;

@property (weak, nonatomic) IBOutlet UIButton *startDateButton;
@property (weak, nonatomic) IBOutlet UITextField *subject;
@property (weak, nonatomic) IBOutlet UITextField *matterId;
@property (weak, nonatomic) IBOutlet UITextField *remindBefore;
@property (weak, nonatomic) IBOutlet UITextField *assignee;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSDate *dueDate;
@property (nonatomic, strong) NSString *typeString;
@property (nonatomic, strong) NSString *statusString;
@property (nonatomic, strong) NSString *priorityString;

@end
@implementation EventCreatorVC
@synthesize startDate;
@synthesize endDate;
@synthesize dueDate;
@synthesize typeString;
@synthesize statusString;
@synthesize priorityString;
@synthesize ref;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initPriorityMenu];
    [self initStatusMenu];
    [self initTypeMenu];
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];
    self.startDateButton.font = font;
    self.dueDateButton.font = font;
    self.endDateButton.font = font;
    self.ref = [[FIRDatabase database] reference];

}
- (void)initPriorityMenu
{
    NSMutableArray *dropdownItems = [[NSMutableArray alloc] init];
    IGLDropDownItem *item1 = [[IGLDropDownItem alloc] init];
    [item1 setText:@"1"];
    [dropdownItems addObject:item1];
    IGLDropDownItem *item2 = [[IGLDropDownItem alloc] init];
    [item2 setText:@"2"];
    [dropdownItems addObject:item2];
    IGLDropDownItem *item3 = [[IGLDropDownItem alloc] init];
    [item3 setText:@"3"];
    [dropdownItems addObject:item3];
    
    self.priority = [[IGLDropDownMenu alloc] init];
    self.priority.menuText = @"Choose Priority";
    self.priority.dropDownItems = dropdownItems;
    self.priority.paddingLeft = 10;
    [self.priority setFrame:CGRectMake(118, 328, 183, 24)];
    self.priority.delegate = self;
    
    [self.view addSubview:self.priority];
    
    [self.priority reloadView];
}
- (void)initStatusMenu
{
    NSMutableArray *dropdownItems = [[NSMutableArray alloc] init];
    IGLDropDownItem *item1 = [[IGLDropDownItem alloc] init];
    [item1 setText:@"Completed"];
    [dropdownItems addObject:item1];
    IGLDropDownItem *item2 = [[IGLDropDownItem alloc] init];
    [item2 setText:@"In Progress"];
    [dropdownItems addObject:item2];
    IGLDropDownItem *item3 = [[IGLDropDownItem alloc] init];
    [item3 setText:@"Not Started"];
    [dropdownItems addObject:item3];
    
    self.status = [[IGLDropDownMenu alloc] init];
    self.status.menuText = @"Choose Status";
    self.status.dropDownItems = dropdownItems;
    self.status.paddingLeft = 10;
    [self.status setFrame:CGRectMake(118, 290, 183, 24)];
    self.status.delegate = self;
    
    [self.view addSubview:self.status];
    
    [self.status reloadView];
}
- (void)initTypeMenu
{
    NSMutableArray *dropdownItems = [[NSMutableArray alloc] init];
    IGLDropDownItem *item1 = [[IGLDropDownItem alloc] init];
    [item1 setText:@"Meeting"];
    [dropdownItems addObject:item1];
    IGLDropDownItem *item2 = [[IGLDropDownItem alloc] init];
    [item2 setText:@"Milestone"];
    [dropdownItems addObject:item2];
    IGLDropDownItem *item3 = [[IGLDropDownItem alloc] init];
    [item3 setText:@"Task"];
    [dropdownItems addObject:item3];
    
    self.type = [[IGLDropDownMenu alloc] init];
    self.type.menuText = @"Choose Type";
    self.type.dropDownItems = dropdownItems;
    self.type.paddingLeft = 10;
    [self.type setFrame:CGRectMake(118, 255, 183, 24)];
    self.type.delegate = self;
    
    [self.view addSubview:self.type];
    
    [self.type reloadView];
}

#pragma mark - IGLDropDownMenuDelegate

- (void)dropDownMenu:(IGLDropDownMenu *)dropDownMenu selectedItemAtIndex:(NSInteger)index
{
//    if (self.dropDownMenu == self.defaultDropDownMenu) {
//        IGLDropDownItem *item = dropDownMenu.dropDownItems[index];
//    }
    IGLDropDownItem *item = dropDownMenu.dropDownItems[index];

    if([dropDownMenu.menuText isEqualToString:@"Choose Priority"]){
        NSLog(@"---%@",item.text);
        [self setStatusString:item.text];
    }else if([dropDownMenu.menuText isEqualToString:@"Choose Status"]){
        NSLog(@"---%@",item.text);
        [self setStatusString:item.text];
    }else{
        NSLog(@"---%@",item.text);
        [self setTypeString:item.text];

    }
    
}

- (void)dropDownMenu:(IGLDropDownMenu *)dropDownMenu expandingChanged:(BOOL)isExpending
{
    NSLog(@"Expending changed to: %@", isExpending? @"expand" : @"fold");
    
}

- (void)dropDownMenu:(IGLDropDownMenu *)dropDownMenu expandingChangedWithAnimationCompledted:(BOOL)isExpending
{
    NSLog(@"IGLDropDownMenu size: %@", NSStringFromCGSize(dropDownMenu.bounds.size));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)selectDueDate:(id)sender {
    [self createDateSelector:sender];
}
- (IBAction)selectStartDate:(id)sender {
    [self createDateSelector:sender];

}
- (IBAction)selectEndDate:(id)sender {
    [self createDateSelector:sender];

}

- (void)createDateSelector:(id)sender {
    //Create select action
    RMAction *selectAction = [RMAction actionWithTitle:@"Select" style:RMActionStyleDone andHandler:^(RMActionController *controller) {
        if([sender tag]==0){
            //start
            self.startDate = ((UIDatePicker *)controller.contentView).date;
            [self.startDateButton setTitle:[self getDateString: ((UIDatePicker *)controller.contentView).date] forState:UIControlStateNormal];
        }else if([sender tag]==1){
            //end
            self.endDate = ((UIDatePicker *)controller.contentView).date;
            [self.endDateButton setTitle:[self getDateString: ((UIDatePicker *)controller.contentView).date] forState:UIControlStateNormal];
        }else{
            //due
            self.dueDate = ((UIDatePicker *)controller.contentView).date;
            [self.dueDateButton setTitle:[self getDateString: ((UIDatePicker *)controller.contentView).date] forState:UIControlStateNormal];
        }
        NSLog(@"Successfully selected date: %@", ((UIDatePicker *)controller.contentView).date);
    }];
    
    //Create cancel action
    RMAction *cancelAction = [RMAction actionWithTitle:@"Cancel" style:RMActionStyleCancel andHandler:^(RMActionController *controller) {
        NSLog(@"Date selection was canceled");
    }];
    RMActionControllerStyle style = RMActionControllerStyleWhite;

    //Create date selection view controller
    RMDateSelectionViewController *dateSelectionController = [RMDateSelectionViewController actionControllerWithStyle:style selectAction:selectAction andCancelAction:cancelAction];
    dateSelectionController.title = @"Test";
    dateSelectionController.message = @"This is a test message.\nPlease choose a date and press 'Select' or 'Cancel'.";
    
    //Now just present the date selection controller using the standard iOS presentation method
    [self presentViewController:dateSelectionController animated:YES completion:nil];
}

-(NSString*) getDateString:(NSDate *)date{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy HH:mm a"];
    return [format stringFromDate:date];

}

-(void) saveData{
    NSMutableDictionary *newEvent = [NSMutableDictionary new];
    [newEvent setValue:[self assignee].text forKey:@"assignee"];
    [newEvent setValue:[self subject].text forKey:@"subject"];
    [newEvent setValue:[self matterId].text forKey:@"related_to_matter_id"];
    [newEvent setValue:[self remindBefore].text forKey:@"remind_before"];
    [newEvent setValue:[self priorityString] forKey:@"priority"];
    NSString *sTemp = [self statusString];
    NSString *statusFinal = @"";
    if([sTemp isEqualToString:@"Completed"]){
        statusFinal = @"completed";
    }else if ([sTemp isEqualToString:@"In Progress"]){
        statusFinal = @"in_progress";
    }else{
        statusFinal = @"not_started";
    }
   
    [newEvent setValue:statusFinal forKey:@"status"];
    [newEvent setValue:[self typeString] forKey:@"type"];
    [newEvent setValue:[NSNumber numberWithDouble:[[self startDate]timeIntervalSince1970]] forKey:@"start_date"];
    [newEvent setValue:[NSNumber numberWithDouble:[[self endDate]timeIntervalSince1970]] forKey:@"end_date"];
    [newEvent setValue:[NSNumber numberWithDouble:[[self dueDate]timeIntervalSince1970]] forKey:@"due_date"];
    
    NSLog(@"--%@", newEvent);
    [self updateToFirebase:newEvent];
    
    
}

-(void)updateToFirebase:(NSMutableDictionary* )dataDict{
    NSString *key = [[[self ref] child:@"calendar_event"] childByAutoId].key;
    NSDictionary *childUpdates = @{[@"/calendar_event/" stringByAppendingString:key]: dataDict
                                   };
    [[self ref] updateChildValues:childUpdates];
    [self displayAlert];
}
-(void)displayAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message: [NSString stringWithFormat:@"%@Event Created Successfully!", @""]  delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [alert show];
}
- (IBAction)saveData:(id)sender {
    [self saveData];
}

@end
