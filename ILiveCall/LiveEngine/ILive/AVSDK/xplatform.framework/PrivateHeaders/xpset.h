//
//  xpmap.h
//  
//
//  Created by gavin huang on 12-7-23.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#ifndef _XP_SET_H_INCLUDED__
#define _XP_SET_H_INCLUDED__

#include <xptypes.h>

namespace xpstl {
    
template <class KeyType>
class set
{   
	//! red/black tree for map
	template <class KeyTypeRB>
	class RBTree
	{
	public:

		RBTree(const KeyTypeRB& k)
			: LeftChild(0), RightChild(0), Parent(0), IsRed(true) 
        {
            first = k;
        }

		void setLeftChild(RBTree* p)
		{
			LeftChild=p;
			if (p)
				p->setParent(this);
		}

		void setRightChild(RBTree* p)
		{
			RightChild=p;
			if (p)
				p->setParent(this);
		}

		void setParent(RBTree* p)		{ Parent=p; }

		void setRed()			{ IsRed = true; }
		void setBlack()			{ IsRed = false; }

		RBTree* getLeftChild() const	{ return LeftChild; }
		RBTree* getRightChild() const	{ return RightChild; }
		RBTree* getParent() const		{ return Parent; }

		KeyTypeRB getKey() const
		{
			return first;
		}

		bool isRoot() const
		{
			return Parent==0;
		}

		bool isLeftChild() const
		{
			return (Parent != 0) && (Parent->getLeftChild()==this);
		}

		bool isRightChild() const
		{
			return (Parent!=0) && (Parent->getRightChild()==this);
		}

		bool isLeaf() const
		{
			return (LeftChild==0) && (RightChild==0);
		}

		unsigned int getLevel() const
		{
			if (isRoot())
				return 1;
			else
				return getParent()->getLevel() + 1;
		}

		bool isRed() const
		{
			return IsRed;
		}

		bool isBlack() const
		{
			return !IsRed;
		}
        
    public:    
        KeyTypeRB	first;
        
	private:
		RBTree();

		RBTree*		LeftChild;
		RBTree*		RightChild;
		RBTree*		Parent;

		bool IsRed;
	}; // RBTree

	public:

	typedef RBTree<KeyType> Node;

	//! Normal iterator
	class iterator
	{
	public:

		iterator() : Root(0), Cur(0) {}

		// Constructor(Node*)
		iterator(Node* root) : Root(root)
		{
			reset();
		}
        
 		iterator(Node* root,Node* cur)
		{
			Root = root;
            Cur  = cur;
		}

		iterator(const iterator& src) 
        {
            Root  = src.Root;
            Cur   = src.Cur;
        }

		void reset(bool atLowest=true)
		{
			if (atLowest)
				Cur = getMin(Root);
			else
				Cur = getMax(Root);
		}

		bool atEnd() const
		{
			return Cur==0;
		}

		Node* getNode()
		{
			return Cur;
		}

		iterator& operator=(const iterator& src)
		{
			Root = src.Root;
			Cur = src.Cur;
			return (*this);
		}
        
        bool operator==(const iterator& other) const 
        {
            return (  Cur == other.Cur  );
        }
        
        bool operator!=(const iterator& other) const 
        {
            bool b = ( Cur != other.Cur );
            return b;
        }
        
        iterator& operator++()  { // prefix
            inc();
            return (*this); 
        }
        
        iterator operator++(int) { // postfix
            iterator saved_this = *this;
            inc();
            return saved_this;
        }
        
        iterator& operator--() { // prefix
            if( NULL == Cur )reset(false);
            else dec();
            return (*this); 
        }
        
        iterator operator--(int) { // postfix
            iterator saved_this = *this;
            if( NULL == Cur ) reset(false);
            else dec();
            return saved_this;
        }

//		Node* operator -> ()
//		{
//			return getNode();
//		}

		KeyType& operator* ()
		{
			return Cur->first;
		}

	private:

		Node* getMin(Node* n)
		{
			while(n && n->getLeftChild())
				n = n->getLeftChild();
			return n;
		}

		Node* getMax(Node* n)
		{
			while(n && n->getRightChild())
				n = n->getRightChild();
			return n;
		}

		void inc()
		{
			// Already at end?
			if (Cur==0)
				return;

			if (Cur->getRightChild())
			{
				// If current node has a right child, the next higher node is the
				// node with lowest key beneath the right child.
				Cur = getMin(Cur->getRightChild());
			}
			else if (Cur->isLeftChild())
			{
				// No right child? Well if current node is a left child then
				// the next higher node is the parent
				Cur = Cur->getParent();
			}
			else
			{
				// Current node neither is left child nor has a right child.
				// Ie it is either right child or root
				// The next higher node is the parent of the first non-right
				// child (ie either a left child or the root) up in the
				// hierarchy. Root's parent is 0.
				while(Cur->isRightChild())
					Cur = Cur->getParent();
				Cur = Cur->getParent();
			}
		}

		void dec()
		{
			// Already at end?
			if (Cur==0)
				return;

			if (Cur->getLeftChild())
			{
				// If current node has a left child, the next lower node is the
				// node with highest key beneath the left child.
				Cur = getMax(Cur->getLeftChild());
			}
			else if (Cur->isRightChild())
			{
				// No left child? Well if current node is a right child then
				// the next lower node is the parent
				Cur = Cur->getParent();
			}
			else
			{
				// Current node neither is right child nor has a left child.
				// Ie it is either left child or root
				// The next higher node is the parent of the first non-left
				// child (ie either a right child or the root) up in the
				// hierarchy. Root's parent is 0.

				while(Cur->isLeftChild())
					Cur = Cur->getParent();
				Cur = Cur->getParent();
			}
		}

		Node* Root;
		Node* Cur;
	}; // iterator

    typedef iterator const_iterator;

	//! Parent First iterator.
	/** Traverses the tree from top to bottom. Typical usage is
	when storing the tree structure, because when reading it
	later (and inserting elements) the tree structure will
	be the same. */
	class ParentFirstiterator
	{
	public:


	ParentFirstiterator() : Root(0), Cur(0)
	{
	}

	explicit ParentFirstiterator(Node* root) : Root(root), Cur(0)
	{
		reset();
	}

	void reset()
	{
		Cur = Root;
	}

	bool atEnd() const
	{
		//_IRR_IMPLEMENT_MANAGED_MARSHALLING_BUGFIX;
		return Cur==0;
	}

	Node* getNode()
	{
		return Cur;
	}


	ParentFirstiterator& operator=(const ParentFirstiterator& src)
	{
		Root = src.Root;
		Cur = src.Cur;
		return (*this);
	}


	void operator++(int)
	{
		inc();
	}


	Node* operator -> ()
	{
		return getNode();
	}

	Node& operator* ()
	{
		return *getNode();
	}

	private:

	void inc()
	{
		// Already at end?
		if (Cur==0)
			return;

		// First we try down to the left
		if (Cur->getLeftChild())
		{
			Cur = Cur->getLeftChild();
		}
		else if (Cur->getRightChild())
		{
			// No left child? The we go down to the right.
			Cur = Cur->getRightChild();
		}
		else
		{
			// No children? Move up in the hierarcy until
			// we either reach 0 (and are finished) or
			// find a right uncle.
			while (Cur!=0)
			{
				// But if parent is left child and has a right "uncle" the parent
				// has already been processed but the uncle hasn't. Move to
				// the uncle.
				if (Cur->isLeftChild() && Cur->getParent()->getRightChild())
				{
					Cur = Cur->getParent()->getRightChild();
					return;
				}
				Cur = Cur->getParent();
			}
		}
	}

	Node* Root;
	Node* Cur;

	}; // ParentFirstiterator


	//! Parent Last iterator
	/** Traverse the tree from bottom to top.
	Typical usage is when deleting all elements in the tree
	because you must delete the children before you delete
	their parent. */
	class ParentLastiterator
	{
	public:

		ParentLastiterator() : Root(0), Cur(0) {}

		explicit ParentLastiterator(Node* root) : Root(root), Cur(0)
		{
			reset();
		}

		void reset()
		{
			Cur = getMin(Root);
		}

		bool atEnd() const
		{
			return Cur==0;
		}

		Node* getNode()
		{
			return Cur;
		}

		ParentLastiterator& operator=(const ParentLastiterator& src)
		{
			Root = src.Root;
			Cur = src.Cur;
			return (*this);
		}

		void operator++(int)
		{
			inc();
		}

		Node* operator -> ()
		{
			return getNode();
		}

		Node& operator* ()
		{
			return *getNode();
		}
	private:

		Node* getMin(Node* n)
		{
			while(n!=0 && (n->getLeftChild()!=0 || n->getRightChild()!=0))
			{
				if (n->getLeftChild())
					n = n->getLeftChild();
				else
					n = n->getRightChild();
			}
			return n;
		}

		void inc()
		{
			// Already at end?
			if (Cur==0)
				return;

			// Note: Starting point is the node as far down to the left as possible.

			// If current node has an uncle to the right, go to the
			// node as far down to the left from the uncle as possible
			// else just go up a level to the parent.
			if (Cur->isLeftChild() && Cur->getParent()->getRightChild())
			{
				Cur = getMin(Cur->getParent()->getRightChild());
			}
			else
				Cur = Cur->getParent();
		}

		Node* Root;
		Node* Cur;
	}; // ParentLastiterator

public:
    
    // Constructor.
    set();
    ~set();
    set( const set& other )
    {
        Root = 0;
        Size = 0;
        *this = other;
    }
    set& operator = (const set& src)
    {
		if ( src.Root == Root )
		{
			return *this;
		}
        clear();
        
        iterator it = src.begin();
        
        while (it != src.end() ) 
        {
            insert(*it);
            it++;
        }
        
        return *this;
    }
    
    
    //del
    bool erase(const KeyType& k);
    bool erase(iterator it);
    void clear();
    
    //len
    bool empty() const;
    uint32 size() const;
    
    //get
    iterator begin() const;
    iterator end() const;
    iterator find(const KeyType& keyToFind) const;
    iterator upper_bound(const KeyType& keyToFind);
    iterator lower_bound(const KeyType& keyToFind);
    
    //insert
    bool insert(const KeyType& keyNew);
    template<class _InputIterator>
    bool insert(_InputIterator __first, _InputIterator __last)
    {
        _InputIterator it = __first;
        
        for(; it != __last; it++ )
        {
            if( !insert(*it) )
            {
                return false;
            }
        }
        
        return true;
    }

    
private:
    
	Node* delink(const KeyType& k);
    bool isEmpty() const;
	Node* findnode(const KeyType& keyToFind) const;
	Node* getRoot() const;

	//! Returns an iterator
	iterator getiterator()
	{
		iterator it(getRoot());
		return it;
	}
	//! Returns a ParentFirstiterator.
	//! Traverses the tree from top to bottom. Typical usage is
	//! when storing the tree structure, because when reading it
	//! later (and inserting elements) the tree structure will
	//! be the same.
	ParentFirstiterator getParentFirstiterator()
	{
		ParentFirstiterator it(getRoot());
		return it;
	}
	//! Returns a ParentLastiterator to traverse the tree from
	//! bottom to top.
	//! Typical usage is when deleting all elements in the tree
	//! because you must delete the children before you delete
	//! their parent.
	ParentLastiterator getParentLastiterator()
	{
		ParentLastiterator it(getRoot());
		return it;
	}

	//! Set node as new root.
	/** The node will be set to black, otherwise core dumps may arise
	(patch provided by rogerborg).
	\param newRoot Node which will be the new root
	*/
	void setRoot(Node* newRoot)
	{
		Root = newRoot;
		if (Root != 0)
		{
			Root->setParent(0);
			Root->setBlack();
		}
	}

	//! Insert a node into the tree without using any fancy balancing logic.
	/** \return false if that key already exist in the tree. */
	bool insert(Node* newNode)
	{
		bool result=true; // Assume success

		if (Root==0)
		{
			setRoot(newNode);
			Size = 1;
		}
		else
		{
			Node* pNode = Root;
			KeyType keyNew = newNode->getKey();
			while (pNode)
			{
				KeyType key(pNode->getKey());
                
                if (keyNew < key)
				{
					if (pNode->getLeftChild() == 0)
					{
						pNode->setLeftChild(newNode);
						pNode = 0;
					}
					else
						pNode = pNode->getLeftChild();
				}
				else if( key < keyNew )
				{
					if (pNode->getRightChild()==0)
					{
						pNode->setRightChild(newNode);
						pNode = 0;
					}
					else
					{
						pNode = pNode->getRightChild();
					}
				}
                else
                {
                    result = false;
					pNode = 0;
                }
			}

			if (result)
				++Size;
		}

		return result;
	}

	//! Rotate left.
	//! Pull up node's right child and let it knock node down to the left
	void rotateLeft(Node* p)
	{
		Node* right = p->getRightChild();

		p->setRightChild(right->getLeftChild());

		if (p->isLeftChild())
			p->getParent()->setLeftChild(right);
		else if (p->isRightChild())
			p->getParent()->setRightChild(right);
		else
			setRoot(right);

		right->setLeftChild(p);
	}

	//! Rotate right.
	//! Pull up node's left child and let it knock node down to the right
	void rotateRight(Node* p)
	{
		Node* left = p->getLeftChild();

		p->setLeftChild(left->getRightChild());

		if (p->isLeftChild())
			p->getParent()->setLeftChild(left);
		else if (p->isRightChild())
			p->getParent()->setRightChild(left);
		else
			setRoot(left);

		left->setRightChild(p);
	}

	//------------------------------
	// Private Members
	//------------------------------
	Node* Root; // The top node. 0 if empty.
	uint32 Size; // Number of nodes in the tree
};

    
	// Constructor.
template<typename _T1>
inline
set<_T1>::set() : Root(0), Size(0) {};
   
template<typename _T1>
inline
set<_T1>::~set()
{
    clear();
}
    
template<typename _T1>
bool 
set<_T1>::insert(const _T1& keyNew)
{
    // First insert node the "usual" way (no fancy balance logic yet)
    Node* newNode = new Node(keyNew);
    if (!insert(newNode))
    {
        delete newNode;
        return false;
    }
    
    // Then attend a balancing party
    while (!newNode->isRoot() && (newNode->getParent()->isRed()))
    {
        if (newNode->getParent()->isLeftChild())
        {
            // If newNode is a left child, get its right 'uncle'
            Node* newNodesUncle = newNode->getParent()->getParent()->getRightChild();
            if ( newNodesUncle!=0 && newNodesUncle->isRed())
            {
                // case 1 - change the colours
                newNode->getParent()->setBlack();
                newNodesUncle->setBlack();
                newNode->getParent()->getParent()->setRed();
                // Move newNode up the tree
                newNode = newNode->getParent()->getParent();
            }
            else
            {
                // newNodesUncle is a black node
                if ( newNode->isRightChild())
                {
                    // and newNode is to the right
                    // case 2 - move newNode up and rotate
                    newNode = newNode->getParent();
                    rotateLeft(newNode);
                }
                // case 3
                newNode->getParent()->setBlack();
                newNode->getParent()->getParent()->setRed();
                rotateRight(newNode->getParent()->getParent());
            }
        }
        else
        {
            // If newNode is a right child, get its left 'uncle'
            Node* newNodesUncle = newNode->getParent()->getParent()->getLeftChild();
            if ( newNodesUncle!=0 && newNodesUncle->isRed())
            {
                // case 1 - change the colours
                newNode->getParent()->setBlack();
                newNodesUncle->setBlack();
                newNode->getParent()->getParent()->setRed();
                // Move newNode up the tree
                newNode = newNode->getParent()->getParent();
            }
            else
            {
                // newNodesUncle is a black node
                if (newNode->isLeftChild())
                {
                    // and newNode is to the left
                    // case 2 - move newNode up and rotate
                    newNode = newNode->getParent();
                    rotateRight(newNode);
                }
                // case 3
                newNode->getParent()->setBlack();
                newNode->getParent()->getParent()->setRed();
                rotateLeft(newNode->getParent()->getParent());
            }
            
        }
    }
    // Color the root black
    Root->setBlack();
    return true;
}
    

    
//! Removes a node from the tree and returns it.
/** The returned node must be deleted by the user
 \param k the key to remove
 \return A pointer to the node, or 0 if not found */
template<typename KeyType>
typename set<KeyType>::Node* 
set<KeyType>::    
delink(const KeyType& k)
{
    Node* p = findnode(k);
    if (p == 0)
        return 0;
    
    // Rotate p down to the left until it has no right child, will get there
    // sooner or later.
    while(p->getRightChild())
    {
        // "Pull up my right child and let it knock me down to the left"
        rotateLeft(p);
    }
    // p now has no right child but might have a left child
    Node* left = p->getLeftChild();
    
    // Let p's parent point to p's child instead of point to p
    if (p->isLeftChild())
        p->getParent()->setLeftChild(left);
    
    else if (p->isRightChild())
        p->getParent()->setRightChild(left);
    
    else
    {
        // p has no parent => p is the root.
        // Let the left child be the new root.
        setRoot(left);
    }
    
    // p is now gone from the tree in the sense that
    // no one is pointing at it, so return it.
    
    --Size;
    return p;
}
    
//! Removes a node from the tree and deletes it.
/** \return True if the node was found and deleted */
template<typename KeyType>
bool
set<KeyType>::erase(const KeyType& k)
{
    Node* p = findnode(k);
    if (p == 0)
    {
        //_IRR_IMPLEMENT_MANAGED_MARSHALLING_BUGFIX;
        return false;
    }
    
    // Rotate p down to the left until it has no right child, will get there
    // sooner or later.
    while(p->getRightChild())
    {
        // "Pull up my right child and let it knock me down to the left"
        rotateLeft(p);
    }
    // p now has no right child but might have a left child
    Node* left = p->getLeftChild();
    
    // Let p's parent point to p's child instead of point to p
    if (p->isLeftChild())
        p->getParent()->setLeftChild(left);
    
    else if (p->isRightChild())
        p->getParent()->setRightChild(left);
    
    else
    {
        // p has no parent => p is the root.
        // Let the left child be the new root.
        setRoot(left);
    }
    
    // p is now gone from the tree in the sense that
    // no one is pointing at it. Let's get rid of it.
    delete p;
    
    --Size;
    return true;
}
    
//! Clear the entire tree
template<typename KeyType>
void
set<KeyType>::clear()
{
    ParentLastiterator i(getParentLastiterator());
    
    while(!i.atEnd())
    {
        Node* p = i.getNode();
        i++; // Increment it before it is deleted
        // else iterator will get quite confused.
        delete p;
    }
    Root = 0;
    Size= 0;
}
    
//! Is the tree empty?
//! \return Returns true if empty, false if not
template<typename KeyType>
bool
set<KeyType>::empty() const
{
    return Root == 0;
}
    
//! \deprecated Use empty() instead.
template<typename KeyType>
bool
set<KeyType>::isEmpty() const
{
    return empty();
}
    
	//! Search for a node with the specified key.
	//! \param keyToFind: The key to find
	//! \return Returns 0 if node couldn't be found.
template<typename KeyType>
typename set<KeyType>::Node*
set<KeyType>::findnode(const KeyType& keyToFind) const
{
    Node* pNode = Root;
    
    while(pNode!=0)
    {
        KeyType key(pNode->getKey());
        
        if (keyToFind < key)
            pNode = pNode->getLeftChild();
        else if( key < keyToFind )
            pNode = pNode->getRightChild();
        else return pNode;
    }
    
    return 0;
}
    
//! Gets the root element.
//! \return Returns a pointer to the root node, or
//! 0 if the tree is empty.
template<typename KeyType>
typename set<KeyType>::Node*
set<KeyType>::getRoot() const
{
    return Root;
}
    
//! Returns the number of nodes in the tree.
template<typename KeyType>
uint32
set<KeyType>::size() const
{
    return Size;
}

template<typename KeyType>
typename set<KeyType>::iterator
set<KeyType>::begin() const
{
    iterator it(getRoot());
    return it; 
}
    
template<typename KeyType>
typename set<KeyType>::iterator
set<KeyType>::end() const
{
    iterator it(Root,NULL);
    return it;
}

template<typename KeyType>
typename set<KeyType>::iterator
set<KeyType>::find(const KeyType& keyToFind) const
{
    Node* p = findnode(keyToFind);
    
    if( p == NULL ) return end();
    return iterator(getRoot(),p);
}
    
template<typename KeyType>
bool
set<KeyType>::erase(iterator it)
{
    if( it == end() ) return false;
    return erase(*it);
}
    

    
template<typename KeyType>
typename set<KeyType>::iterator
set<KeyType>::upper_bound(const KeyType& keyToFind)
{ 
    iterator it = lower_bound(keyToFind);
    
    if( it == end() )
    {
        return it;
    }
    
    if( it->first == keyToFind )
    {
        return ++it;
    }
    
    return it;
}
    
template<typename KeyType>
typename set<KeyType>::iterator
set<KeyType>::lower_bound(const KeyType& keyToFind)
{ 
    Node* pNode = Root;
    
    while(pNode!=0)
    {
        KeyType key(pNode->getKey());
        
        if (keyToFind == key)
        {
            return iterator(getRoot(),pNode);
        }
        else if (keyToFind < key)
        {
            if( pNode->getLeftChild() == 0 )
            {
                return  iterator(Root,pNode);
            }
            
            pNode = pNode->getLeftChild();
        }
        else //keyToFind > key
        {
            if( pNode->getRightChild() == 0 )
            {
                iterator it = iterator(Root,pNode);
                return ++it;
            }
            pNode = pNode->getRightChild();
        }
    }
    
    return iterator(Root,0);
}
    
}

#endif // _XP_MAP_H_INCLUDED__

