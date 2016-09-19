/******************************************************************
 ** File 		: xpatomic.h
 ** Author		: amoslan
 ** Date		: 2012-03-12
 ** Copyright	: Copyright (c) 2012-2014 Tencent Co.,Ltd.
 ** Description	: x platform atomic
 **
 ** Version		: 1.0
 ** History		:
 ******************************************************************/
#if !defined(_XPATOMIC_INC_)
#define _XPATOMIC_INC_
#pragma once

#include <xptypes.h>

/*noly support no barrier mode*/
typedef int32	atomic32;

/*** part of following code comes from chromium ***
 
// Atomically execute:
//      result = *ptr;
//      if (*ptr == old_value)
//        *ptr = new_value;
//      return result;
//
// I.e., replace "*ptr" with "new_value" if "*ptr" used to be "old_value".
// Always return the old value of "*ptr"
//
// This routine implies no memory barriers.
//>>> xpatomic_exchnage_compare

// Atomically store new_value into *ptr, returning the previous value held in
// *ptr.  This routine implies no memory barriers.
//>>> xpatomic_increment

// Atomically increment *ptr by "increment".  Returns the new value of
// *ptr with the increment applied.  This routine implies no memory barriers.
//>>> xpatomic_exchange
 */

// xpatomic_ref_inc(ref_count_ptr) 是专门针对引用计数+1的原子操作
// xpatomic_ref_dec(ref_count_ptr) 是专门针对引用计数-1的原子操作

#if _OS_WIN_
#	include <windows.h>
#	define	xpatomic_increment(ptr, increment)							(InterlockedExchangeAdd(reinterpret_cast<volatile LONG*>(ptr), static_cast<LONG>(increment)) + increment)
#	define	xpatomic_exchnage_compare(ptr, old_value, new_value)		static_cast<atomic32>(InterlockedCompareExchange(reinterpret_cast<volatile LONG*>(ptr), static_cast<LONG>(new_value), static_cast<LONG>(old_value)))
#	define	xpatomic_exchange(ptr, new_value)							static_cast<atomic32>(InterlockedExchange(reinterpret_cast<volatile LONG*>(ptr), static_cast<LONG>(new_value)))
#   define  xpatomic_ref_inc(ref_count_ptr)                             InterlockedIncrement(reinterpret_cast<volatile LONG*>(ref_count_ptr))
#   define  xpatomic_ref_dec(ref_count_ptr)                             InterlockedDecrement(reinterpret_cast<volatile LONG*>(ref_count_ptr))

#elif defined(_OS_IOS_) || defined(_OS_MAC_)
#	include <libkern/OSAtomic.h>
#	define	xpatomic_increment(ptr, increment)							OSAtomicAdd32(increment, reinterpret_cast<atomic32*>(ptr))
#   define  xpatomic_ref_inc(ref_count_ptr)                             OSAtomicIncrement32(reinterpret_cast<atomic32*>(ref_count_ptr))
#   define  xpatomic_ref_dec(ref_count_ptr)                             OSAtomicDecrement32(reinterpret_cast<atomic32*>(ref_count_ptr))

inline atomic32 xpatomic_exchnage_compare(volatile atomic32 *ptr,
                                         atomic32 old_value,
                                         atomic32 new_value) {
	atomic32 prev_value;
	do {
		if (OSAtomicCompareAndSwap32(old_value, new_value,
									 ptr)) {
			return old_value;
		}
		prev_value = *ptr;
	} while (prev_value == old_value);
	return prev_value;
}

inline atomic32 xpatomic_exchange(volatile atomic32 *ptr,
                                         atomic32 new_value) {
	atomic32 old_value;
	do {
		old_value = *ptr;
	} while (!OSAtomicCompareAndSwap32(old_value, new_value,
									   ptr));
	return old_value;
}

#elif ( defined(_ARM_) && defined(_OS_LINUX_) ) || defined(_OS_ANDROID_)
// 0xffff0fc0 is the hard coded address of a function provided by
// the kernel which implements an atomic compare-exchange. On older
// ARM architecture revisions (pre-v6) this may be implemented using
// a syscall. This address is stable, and in active use (hard coded)
// by at least glibc-2.7 and the Android C library.
typedef atomic32 (*LinuxKernelCmpxchgFunc)(atomic32 old_value,
                                           atomic32 new_value,
                                           volatile atomic32* ptr);
LinuxKernelCmpxchgFunc pLinuxKernelCmpxchg __attribute__((weak)) =
(LinuxKernelCmpxchgFunc) 0xffff0fc0;

typedef void (*LinuxKernelMemoryBarrierFunc)(void);
LinuxKernelMemoryBarrierFunc pLinuxKernelMemoryBarrier __attribute__((weak)) =
(LinuxKernelMemoryBarrierFunc) 0xffff0fa0;

inline atomic32 xpatomic_exchnage_compare(volatile atomic32* ptr,
                                         atomic32 old_value,
                                         atomic32 new_value) {
	atomic32 prev_value = *ptr;
	do {
		if (!pLinuxKernelCmpxchg(old_value, new_value,
								 const_cast<atomic32*>(ptr))) {
			return old_value;
		}
		prev_value = *ptr;
	} while (prev_value == old_value);
	return prev_value;
}

inline atomic32 xpatomic_exchange(volatile atomic32* ptr,
                                         atomic32 new_value) {
	atomic32 old_value;
	do {
		old_value = *ptr;
	} while (pLinuxKernelCmpxchg(old_value, new_value,
								 const_cast<atomic32*>(ptr)));
	return old_value;
}

inline atomic32 xpatomic_increment(volatile atomic32* ptr,
                                        atomic32 increment) {
	for (;;) {
		// Atomic exchange the old value with an incremented one.
		atomic32 old_value = *ptr;
		atomic32 new_value = old_value + increment;
		if (pLinuxKernelCmpxchg(old_value, new_value,
								const_cast<atomic32*>(ptr)) == 0) {
			// The exchange took place as expected.
			return new_value;
		}
		// Otherwise, *ptr changed mid-loop and we need to retry.
	}
}

// __atomic_inc/__atomic_dec 的返回值都是修改之前的旧值。
#include <sys/atomics.h>
#define xpatomic_ref_inc(ref_count_ptr) (__atomic_inc(ref_count_ptr) + 1)
#define xpatomic_ref_dec(ref_count_ptr) (__atomic_dec(ref_count_ptr) - 1)

#else

// 32-bit low-level operations on any platform.

inline atomic32 xpatomic_exchnage_compare(volatile atomic32* ptr,
                                         atomic32 old_value,
                                         atomic32 new_value) {
	atomic32 prev;
	__asm__ __volatile__("lock; cmpxchgl %1,%2"
						 : "=a" (prev)
						 : "q" (new_value), "m" (*ptr), "0" (old_value)
						 : "memory");
	return prev;
}

inline atomic32 xpatomic_exchange(volatile atomic32* ptr,
                                         atomic32 new_value) {
	__asm__ __volatile__("xchgl %1,%0"  // The lock prefix is implicit for xchg.
						 : "=r" (new_value)
						 : "m" (*ptr), "0" (new_value)
						 : "memory");
	return new_value;  // Now it's the previous value.
}

inline atomic32 xpatomic_increment(volatile atomic32* ptr,
                                          atomic32 increment) {
	atomic32 temp = increment;
	__asm__ __volatile__("lock; xaddl %0,%1"
						 : "+r" (temp), "+m" (*ptr)
						 : : "memory");
	// temp now holds the old value of *ptr
	return temp + increment;
}

#endif

#endif /*_XPATOMIC_INC_*/
