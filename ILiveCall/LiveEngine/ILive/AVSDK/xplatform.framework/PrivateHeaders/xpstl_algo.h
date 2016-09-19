
#ifndef _XPSTL_ALGO_H_
#define _XPSTL_ALGO_H_

namespace xpstl 
{
    template<typename _InputIterator, typename _Tp>
    inline _InputIterator
    find(_InputIterator __first, _InputIterator __last,const _Tp& __val)
    {
        while (__first != __last && !(*__first == __val))
            ++__first;
        return __first;
    }
    
    template<typename _T>
    inline void
    sort(_T __first, _T __last)
    {
        _T it = __first;
        
        for( ;it != __last; it++ )
        {
            _T subit = it;
            subit++;
            
            for(; subit != __last; subit++ )
            {
                if( *subit < *it  )
                {
                    it.swap(subit);
                }
            }
        }
    }
    
    
    template<typename _ForwardIterator, typename _Tp>
    _ForwardIterator
    lower_bound(_ForwardIterator __first, _ForwardIterator __last,
                const _Tp& __val)
    {
        _ForwardIterator it = __first;
        
        for(; it != __last; it++ )
        {
            const _Tp& v = *it;
            
            if( __val < v )
            {
                break;
            }
            else if( v < __val )
            {
                continue;
            }
            else //*it == __val
            {
                break;
            }
        }
        
        return it;
    }
    
    template<typename _ForwardIterator, typename _Tp>
    _ForwardIterator
    upper_bound(_ForwardIterator __first, _ForwardIterator __last,
                const _Tp& __val)
    {
        _ForwardIterator it = __first;
        
        for(; it != __last; it++ )
        {
            if( __val < *it )
            {
                break;
            }
        }
        
        return it;
    }
    
    template<typename _InputIterator, typename _Distance>
    inline void
    advance(_InputIterator& __i, _Distance __n)
    {
        while (__n--)
            ++__i;
    }

	template<class _Ty> inline
		void swap(_Ty& _Left, _Ty& _Right)
	{	// exchange values stored at _Left and _Right
		_Ty _Tmp = _Left;
		_Left = _Right, _Right = _Tmp;
	}

}


#endif // _XPSTL_ALGO_H_
