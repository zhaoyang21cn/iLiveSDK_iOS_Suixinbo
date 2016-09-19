//
//  allocator.h
//  SmartSTL
//
//  Created by wenlongluo on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef XP_Allocator_h
#define XP_Allocator_h

#include <xptypes.h>
#include <xpexcept.h>

// Define the base class to std::allocator.
#include <bits/c++allocator.h>

#include <bits/cpp_type_traits.h> // for __is_empty

namespace xp{

namespace XSTL {

template<typename _Tp>
class allocator;

/// allocator<void> specialization.
template<>
class allocator<void>
{
public:
    typedef size_t      size_type;
    typedef ptrdiff_t   difference_type;
    typedef void*       pointer;
    typedef const void* const_pointer;
    typedef void        value_type;
    
    template<typename _Tp1>
    struct rebind
    { typedef allocator<_Tp1> other; };
};

/**
 * @brief  The "standard" allocator, as per [20.4].
 *
 *  Further details:
 *  http://gcc.gnu.org/onlinedocs/libstdc++/20_util/allocator.html
 */
template<typename _Tp>
class allocator: public __glibcxx_base_allocator<_Tp>
{
public:
    typedef size_t     size_type;
    typedef ptrdiff_t  difference_type;
    typedef _Tp*       pointer;
    typedef const _Tp* const_pointer;
    typedef _Tp&       reference;
    typedef const _Tp& const_reference;
    typedef _Tp        value_type;
    
    template<typename _Tp1>
    struct rebind
    { typedef allocator<_Tp1> other; };
    
    allocator() throw() { }
    
    allocator(const allocator& __a) throw()
    : __glibcxx_base_allocator<_Tp>(__a) { }
    
    template<typename _Tp1>
    allocator(const allocator<_Tp1>&) throw() { }
    
    ~allocator() throw() { }
    
    // Inherit everything else.
};

template<typename _T1, typename _T2>
inline bool
operator==(const allocator<_T1>&, const allocator<_T2>&)
{ return true; }

template<typename _T1, typename _T2>
inline bool
operator!=(const allocator<_T1>&, const allocator<_T2>&)
{ return false; }

/*
// Inhibit implicit instantiations for required instantiations,
// which are defined via explicit instantiations elsewhere.
// NB: This syntax is a GNU extension.
#if _GLIBCXX_EXTERN_TEMPLATE
extern template class allocator<char>;
extern template class allocator<wchar_t>;
#endif
*/
    
// Undefine.
#undef __glibcxx_base_allocator

// To implement Option 3 of DR 431.
template<typename _Alloc, bool = std::__is_empty<_Alloc>::__value>
struct __alloc_swap
{ static void _S_do_it(_Alloc&, _Alloc&) { } };

template<typename _Alloc>
struct __alloc_swap<_Alloc, false>
{
    static void
    _S_do_it(_Alloc& __one, _Alloc& __two)
    {
        // Precondition: swappable allocators.
        if (__one != __two)
            swap(__one, __two);
    }
};

} // namespace XSTL
} // namespace xp

#endif
