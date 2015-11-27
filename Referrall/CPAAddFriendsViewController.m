//
//  CPAAddFriendsViewController.m
//  Referrall
//
//  Created by Collin Adler on 8/27/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"
#import "CPAHomeViewController.h"
#import "CPAContact.h"
#import "CPAConstants.h"
#import "CPAAddFriendsViewController.h"
#import "CPAFriendTableViewCell.h"
#import "CPAContactTableViewCell.h"
#import "CPAParseUtility.h"

@interface CPAAddFriendsViewController () <UITableViewDataSource, UITableViewDelegate, CPAContactTableViewCellDelegate, CPAFriendTableViewCellDelegate, MFMessageComposeViewControllerDelegate>

// Main tableview
@property (nonatomic, strong) UITableView *tableView;

// Data array for retreived friends
@property (nonatomic, strong) NSArray *friendObjects; // all the user's FB's friends that are using Referrall
@property (nonatomic, strong) NSMutableArray *followingArray; // all of the user's friends on Referall

// Array of contacts
@property (nonatomic, strong) NSMutableArray *contactsArray;
@property (nonatomic, strong) NSArray *sortedContactsArray;

@end

@implementation CPAAddFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Add Friends";
    self.view.backgroundColor = [CPAConstants lightGrayColor];
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"Next button")
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(nextBarButtonPressed:)];
    self.navigationItem.rightBarButtonItem = nextBarButton;

    
    // Main friends tableView
    self.tableView = [UITableView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:_tableView];
    
    self.contactsArray = [[NSMutableArray alloc] init];
    self.sortedContactsArray = [[NSArray alloc] init];
    
    // Get permission to access the address book
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted) {
        
        UIAlertController *contactsAlert = [UIAlertController alertControllerWithTitle:@"Cannot Load Contacts" message:@"Please provide Cabaray with permission to access your address book contacts in the Settings app" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Return" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [contactsAlert addAction:defaultAction];
        [self presentViewController:contactsAlert animated:YES completion:nil];
        
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        
        [self getPersonOutOfAddressBook]; // will fill in our friendsArray with all contacts
        
    } else {
        
        // Request access to address book
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted) {
                
                UIAlertController *contactsAlert = [UIAlertController alertControllerWithTitle:@"Cannot Load Contacts" message:@"Please provide Cabaray with permission to access your address book contacts in the Settings app" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Return" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
                [contactsAlert addAction:defaultAction];
                [self presentViewController:contactsAlert animated:YES completion:nil];
                return;
            }
            [self getPersonOutOfAddressBook]; // will fill in our friendsArray with all contacts
        });
    }
    
    [self.tableView registerClass:[CPAFriendTableViewCell class] forCellReuseIdentifier:@"friendCell"];
    [self.tableView registerClass:[CPAContactTableViewCell class] forCellReuseIdentifier:@"contactCell"];

    [self queryFacebookForFriendsOnReferall];
    [self queryParseForFriends];
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2; // Always have 2 sections, even if Parse / Facebook doesn't return any users
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        if (self.friendObjects.count == 0) {
            return 1; // return a single cell indicating there were no users found
        }
        return [self.friendObjects count]; // return however many Parse users were found
    } else if (section == 1) {
        return [self.sortedContactsArray count];
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        CPAFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
        if (cell == nil) {
            cell = [[CPAFriendTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"friendCell"];
        }
        cell.delegate = self;
        
        
        if (self.friendObjects.count == 0) {
            // TODO: DO SOMETHING HERE, CREATE A CUSTOM CELL
//            cell.nameLabel.text = @"No Cabaray users in your contacts";
//            cell.nameLabel.adjustsFontSizeToFitWidth = YES;
//            cell.userSubtitleLabel.text = @"Invite your friends below!";
//            cell.followButton.hidden = YES;
//            return cell;
        } else {
            cell.user = self.friendObjects[indexPath.row];

            // TODO: IMPLEMENT THE BELOW FOR OUR SITUATION
            if (self.followingArray) {
                if ([self.followingArray containsObject:cell.user.objectId]) {
                    cell.addButton.selected = YES;
                } else {
                    cell.addButton.selected = NO;
                }
            }
        }
        return cell;
        
    } else {
        
        CPAContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell"];
        if (cell == nil) {
            cell = [[CPAContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"contactCell"];
        }
        cell.delegate = self;
        cell.contact = self.sortedContactsArray[indexPath.row];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        // TODO: CONSIDER SHOWING THE PROFILE HERE
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [CPAConstants skyBlueColor];
    CGFloat headerHeight = 26;
    CGFloat padding = 10;
    headerView.frame = CGRectMake(padding,
                                  0,
                                  CGRectGetWidth(self.view.frame),
                                  headerHeight);
    
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.frame = CGRectMake(padding,
                                   0,
                                   CGRectGetWidth(self.view.frame),
                                   headerHeight);
    [headerView addSubview:headerLabel];
    
    if (section == 0) {
        headerLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Find friends on Referrall"
                                                                     attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:14.0f],
                                                                                  NSForegroundColorAttributeName : [UIColor whiteColor]}];
    } else {
        headerLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Invite contacts"
                                                                     attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:14.0f],
                                                                                  NSForegroundColorAttributeName : [UIColor whiteColor]}];
    }
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 26;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (self.friendObjects.count > 0) {
            PFUser *user = self.friendObjects[indexPath.row];
            
            // We want to keep consistent padding around each cell, so on the last cell add extra padding
            if (indexPath.row == (self.friendObjects.count - 1)) {
                return [CPAFriendTableViewCell heightForFriendCell:user width:CGRectGetWidth(self.view.frame)] + 10;
            } else {
                return [CPAFriendTableViewCell heightForFriendCell:user width:CGRectGetWidth(self.view.frame)];
            }
        } else {
            // TODO: IMPLEMENT THIRD HEIGHT METHOD
            return 60;
        }
    } else {
        CPAContact *contact = self.sortedContactsArray[indexPath.row];
        return [CPAContactTableViewCell heightForContactCell:contact width:CGRectGetWidth(self.view.frame)];
    }
}


#pragma mark - Facebook & Parse Networking

- (void)queryFacebookForFriendsOnReferall {

    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/me/friends"
                                  parameters:@{@"fields" : @"id"}
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        // Handle the result
        if (!error) {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                [friendIds addObject:[friendObject objectForKey:@"id"]];
            }
            
            // Construct a PFUser query that will find friends whose facebook ids
            // are contained in the current user's friend list.
            PFQuery *friendQuery = [PFUser query];
            [friendQuery whereKey:@"facebookID" containedIn:friendIds];
            
            // findObjects will return a list of PFUsers that are friends
            // with the current user
            self.friendObjects = [friendQuery findObjects];
            [self.tableView reloadData];
        } else {
            // TODO: ADD UIALERT
        }
    }];
}

- (void)queryParseForFriends {

    // List of all users that the current user is currently following
    PFQuery *isFollowingQuery = [PFQuery queryWithClassName:@"Activity"];
    [isFollowingQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [isFollowingQuery whereKey:@"type" equalTo:@"follow"];
    [isFollowingQuery selectKeys:@[@"toUser"]];
    [isFollowingQuery includeKey:@"toUser"];
    [isFollowingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        // Hide HUD view
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (error) {
            NSLog(@"error finding matching users");
        } else {
            NSMutableArray *parseFollowingArray = [[NSMutableArray alloc] init];
            for (PFObject *activityObject in objects) {
                PFUser *followedUser = activityObject[@"toUser"];
                [parseFollowingArray addObject:followedUser.objectId];
            }
            self.followingArray = parseFollowingArray;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Address Book API

- (void)getPersonOutOfAddressBook {
    
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (addressBook != nil) {
        
        NSArray *allContacts = (__bridge_transfer NSArray *)(ABAddressBookCopyArrayOfAllPeople(addressBook));
        
        NSUInteger i = 0;
        
        for (i = 0; i < [allContacts count]; i++) {
            CPAContact *contact = [[CPAContact alloc] init];
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            
            // Retrieve name data
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            
            contact.firstName = firstName;
            contact.lastName = lastName;
            contact.fullName = fullName;
            
            // Retrieve email
            ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
            NSUInteger j = 0;
            for (j = 0; j < ABMultiValueGetCount(emails); j++) {
                NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, j);
                if (j == 0) {
                    contact.firstEmail = email;
                } else if (j == 1) {
                    contact.secondEmail = email;
                }
            }
            CFRelease(emails);
            // Retrieve phone
            ABMultiValueRef phones = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
            NSUInteger t = 0;
            for (t = 0; t < ABMultiValueGetCount(phones); t++) {
                NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, t);
                if (t == 0) {
                    contact.firstPhone = [[phone componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                } else if (t == 1) {
                    contact.secondPhone = [[phone componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                }
            }
            CFRelease(phones);
            
            // If the contact has neither a first or last name, don't add it to the array
            if ((contact.lastName == (id)[NSNull null] || contact.lastName.length == 0) && (contact.firstName == (id)[NSNull null] || contact.firstName.length == 0)) { // no first name or last name
            } else {
                [self.contactsArray addObject:contact];
            }
        }
        CFRelease(addressBook);
        
        // Sort the contacts array and reload the tableview
        NSSortDescriptor *contactsSort = [NSSortDescriptor sortDescriptorWithKey:@"firstName"
                                                                       ascending:YES
                                                                        selector:@selector(caseInsensitiveCompare:)];
        self.sortedContactsArray = [self.contactsArray sortedArrayUsingDescriptors:@[contactsSort]];
        [self.tableView reloadData];

    } else {
        NSLog(@"Error reading Address Book");
    }
}

#pragma mark - CPAFriendTableViewCellDelegate

- (void)cell:(CPAFriendTableViewCell *)cellView didTapAddFriendButton:(PFUser *)user {
    [self shouldToggleAddFriendForCell:cellView];
}

- (void)shouldToggleAddFriendForCell:(CPAFriendTableViewCell *)cell {
    
    PFUser *cellUser = cell.user;
    if ([cell.addButton isSelected]) {
        // Unfollow
        cell.addButton.selected = NO;
        [CPAParseUtility unfollowUserEventually:cellUser];
        if ([self.followingArray containsObject:cellUser.objectId]) {
            [self.followingArray removeObject:cellUser.objectId];
        } else {
            NSLog(@"array doesn't have this user");
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.parse.Referrall.utility.userFollowingChanged" object:nil];
    } else {
        // Follow
        cell.addButton.selected = YES;
        [CPAParseUtility followUserEventually:cellUser block:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"friend added");
                // Post user following changed notification
                [[NSNotificationCenter defaultCenter] postNotificationName:@"com.parse.Referrall.utility.userFollowingChanged" object:nil];
                
                // Send the user a push notification using Parse cloud code
                [PFCloud callFunctionInBackground:@"sendPushToUser"
                                   withParameters:@{@"recipientId" : cellUser.objectId,
                                                    @"message" : @"Someone just followed you"}
                                            block:^(NSString *success, NSError *error) {
                                                if (!error) {
                                                    NSLog(@"Push sent successfully");
                                                } else {
                                                    NSLog(@"PUSH ERROR: %@", error.localizedDescription);
                                                }
                                            }];
                
                if ([self.followingArray containsObject:cellUser.objectId]) {
                    NSLog(@"array already has this user");
                } else {
                    [self.followingArray addObject:cellUser.objectId];
                }
                
            } else {
                cell.addButton.selected = NO;
            }
        }];
    }
}

#pragma mark - CPAContactTableViewCellDelegate

- (void)cell:(CPAContactTableViewCell *)cellView didTapInviteButton:(CPAContact *)contact {
    
    if(![MFMessageComposeViewController canSendText]) {
        
        UIAlertController *textAlert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Your device does not support sending SMS messages" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Return" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [textAlert addAction:defaultAction];
        [self presentViewController:textAlert animated:YES completion:nil];
        
        return;
    }
    
    NSMutableArray *recipients = [NSMutableArray array];
    
    if (contact.firstPhone) {
        [recipients addObject:contact.firstPhone];
    } else if (contact.secondPhone) {
        [recipients addObject:contact.secondPhone];
    } else {
        
        UIAlertController *phoneAlert = [UIAlertController alertControllerWithTitle:@"Error" message:@"This contact does not contain a phone number to send a message to" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Return" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [phoneAlert addAction:defaultAction];
        [self presentViewController:phoneAlert animated:YES completion:nil];
        
        return;
    }
    
    NSString *message = @"I'd like to add you on Referrall! Download the app here: www.referrall.co"; // TODO: UPDATE THIS WITH APPROPRIATE WEBSITE
    
    if (recipients.count > 0) {
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.messageComposeDelegate = self;
        [messageController setRecipients:recipients];
        [messageController setBody:message];
        
        // Present message view controller on screen
        [self presentViewController:messageController animated:YES completion:nil];
    }
}

#pragma mark - MFMessage
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result {
    
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            
            
            UIAlertController *messageAlert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to send SMS. Please check SMS settings and connection and try again" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Return" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
            [messageAlert addAction:defaultAction];
            [self presentViewController:messageAlert animated:YES completion:nil];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Buttons

- (void)nextBarButtonPressed:(UIBarButtonItem *)barButton {
    CPAHomeViewController *homeVC = [[CPAHomeViewController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:homeVC];
    [self presentViewController:navVC animated:YES completion:nil];
}

@end
