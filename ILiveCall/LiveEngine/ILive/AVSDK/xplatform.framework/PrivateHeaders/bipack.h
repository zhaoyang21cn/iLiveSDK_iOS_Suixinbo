/** 
@file 
@brief CCommPack的头文件
*/

#pragma once
#include <xptypes.h>
#include "bibuffer.h"
#include "biclssext.h"
#include <xpstream.h>

enum BIPackDataType
{
	DATATYPE_BYTE	= 1,	
	DATATYPE_WORD	= 2,	
	DATATYPE_DWORD  = 3,
};

/// 通用协议组包工具
/**@ingroup ov_Protocol
*/
class  _XP_CLS CBIPack 
{
public:

	CBIPack();
	virtual	~CBIPack();	
	
	/// 运行模式
	enum RunMode
	{
		RUNMODE_UNDETERMINED = 0,	///< 未确定
		RUNMODE_ENCODING,			///< 组包中
		RUNMODE_DECODING,			///< 解包中
	};

	/// 恢复CreatePack时的初始状态
	void Reset();
	RunMode	GetRunMode() const;

public: /* 组包相关*/

	/// 设置每次增加分配的缓冲区大小
	/** @note 在添加任何数据前使用即可在首次添加数据时令缓冲区一次性分配到所需长度
	 *	@remark 当设置uGrowLen为0时，uGrowLen会被设置为1
	 *
	 */
	void SetGrowLen(uint32 uGrowLen);

	/// 获得组包后的Buffer和长度, 注意该方法直接引用类内部的buffer。并将内部buffer置空
	boolean GetBufferOut(CBIBuffer &buf);
	/// 获得组包后的长度
	uint32 GetBufferOutLen();
	
	boolean GetBufferOut(bi_buf &buf);

	/// 使用本方法需要由调用者自主分配buffer
	boolean CopyBufferOut(uint8 *pcBuffer, uint32 &uLen) const;
	/// copy buffer
	boolean CopyBufferOut(CBIBuffer &buf) const;

	/// 增加一个pack buffer.原来的pack继续有效
	boolean AddPack(CBIPack &pack);
	/// 增加一个Byte字段
	boolean Adduint8(uint8 cIn);
	/// 增加一个Word字段
	boolean Adduint16(uint16  wIn, boolean bNetOrder = true);
	/// 增加一个DWord字段
	boolean Adduint32(uint32 dwIn, boolean bNetOrder = true);
	/// 增加一个UInt64字段
	boolean Adduint64(uint64 un64In, boolean bNetOrder = true);
	/// 增加一个buffer
	boolean AddBuf(uint8 *pcBuffer, uint32 uLen);
	/// 增加一个buffer
	boolean AddBuf(CBIBuffer &buf);
	/// 增加一个Len + buffer, len 占一个字节
	boolean AddBufLenByte(CBIBuffer &buf);
	/// 增加一个Len + buffer, len 占二个字节
	boolean AddBufLenWord(CBIBuffer &buf, boolean bLenNetOrder = true);
	/// 增加一个Len + buffer, len 占四个个字节
	boolean AddBufLenDWord(CBIBuffer &buf, boolean bLenNetOrder = true);
	
	/// 增加一个Ansi String, 不包括结尾0 
	boolean AddStr(utf8* str);
	/// 增加一个Ansi String, 并且在其尾部增加指定的字符。默认为0
	boolean AddStrEndChar(utf8* str, uint8 cChar = 0);
	/// 增加一个Len + Ansi String， len 占一个字节
	boolean AddStrLenByte(utf8* str);
	/// 增加一个Len + Ansi String， len 占二个字节
	boolean AddStrLenWord(utf8* str, boolean bLenNetOrder = true);
	/// 增加一个Len + Ansi String， len 占四个字节
	boolean AddStrLenDWord(utf8* str, boolean bLenNetOrder = true);
	
	boolean AddStrLenWord( bi_stru16 &str, boolean bLenNetOrder = true );


	/// 增加一个TLV项目
	boolean AddTLV(uint8  cT,CBIBuffer &bufV,BIPackDataType cLType);
	boolean AddTLV(uint16  wT,CBIBuffer &bufV,BIPackDataType cLType);
	boolean AddTLV(uint32 dwT,CBIBuffer &bufV,BIPackDataType cLType);

	/// 修改指定位置的数据的值
	boolean Setuint16(uint16 wIn,uint32 uPos,boolean bNetOrder = true);
	

public: /* 解包相关*/
	/// 设置解包前的Buffer
	/** @remark 注意如果设置bExternalLifeScope为true，
	 *			则使用者必须保证所提供的缓冲不会在该CommPack之前被销毁
	 *
	 */
	void SetBufferIn(const uint8 *pcBuffer, uint32 uLen, boolean bExternalLifeScope = false);

	/// 设置解包前的Buffer
	/** @remark 注意如果设置bExternalLifeScope为true，
	*			则使用者必须保证所提供的CBIBuffer不会在该CommPack之前被销毁，也不应在
	*			该CommPack被销毁前使用CBIBuffer中任何可能导致空间重新分配的操作
	*
	*/
	void SetBufferIn(CBIBuffer &buf, boolean bExternalLifeScope = false);

	/// 获得解包buffer剩余字节数
	int32 GetBufferByteLeft() const;

	/// 使用本方法需要由调用者自主分配buffer
	boolean CopyDecodeBufferOut(uint8 *pcBuffer, uint32 &uLen) const;
	/// copy buffer
	//boolean CopyDecodeBufferOut(CBIBuffer &buf) const;

	/// 取出一个Byte字段
	boolean Getuint8(uint8 &cOut, boolean bRemove = true);

	/// 取出一个Word字段
	boolean Getuint16(uint16 &wOut, boolean bNetOrder = true, boolean bRemove = true);

	/// 取出一个DWord字段
	boolean Getuint32(uint32 &dwOut, boolean bNetOrder = true, boolean bRemove = true);

	/// 取出一个UInt64字段
	boolean Getuint64(uint64 &un64Out, boolean bNetOrder = true, boolean bRemove = true);

	/// 取出一段buffer，这个实现从待解包缓冲中把指定的长度的数据复制出来
	boolean GetBuf(uint8 *pcBuffer, int32 nGetLen, boolean bRemove = true);

	/// 取出一段buffer，这个实现在指定的长度有效的情况下，直接返回待解包缓冲中的指针
	/** @remark 仅当工作在外部控制缓冲生命期状态下可用
	 *
	 */
	boolean GetBuf(uint8 **ppcBuffer, int32 nGetLen, boolean bRemove = true);

    
    boolean GetString(xp::strutf16 &str, int32 nGetLen, boolean bUnicode = true, boolean bRemove = true );
    
	//
	boolean GetString(utf8* str, int32 nGetLen, boolean bUnicode, boolean bRemove = true);

	/// 在后续buffer查找指定的字符。获得所在位置。如果找不到，则返回结尾
	int32 CheckBufEndChar(uint8 cEndChar);

	// 取出一段Len + buffer 暂感觉不需要实现
	//boolean GetBufLenHead(uint8 *pcBuffer, int32 &nGetLen);

	/// 跳过一个Byte字段
	boolean JumpByte();

	/// 跳过一个Word字段
	boolean JumpWord();

	/// 跳过一个DWord字段
	boolean JumpDWord();

	/// 跳过一段buffer
	boolean JumpBuf(int32 nGetLen);

	/// 取出一个TLV项目
	boolean GetTLV(uint8  &cT, CBIBuffer &bufV,BIPackDataType cLType, boolean bRemove = true);
	boolean GetTLV(uint16  &wT, CBIBuffer &bufV,BIPackDataType cLType, boolean bRemove = true);
	boolean GetTLV(uint32 &dwT,CBIBuffer &bufV,BIPackDataType cLType, boolean bRemove = true);

	boolean GetTLV(uint8  &cT, uint8 **ppcVBuf, uint32 &uVBufLen, BIPackDataType cLType, boolean bRemove = true);
	boolean GetTLV(uint16  &wT, uint8 **ppcVBuf, uint32 &uVBufLen, BIPackDataType cLType, boolean bRemove = true);
	boolean GetTLV(uint32 &dwT, uint8 **ppcVBuf, uint32 &uVBufLen, BIPackDataType cLType, boolean bRemove = true);	
	
	
	boolean GetStrWordLenHead(bi_str &strOut,boolean bRemove = true);
	boolean GetStrWordLenHead(bi_stru16 &strOut,boolean bRemove = true);
	boolean GetBufWordLenHead(bi_buf &strOut,boolean bRemove = true);

protected:	
	uint32 m_dwLen;				///< 组包过程中当前分配的缓冲的有效长度
	uint32 m_dwAllocLen;			///< 组包过程中当前分配的缓冲长度总长

	uint8*	m_pcEncodeBuffer;	///< 组包生成的缓冲
	uint8*	m_pcDecodeBuffer;	///< 待解包缓冲

	uint32 m_uOutPos;			///< 下一个解包偏移量
	uint32 m_uOutBufferLen;	///< 待解包缓冲总长

	uint32 m_uBufferGrowLen;	///< 每次预分配的内存块大小

	boolean m_bExternalLifeScope;	///< 是否由外部负责所处理的uint8缓冲区的生命期

	RunMode m_eRunMode;	///< 运行模式

protected:
	/// 检查缓冲区是否能容纳给定的大小，如果不行，自动增大缓冲区
	boolean CheckBuffer(uint32 uNewLen);

	/// 增大缓冲区
	boolean GrowBuffer(uint32 uNewBufferLen);

	/// 检查指定的长度是否已超出缓冲区边界
	boolean CheckOutOverflow(uint32 uNewLen);

	template <typename T>
		boolean AddNumber(T in);

	template <typename T>
		boolean GetNumber(T &out, boolean bRemove);

	/// 检查当前的运行模式是否与给定的模式相容
	boolean CheckRunMode(RunMode e);

	boolean GetVBuf(CBIBuffer &bufV, BIPackDataType cLType, boolean bRemove);
	boolean GetVBuf(uint8 **ppcVBuf, uint32 &uVBufLen, BIPackDataType cLType, boolean bRemove);
	boolean AddVBuf(CBIBuffer &bufV,BIPackDataType cLType);
};

