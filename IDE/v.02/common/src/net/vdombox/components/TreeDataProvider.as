/* Copyright (c) 2010 Maxim Kachurovskiy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE. */

package net.vdombox.components
{
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;

import mx.collections.ICollectionView;
import mx.collections.IList;
import mx.collections.IViewCursor;
import mx.collections.Sort;
import mx.controls.Tree;
import mx.controls.treeClasses.ITreeDataDescriptor2;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.PropertyChangeEvent;
import mx.events.PropertyChangeEventKind;

public class TreeDataProvider extends EventDispatcher implements IList, ICollectionView
{
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	public function TreeDataProvider(dataProvider:IList)
	{
		_dataProvider = dataProvider;
		
		resetDataStructures();
	}

	//--------------------------------------------------------------------------
	//
	//  Implementation of IList and ICollectionView: properties
	//
	//--------------------------------------------------------------------------
	
	private var _length:int = 0;
	
	[Bindable("collectionChange")]
	public function get length():int
	{
		return _length;
	}

	//--------------------------------------------------------------------------
	//
	//  Implementation of IList: methods
	//
	//--------------------------------------------------------------------------
	
	public function addItem(item:Object):void
	{
		throw error;
	}
	
	public function addItemAt(item:Object, index:int):void
	{
		throw error;
	}
	
	public function getItemAt(index:int, prefetch:int=0):Object
	{
		if (index < 0 || index >= _length)
			throw new Error("index " + index + " is out of bounds");

		if (index < cache.length)
			return cache[index];
		
		var branches:Vector.<IList> = new Vector.<IList>();
		var branchIndexes:Vector.<int> = new Vector.<int>();
		var branch:IList = _dataProvider;
		var branchLength:int = branch.length;
		var branchIndex:int = 0;
		var currentItem:Object = branch.getItemAt(branchIndex);
		var cacheIndex:int = 0;
		while (currentItem)
		{
			cache[cacheIndex++] = currentItem;
			if (index == 0)
				return currentItem;
			
			if (parentObjectsToOpenedBranches[currentItem])
			{
				branches.push(branch);
				branchIndexes.push(branchIndex);
				branch = parentObjectsToOpenedBranches[currentItem];
				branchIndex = 0;
				branchLength = branch.length;
				index--;
				currentItem = branch.getItemAt(branchIndex);
			}
			else if (branchIndex < branchLength - 1)
			{
				branchIndex++;
				index--;
				currentItem = branch.getItemAt(branchIndex);
			}
			else if (branches.length > 0)
			{
				do
				{
					branch = branches.pop();
					branchIndex = branchIndexes.pop() + 1;
					branchLength = branch.length;
				} while (branches.length > 0 && branchIndex >= branchLength)
				index--;
				currentItem = branch.getItemAt(branchIndex);
			}
			else
			{
				throw new Error("index " + index + " is out of bounds");
			}
		}
		throw new Error("index " + index + " is out of bounds");
		return null;
	}
	
	public function getItemIndex(item:Object):int
	{
		if (!item)
			return -1;
		
		var cacheIndex:int = cache.indexOf(item);
		if (cacheIndex >= 0)
			return cacheIndex;
		
		var index:int = 0;
		var branches:Vector.<IList> = new Vector.<IList>();
		var branchIndexes:Vector.<int> = new Vector.<int>();
		var branch:IList = _dataProvider;
		var branchLength:int = branch.length;
		var branchIndex:int = 0;
		var currentItem:Object = branch.getItemAt(branchIndex);
		cacheIndex = 0;
		while (currentItem)
		{
			cache[cacheIndex++] = currentItem;
			if (currentItem == item)
				return index;
			
			if (parentObjectsToOpenedBranches[currentItem])
			{
				branches.push(branch);
				branchIndexes.push(branchIndex);
				branch = parentObjectsToOpenedBranches[currentItem];
				branchIndex = 0;
				branchLength = branch.length;
				index++;
				currentItem = branch.getItemAt(branchIndex);
			}
			else if (branchIndex < branchLength - 1)
			{
				branchIndex++;
				index++;
				currentItem = branch.getItemAt(branchIndex);
			}
			else if (branches.length > 0)
			{
				do
				{
					branch = branches.pop();
					branchIndex = branchIndexes.pop() + 1;
					branchLength = branch.length;
				} while (branches.length > 0 && branchIndex >= branchLength)
				index++;
				currentItem = branch.getItemAt(branchIndex);
			}
			else
			{
				throw new Error("index " + index + " is out of bounds");
			}
		}
		throw new Error("index " + index + " is out of bounds");
		return null;
	}
	
	public function itemUpdated(item:Object, property:Object=null, oldValue:Object=null, newValue:Object=null):void
	{
		throw error;
	}
	
	public function removeAll():void
	{
		throw error;
	}
	
	public function removeItemAt(index:int):Object
	{
		throw error;
	}
	
	public function setItemAt(item:Object, index:int):Object
	{
		throw error;
	}
	
	public function toArray():Array
	{
		var result:Array = [];
		var branches:Vector.<IList> = new Vector.<IList>();
		var branchIndexes:Vector.<int> = new Vector.<int>();
		var branch:IList = _dataProvider;
		var branchLength:int = branch.length;
		var branchIndex:int = 0;
		var currentItem:Object = branch.getItemAt(branchIndex);
		while (true)
		{
			result.push(currentItem);
			
			if (parentObjectsToOpenedBranches[currentItem])
			{
				branches.push(branch);
				branchIndexes.push(branchIndex);
				branch = parentObjectsToOpenedBranches[currentItem];
				branchIndex = 0;
				branchLength = branch.length;
				currentItem = branch.getItemAt(branchIndex);
			}
			else if (branchIndex < branchLength - 1)
			{
				branchIndex++;
				currentItem = branch.getItemAt(branchIndex);
			}
			else if (branches.length > 0)
			{
				do
				{
					branch = branches.pop();
					branchIndex = branchIndexes.pop() + 1;
					branchLength = branch.length;
				} while (branches.length > 0 && branchIndex >= branchLength)
				currentItem = branch.getItemAt(branchIndex);
			}
			else
			{
				return result;
			}
		}
		return null; // never happen
	}
	
	//--------------------------------------------------------------------------
	//
	//  Implementation of ICollectionView: methods
	//
	//--------------------------------------------------------------------------
	
	public function get filterFunction():Function
	{
		return null;
	}
	
	public function set filterFunction(value:Function):void {}
	
	public function get sort():Sort
	{
		return null;
	}

	public function set sort(value:Sort):void {}
	
	public function createCursor():IViewCursor
	{
		return null;
	}
	
	public function contains(item:Object):Boolean
	{
		return parentObjectsToOpenedBranches[item] || getItemIndex(item) >= 0;
	}
	
	public function disableAutoUpdate():void {}
	
	public function enableAutoUpdate():void {}
	
	public function refresh():Boolean
	{
		resetDataStructures();
		resetCache();
		refreshLength();
		dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false,
			false, CollectionEventKind.REFRESH));
		return true;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	private var error:Error = new Error("modifications should be done in source collection");

	private var openedBranchesToParentObjects:Dictionary;
	
	private var parentObjectsToOpenedBranches:Dictionary;
	
	/**
	 * Vector of open branches. It is always sorted by branch first element order
	 * in UI list.
	 */
	private var openedBranchesVector:Vector.<IList>;
	
	/**
	 * Should be set before operating.
	 */
	public var dataDescriptor:ITreeDataDescriptor2;
	
	/**
	 * Cache contains currently visible items in the correct order. Cache can
	 * have smaller length - it means it does not surely contains all items.
	 */
	private var cache:Vector.<Object>;
	
	/**
	 * Maps branches to levels.
	 */
	private var branchLevels:Dictionary;
	
	/**
	 * Caches levels since it's the most time-consuming operation.
	 */
	private var levelsCache:Dictionary;
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	private var _dataProvider:IList;
	
	public function get dataProvider():IList
	{
		return _dataProvider;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	private function resetDataStructures():void
	{
		openedBranchesToParentObjects = new Dictionary(true);
		parentObjectsToOpenedBranches = new Dictionary(true);
		openedBranchesVector = new Vector.<IList>();
		resetCache();
		
		if (_dataProvider)
			openBranch(_dataProvider, null);
	}
	
	private function resetCache():void
	{
		cache = new Vector.<Object>();
		branchLevels = new Dictionary();
		levelsCache = new Dictionary();
	}
	
	public function openBranch(branch:IList, parentObject:Object):void
	{
		if (parentObject && isOpen(parentObject))
			return;
		
		openedBranchesToParentObjects[branch] = parentObject;
		if (parentObject)
			parentObjectsToOpenedBranches[parentObject] = branch;
		insertBranchIntoVector(branch, parentObject);
		branch.addEventListener(CollectionEvent.COLLECTION_CHANGE,
			branch_collectionChangeHandler);
		
		_length += branch.length;
		
		// cache branch level so that getItemLevel() work faster
		var level:int = parentObject ? getItemLevel(parentObject) + 1 : 0;
		branchLevels[branch] = level;
		// fill levelsCache from branch items
		var n:int = branch.length;
		for (var i:int = 0; i < n; i++)
		{
			levelsCache[branch[i]] = level;
		}
		
		// clear untrusted area of cache
		var parentObjectIndex:int = parentObject ? getItemIndex(parentObject) : -1;
		if (parentObjectIndex >= 0 && cache.length >= parentObjectIndex)
			cache.splice(parentObjectIndex, cache.length - parentObjectIndex);
		
		var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE,
			false, false, CollectionEventKind.ADD, 
			parentObject ? parentObjectIndex + 1 : 0, -1, branch.toArray());
		dispatchEvent(event);
		
		if (parentObject)
			dispatchParentObjectUpdateEvent(parentObject, parentObjectIndex);
	}
	
	private function dispatchParentObjectUpdateEvent(parentObject:Object, parentObjectIndex:int):void
	{
		var propertyChangeEvent:PropertyChangeEvent = 
			new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE, 
				false, false, PropertyChangeEventKind.UPDATE, null,
				null, null, parentObject);
		var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE,
			false, false, CollectionEventKind.UPDATE, 
			parentObjectIndex, parentObjectIndex, [ propertyChangeEvent ]);
		dispatchEvent(event);
	}
	
	private function insertBranchIntoVector(branch:IList, parentObject:Object):void
	{
		var index:int = 0;
		var n:int = openedBranchesVector.length;
		for (var i:int = 0; i < n; i++)
		{
			var tempBranch:IList = openedBranchesVector[i];
			if (tempBranch.getItemIndex(parentObject) >= 0)
			{
				index = i + 1;
				break;
			}
		}
		openedBranchesVector.splice(index, 0, branch);
	}
	
	public function closeBranch(branch:IList, parentObject:Object):void
	{
		if (!parentObject || !isOpen(parentObject))
			return;
		
		closeAllChildBranches(branch, parentObject);
		
		branch.removeEventListener(CollectionEvent.COLLECTION_CHANGE,
			branch_collectionChangeHandler);
		delete openedBranchesToParentObjects[branch];
		if (parentObject)
			delete parentObjectsToOpenedBranches[parentObject];
		openedBranchesVector.splice(openedBranchesVector.indexOf(branch), 1);
		
		_length -= branch.length;
		
		delete branchLevels[branch];
		
		// clear levelsCache from branch items
		var n:int = branch.length;
		for (var i:int = 0; i < n; i++)
		{
			delete levelsCache[branch[i]];
		}
		
		// clear untrusted area of cache
		var parentObjectIndex:int = parentObject ? getItemIndex(parentObject) : -1;
		if (parentObjectIndex >= 0 && cache.length >= parentObjectIndex)
			cache.splice(parentObjectIndex, cache.length - parentObjectIndex);
		
		var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE,
			false, false, CollectionEventKind.REMOVE, parentObject ? parentObjectIndex + 1 : 0,
			parentObject ? parentObjectIndex + 1 : 0, branch.toArray());
		dispatchEvent(event);
		
		if (parentObject)
			dispatchParentObjectUpdateEvent(parentObject, parentObjectIndex);
	}
	
	public function closeAllChildBranches(branch:IList, parentObject:Object):void
	{
		var n:int = branch.length;
		for (var i:int = 0; i < n; i++)
		{
			var item:Object = branch.getItemAt(i);
			if (!parentObjectsToOpenedBranches[item])
				continue;
			
			if (!dataDescriptor.hasChildren(item))
				continue;
			
			var children:IList = IList(dataDescriptor.getChildren(item));
			closeBranch(children, item);
		}
	}
	
	public function isOpen(item:Object):Boolean
	{
		return Boolean(parentObjectsToOpenedBranches[item]);
	}
	
	public function getItemLevel(item:Object):int
	{
		if (levelsCache[item] !== undefined)
			return levelsCache[item];
		
		for (var p:* in branchLevels)
		{
			var branch:IList = IList(p);
			var n:int = branch.length;
			for (var i:int = 0; i < n; i++)
			{
				if (branch[i] == item)
				{
					var level:int = branchLevels[p];
					levelsCache[item] = level;
					return level;
				}
			}
		}
		throw new Error("unknown item " + item);
		return -1;
	}
	
	private function refreshLength():void
	{
		var n:int = openedBranchesVector.length;
		_length = 0;
		for (var i:int = 0; i < n; i++)
		{
			_length += openedBranchesVector[i].length;
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------

	private function branch_collectionChangeHandler(event:CollectionEvent):void
	{
		var parentObject:Object = openedBranchesToParentObjects[event.target];
		var branchStartIndex:int = parentObject ? getItemIndex(parentObject) + 1 : 0;
		var kind:String = event.kind;
		var items:Array = event.items;
		var item:Object;
		var n:int = items ? items.length : 0;
		var i:int;
		
		// clear untrusted areas of cache
		if (kind == CollectionEventKind.REFRESH || kind == CollectionEventKind.RESET)
		{
			resetCache();
		}
		else if (kind != CollectionEventKind.UPDATE)
		{
			var minLocation:int = -1;
			if (event.oldLocation >= 0)
				minLocation = event.oldLocation;
			if (event.location >= 0)
				minLocation = event.location;
			if (minLocation >= 0)
				cache.splice(minLocation, cache.length - minLocation);
			else
				resetCache();
		}
		
		// clear untrusted items in levelCache
		if (kind == CollectionEventKind.REMOVE || kind == CollectionEventKind.MOVE || 
			kind == CollectionEventKind.REPLACE)
		{
			for (i = 0; i < n; i++)
			{
				delete levelsCache[items[i]];
			}
		}
		else if (kind == CollectionEventKind.ADD)
		{
			var level:int = parentObject ? getItemLevel(parentObject) + 1 : 0;
			for (i = 0; i < n; i++)
			{
				levelsCache[items[i]] = level;
			}
		}
		else if (kind != CollectionEventKind.UPDATE)
		{
			resetCache();
		}
		
		// check if we need to close some child object branches that have been updated/removed
		if (kind == CollectionEventKind.REMOVE || kind == CollectionEventKind.REPLACE)
		{
			for (i = 0; i < n; i++)
			{
				item = items[i];
				if (parentObjectsToOpenedBranches[item])
					closeBranch(parentObjectsToOpenedBranches[item], item);
			}
		}
		else if (kind == CollectionEventKind.UPDATE)
		{
			var propertyEvent:PropertyChangeEvent;
			for (i = 0; i < n; i++)
			{
				propertyEvent = items[i];
				item = propertyEvent.source;
				if (parentObjectsToOpenedBranches[item])
					closeBranch(parentObjectsToOpenedBranches[item], item);
			}
		}
		
		if (kind == CollectionEventKind.ADD || kind == CollectionEventKind.REMOVE ||
			kind == CollectionEventKind.MOVE || kind == CollectionEventKind.REPLACE ||
			kind == CollectionEventKind.UPDATE)
		{
			if (event.location != -1)
				event.location += branchStartIndex;
			if (event.oldLocation != -1)
				event.oldLocation += branchStartIndex;
			refreshLength();
			dispatchEvent(event);
		}
		else // if (kind == CollectionEventKind.REFRESH || kind == CollectionEventKind.RESET)
		{
			refreshLength();
			dispatchEvent(event); 
		}
	}
	
}
}