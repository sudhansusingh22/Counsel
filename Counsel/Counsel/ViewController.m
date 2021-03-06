//
//  ViewController.m
//
//

#import "ViewController.h"
#import "GAEvent.h"
#import "GAEventCell.h"
#import "NSDate+GADate.h"
#import "EventDetailViewController.h"
NSString *const oliveColor = @"33AA99";

@interface ViewController () <MZDayPickerDelegate, MZDayPickerDataSource>
@property (nonatomic,strong) NSDateFormatter *dayPickerdateFormatter;
@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, strong) NSMutableArray *allEvents;
@property (nonatomic, strong) NSDictionary *filteredEventsDictionary;
@property (nonatomic, strong) NSArray *sortedDateKeys;
@property (nonatomic, strong) NSArray *filteredSortedDateKeys;
@property (nonatomic, strong) NSDate *focusedDate;

- (IBAction)goToToday:(id)sender;

@end

@implementation ViewController
@synthesize ref;
@synthesize allEvents;
- (IBAction)didDoubleTapDays:(id)sender {
    [self goToTodayAnimated:YES];
}
- (void)viewDidLoad
{
    self.tableView.scrollEnabled = NO;
//    GAEvent *event = [[GAEvent alloc] init];
    self.allEvents = [[NSMutableArray alloc]init];
    self.ref = [[FIRDatabase database] reference];
    [self fetchDataFromFirebase:@"Bob"
                         completion:^(NSError *error) {
                             NSLog(@"%@ ====",error);
                             if (error==nil) {
                                 [self reloadTableData: true];
                             } else {
                                 NSLog(@"Holy crap!!");
                                 [self reloadTableData:false];
                             }
                         }];
   
    
    
    self.dayPicker.activeDayColor = [UIColor redColor];
    self.dayPicker.bottomBorderColor = [UIColor colorWithRed:0.693 green:0.008 blue:0.207 alpha:1.000];
    self.dayPicker.inactiveDayColor = [UIColor grayColor];
    
    self.dayPicker.delegate = self;
    self.dayPicker.dataSource = self;
    
    self.dayPicker.dayNameLabelFontSize = 12.0f;
    self.dayPicker.dayLabelFontSize = 18.0f;
    
    self.dayPickerdateFormatter = [[NSDateFormatter alloc] init];
    [self.dayPickerdateFormatter setDateFormat:@"EE"];
    self.filteredEventsArray = [NSMutableArray arrayWithCapacity:self.flatEventsData.count];
}

-(void)reloadTableData :(BOOL)flag{
    if(flag){
        NSLog(@"reloading table data");
        
    if (self.allEvents.count == 0){
            [[[UIAlertView alloc] initWithTitle:@"Sorry about this..."
                                        message:@"We're doing some server maintenence. Try relaunching the app in a few minutes."
                                       delegate:nil
                              cancelButtonTitle:@"No hard feelings"
                              otherButtonTitles:nil, nil] show];
        }
        else {
            NSLog(@"%lu", [self.allEvents count]);
            NSMutableDictionary *theEvents = [[NSMutableDictionary alloc] init];
            
            for (GAEvent *event in self.allEvents) {
                NSString *eventDate = [self convertToTimeStamp:event.startDate];
                
                if ( theEvents[eventDate] ) {
                    /* It has an array with this date. Add to event to existing array. */
                    [theEvents[eventDate] addObject:event];
                } else {
                    /* Create the array and add event */
                    theEvents[eventDate] = [[NSMutableArray alloc] init];
                    [theEvents[eventDate] addObject:event];
                }
            }
            
            self.filteredEventsDictionary = theEvents;
            // Sort the keys by date
            NSArray *keys = [theEvents allKeys];
            self.sortedDateKeys =  [keys sortedArrayUsingComparator: ^(NSString *d1, NSString *d2) {
//                NSDate *date1 = [NSDate dateFromString:d1];
//                NSDate *date2 = [NSDate dateFromString:d2];
                NSDate *date1 = [self convertToDate: [ NSNumber numberWithDouble:d1.doubleValue]];
                NSDate *date2 = [self convertToDate: [ NSNumber numberWithDouble:d2.doubleValue]];
                return [date1 compare:date2];
            }];
            
            [self filterContentForSearchText:@"" scope:
             [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
            
            [self.tableView reloadData];
            
            // Set start and end dates in dayPicker
            NSDate *firstDate = [self convertToDate: [NSNumber numberWithDouble:((NSString*)self.sortedDateKeys.firstObject).doubleValue] ];
            NSDate *lastDate = [self convertToDate: [NSNumber numberWithDouble:((NSString*)self.sortedDateKeys.lastObject).doubleValue] ];
            
            NSDateComponents *firstComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:firstDate];
            
            NSInteger firstYear = [firstComponents year];
            NSInteger firstMonth = [firstComponents month];
            NSInteger firstDay = [firstComponents day];
            
            NSDateComponents *lastComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:lastDate];
            NSInteger lastYear = [lastComponents year];
            NSInteger lastMonth = [lastComponents month];
            NSInteger lastDay = [lastComponents day];
            NSLog(@"%ld,%ld,%ld,%ld",lastYear,lastMonth,lastDay,(long)firstYear);
            [self.dayPicker setStartDate:[NSDate dateFromDay:firstDay month:firstMonth year:firstYear] endDate:[NSDate dateFromDay:lastDay month:lastMonth year:lastYear]];
            
            // Then display today in the picker and tableView
            [self goToTodayAnimated:NO];
            self.tableView.scrollEnabled = YES;
        }
        
    }else{
        
            [[[UIAlertView alloc] initWithTitle:@"Sorry about this..."
                                        message:@"There has been an error. Try relaunching the app."
                                       delegate:nil
                              cancelButtonTitle:@"No hard feelings"
                              otherButtonTitles:nil, nil] show];
        
    }
}

-(NSString*)convertToTimeStamp :(NSDate*)date{
    return [[NSNumber numberWithDouble:[date timeIntervalSince1970]] stringValue];
}
-(NSDate*)convertToDate :(NSNumber *)unixTime
{
    return [NSDate dateWithTimeIntervalSince1970:[unixTime doubleValue]];
}
-(void)viewWillAppear:(BOOL)animated {
    
    
}


-(void)goToTodayAnimated:(BOOL)animated {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps1 = [cal components:(NSCalendarUnitMonth| NSCalendarUnitYear | NSCalendarUnitDay) fromDate:[NSDate date]];
    
    for (int i = 0 ; i < self.sortedDateKeys.count; i++){
        NSDateComponents *comps2 = [cal components:(NSCalendarUnitMonth| NSCalendarUnitYear | NSCalendarUnitDay) fromDate:[self convertToDate: [NSNumber numberWithDouble:((NSString*)self.sortedDateKeys[i]).doubleValue] ]];

        if (comps1.day == comps2.day && comps1.month == comps2.month && comps1.year == comps2.year){
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection: i] atScrollPosition:UITableViewScrollPositionTop animated:animated];
            break;
        }
    }
    
    [self.dayPicker setCurrentDate:[NSDate date] animated:animated];
}


#pragma mark - MZDayPickerDelegate methods
- (NSString *)dayPicker:(MZDayPicker *)dayPicker titleForCellDayNameLabelInDay:(MZDay *)day
{
    return [self.dayPickerdateFormatter stringFromDate:day.date];
}

- (void)dayPicker:(MZDayPicker *)dayPicker didSelectDay:(MZDay *)day
{
    //We scroll to that section. Sections are labeled by the date (sortedKeys)
    NSString *selectedDateString = [NSDate formattedStringFromDate:day.date];
    NSInteger index = [self.sortedDateKeys indexOfObject:selectedDateString];
    
    //This way we make sure it doesn't crash if things get glitchy and index isn't found.
    if (index != NSNotFound) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - UITableView Delegate Methods

#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Perform segue to event detail
    [self performSegueWithIdentifier:@"showEventDetail" sender:tableView];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showEventDetail"]) {
        
        EventDetailViewController *eventDetailViewController = [segue destinationViewController];
        GAEvent *event;
        NSIndexPath *indexPath;
        
        if (sender == self.searchDisplayController.searchResultsTableView) {
            
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        
        } else if (sender == self.tableView) {
            
            indexPath = [self.tableView indexPathForSelectedRow];
        
        }
        
        NSString *key = self.filteredSortedDateKeys[indexPath.section];
        event = self.filteredEventsDictionary[key][indexPath.row];
        
        eventDetailViewController.theEvent = event;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDate *date = [self convertToDate:[NSNumber numberWithDouble:((NSString*)self.filteredSortedDateKeys[section]).doubleValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE MMM d yyyy"];
    NSLog(@"--%@",[dateFormatter stringFromDate:date]);
    return [dateFormatter stringFromDate:date];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.filteredEventsDictionary allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filteredEventsDictionary[self.filteredSortedDateKeys[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reuseIdentifier = @"EventCell";
    
    GAEventCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    GAEvent *event;
    
    NSString *key = self.filteredSortedDateKeys[indexPath.section];
    event = self.filteredEventsDictionary[key][indexPath.row];
    
    cell.title.text = event.subject;
    cell.location.text = event.type;
    cell.date.text =  [NSString stringWithFormat:@"%@ - %@", [NSDate timeStringFormatFromDate:event.startDate], [NSDate timeStringFormatFromDate:event.endDate]];
    NSString *statusOfEvent = @"";
    statusOfEvent = event.status;
    if([statusOfEvent isEqualToString:@"not_started"]){
        [cell setBackgroundColor:[self colorFromHexString:@"000000"]]; // green
    }else if([statusOfEvent isEqualToString:@"in_progress"]){
        [cell setBackgroundColor:[self colorFromHexString:@"FFFCB1"]]; // yellow

    }else{
        [cell setBackgroundColor:[self colorFromHexString:@"ff9999"]]; // red
    }
    return cell;
}
- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}



#pragma mark - Scrollview Delegate Methods
BOOL _dayPickerIsAnimating = NO;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSArray *visibleRows = [self.tableView visibleCells];
    UITableViewCell *firstVisibleCell = [visibleRows objectAtIndex:0];
    NSIndexPath *path = [self.tableView indexPathForCell:firstVisibleCell];
    
    //Scroll to the selected date.
//    [self convertToDate:[NSNumber numberWithDouble:((NSString*)self.filteredSortedDateKeys[path.section]).doubleValue]]
    NSDate *toDate = [self convertToDate:[NSNumber numberWithDouble:((NSString*)self.filteredSortedDateKeys[path.section]).doubleValue]];
    BOOL selectedDateIsCurrentlyViewed = [toDate isEqualToDate:self.focusedDate];
    
    if (!selectedDateIsCurrentlyViewed){
        self.focusedDate = toDate;
        NSDateComponents *firstComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self.focusedDate];
    
        NSInteger year = [firstComponents year];
        NSInteger month = [firstComponents month];
        NSInteger day = [firstComponents day];
    
        NSDate *followingDay = [NSDate dateFromDay:day+1 month:month year:year];
        [self.dayPicker setCurrentDate:followingDay animated:YES];
    }
    
}



#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    
    // Remove all objects from the filtered search array
    [self.filteredEventsArray removeAllObjects];
    
    // Update the filtered array based on the search text and scope.
    self.searchText = searchText;
    
    
    //http://stackoverflow.com/questions/15091155/nspredicate-match-any-characters
    
    NSMutableString *searchWithWildcards = [NSMutableString stringWithFormat:@"*%@*", searchText];
    if (searchWithWildcards.length > 3) {
        for (int i = 2; i < self.searchText.length * 2; i += 2) {
            [searchWithWildcards insertString:@"*" atIndex:i];
        }
    }
    
    // Filter the array using NSPredicate
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.subject LIKE[cd] %@)", searchWithWildcards];
    
    self.filteredEventsArray = [NSMutableArray arrayWithArray:[self.allEvents filteredArrayUsingPredicate:predicate]];

    NSMutableDictionary *searchEvents = [[NSMutableDictionary alloc] init];
    for (GAEvent *event in self.filteredEventsArray) {
        NSString *eventDate = [self convertToTimeStamp:event.startDate];
     
        if ( searchEvents[eventDate] ) {
            [searchEvents[eventDate] addObject:event];
        } else {
            searchEvents[eventDate] = [[NSMutableArray alloc] init];
            [searchEvents[eventDate] addObject:event];
        }
    }
    
    self.filteredEventsDictionary = searchEvents;
     
     NSArray *newKeys = [searchEvents allKeys];
     self.filteredSortedDateKeys =  [newKeys sortedArrayUsingComparator: ^(NSString *d1, NSString *d2) {
         NSDate *date1 = [self convertToDate: [ NSNumber numberWithDouble:d1.doubleValue]];
         NSDate *date2 = [self convertToDate: [ NSNumber numberWithDouble:d2.doubleValue]];
         return [date1 compare:date2];
     }];
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    //Search Results Table View has a different Row height - Fix it to use the height of our prototype cell
    tableView.rowHeight = 72;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)SearchBar {

    [self filterContentForSearchText:@"" scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar
                                                                                selectedScopeButtonIndex]]];
    [self.tableView reloadData];
    
}

- (IBAction)didTapDays:(id)sender {
}
- (IBAction)goToToday:(id)sender {
    [self goToTodayAnimated:YES];
}
// fetch data from firebase

- (void)fetchDataFromFirebase:(NSString *)refName
                   completion:(void (^)(NSError *error))completionBlock{
    [[ref child:@"calendar_event" ] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        for(FIRDataSnapshot* snap in snapshot.children){
            [self.allEvents addObject:[[GAEvent alloc] initWithParams: snap]];
            
        }
        if (snapshot!=nil) {
            if (completionBlock != nil) completionBlock(nil);
        } else {
            NSInteger errorCode;
            
                errorCode = 404;
           
            NSError *error = [NSError errorWithDomain:@"test" code:errorCode userInfo:nil];
            if (completionBlock != nil) completionBlock(error);
            NSLog(@"An internal error has occuredd");
        }
    }];
    
}



@end
