/*
 *  UtilHelp.h
 *  Engine
 *
 *  Created by gavinhuang on 10-12-7.
 *  Copyright 2010 Tencent. All rights reserved.
 *
 */
#pragma once

#include "biclssext.h"
#include <xpfile.h>

//todo...

#define MD5_DIGEST_LENGTH	16

int32 FindStr(const bi_str& strSrc,const char* pSub);
int32 FindStr(const bi_str& strSrc,const bi_str& strSub);
int32 FindStr(const char* pSrc,const char* pSub);
int32 FindStr(const xp::strutf8 &strSrc,const xp::strutf8 &strSub);

int32 FindStr(const bi_str& strSrc,const char* pSub,int32 nBeginPos);
int32 FindStr(const bi_str& strSrc,const bi_str& strSub,int32 nBeginPos);
int32 FindStr(const char* pSrc,const char* pSub,int32 nBeginPos);

boolean SplitHttpHead2Body(bi_buf &bufRecv,bi_str &strHttpHead,uint32 *puBodyBeginPos);

void GetStringHash(const bi_stru16& strContent,CBIBuffer& bufMd5);
boolean GetFileHash(bi_str & strFileName,bi_stru16 & strHash);
boolean GetFileHashForTransfer(xp::io::CFile* pf,uint8 *pcHashContent);
boolean GetPureFileName(const bi_stru16 &strFileName,bi_stru16 &strPureFileName);
boolean GetPureFileName(const bi_str &strFileName,bi_str &strPureFileName);
boolean GetFileExtension(const bi_stru16 &strFileName,bi_stru16 &strExt);
boolean GetFileExtension(const bi_str &strFileName,bi_str &strExt);
boolean SplitFileName2Path(const bi_str &strFileName,bi_str &strPureFileName,bi_str &strPureFilePath);

boolean GetValueFromHttpString(const char* pSrc,const char* pSub,int32 &nValue);
boolean GetValueFromHttpString(const char* pSrc,const char* pSub,uint32 &dwValue);
boolean GetValueFromHttpString(const char* pSrc,const char* pSub,bi_str &strValue);

