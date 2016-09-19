//
//  xpmap.h
//  xplatform
//
//  Created by gavin huang on 12-7-23.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#ifndef _XP_MAP_H_INCLUDED__
#define _XP_MAP_H_INCLUDED__

#include <xptypes.h>

namespace xpstl {
    
/// pair holds two objects of arbitrary type.
template<class _T1, class _T2>
struct pair
{
    typedef _T1 first_type;    ///<  @c first_type is the first bound type
    typedef _T2 second_type;   ///<  @c second_type is the second bound type
    
    _T1 first;                 ///< @c first is a copy of the first object
    _T2 second;                ///< @c second is a copy of the second object
    
    // _GLIBCXX_RESOLVE_LIB_DEFECTS
    // 265.  std::pair::pair() effects overly restrictive
    /** The default constructor creates @c first and @c second using their
     *  respective default constructors.  */
    pair()
    : first(), second() { }
    
    /** Two objects may be passed to a @c pair constructor to be copied.  */
    pair(const _T1& __a, const _T2& __b)
    : first(__a), second(__b) { }
    
    /** There is also a templated copy ctor for the @c pair class itself.  */
    template<class _U1, class _U2>
    pair(const pair<_U1, _U2>& __p)
    : first(__p.first), second(__p.second) { }
};
   
template<class _T1, class _T2>
inline pair<_T1, _T2>
make_pair(_T1 __x, _T2 __y)
{ return pair<_T1, _T2>(__x, __y); }


#define _IRR_DEBUG_BREAK_IF( _CONDITION_ ) //if (_CONDITION_) {_asm int 3}
//! map template for associative arrays using a red-black tree
template <class KeyType, class ValueType>
class map
{   
	//! red/black tree for map
	template <class KeyTypeRB, class ValueTypeRB>
	class RBTree
	{
	public:

		RBTree(const KeyTypeRB& k, const ValueTypeRB& v)
			: LeftChild(0), RightChild(0), Parent(0), IsRed(true) 
        {
            first = k;
            second= v;
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

		void setValue(const ValueTypeRB& v)	{ second = v; }

		void setRed()			{ IsRed = true; }
		void setBlack()			{ IsRed = false; }

		RBTree* getLeftChild() const	{ return LeftChild; }
		RBTree* getRightChild() const	{ return RightChild; }
		RBTree* getParent() const		{ return Parent; }

		ValueTypeRB getValue() const
		{
			return second;
		}

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
        ValueTypeRB	second;
        
	private:
		RBTree();

		RBTree*		LeftChild;
		RBTree*		RightChild;
		RBTree*		Parent;

		bool IsRed;
	}; // RBTree

	public:

	typedef RBTree<KeyType,ValueType> Node;

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
            if( NULL == Cur ) reset(false);
            else dec();
            return (*this); 
        }
        
        iterator operator--(int) { // postfix
            iterator saved_this = *this;
            if( NULL == Cur ) reset(false);
            else dec();
            return saved_this;
        }

		Node* operator -> ()
		{
			return getNode();
		}

		Node& operator* ()
		{
			_IRR_DEBUG_BREAK_IF(atEnd()) // access violation

			return *Cur;
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
		_IRR_DEBUG_BREAK_IF(atEnd()) // access violation

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
			_IRR_DEBUG_BREAK_IF(atEnd()) // access violation

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


	// AccessClass is a temporary class used with the [] operator.
	// It makes it possible to have different behavior in situations like:
	// myTree["Foo"] = 32;
	// If "Foo" already exists update its value else insert a new element.
	// int i = myTree["Foo"]
	// If "Foo" exists return its value.
	class AccessClass
	{
		// Let map be the only one who can instantiate this class.
		friend class map<KeyType, ValueType>;

	public:

		// Assignment operator. Handles the myTree["Foo"] = 32; situation
		void operator=(const ValueType& value)
		{
			// Just use the Set method, it handles already exist/not exist situation
			Tree.set(Key,value);
		}

		// ValueType operator
		operator ValueType()
		{
			Node* node = Tree.findnode(Key);

			// Not found
			_IRR_DEBUG_BREAK_IF(node==0) // access violation

			//_IRR_IMPLEMENT_MANAGED_MARSHALLING_BUGFIX;
			return node->getValue();
		}

	private:

		AccessClass(map& tree, const KeyType& key) : Tree(tree), Key(key) {}

		AccessClass();

		map& Tree;
		const KeyType& Key;
	}; // AccessClass


public:   
    
    typedef pair<const KeyType, ValueType> value_type;
    
    // Constructor.
    map();
    ~map();
    map( const map& other )
    {
        Root = 0;
        Size = 0;
        *this = other;
    }
    map& operator = (const map& src)
    {
        clear();
        
        iterator it = src.begin();
        
        while (it != src.end() ) 
        {
            insert(it->first, it->second);
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
    iterator find(const KeyType& keyToFind)const;
    ValueType& operator[](const KeyType& k);
    iterator upper_bound(const KeyType& keyToFind);
    iterator lower_bound(const KeyType& keyToFind);
    
    //insert
    bool insert(const KeyType& keyNew, const ValueType& v);
    void set(const KeyType& k, const ValueType& v);
    pair<iterator, bool>
    insert(const value_type& kv)
    {
        bool b = insert(kv.first,kv.second);
        return pair<iterator, bool>(find(kv.first), b);
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
template<typename _T1, typename _T2>
inline
map<_T1,_T2>::map() : Root(0), Size(0) {};
   
template<typename _T1, typename _T2>
inline
map<_T1,_T2>::~map()
{
    clear();
}
    
template<typename _T1, typename _T2>
bool 
map<_T1,_T2>::insert(const _T1& keyNew, const _T2& v)
{
    // First insert node the "usual" way (no fancy balance logic yet)
    Node* newNode = new Node(keyNew,v);
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
    
//! Replaces the value if the key already exists, otherwise inserts a new element.
/** \param k The index for this value
 \param v The new value of */
template<typename KeyType, typename ValueType>
void 
map<KeyType,ValueType>::set(const KeyType& k, const ValueType& v)
{
    Node* p = findnode(k);
    if (p)
        p->setValue(v);
    else
        insert(k,v);
}
    
	//! Removes a node from the tree and returns it.
	/** The returned node must be deleted by the user
     \param k the key to remove
     \return A pointer to the node, or 0 if not found */
template<typename KeyType, typename ValueType>
typename map<KeyType,ValueType>::Node* 
map<KeyType,ValueType>::    
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
template<typename KeyType, typename ValueType>
bool
map<KeyType,ValueType>::erase(const KeyType& k)
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
template<typename KeyType, typename ValueType>
void
map<KeyType,ValueType>::clear()
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
template<typename KeyType, typename ValueType>
bool
map<KeyType,ValueType>::empty() const
{
    return Root == 0;
}
    
//! \deprecated Use empty() instead.
template<typename KeyType, typename ValueType>
bool
map<KeyType,ValueType>::isEmpty() const
{
    return empty();
}
    
	//! Search for a node with the specified key.
	//! \param keyToFind: The key to find
	//! \return Returns 0 if node couldn't be found.
template<typename KeyType, typename ValueType>
typename map<KeyType,ValueType>::Node*
map<KeyType,ValueType>::findnode(const KeyType& keyToFind) const
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
template<typename KeyType, typename ValueType>
typename map<KeyType,ValueType>::Node*
map<KeyType,ValueType>::getRoot() const
{
    return Root;
}
    
//! Returns the number of nodes in the tree.
template<typename KeyType, typename ValueType>
uint32
map<KeyType,ValueType>::size() const
{
    return Size;
}

template<typename KeyType, typename ValueType>
typename map<KeyType,ValueType>::iterator
map<KeyType,ValueType>::begin() const
{
    iterator it(getRoot());
    return it; 
}
    
template<typename KeyType, typename ValueType>
typename map<KeyType,ValueType>::iterator
map<KeyType,ValueType>::end() const
{
    iterator it(Root,NULL);
    return it;
}

template<typename KeyType, typename ValueType>
typename map<KeyType,ValueType>::iterator
map<KeyType,ValueType>::find(const KeyType& keyToFind)const
{
    Node* p = findnode(keyToFind);
    
    if( p == NULL ) return end();
    return iterator(getRoot(),p);
}
    
template<typename KeyType, typename ValueType>
bool
map<KeyType,ValueType>::erase(iterator it)
{
    return erase(it->first);
}
    

    
template<typename KeyType, typename ValueType>
typename map<KeyType,ValueType>::iterator
map<KeyType,ValueType>::upper_bound(const KeyType& keyToFind)
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
    
template<typename KeyType, typename ValueType>
typename map<KeyType,ValueType>::iterator
map<KeyType,ValueType>::lower_bound(const KeyType& keyToFind)
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

//! operator [] for access to elements
/** for example myMap["key"] */
template<typename KeyType, typename ValueType>
ValueType&
map<KeyType,ValueType>::operator[](const KeyType& k)             
{
    Node* pNode = findnode(k);
    
    if( NULL == pNode )
    {
        ValueType v;
        insert(k,v);
        pNode = findnode(k);
    }
    
    return pNode->second;
}

    
}

#endif // _XP_MAP_H_INCLUDED__

