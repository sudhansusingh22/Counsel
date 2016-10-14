

#import <Foundation/Foundation.h>
#import "Firebase.h"
@interface GAEvent : NSObject



@property (nonatomic, strong) NSString *eventId;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *asignee;
@property (nonatomic) NSDate *dueDate;
@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;
@property (nonatomic, strong) NSString *priority;
@property (nonatomic, strong) NSString *relatedToMatterId;
@property (nonatomic, strong) NSString *remindBefore;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *type;
@property (strong, nonatomic) FIRDatabaseReference *ref;

//+ (instancetype) eventWithTitle:(NSString *)aTitle andCategory:(NSString *)aCategory andDate:(NSDate *)aDate;


+ (NSString *)parseClassName;
//+ (void)findAllEventsInBackground:(PFArrayResultBlock)resultBlock;
-(id)initWithParams:(FIRDataSnapshot *)snapshot;
@end
