#pragma once

#include <google/protobuf/wire_format_lite.h>
#include <google/protobuf/message.h>
#include <google/protobuf/io/coded_stream.h>
#include <google/protobuf/io/zero_copy_stream_impl.h>
#include <google/protobuf/generated_message_util.h>

#include "xptypes.h"
#include "xpnet.h"

#include "bicmdcodec.h"

#undef	__MODULE__
#define __MODULE__			"PBCodeBase"

using namespace google::protobuf::io;
using namespace google::protobuf::internal;

template<class T1, class T2>
class CBIPBCodecBase: public CBICmdCodec
{
public:
    CBIPBCodecBase() :m_pRqData(NULL), m_pRspData(NULL), m_pOutputStream(NULL), m_pOutput(NULL)  { };
    virtual ~CBIPBCodecBase()
    {
        if (NULL != m_pOutput) {
            delete m_pOutput;
            m_pOutput = NULL;
        }
        if (NULL != m_pOutputStream) {
            delete m_pOutputStream;
            m_pOutputStream = NULL;
        }
    }
    
    boolean CodeST(pt_obj* pCmdData, CBIBuffer &str)
    {
        m_pRqData = (T1 *)pCmdData;
        uint32 uPredictSize = ByteSize();
        str.Resize(uPredictSize);
        m_pOutputStream = new ArrayOutputStream(str.GetNativeBuf(), uPredictSize);
        m_pOutput = new CodedOutputStream(m_pOutputStream);
        
        SetCodeStruct(m_pOutput);
        
        m_pRqData = NULL;
        delete m_pOutput;
        m_pOutput = NULL;
        delete m_pOutputStream;
        m_pOutputStream = NULL;
        return true;
    }
    
    boolean DecodeBuffer(CodedInputStream* pInput, pt_obj* pCmdData)
    {
        while (true) {
            uint32 uTag = pInput->ReadTag();
            if (uTag == 0) {
                return true;
            }
            
            int iFieldNumber = WireFormatLite::GetTagFieldNumber(uTag);
            m_pRspData = (T2 *)pCmdData;
            SetDecodeStruct(uTag, iFieldNumber, pInput);
            m_pRspData = NULL;
        }
        return false;
    }
    
    boolean DecodeBuffer(const void* data, int size, pt_obj* pCmdData)
    {
        CodedInputStream *pInput = new CodedInputStream(reinterpret_cast<const uint8*>(data), size);
        boolean ret = DecodeBuffer(pInput, pCmdData);
        delete pInput;
        return ret;
    }
    
    /// 从Buffer Decode得到TXData	
	boolean DecodeBuffer(CBIBuffer &bufIn, pt_obj** ppCmdData, pt_obj* pSendData)
	{
		uint8 *p = bufIn.GetNativeBuf();
		uint32 n = bufIn.GetSize();	
		return DecodeBuffer(p, n, ppCmdData, pSendData);
	}
	
	boolean  DecodeBuffer(CBIBuffer &bufIn, pt_obj* pCmdData, pt_obj* pSendData)
	{
		uint8 *p = bufIn.GetNativeBuf();
		uint32 n = bufIn.GetSize();	
		return DecodeBuffer(p,n, pCmdData, pSendData);
	}
    
    boolean  DecodeBuffer(uint8* pbuf,uint32 nbuflen, pt_obj** ppCmdData, pt_obj* pSendData)
	{
		*ppCmdData = new T2;
		((T2*)(*ppCmdData))->AddRef();
		return DecodeBuffer(pbuf, nbuflen, *ppCmdData, pSendData);
    }	
    
	boolean  DecodeBuffer(uint8* pbuf,uint32 nbuflen, pt_obj* pCmdData, pt_obj* pSendData)
	{
        boolean ret = DecodeBuffer(pbuf, nbuflen, pCmdData);
        m_pRspData = NULL;
        return ret;
	}
public:
    virtual uint32 ByteSize() const = 0; 
    virtual void SetCodeStruct(CodedOutputStream *pOutput) = 0;
    virtual boolean SetDecodeStruct(uint32 uTag, int iFieldNumber, CodedInputStream *pInput) = 0;
    
public:
    T1 *m_pRqData;
    T2 *m_pRspData;
    ArrayOutputStream *m_pOutputStream;
    CodedOutputStream *m_pOutput;
    
public:
#define ADDFIELDSIZE(NAME, CPPTYPE, DECLARED_TYPE)                                      \
    inline static uint32 AddFieldSize##NAME(uint32 uFieldNum, CPPTYPE uValue) {         \
        uint32 uTotalSize = 0;                                                          \
        uTotalSize += WireFormatLite::TagSize(uFieldNum, WireFormatLite::DECLARED_TYPE) \
                    + WireFormatLite::NAME##Size(uValue);                               \
        return uTotalSize;                                                              \
    }

    ADDFIELDSIZE(Bytes, const std::string &, TYPE_BYTES);
    ADDFIELDSIZE(String, const std::string &, TYPE_STRING);
#undef ADDFIELDSIZE
    
#define ADDFIELDKSIZE(NAME, CPPTYPE, DECLARED_TYPE)                                     \
    inline static uint32 AddFieldSize##NAME(uint32 uFieldNum, CPPTYPE uValue) {         \
        uint32 uTotalSize = 0;                                                          \
        uTotalSize += WireFormatLite::TagSize(uFieldNum, WireFormatLite::DECLARED_TYPE) \
                    + WireFormatLite::k##NAME##Size;                                    \
        return uTotalSize;                                                              \
    }
    
    ADDFIELDKSIZE(Fixed32, uint32, TYPE_FIXED32);
    ADDFIELDKSIZE(Fixed64, uint64, TYPE_FIXED64);
    ADDFIELDKSIZE(SFixed32, int32, TYPE_SFIXED32);
    ADDFIELDKSIZE(SFixed64, int64, TYPE_SFIXED64);
    ADDFIELDKSIZE(Float, float, TYPE_FLOAT);
    ADDFIELDKSIZE(Double, double, TYPE_DOUBLE);
    ADDFIELDKSIZE(Bool, boolean, TYPE_BOOL);
#undef ADDFIELDKSIZE
    
#define ADDFIELDSIZEEX(NAME, CPPTYPE, DECLARED_TYPE, HTON)                                          \
    inline static uint32 AddFieldSize##NAME(uint32 uFieldNum, CPPTYPE uValue, boolean bNetOrder = false) {         \
        uint32 uTotalSize = 0;                                                                      \
        if (bNetOrder) {                                                                            \
            uTotalSize += WireFormatLite::TagSize(uFieldNum, WireFormatLite::DECLARED_TYPE)         \
                        + WireFormatLite::NAME##Size(HTON(uValue));                                 \
        } else {                                                                                    \
            uTotalSize += WireFormatLite::TagSize(uFieldNum, WireFormatLite::DECLARED_TYPE)         \
                        + WireFormatLite::NAME##Size(uValue);                                       \
        }                                                                                           \
        return uTotalSize;                                                                          \
    }

    ADDFIELDSIZEEX(Int32, int32, TYPE_INT32, xpnet_hton32);
    ADDFIELDSIZEEX(Int64, int64, TYPE_INT64, xpnet_hton64);
    ADDFIELDSIZEEX(UInt32, uint32, TYPE_UINT32, xpnet_hton32);
    ADDFIELDSIZEEX(UInt64, uint64, TYPE_UINT64, xpnet_hton64);
    ADDFIELDSIZEEX(SInt32, int32, TYPE_SINT32, xpnet_hton32);
    ADDFIELDSIZEEX(SInt64, int64, TYPE_SINT64, xpnet_hton64);
#undef ADDFIELDSIZEEX
    
    template<class T3, class T4>
    static uint32 AddFieldSizeMessage(uint32 uFieldNum, CBIPBCodecBase<T3, T4> *pValue) {
        uint32 uTotalSize = 0;
        const uint32 uLoginSigSize = pValue->ByteSize();
        uTotalSize += WireFormatLite::TagSize(2, WireFormatLite::TYPE_MESSAGE) + WireFormatLite::UInt32Size(uLoginSigSize) + uLoginSigSize;
        
        return uTotalSize;
    }
    
#define CODEPRIMITIVE(NAME, CPPTYPE)                                                                \
    inline static void Code##NAME(uint32 uFieldNum, CPPTYPE uValue, CodedOutputStream *pOutput) {   \
        WireFormatLite::Write##NAME(uFieldNum, uValue, pOutput);                                    \
    }

    CODEPRIMITIVE(Float, float);
    CODEPRIMITIVE(Double, double);
    CODEPRIMITIVE(Bool, boolean);
    CODEPRIMITIVE(Bytes, const std::string &);
    CODEPRIMITIVE(String, const std::string &);
#undef CODEPRIMITIVE
    
#define CODEPRIMITIVEEX(NAME, CPPTYPE, HTON) \
    inline static void Code##NAME(uint32 uFieldNum, CPPTYPE uValue, CodedOutputStream *pOutput, boolean bNetOrder = false) {   \
        if (bNetOrder) {                                                                                \
            WireFormatLite::Write##NAME(uFieldNum, HTON(uValue), pOutput);                              \
        } else {                                                                                        \
            WireFormatLite::Write##NAME(uFieldNum, uValue, pOutput);                                    \
        }                                                                                               \
    }
    
    CODEPRIMITIVEEX(Int32, int32, xpnet_hton32);
    CODEPRIMITIVEEX(Int64, int64, xpnet_hton64);
    CODEPRIMITIVEEX(UInt32, uint32, xpnet_hton32);
    CODEPRIMITIVEEX(UInt64, uint64, xpnet_hton64);
    CODEPRIMITIVEEX(SInt32, int32, xpnet_hton32);
    CODEPRIMITIVEEX(SInt64, int64, xpnet_hton64);
    CODEPRIMITIVEEX(Fixed32, uint32, xpnet_hton32);
    CODEPRIMITIVEEX(Fixed64, uint64, xpnet_hton64);
    CODEPRIMITIVEEX(SFixed32, int32, xpnet_hton32);
    CODEPRIMITIVEEX(SFixed64, int64, xpnet_hton64);
#undef CODEPRIMITIVEEX

    template<class T3, class T4>
    static void CodeMessage(uint32 uFieldNum, CBIPBCodecBase<T3, T4> *pValue, CodedOutputStream *pOutput)
    {
        pOutput->WriteTag(WireFormatLite::MakeTag(uFieldNum, WireFormatLite::WIRETYPE_LENGTH_DELIMITED));
        const uint32 uLoginSigSize = pValue->ByteSize();
        pOutput->WriteVarint32(uLoginSigSize);
        
        pValue->SetCodeStruct(pOutput);
    }

    inline static boolean SkipField(uint32 uTag, CodedInputStream *pInput)
    {
        return WireFormatLite::SkipField(pInput, uTag); 
    }
    
#define DECODEPRIMITIVE(NAME, CPPTYPE, DECLARED_TYPE) \
    inline static boolean Decode##NAME(uint32 uTag, CodedInputStream *pInput, CPPTYPE &value) {         \
        WireFormatLite::WireType type = WireFormatLite::GetTagWireType(uTag);                           \
        if (type != WireFormatLite::WireTypeForFieldType(WireFormatLite::DECLARED_TYPE)) {              \
            SkipField(uTag, pInput);                                                                    \
            return false;                                                                               \
        }                                                                                               \
        if (WireFormatLite::ReadPrimitive<CPPTYPE, WireFormatLite::DECLARED_TYPE>(pInput, &value)) {    \
            return true;                                                                                \
        } else {                                                                                        \
            return false;                                                                               \
        }                                                                                               \
    }

    DECODEPRIMITIVE(Float, float, TYPE_FLOAT);
    DECODEPRIMITIVE(Double, double, TYPE_DOUBLE);
#undef DECODEPRIMITIVE
    
#define DECODEPRIMITIVEEX(NAME, CPPTYPE, DECLARED_TYPE, NTOH) \
    inline static boolean Decode##NAME(uint32 uTag, CodedInputStream *pInput, CPPTYPE &value, boolean bNetOrder = false) {        \
        WireFormatLite::WireType type = WireFormatLite::GetTagWireType(uTag);                           \
        if (type != WireFormatLite::WireTypeForFieldType(WireFormatLite::DECLARED_TYPE)) {              \
            SkipField(uTag, pInput);                                                                    \
            return false;                                                                               \
        }                                                                                               \
        if (WireFormatLite::ReadPrimitive<CPPTYPE, WireFormatLite::DECLARED_TYPE>(pInput, &value)) {    \
            if (bNetOrder) {                                                                            \
                value = NTOH(value);                                                                    \
            }                                                                                           \
            return true;                                                                                \
        } else {                                                                                        \
            return false;                                                                               \
        }                                                                                               \
    }
    
    DECODEPRIMITIVEEX(SInt32, int32, TYPE_SINT32, xpnet_ntoh32);
    DECODEPRIMITIVEEX(SInt64, int64, TYPE_SINT64, xpnet_ntoh64);
    DECODEPRIMITIVEEX(Int32, int32, TYPE_INT32, xpnet_ntoh32);
    DECODEPRIMITIVEEX(Int64, int64, TYPE_INT64, xpnet_ntoh64);
    DECODEPRIMITIVEEX(UInt32, uint32, TYPE_UINT32, xpnet_ntoh32);
    DECODEPRIMITIVEEX(UInt64, uint64, TYPE_UINT64, xpnet_ntoh64);
    DECODEPRIMITIVEEX(Uint32, uint32, TYPE_UINT32, xpnet_ntoh32);
    DECODEPRIMITIVEEX(Uint64, uint64, TYPE_UINT64, xpnet_ntoh64);
    DECODEPRIMITIVEEX(SFixed32, int32, TYPE_SFIXED32, xpnet_ntoh32);
    DECODEPRIMITIVEEX(SFixed64, int64, TYPE_SFIXED64, xpnet_ntoh64);
    DECODEPRIMITIVEEX(Fixed32, uint32, TYPE_FIXED32, xpnet_ntoh32);
    DECODEPRIMITIVEEX(Fixed64, uint64, TYPE_FIXED64, xpnet_ntoh64);
#undef DECODEPRIMITIVEEX    
    inline static boolean DecodeBool(uint32 uTag, CodedInputStream *pInput, boolean &value)
    {
        uint32 temp;
        WireFormatLite::WireType type = WireFormatLite::GetTagWireType(uTag);
        if (type != WireFormatLite::WireTypeForFieldType(WireFormatLite::TYPE_BOOL)) {
            SkipField(uTag, pInput);
            return false;
        } 
        
        if (WireFormatLite::ReadPrimitive<uint32, WireFormatLite::TYPE_UINT32>(pInput, &temp)) {
            value = temp != 0;
            return true;
        } else {
            return false;
        }
    }
    
    inline static boolean DecodeString(uint32 uTag, CodedInputStream *pInput, std::string *value)
    {
        WireFormatLite::WireType type = WireFormatLite::GetTagWireType(uTag);
        if (type != WireFormatLite::WireTypeForFieldType(WireFormatLite::TYPE_STRING)) {
            SkipField(uTag, pInput);
            return false;
        } 
        
        if (WireFormatLite::ReadString(pInput, value)) {
            return true;
        } else {
            return false;
        }
    }
    
    inline static boolean DecodeBytes(uint32 uTag, CodedInputStream *pInput, std::string *value)
    {
        return DecodeString(uTag, pInput, value);
    }
    
    template<class T3, class T4>
    static boolean DecodeMessage(uint32 uTag, CodedInputStream *pInput, T4 *value)
    {
        WireFormatLite::WireType type = WireFormatLite::GetTagWireType(uTag);
        if (type != WireFormatLite::WireTypeForFieldType(WireFormatLite::TYPE_MESSAGE)) {
            SkipField(uTag, pInput);
        } else {
            uint32 length;
            if (!pInput->ReadVarint32(&length)) {
                return false;
            }
            if (!pInput->IncrementRecursionDepth()) {
                return false;
            }
            CodedInputStream::Limit limit = pInput->PushLimit(length);
            
            T3 *pHttpConnHeadDecode = new T3();
            boolean ret = pHttpConnHeadDecode->DecodeBuffer(pInput, value);
            delete pHttpConnHeadDecode;
            pHttpConnHeadDecode = NULL;
            if (!ret) {
                return false;
            }
            if (!pInput->ConsumedEntireMessage()) {
                return false;
            }
            pInput->PopLimit(limit);
            pInput->DecrementRecursionDepth();
        }
        return true;
    }
};

#define DECLARE_PROTOCODEC(className, protoCS, protoSC)                                     \
class className : public CBIPBCodecBase<protoCS, protoSC>                                   \
{                                                                                           \
public:                                                                                     \
    virtual uint32 ByteSize() const;                                                        \
    virtual void SetCodeStruct(CodedOutputStream *pOutput);                                 \
    virtual boolean SetDecodeStruct(uint32 uTag, int iFieldNumber, CodedInputStream *pInput);  \
};
