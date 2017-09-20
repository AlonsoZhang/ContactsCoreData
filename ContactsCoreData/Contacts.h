//
//  Contacts.h
//  Checklists
//
//  Created by Alonso Zhang on 16/2/17.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ContactsUI/CNContactViewController.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/CNContactViewController.h>

@interface Contacts : NSObject
//生成一个联系人信息
- (void)setNewContact:(CNMutableContact *)contact name:(NSString *)fullname engname:(NSString *)englishname phoneNum:(NSString *)phonenumber shortNum:(NSString *)shortphonenumber note:(NSString *)note birthday:(NSDateComponents *)birthday email:(NSString *)email imessage:(NSString *)imessage photo:(NSData *)photo department:(NSString *)department;

//保存一个联系人到指定分组
- (void)savecontact:(CNMutableContact *)contact;

//删除一个联系人
- (void)deleteContact:(CNContact *)contact;

//删除一个群组
- (void)deleteGroup:(NSString *)group;

//匹配所有联系人
- (NSMutableArray *)fetchcontact;


@end
