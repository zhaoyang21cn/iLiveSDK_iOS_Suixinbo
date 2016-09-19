//
//  xpvector.h
//  
//
//  Created by gavin huang on 12-7-23.
//  Copyright (c) 2012å¹?tencent. All rights reserved.
//
#ifndef _XPVECTOR_H_
#define _XPVECTOR_H_

/*----------------------------------------------------------------------
|   includes
+---------------------------------------------------------------------*/
#include <new>
#include <xptypes.h>

namespace xpstl {
    
/*----------------------------------------------------------------------
|   constants
+---------------------------------------------------------------------*/
const int XPVECTOR_INITIAL_MAX_SIZE = 128; // bytes

/*----------------------------------------------------------------------
|   xpvector
+---------------------------------------------------------------------*/
template <typename T> 
class vector 
{
public:
    // types
    typedef T Element;
    //typedef T* iterator;
    //typedef const T* const_iterator;
    
    class iterator
    {
    public:
        iterator(): m_Item(NULL) {};
        
        iterator( T* Item ) 
        {
            m_Item = Item;
        }
        
        iterator & operator++()
        {
            if( m_Item ) m_Item++;
            return *this;
        }
        
        iterator operator++(int)
        {
            iterator it(m_Item);
            if( m_Item ) m_Item++;
            return it;
        }
        
        iterator operator+(uint32 nOffset)
        {
            T* tmp = m_Item;
            tmp += nOffset;
            return iterator( tmp );
        }
    
        iterator & operator--()
        {
            if( m_Item ) m_Item--;
            return *this;
        }
        
        iterator  operator--(int)
        {
            iterator it(m_Item);
            if( m_Item ) m_Item--;
            return it;
        }
        
        T& operator*()
        {
            return *m_Item;
        }
        
        T* operator->()
        {
            return m_Item;
        }
        
        bool operator == ( const iterator &other) const
        {
            return m_Item == other.m_Item;
        }
        
        bool operator != ( const iterator &other) const
        {
            return m_Item != other.m_Item;
        }
        
        void swap(iterator &other)
        {
            T tmp   = *m_Item;
            T tmp1  = tmp;
            *m_Item = *other.m_Item;
            *other.m_Item = tmp1; 
        }
        
    private:
        T*  m_Item;
    };
    
    typedef iterator const_iterator;

    // construct
    vector<T>(): m_Capacity(0), m_ItemCount(0), m_Items(0) {}
    explicit vector<T>(uint32 count);
    vector<T>(uint32 count, const T& item);
    vector<T>(const T* items, uint32 item_count) ;
    ~vector<T>();
    vector<T>(const vector<T>& copy);
    vector<T>& operator=(const vector<T>& copy);
    
    // operator
    bool     operator==(const vector<T>& other) const;
    bool     operator!=(const vector<T>& other) const;
    T&       operator[](uint32 pos) { return m_Items[pos]; }
    const T& operator[](uint32 pos) const { return m_Items[pos]; }

    // erase
    iterator    erase(iterator which);
    void        clear();
    
    // length
    int32       reserve(uint32 count);
	int32       shrink(uint32 size);
    uint32      capacity() const { return m_Capacity; }
    uint32      size()  const  { return m_ItemCount; }
    bool        empty() const  { return ( m_ItemCount == 0); }
    
    // add
    int32       insert(iterator where, const T& item, uint32 count = 1);
    int32       push_back(const T& item) { return Add(item); }
    
    // get
    bool        contains(const T& data) const;
    iterator    front() const  { return GetFirstItem(); }
    iterator    back()  const  { return GetLastItem(); };
    iterator    begin() const  { return GetFirstItem(); }
    iterator    end()   const  { return m_ItemCount?&m_Items[m_ItemCount]:NULL; }
    void        swap(vector<T>& v);

    //samqin
    iterator    get(uint32 n) { return n<m_ItemCount?&m_Items[n]:NULL; }
    //end
    
private:
    
    int32       erase(uint32 first, uint32 last) { return erase(&m_Items[first], &m_Items[last]); }
    int32       erase(iterator first, iterator last);
    uint32      GetItemCount() const { return m_ItemCount; }
    int32       Add(const T& item);    
    int32       Resize(uint32 count);
    int32       Resize(uint32 count, const T& fill);
    iterator    GetFirstItem() const { return m_ItemCount?&m_Items[0]:NULL; }
    iterator    GetLastItem() const  { return m_ItemCount?&m_Items[m_ItemCount-1]:NULL; }
    iterator    GetItem(uint32 n) { return n<m_ItemCount?&m_Items[n]:NULL; }


    // template list operations
    // keep these template members defined here because MSV6 does not let
    // us define them later
    template <typename X> 
    int32 Apply(const X& function) const
    {                                  
        for (uint32 i=0; i<m_ItemCount; i++) function(m_Items[i]);
        return 0;
    }

    template <typename X, typename P>
    int32 ApplyUntil(const X& function, const P& predicate, bool* match = NULL) const
    {                                  
        for (uint32 i=0; i<m_ItemCount; i++) {
            int32 return_value;
            if (predicate(function(m_Items[i]), return_value)) {
                if (match) *match = true;
                return return_value;
            }
        }
        if (match) *match = false;
        return 0;
    }

    template <typename X> 
    T* Find(const X& predicate, uint32 n=0, uint32* pos = NULL) const
    {
        if (pos) *pos = -1;

        for (uint32 i=0; i<m_ItemCount; i++) {
            if (predicate(m_Items[i])) {
                if (pos) *pos = i;
                if (n == 0) return &m_Items[i];
                --n;
            }
        }
        return NULL;
    }

protected:
    // methods
    T* Allocate(uint32 count, uint32& allocated);

    // members
    uint32 m_Capacity;
    uint32 m_ItemCount;
    T*     m_Items;
};

/*----------------------------------------------------------------------
|   vector<T>::vector<T>
+---------------------------------------------------------------------*/
template <typename T>
inline
vector<T>::vector(uint32 count) :
    m_Capacity(0),
    m_ItemCount(0),
    m_Items(0)
{
    reserve(count);
}

/*----------------------------------------------------------------------
|   vector<T>::vector<T>
+---------------------------------------------------------------------*/
template <typename T>
inline
vector<T>::vector(const vector<T>& copy) :
    m_Capacity(0),
    m_ItemCount(0),
    m_Items(0)
{
    reserve(copy.GetItemCount());
    for (uint32 i=0; i<copy.m_ItemCount; i++) {
        new ((void*)&m_Items[i]) T(copy.m_Items[i]);
    }
    m_ItemCount = copy.m_ItemCount;
}

/*----------------------------------------------------------------------
|   vector<T>::vector<T>
+---------------------------------------------------------------------*/
template <typename T>
inline
vector<T>::vector(uint32 count, const T& item) :
    m_Capacity(0),
    m_ItemCount(count),
    m_Items(0)    
{
    reserve(count);
    for (uint32 i=0; i<count; i++) {
        new ((void*)&m_Items[i]) T(item);
    }
}

/*----------------------------------------------------------------------
|   vector<T>::vector<T>
+---------------------------------------------------------------------*/
template <typename T>
inline
vector<T>::vector(const T* items, uint32 item_count) :
    m_Capacity(0),
    m_ItemCount(item_count),
    m_Items(0)    
{
    reserve(item_count);
    for (uint32 i=0; i<item_count; i++) {
        new ((void*)&m_Items[i]) T(items[i]);
    }
}

/*----------------------------------------------------------------------
|   vector<T>::~vector<T>
+---------------------------------------------------------------------*/
template <typename T>
inline
vector<T>::~vector()
{
    // remove all items
    clear();

    // free the memory
    ::operator delete((void*)m_Items);
}



/*----------------------------------------------------------------------
 |   vector<T>::operator=
 +---------------------------------------------------------------------*/
template <typename T>
void
vector<T>::swap(vector<T>& v)
{
    if( this == &v ) return;
    
    uint32 Capacity  = m_Capacity;
    uint32 ItemCount = m_ItemCount;
    T*     Items     = m_Items;
    
    m_Capacity = v.m_Capacity;
    m_Items    = v.m_Items;
    m_ItemCount= v.m_ItemCount;
    
    v.m_Capacity = Capacity;
    v.m_Items    = Items;
    v.m_ItemCount= ItemCount;
}
        
/*----------------------------------------------------------------------
|   vector<T>::operator=
+---------------------------------------------------------------------*/
template <typename T>
vector<T>&
vector<T>::operator=(const vector<T>& copy)
{
    // do nothing if we're assigning to ourselves
    if (this == &copy) return *this;

    // destroy all elements
    clear();

    // copy all elements from the other object
    reserve(copy.GetItemCount());
    m_ItemCount = copy.m_ItemCount;
    for (uint32 i=0; i<copy.m_ItemCount; i++) {
        new ((void*)&m_Items[i]) T(copy.m_Items[i]);
    }

    return *this;
}

/*----------------------------------------------------------------------
|   vector<T>::clear
+---------------------------------------------------------------------*/
template <typename T>
void
vector<T>::clear()
{
    // destroy all items
    for (uint32 i=0; i<m_ItemCount; i++) {
        m_Items[i].~T();
    }

    m_ItemCount = 0;
}

/*----------------------------------------------------------------------
|   vector<T>::Allocate
+---------------------------------------------------------------------*/
template <typename T>
T*
vector<T>::Allocate(uint32 count, uint32& allocated) 
{
    if (m_Capacity) {
        allocated = 2*m_Capacity;
    } else {
        // start with just enough elements to fill 
        // XPVECTOR_INITIAL_MAX_SIZE worth of memory
        allocated = XPVECTOR_INITIAL_MAX_SIZE/sizeof(T);
        if (allocated == 0) allocated = 1;
    }
    if (allocated < count) allocated = count;

    // allocate the items
    return (T*)::operator new(allocated*sizeof(T));
}

/*----------------------------------------------------------------------
|   vector<T>::reserve
+---------------------------------------------------------------------*/
template <typename T>
int32
vector<T>::reserve(uint32 count)
{
    if (count <= m_Capacity) return 0;

    // (re)allocate the items
    uint32 new_capacity;
    T* new_items = Allocate(count, new_capacity);
    if (new_items == NULL) {
        return -1;
    }
    if (m_ItemCount && m_Items) {
        for (uint32 i=0; i<m_ItemCount; i++) {
            // construct the copy
            new ((void*)&new_items[i])T(m_Items[i]);

            // destroy the item
            m_Items[i].~T();
        }
    }
    ::operator delete((void*)m_Items);
    m_Items = new_items;
    m_Capacity = new_capacity;

    return 0;
}

/*----------------------------------------------------------------------
|   vector<T>::shrink
+---------------------------------------------------------------------*/
template <typename T>
int32
vector<T>::shrink(uint32 size)
{
	if (size < m_ItemCount) {
		// shrink
		for (uint32 i=size; i<m_ItemCount; i++) {
			m_Items[i].~T();
		}
		m_ItemCount = size;
	}

	return 0;
}

/*----------------------------------------------------------------------
|   vector<T>::Add
+---------------------------------------------------------------------*/
template <typename T>
inline
int32
vector<T>::Add(const T& item)
{
    // ensure capacity
    int32 result = reserve(m_ItemCount+1);
    if (result != 0) return result;

    // store the item
    new ((void*)&m_Items[m_ItemCount++]) T(item);

    return 0;
}

/*----------------------------------------------------------------------
|   vector<T>::erase
+---------------------------------------------------------------------*/
template <typename T>
inline
typename vector<T>::iterator
vector<T>::erase(iterator it)
{
    T* which = &(*it);
    uint32 uindex = (uint32)(uint64(which - m_Items));
    if( 0 != erase(which, which) || m_ItemCount == 0)
    {
        return end();
    }

    return &m_Items[uindex];
}

/*----------------------------------------------------------------------
|   vector<T>::erase
+---------------------------------------------------------------------*/
template <typename T>
int32
vector<T>::erase(iterator itfirst, iterator itlast)
{
    T* first = &(*itfirst);
    T* last  = &(*itlast);
    // check parameters
    if (first == NULL || last == NULL) return -1;

    // check the bounds
    uint32 first_index = (uint32)(uint64(first-m_Items));
    uint32 last_index  = (uint32)(uint64(last-m_Items));
    if (first_index >= m_ItemCount ||
        last_index  >= m_ItemCount ||
        first_index > last_index) {
        return -1;
    }

    // shift items to the left
    uint32 interval = last_index-first_index+1;
    uint32 shifted = m_ItemCount-last_index-1;
    for (uint32 i=first_index; i<first_index+shifted; i++) {
        m_Items[i] = m_Items[i+interval];
    }

    // destruct the remaining items
    for (uint32 i=first_index+shifted; i<m_ItemCount; i++) {
        m_Items[i].~T();
    }

    // update the item count
    m_ItemCount -= interval;

    return 0;
}

/*----------------------------------------------------------------------
|   vector<T>::insert
+---------------------------------------------------------------------*/
template <typename T>
int32
vector<T>::insert(iterator it, const T& item, uint32 repeat)
{
    // check bounds
    T* where = &(*it);
    uint32 where_index = where?((uint32)(uint64)(where-m_Items)):m_ItemCount;
    if (where > &m_Items[m_ItemCount] || repeat == 0) return -1;

    uint32 needed = m_ItemCount+repeat;
    if (needed > m_Capacity) {
        // allocate more memory
        uint32 new_capacity;
        T* new_items = Allocate(needed, new_capacity);
        if (new_items == NULL) return -1;
        m_Capacity = new_capacity;

        // move the items before the insertion point
        for (uint32 i=0; i<where_index; i++) {
            new((void*)&new_items[i])T(m_Items[i]);
            m_Items[i].~T();
        }

        // move the items after the insertion point
        for (uint32 i=where_index; i<m_ItemCount; i++) {
            new((void*)&new_items[i+repeat])T(m_Items[i]);
            m_Items[i].~T();
        }

        // use the new items instead of the current ones
        ::operator delete((void*)m_Items);
        m_Items = new_items;
    } else {
        // shift items after the insertion point to the right
        for (uint32 i=m_ItemCount; i>where_index; i--) {
            new((void*)&m_Items[i+repeat-1])T(m_Items[i-1]);
            m_Items[i-1].~T();
        }
    }

    // insert the new items
    for (uint32 i=where_index; i<where_index+repeat; i++) {
        new((void*)&m_Items[i])T(item);
    }

    // update the item count
    m_ItemCount += repeat;

    return 0;
}

/*----------------------------------------------------------------------
|   vector<T>::Resize
+---------------------------------------------------------------------*/
template <typename T>
int32
vector<T>::Resize(uint32 size)
{
    if (size < m_ItemCount) {
        // shrink
        for (uint32 i=size; i<m_ItemCount; i++) {
            m_Items[i].~T();
        }
        m_ItemCount = size;
    } else if (size > m_ItemCount) {
        return Resize(size, T());
    }

    return 0;
}

/*----------------------------------------------------------------------
|   vector<T>::Resize
+---------------------------------------------------------------------*/
template <typename T>
int32
vector<T>::Resize(uint32 size, const T& fill)
{
    if (size < m_ItemCount) {
        return Resize(size);
    } else if (size > m_ItemCount) {
        reserve(size);
        for (uint32 i=m_ItemCount; i<size; i++) {
            new ((void*)&m_Items[i]) T(fill);
        }
        m_ItemCount = size;
    }

    return 0;
}

/*----------------------------------------------------------------------
|   vector<T>::contains
+---------------------------------------------------------------------*/
template <typename T>
bool
vector<T>::contains(const T& data) const
{
    for (uint32 i=0; i<m_ItemCount; i++) {
        if (m_Items[i] < data || data < m_Items[i] )
            continue;
        return true;
    }

    return false;
}

/*----------------------------------------------------------------------
|   vector<T>::operator==
+---------------------------------------------------------------------*/
template <typename T>
bool
vector<T>::operator==(const vector<T>& other) const
{
    // we need the same number of items
    if (other.m_ItemCount != m_ItemCount) return false;

    // compare all items
    for (uint32 i=0; i<m_ItemCount; i++) {
        if ( m_Items[i] < other.m_Items[i] ) return false;
        else if ( other.m_Items[i] < m_Items[i] ) return false;
    }

    return true;
}

/*----------------------------------------------------------------------
|   vector<T>::operator!=
+---------------------------------------------------------------------*/
template <typename T>
inline
bool
vector<T>::operator!=(const vector<T>& other) const
{
    return !(*this == other);
}

}

#endif // _xpvector_H_
