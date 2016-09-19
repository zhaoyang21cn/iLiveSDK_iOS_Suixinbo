//
//  xplist.h
//  
//
//  Created by gavin huang on 12-7-23.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#ifndef _XP_LIST_H_
#define _XP_LIST_H_

/*----------------------------------------------------------------------
|   includes
+---------------------------------------------------------------------*/
#include <xptypes.h>

namespace xpstl
{
///*----------------------------------------------------------------------
//|   constants
//+---------------------------------------------------------------------*/
//const int -1              = NPT_ERROR_BASE_LIST - 0;
//const int NPT_ERROR_LIST_OPERATION_ABORTED  = NPT_ERROR_BASE_LIST - 1;
//const int NPT_ERROR_LIST_OPERATION_CONTINUE = NPT_ERROR_BASE_LIST - 2;

/*----------------------------------------------------------------------
|   list
+---------------------------------------------------------------------*/
template <typename T> 
class list 
{
protected:
    class Item;

public:
    // types
    typedef T Element;

    class iterator 
    {
    public:
        iterator() : m_Item(NULL),m_Tail(NULL) {}
        explicit iterator(Item* item,void** tail) : m_Item(item),m_Tail(tail) {}
        iterator(const iterator& copy) : m_Item(copy.m_Item),m_Tail(copy.m_Tail) {}
        T&  operator*()  const { return m_Item->m_Data; }
        T*  operator->() const { return &m_Item->m_Data;}
        iterator& operator++()  { // prefix
            m_Item = m_Item->m_Next;
            return (*this); 
        }
        iterator operator++(int) { // postfix
            iterator saved_this = *this;
            m_Item = m_Item->m_Next;
            return saved_this;
        }
        iterator& operator--() { // prefix
            if( m_Item == NULL ) m_Item = *((Item**)m_Tail);
            else m_Item = m_Item->m_Prev;
            return (*this); 
        }
        iterator operator--(int) { // postfix
            iterator saved_this = *this;
            if( m_Item == NULL )m_Item = *((Item**)m_Tail);
            else m_Item = m_Item->m_Prev;
            return saved_this;
        }
        operator bool() const {
            return m_Item != NULL;
        }
        bool operator==(const iterator& other) const {
            if( m_Item == NULL && other.m_Item == NULL )
            {
                return m_Tail == other.m_Tail;
            }
            return m_Item == other.m_Item;
        }
        bool operator!=(const iterator& other) const {
            if( m_Item == NULL && other.m_Item == NULL )
            {
                return m_Tail != other.m_Tail;
            }
            return m_Item != other.m_Item;
        }
        void operator=(const iterator& other) {
            m_Item = other.m_Item;
            m_Tail = other.m_Tail;
        }
        
        void swap( iterator & other )
        {
            if( NULL == m_Item || NULL == other.m_Item )
            {
                return;
            }
            
            T data = m_Item->m_Data;
            m_Item->m_Data = other.m_Item->m_Data;
            other.m_Item->m_Data = data;
        }

    private:
        Item* m_Item;
        void** m_Tail;

        // friends
        friend class list<T>;
    };
    
    typedef iterator const_iterator;

public:    
    
    //construct methods
    list<T>();
    list<T>(const list<T>& list);
    ~list<T>();
    
    // operators
    void operator=(const list<T>& other);
    bool operator==(const list<T>& other) const;
    bool operator!=(const list<T>& other) const;
    
    //add 
    iterator    insert(const iterator where, const T& data);
    void        push_back(const T&data) { Add(data); };
    void        push_front(const T&data) { insert(begin(), data); };

    //del
    void        pop_front() { erase(GetFirstItem()); };
    void        pop_back() { erase(GetLastItem()); };
    iterator    erase(const iterator position);
    void        clear();
    
    //size
    uint32      size() const { return m_ItemCount; };
    bool        empty() const { return m_ItemCount == 0; };
    
    //get
    iterator    begin() const { return iterator(m_Head,(void**)&m_Tail); }
    iterator    end() const { return iterator(NULL,(void**)&m_Tail); }
	iterator	last() const{ return iterator(m_Tail,(void**)&m_Tail);}
    T&          front() const { return *iterator(m_Head,(void**)&m_Tail); }
    T&          back() const { return *iterator(m_Tail,(void**)&m_Tail); }
    bool        contains(const T& data) const;
    
    //set
    void        swap(list<T> &v);
    void        splice(iterator __position, list& __x);
    void        splice(iterator __position, list& __x, iterator __i);
    void        splice(iterator __position, list& __x, iterator __first, iterator __last);
    
    //mutil insert
    template<typename _InputIterator>
    void
    insert(iterator __position,_InputIterator __first,_InputIterator __last)
    {
        iterator it     = __first;
        iterator itpos  = __position;
        for(; it!= __last; it++ )
        {
            itpos = insert(itpos, *it);
            itpos++;
        }
    }
    
private:
    
    iterator    insert(const iterator where, Item& item);
    int32       Add(const T& data);
    int32       Remove(const T& data, bool all=false);
    int32       PopHead(T& data);
    int32       Get(uint32 index, T& data) const;
    int32       Get(uint32 index, T*& data) const;
    uint32      GetItemCount() const { return m_ItemCount; }
    iterator    GetFirstItem() const { return iterator(m_Head,(void**)&m_Tail); }
    iterator    GetLastItem() const  { return iterator(m_Tail,(void**)&m_Tail); }
    iterator    GetItem(uint32 index) const;

    // list manipulation
    int32       Add(list<T>& list);
    int32       Remove(const list<T>& list, bool all=false);

    // item manipulation
    int32       Add(Item& item);
    int32       Detach(Item& item);
  
    // list operations
    // keep these template members defined here because MSV6 does not let
    // us define them later
    template <typename X> 
    int32 Apply(const X& function) const
    {                          
        Item* item = m_Head;
        while (item) {
            function(item->m_Data);
            item = item->m_Next;
        }

        return 0;
    }

    template <typename X, typename P> 
    int32 ApplyUntil(const X& function, const P& predicate, bool* match = NULL) const
    {                          
        Item* item = m_Head;
        while (item) {
            int32 return_value;
            if (predicate(function(item->m_Data), return_value)) {
                if (match) *match = true;
                return return_value;
            }
            item = item->m_Next;
        }
        
        if (match) *match = false;
        return 0;
    }

    template <typename P> 
    iterator Find(const P& predicate, uint32 n=0) const
    {
        Item* item = m_Head;
        while (item) {
            if (predicate(item->m_Data)) {
                if (n == 0) {
                    return iterator(item,(void**)&m_Tail);
                }
                --n;
            }
            item = item->m_Next;
        }

        return iterator(NULL,(void**)&m_Tail);
    }

protected:
    // types
    class Item 
    {
    public:
        // methods
        Item(const T& data) : m_Next(0), m_Prev(0), m_Data(data) {}

        // members
        Item* m_Next;
        Item* m_Prev;
        T     m_Data;

        // friends
        //friend class list<T>;
        //friend class list<T>::iterator;
    };

    // members
    uint32       m_ItemCount;
    Item*        m_Head;
    Item*        m_Tail;
};

/*----------------------------------------------------------------------
|   list<T>::list
+---------------------------------------------------------------------*/
template <typename T>
inline
list<T>::list() : m_ItemCount(0), m_Head(0), m_Tail(0) 
{
}

/*----------------------------------------------------------------------
|   list<T>::list
+---------------------------------------------------------------------*/
template <typename T>
inline
list<T>::list(const list<T>& list) : m_ItemCount(0), m_Head(0), m_Tail(0) 
{
    *this = list;
}

/*----------------------------------------------------------------------
|   list<T>::~list<T>
+---------------------------------------------------------------------*/
template <typename T>
inline
list<T>::~list()
{
    clear();
}
 
/*----------------------------------------------------------------------
|   list<T>::operator=
+---------------------------------------------------------------------*/
template <typename T>
void
list<T>::operator=(const list<T>& list)
{
    // cleanup
    clear();

    // copy the new list
    Item* item = list.m_Head;
    while (item) {
        Add(item->m_Data);
        item = item->m_Next;
    }
}

/*----------------------------------------------------------------------
|   list<T>::operator==
+---------------------------------------------------------------------*/
template <typename T>
bool
list<T>::operator==(const list<T>& other) const
{
    // quick test
    if (m_ItemCount != other.m_ItemCount) return false;

    // compare all elements one by one
    Item* our_item = m_Head;
    Item* their_item = other.m_Head;
    while (our_item && their_item) {
        if (our_item->m_Data != their_item->m_Data) return false;
        our_item   = our_item->m_Next;
        their_item = their_item->m_Next;
    }
    
    return our_item == NULL && their_item == NULL;
}

/*----------------------------------------------------------------------
|   list<T>::operator!=
+---------------------------------------------------------------------*/
template <typename T>
inline
bool
list<T>::operator!=(const list<T>& other) const
{
    return !(*this == other);
}

/*----------------------------------------------------------------------
|   list<T>::clear
+---------------------------------------------------------------------*/
template <typename T>
void
list<T>::clear()
{
    // delete all items
    Item* item = m_Head;
    while (item) {
        Item* next = item->m_Next;
        delete item;
        item = next;
    }

    m_ItemCount = 0;
    m_Head      = NULL;
    m_Tail      = NULL;
}

/*----------------------------------------------------------------------
|   list<T>::Add
+---------------------------------------------------------------------*/
template <typename T>
int32
list<T>::Add(Item& item)
{
    // add element at the tail
    if (m_Tail) {
        item.m_Prev = m_Tail;
        item.m_Next = NULL;
        m_Tail->m_Next = &item;
        m_Tail = &item;
    } else {
        m_Head = &item;
        m_Tail = &item;
        item.m_Next = NULL;
        item.m_Prev = NULL;
    }

    // one more item in the list now
    ++m_ItemCount;
 
    return 0;
}

/*----------------------------------------------------------------------
|   list<T>::Add
+---------------------------------------------------------------------*/
template <typename T>
int32
list<T>::Add(list<T>& list)
{
    // copy the new list
    Item* item = list.m_Head;
    while (item) {
        Add(item->m_Data);
        item = item->m_Next;
    }

    return 0;
}

/*----------------------------------------------------------------------
|   list<T>::Add
+---------------------------------------------------------------------*/
template <typename T>
inline
int32
list<T>::Add(const T& data)
{
    return Add(*new Item(data));
}

/*----------------------------------------------------------------------
|   list<T>::GetItem
+---------------------------------------------------------------------*/
template <typename T>
typename list<T>::iterator
list<T>::GetItem(uint32 n) const
{
    iterator result;
    if (n >= m_ItemCount) return result;
    
    result = m_Head;
    for (unsigned int i=0; i<n; i++) {
        ++result;
    }

    return result;
}

/*----------------------------------------------------------------------
|   list<T>::insert
+---------------------------------------------------------------------*/
template <typename T>
typename list<T>::iterator
list<T>::insert(iterator where, const T&data)
{
    return insert(where, *new Item(data));
}

/*----------------------------------------------------------------------
 |   list<T>::insert
 +---------------------------------------------------------------------*/
template <typename T>
typename list<T>::iterator 
list<T>::insert(iterator where, Item& item)
{
    // insert the item in the list
    Item* position = where.m_Item;
    if (position) {
        // insert at position
        item.m_Next = position;
        item.m_Prev = position->m_Prev;
        position->m_Prev = &item;
        if (item.m_Prev) {
            item.m_Prev->m_Next = &item;
        }
        else 
        {
            // this is the new head
            m_Head = &item;
        }
        // one more item in the list now
        ++m_ItemCount;
        
        return iterator(&item,(void**)&m_Tail);
    } 
    else 
    {
        // insert at tail
        if( 0 == Add(item) )
        {
            return iterator(m_Tail,(void**)&m_Tail);
        }
    }
    
    return end();
}

/*----------------------------------------------------------------------
|   list<T>::insert
+---------------------------------------------------------------------*/
//template <typename T>
//int32
//list<T>::insert(iterator where, Item& item)
//{
//    // insert the item in the list
//    Item* position = where.m_Item;
//    if (position) {
//        // insert at position
//        item.m_Next = position;
//        item.m_Prev = position->m_Prev;
//        position->m_Prev = &item;
//        if (item.m_Prev) {
//            item.m_Prev->m_Next = &item;
//        } else {
//            // this is the new head
//            m_Head = &item;
//        }
//
//        // one more item in the list now
//        ++m_ItemCount;
//    } else {
//        // insert at tail
//        return Add(item);
//    }
// 
//    return 0;
//}

/*----------------------------------------------------------------------
|   list<T>::erase
+---------------------------------------------------------------------*/
template <typename T>
typename list<T>::iterator
list<T>::erase(iterator position) 
{
    if (!position) return end();
    Item* pNextItem = position.m_Item->m_Next;
    Detach(*position.m_Item);
    delete position.m_Item;

    return iterator(pNextItem,(void**)&m_Tail);
}

/*----------------------------------------------------------------------
|   list<T>::Remove
+---------------------------------------------------------------------*/
template <typename T>
int32
list<T>::Remove(const T& data, bool all)
{
    Item* item = m_Head;
    uint32 matches = 0;

    while (item) {
        Item* next = item->m_Next;
        if (item->m_Data == data) {
            // we found a match
            ++matches;

            // detach item
            Detach(*item);
            
            // destroy the item
            delete item;

            if (!all) return 0;
        }
        item = next;
    }
 
    return matches?0:-1;
}

/*----------------------------------------------------------------------
|   list<T>::Remove
+---------------------------------------------------------------------*/
template <typename T>
int32
list<T>::Remove(const list<T>& list, bool all)
{
    Item* item = list.m_Head;
    while (item) {
        Remove(item->m_Data, all);
        item = item->m_Next;
    }

    return 0;
}

/*----------------------------------------------------------------------
|   list<T>::Detach
+---------------------------------------------------------------------*/
template <typename T>
int32
list<T>::Detach(Item& item)
{
    // remove item
    if (item.m_Prev) {
        // item is not the head
        if (item.m_Next) {
            // item is not the tail
            item.m_Next->m_Prev = item.m_Prev;
            item.m_Prev->m_Next = item.m_Next;
        } else {
            // item is the tail
            m_Tail = item.m_Prev;
            m_Tail->m_Next = NULL;
        }
    } else {
        // item is the head
        m_Head = item.m_Next;
        if (m_Head) {
            // item is not the tail
            m_Head->m_Prev = NULL;
        } else {
            // item is also the tail
            m_Tail = NULL;
        }
    }

    // one less item in the list now
    --m_ItemCount;

    return 0;
}

/*----------------------------------------------------------------------
|   list<T>::Get
+---------------------------------------------------------------------*/
template <typename T>
int32
list<T>::Get(uint32 index, T& data) const
{
    T* data_pointer;
    NPT_CHECK(Get(index, data_pointer));
    data = *data_pointer;
    return 0;
}

/*----------------------------------------------------------------------
|   list<T>::Get
+---------------------------------------------------------------------*/
template <typename T>
int32
list<T>::Get(uint32 index, T*& data) const
{
    Item* item = m_Head;

    if (index < m_ItemCount) {
        while (index--) item = item->m_Next;
        data = &item->m_Data;
        return 0;
    } else {
        data = NULL;
        return -1;
    }
}

/*----------------------------------------------------------------------
|   list<T>::PopHead
+---------------------------------------------------------------------*/
template <typename T>
int32
list<T>::PopHead(T& data)
{
    // check that we have an element
    if (m_Head == NULL) return -1;

    // copy the head item's data
    data = m_Head->m_Data;

    // discard the head item
    Item* head = m_Head;
    m_Head = m_Head->m_Next;
    if (m_Head) {
        m_Head->m_Prev = NULL;
    } else {
        m_Tail = NULL;
    }
    delete head;

    // update the count
    --m_ItemCount;

    return 0;
}

/*----------------------------------------------------------------------
|   list<T>::contains
+---------------------------------------------------------------------*/
template <typename T>
bool
list<T>::contains(const T& data) const
{
    Item* item = m_Head;
    while (item) {
        if (item->m_Data == data) return true;
        item = item->m_Next;
    }

    return false;
}
    
template <typename T>
void
list<T>::swap(list<T>& v)
{
    if( this == &v ) return;
    
    uint32       ItemCount = m_ItemCount;
    Item*        Head = m_Head;
    Item*        Tail = m_Tail;
    
    m_ItemCount = v.m_ItemCount;
    m_Head      = v.m_Head;
    m_Tail      = v.m_Tail;
    
    v.m_ItemCount = ItemCount;
    v.m_Head      = Head;
    v.m_Tail      = Tail;
}
    
template <typename T>
void
list<T>::splice(iterator __position, list& __x)
{
    if( __x.empty() ) return;
    insert(__position,__x.begin(),__x.end());
}
    
/**
 *  @brief  Insert element from another %list.
 *  @param  position  Iterator referencing the element to insert before.
 *  @param  x  Source list.
 *  @param  i  Iterator referencing the element to move.
 *
 *  Removes the element in list @a x referenced by @a i and
 *  inserts it into the current list before @a position.
 */
template <typename T>
void
list<T>::splice(iterator __position, list& __x, iterator __i)
{
    if( __x.empty() || __i == __x.end() )
        return;    
    iterator __j = __i;
    ++__j;
    if (__position == __i || __position == __j)
        return;
    insert(__position,__i,__j);
}
    
/**
 *  @brief  Insert range from another %list.
 *  @param  position  Iterator referencing the element to insert before.
 *  @param  x  Source list.
 *  @param  first  Iterator referencing the start of range in x.
 *  @param  last  Iterator referencing the end of range in x.
 *
 *  Removes elements in the range [first,last) and inserts them
 *  before @a position in constant time.
 *
 *  Undefined if @a position is in [first,last).
 */
template <typename T>
void
list<T>::splice(iterator __position, list& __x, iterator __first, iterator __last)
{
    if (__first == __last)
    {
        return;
    }
    
    if( __x.empty() ) return;
    
    insert(__position,__first,__last);
}

    
}

#endif // _list_H_
