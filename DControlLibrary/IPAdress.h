//
//  IPAdress.h
//  BHAirConditionControls
//
//  Created by heboyce on 5/9/15.
//  Copyright (c) 2015 boyce. All rights reserved.
//

#ifndef __BHAirConditionControls__IPAdress__
#define __BHAirConditionControls__IPAdress__

#include <stdio.h>

#define MAXADDRS    32
extern char *if_names[MAXADDRS];
extern char *ip_names[MAXADDRS];
extern char *hw_addrs[MAXADDRS];
extern unsigned long ip_addrs[MAXADDRS];
// Function prototypes
void InitAddresses();
void FreeAddresses();
void GetIPAddresses();
void GetHWAddresses();

#endif /* defined(__BHAirConditionControls__IPAdress__) */
