/******************************************************************
 ** File 		: xpolist.h
 ** Author		: Amoslan
 ** Date		: 2013-10-17
 ** Copyright	: Copyright (c) 2012-2014 Tencent Co.,Ltd.
 ** Description	: xplatform ordered list impl
 **
 ** Version		: 1.0
 ** History		:
 ******************************************************************/
#if !defined(_XPOLIST_INC_)
#define _XPOLIST_INC_
#pragma once

#include <xptypes.h>

namespace xp {
    template <typename T>
    struct orderList {
        typedef struct node {
            T v;
            node(void) {prev = next = NULL;}
            struct node* prev;
            struct node* next;
        }node;
        
        orderList(void) {
            _head = _tail = NULL;
            _size = 0;
        }
        
        void clear(void) {
            while (_tail != _head) {
                node* prev = _tail->prev;
                prev->next = NULL;
                delete _tail;
                _tail = prev;
            }
            if (_head) {
                delete _head;
            }
            _head = _tail = NULL;
            _size = 0;
        }
        
        T& push_front(void) {
            if (_head == NULL) {
                _head = _tail = new node;
            }
            else {
                _tail->next = new node;
                _tail->next->prev = _tail;
                _tail = _tail->next;
            }
            _size++;
            return _tail->v;
        }
        
        void move_front(T* p) {
            node* n = reinterpret_cast<node*>(p);
            if (n == _head) {
                return;
            }
            else {
                n->prev->next = n->next;
                if (n->next) {
                    n->next->prev = n->prev;
                }
                else { //is tail
                    _tail = n->prev;
                }
                n->next = _head;
                _head->prev = n;
                n->prev = NULL;
                _head = n;
            }
        }
        
        void erase(T* p) {
            node* n = reinterpret_cast<node*>(p);
            if (n == _head) {
                _head = n->next;
                if (_head) {
                    _head->prev = NULL;
                }
                else _tail = NULL;
            }
            else {
                n->prev->next = n->next;
                if (n->next) {
                    n->next->prev = n->prev;
                }
                else { //is tail
                    _tail = n->prev;
                    if (_tail == NULL) {
                        _head = NULL;
                    }
                }
            }
            delete n;
            _size--;
        }
        
        node*   _head;
        node*   _tail;
        int     _size;
    };
}

#endif // _XPOLIST_INC_
