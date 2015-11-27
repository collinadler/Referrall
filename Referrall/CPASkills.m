//
//  CPASkills.m
//  Referrall
//
//  Created by Collin Adler on 8/27/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import "CPASkills.h"

@implementation CPASkills

- (instancetype)init {
    self = [super init];
    if (self) {

        
        self.skillTitles = @[@"Accounting", @"Finance", @"Marketing", @"Engineering"];
        
        self.accounting = @[@"Account Reconciliation", @"Auditing", @"Bookkeeping", @"Budgeting", @"CPA", @"Due Diligence", @"Financial Reporting", @"Financial Statements", @"Forensic", @"IFRS", @"Internal Audit", @"Internal Controls", @"Microsoft Office", @"Payroll", @"QuickBooks", @"Risk Management", @"Sarbanes-Oxley", @"Tax Analysis", @"Tax Returns", @"Transaction Services", @"Transfer Pricing", @"US GAAP"];
        
        self.finance = @[@"Capital Markets", @"CFA", @"Corporate Banking", @"Corporate Development", @"Corporate Finance", @"Equity Research", @"Financial Modeling", @"Investment Banking", @"Mergers & Acquisitions", @"Private Equity", @"Restructuring", @"Valuation", @"Venture Capital"];

    }
    return self;
}

@end
