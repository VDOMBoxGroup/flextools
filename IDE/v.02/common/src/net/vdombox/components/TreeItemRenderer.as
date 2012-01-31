package net.vdombox.components
{
import flash.events.Event;

import net.vdombox.ide.common.interfaces.ITreeItemRenderer;

import spark.components.supportClasses.ItemRenderer;

public class TreeItemRenderer extends ItemRenderer implements ITreeItemRenderer
{
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	public function TreeItemRenderer()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Implementation of ITreeItemRenderer: properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  level
	//----------------------------------

	protected var _level:int = 0;
	
	[Bindable("levelChange")]
	public function get level():int
	{
		return _level;
	}
	
	public function set level(value:int):void
	{
		if (_level == value)
			return;
		
		_level = value;
		dispatchEvent(new Event("levelChange"));
	}
	
	//----------------------------------
	//  parents
	//----------------------------------

	protected var _parents:Vector.<Object>;
	
	[Bindable("parentsChange")]
	public function get parents():Vector.<Object>
	{
		return _parents;
	}
	
	public function set parents(value:Vector.<Object>):void
	{
		// do not check on equality
		
		_parents = value;
		dispatchEvent(new Event("parentsChange"));
	}
	
	//----------------------------------
	//  isBranch
	//----------------------------------

	protected var _isBranch:Boolean = false;
	
	[Bindable("isBranchChange")]
	public function get isBranch():Boolean
	{
		return _isBranch;
	}
	
	public function set isBranch(value:Boolean):void
	{
		if (_isBranch == value)
			return;
		
		_isBranch = value;
		dispatchEvent(new Event("isBranchChange"));
	}
	
	//----------------------------------
	//  isLeaf
	//----------------------------------

	protected var _isLeaf:Boolean = true;
	
	[Bindable("isLeafChange")]
	public function get isLeaf():Boolean
	{
		return _isLeaf;
	}
	
	public function set isLeaf(value:Boolean):void
	{
		if (_isLeaf == value)
			return;
		
		_isLeaf = value;
		dispatchEvent(new Event("isLeafChange"));
	}
	
	//----------------------------------
	//  hasChildren
	//----------------------------------

	protected var _hasChildren:Boolean = false;
	
	[Bindable("hasChildrenChange")]
	public function get hasChildren():Boolean
	{
		return _hasChildren;
	}
	
	public function set hasChildren(value:Boolean):void
	{
		if (_hasChildren == value)
			return;
		
		_hasChildren = value;
		dispatchEvent(new Event("hasChildrenChange"));
	}
	
	//----------------------------------
	//  isOpen
	//----------------------------------
	
	protected var _isOpen:Boolean = false;
	
	[Bindable("isOpenChange")]
	public function get isOpen():Boolean
	{
		return _isOpen;
	}
	
	public function set isOpen(value:Boolean):void
	{
		if (_isOpen == value)
			return;
		
		_isOpen = value;
		dispatchEvent(new Event("isOpenChange"));
	}
	
	//----------------------------------
	//  icon
	//----------------------------------
	
	protected var _icon:Class;
	
	[Bindable("iconChange")]
	public function get icon():Class
	{
		return _icon;
	}
	
	public function set icon(value:Class):void
	{
		if (_icon == value)
			return;
		
		_icon = value;
		dispatchEvent(new Event("iconChange"));
	}
	
	//----------------------------------
	//  indentation
	//----------------------------------
	
	[Bindable("levelChange")]
	public function get indentation():Number
	{
		if (!owner)
			return 0;
		
		var value:Number = Tree(owner).getStyle("indentation");
		if (isNaN(value))
			value = 0;
		
		return _level * value;
	}
	
	//----------------------------------
	//  disclosureIconVisible
	//----------------------------------
	
	[Bindable("hasBranchChange")]
	[Bindable("hasChildrenChange")]
	public function get disclosureIconVisible():Boolean
	{
		return isBranch && hasChildren;
	}
	
	//----------------------------------
	//  textColor
	//----------------------------------
	
	private var _textColor:uint = 0;
	
	[Bindable("textColorChange")]
	public function get textColor():uint
	{
		return _textColor;
	}
	
	public function set textColor(value:uint):void
	{
		if (_textColor == value)
			return;
		
		_textColor = value;
		dispatchEvent(new Event("textColorChange"));
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overriden methods
	//
	//--------------------------------------------------------------------------
	
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		textColor = getTextColor();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	public function toggle():void
	{
		Tree(owner).expandItem(data, !_isOpen);
	}
	
	public function getTextColor():uint
	{
		if (!Tree(owner).useTextColors)
			return getStyle("color");
		
		if (!enabled)
			return getStyle("disabledColor");
		else if (hovered)
			return getStyle("textRollOverColor");
		else if (selected)
			return getStyle("textSelectedColor");
		else
			return getStyle("color");
	}
	
}
}