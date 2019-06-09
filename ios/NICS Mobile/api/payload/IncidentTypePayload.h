//
//  IncidentTypePayload.h
//  SCOUT Mobile
//
//  Created by Luis Gutierrez on 6/4/19.
//  Copyright © 2019 MIT Lincoln Labs. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol IncidentTypePayload

@end



@interface IncidentTypePayload : JSONModel

@property NSNumber *incidentTypeId;
// If typeid is 0, incidentTypeName might be "null"
// If this is not marked as optional, it'll fail the parsing of the whole incident payload
@property NSString<Optional> *incidentTypeName;

@end
