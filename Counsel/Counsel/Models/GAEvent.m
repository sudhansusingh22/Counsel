
//

#import "GAEvent.h"

@implementation GAEvent

@synthesize eventId;
@synthesize priority;
@synthesize relatedToMatterId;
@synthesize remindBefore;
@synthesize status;
@synthesize subject;
@synthesize type;
@synthesize startDate;
@synthesize endDate;
@synthesize dueDate;
@synthesize asignee;
@synthesize ref;
+ (NSString *)parseClassName
{
    return @"Event2";
}

- (instancetype)init
{
    self = [super init];
    self.ref = [[FIRDatabase database] reference];
    return self;
}
-(id)initWithParams:(FIRDataSnapshot *)snapshot{
    if (self = [super init])
    {
        self.asignee = snapshot.value[@"assignee"] ;
        self.priority = snapshot.value[@"priority"];
        self.relatedToMatterId = snapshot.value[@"related_to_matter_id"];
        self.remindBefore = snapshot.value[@"remind_before"];
        self.status = snapshot.value[@"pLocation"] ;
        self.subject = snapshot.value[@"subject"] ;
        self.type = snapshot.value[@"type"];
        
//        self.startDate = snapshot.value[@"start_date"];
//        self.dueDate = snapshot.value[@"due_date"];
//        self.endDate = snapshot.value[@"end_date"];
        
        self.startDate = [GAEvent convertToDate:snapshot.value[@"start_date"]];
        self.dueDate = [GAEvent convertToDate:snapshot.value[@"due_date"]];
        self.endDate  = [GAEvent convertToDate:snapshot.value[@"end_date"]];



    }
    return self;
}

+(NSDate*)convertToDate :(NSNumber *)unixTime
{
    return [NSDate dateWithTimeIntervalSince1970:[unixTime doubleValue]];
}

+(NSString*)convertToTimeStamp :(NSDate*)date{
    return [[NSNumber numberWithDouble:[date timeIntervalSince1970]] stringValue];
}
@end
