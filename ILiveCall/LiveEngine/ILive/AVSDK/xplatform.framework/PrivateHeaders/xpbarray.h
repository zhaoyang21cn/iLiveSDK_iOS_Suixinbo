/******************************************************************
 ** File 		: xpbarray.h
 ** Author		: Amoslan
 ** Date		: 2011-03-13
 ** Copyright	: Copyright (c) 2012-2014 Tencent Co.,Ltd.
 ** Description	: xplatform binary array
 **
 ** Version		: 1.0
 ** History		:
 ******************************************************************/
#if !defined(_XPBARRAY_INC_)
#define _XPBARRAY_INC_
#pragma once

#include <xptypes.h>

namespace xp {
	/*
	 binary function
	 */
	template <typename _T, typename _K>
	inline int32 bsearch(_T* vs, int32 sz, const _K& k, bool& hit) {
		int h = sz >> 1, i = h, bp = 0, ep = sz - 1;
		
		hit = false;
		if (sz == 0) {
			return 0;
		}
		do {
			i = h;
			if (k == *reinterpret_cast<_K*>(&vs[i])) {
				hit = true;
				return i;
			}
			else if (k < *reinterpret_cast<_K*>(&vs[i])) {
				if (i <= bp) {
					return i;
				}
				ep = i - 1;
				h = i >> 1;
			}
			else {
				if (i >= ep) {
					return ep + 1;
				}
				bp = i + 1;
				h = (i + ep + 1) >> 1;
			}
			
		} while (i != h);
		
		return h;
	}
	
	template <class _ET, typename _KT, int cap>
	struct barray {
		typedef union {
			_ET	v;
			_KT	k;
		}_MK;
		typedef _ET*		iterator;
		typedef const _ET*	const_iterator;
		
	public:
		barray(void) {
			_room = cap;
			_last = _end = &_head[0];
			_size = 0;
		}
		
		int32		capacity(void) const {
			return _room;}
		
		void		clearup(void) {
			_last = _end = &_head[0];
			_size	= 0;
		}
		
		// iterators
		/**
		 *  Returns a read/write iterator that points to the first pair in the
		 *  %array.
		 *  Iteration is done in ascending order according to the keys.
		 */
		iterator	begin(void) {
			return &(_head[0].v);}
		
		/**
		 *  Returns a read-only (constant) iterator that points to the first pair
		 *  in the %array.  Iteration is done in ascending order according to the
		 *  keys.
		 */
		const_iterator	begin(void) const {
			return &(_head[0].v);}

		/**
		 *  Returns a read/write iterator that points one past the last
		 *  pair in the %array.  Iteration is done in ascending order
		 *  according to the keys.
		 */
		iterator	end(void) {
			return &(_end->v);}
		
		/**
		 *  Returns a read-only (constant) iterator that points one past the last
		 *  pair in the %array.  Iteration is done in ascending order according to
		 *  the keys.
		 */
		const_iterator	end(void) const {
			return &(_end->v);}

		/**
		 *  Returns a read/write iterator that points the last
		 *  pair in the %array.  Iteration is done in ascending order
		 *  according to the keys.
		 */
		iterator	last(void) {
			return &(_last->v);}
		
		/**
		 *  Returns a read-only (constant) iterator that points the last
		 *  pair in the %array.  Iteration is done in ascending order according to
		 *  the keys.
		 */
		const_iterator	last(void) const {
			return &(_last->v);}
        
		/** Returns the size of the %array.  */
		int32		size(void) const {
			return _size;}
		
		/**
		 *  @brief Tries to locate an element in a %array.
		 *  @param  __k  Key of %value to be located.
		 *  @return  Iterator pointing to sought-after element, or end() if not
		 *           found.
		 *
		 *  This function takes a key and tries to locate the element with which
		 *  the key matches.  If successful the function returns an iterator
		 *  pointing to the sought after %value.  If unsuccessful it returns the
		 *  past-the-end ( @c end() ) iterator.
		 */
		iterator	find(_KT __k) {
			bool hit = false;
			int32 pos = bsearch(_head, _size, __k, hit);
			if (!hit) {
				return &(_end->v);
			}
			return &(_head[pos].v);
		}
		
		/**
		 *  @brief Tries to locate an element in a %array.
		 *  @param  x  Key of %vaue to be located.
		 *  @return  Read-only (constant) iterator pointing to sought-after
		 *           element, or end() if not found.
		 *
		 *  This function takes a key and tries to locate the element with which
		 *  the key matches.  If successful the function returns a constant
		 *  iterator pointing to the sought after %value. If unsuccessful it
		 *  returns the past-the-end ( @c end() ) iterator.
		 */
		const_iterator	find(_KT __k) const {
			bool hit = false;
			int32 pos = bsearch(_head, _size, __k, hit);
			if (!hit) {
				return &(_end->v);
			}
			return &(_head[pos].v);
		}
		
		// modifiers
		/**
		 *  @brief Attempts to insert a value into the %array.
		 
		 *  @param  __x  Value to be inserted.
		 
		 *  @return  iterator was actually inserted.
		 *
		 *  This function attempts to insert a value into the %array.
		 *  A %array relies on unique keys and thus a %value is only inserted if its
		 *  key element is not already present in the %array.
		 *
		 *  Insertion requires logarithmic time.
		 */
		iterator	insert(const _ET& __x) {
			bool hit = false;
			int32 pos = bsearch(_head, _size, *reinterpret_cast<const _KT*>(&__x), hit);
			if (hit) {
				return &(_head[pos].v);
			}
			else if (_size >= _room) {
				return &(_end->v);
			}
			if(pos != _size) { //need to be moved?
				_MK* dst = &_head[pos + 1];
				memmove(dst, &_head[pos], sizeof(_MK) * (_size - pos));
			}
			_head[pos].v = __x;
			_size++;
			_end++;
            if (_size != 1) {//one past the last
                _last++;
            }
			return &(_head[pos].v);
		}
		
		/**
		 *  @brief Attempts to insert a empty value into the %array.
		 
		 *  @param  __k  Key of new value to be inserted.
		 
		 *  @return  iterator was actually inserted.
		 *
		 *  This function attempts to insert a value into the %array.
		 *  A %array relies on unique keys and thus a %value is only inserted if its
		 *  key element is not already present in the %array.
		 *
		 *  Insertion requires logarithmic time.
		 */
		iterator	insert(_KT __k) {
			bool hit = false;
			int32 pos = bsearch(_head, _size, __k, hit);
			if (hit) {
				return &(_head[pos].v);
			}
			else if (_size >= _room) {
				return &_end->v;
			}
			if(pos != _size) { //need to be moved?
				_MK* dst = &_head[pos + 1];
				memmove(dst, &_head[pos], sizeof(_MK) * (_size - pos));
			}
			_head[pos].k = __k;
			_size++;
			_end++;
            if (_size != 1) {//one past the last
                _last++;
            }
			return &(_head[pos].v);
		}
		
		/**
		 *  @brief Erases an element from a %array.
		 *  @param  __k  An key of the element to be erased.
		 *
		 *  This function erases an element, pointed to by the given
		 *  key, from a %array.
		 */
		iterator	erase(_KT __k) {
			bool hit = false;
			int32 pos = bsearch(_head, _size, __k, hit);
			if (!hit) {
				return &(_end->v);
			}
			if(pos != (_size - 1)) { //need to be moved?
				_MK* src = &_head[pos + 1];
				memmove(&_head[pos], src, sizeof(_MK) * (_size - pos - 1));
			}
			_size--;
			_last--;
			_end--;
            if (_size == 0) {//rewind to begin
                _last = _end = &_head[0];
            }
			return &(_head[pos].v);
		}

	protected:
		_MK		_head[cap + 1];
		_MK*	_last;
		_MK*	_end;
		int32	_size;
		int32	_room;
	};
};

#endif // !defined(_XPBARRAY_INC_)
