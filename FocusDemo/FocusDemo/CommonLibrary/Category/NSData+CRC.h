//
//  NSData+CRC.h
//  CommonLibrary
//
//  Created by Ken on 3/25/14.
//  Copyright (c) 2014 Alexi. All rights reserved.
//
#if kSupportNSDataCommon
#import <Foundation/Foundation.h>

#define DEFAULT_POLYNOMIAL 0xEDB88320L
#define DEFAULT_SEED       0xFFFFFFFFL

@interface NSData (CRC)

-(uint8_t) crc8;

-(uint32_t) crc32;
-(uint32_t) crc32WithSeed:(uint32_t)seed;
-(uint32_t) crc32UsingPolynomial:(uint32_t)poly;
-(uint32_t) crc32WithSeed:(uint32_t)seed usingPolynomial:(uint32_t)poly;

@end
#endif