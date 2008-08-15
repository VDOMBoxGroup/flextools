package vdom.containers {

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.html.HTMLLoader;

import mx.containers.Canvas;
import mx.core.FlexSprite;
import mx.core.IRectangularBorder;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.ScrollEvent;

import vdom.managers.wc;	

use namespace mx_internal;

public class Item extends Canvas implements IItem
{	
	private var _objectId:String;
	private var _waitMode:Boolean;
	private var _highlightMarker:Canvas;
	private var _graphicsLayer:Canvas = new Canvas();;
	private var _waitLayout:UIComponent;
	private var _isStatic:Boolean = false;
	private var _editableAttributes:Array = [];
	
	public function Item(objectId:String)
	{
		super();
		
		addEventListener(ScrollEvent.SCROLL, scrollHandler);
		_objectId = objectId;
	}
	
	public function get objectId():String
	{
		
		return _objectId;
	}
	
	public function get waitMode():Boolean
	{
		return _waitMode;
	}
	
	public function set waitMode(value:Boolean):void
	{	
		if(value) {
			
			setChildIndex(_waitLayout, numChildren-1);
			
			_waitLayout.width = width;
			_waitLayout.height = height;
			_graphicsLayer.visible = false;
			_waitLayout.visible = true;
			
			removeAllChildren();
			
		}
		else
		{
			_graphicsLayer.visible = true;
			_waitLayout.visible = false;
			_waitLayout.width = 0;
			_waitLayout.height = 0;
		}
		
		_waitMode = value;
	}
	
	public function get editableAttributes():Array
	{	
		return _editableAttributes;
	}
	
	public function set editableAttributes(attributesArray:Array):void
	{
		_editableAttributes = attributesArray;
	}
	
	public function get isStatic():Boolean
	{	
		return _isStatic;
	}
	
	public function set isStatic(flag:Boolean):void
	{	
		_isStatic = flag;
	}
	
	override protected function createChildren():void
	{	
		
		super.createChildren();
		
		if(!_graphicsLayer)
			_graphicsLayer = new Canvas();
		
		var childIndex:int;
		
		if (border)
		{
			childIndex = rawChildren.getChildIndex(DisplayObject(border)) + 1;
			if (border is IRectangularBorder && IRectangularBorder(border).hasBackgroundImage)
				childIndex++;
		}
		else
		{
			childIndex = 0;
		}
		
		rawChildren.addChildAt(_graphicsLayer, childIndex);
		
		if(!_highlightMarker)
			_highlightMarker = new Canvas();
		
		_highlightMarker.visible = false;
		
		rawChildren.addChild(_highlightMarker);
		
		if(!_waitLayout)
			_waitLayout = new wc();
		
		_waitLayout.visible = false;		
		_waitLayout.width = 0;
		_waitLayout.height = 0;
		
		addChild(_waitLayout);
	}
	
	override public function removeAllChildren():void
	{	
		var offset:int = 0;
		var itemChild:DisplayObject;
		
		while (numChildren > offset) {
			itemChild = getChildAt(offset);
			
			if(itemChild == _waitLayout) {
				
				offset++
				continue;
			}
			if(itemChild is HTMLLoader)
			{
				HTMLLoader(itemChild).loadString("");
			}
			removeChild(itemChild);
		}
		
		var count:uint = graphicsLayer.rawChildren.numChildren;
		
		while (count > 0) {
			graphicsLayer.rawChildren.removeChildAt(0);
			count--;
		}		
	}
	
	public function get graphicsLayer():Canvas
	{	
		return _graphicsLayer;
	}
	
	public function get highlighted():Boolean
	{
		return _graphicsLayer.visible;
	}
	
	public function drawHighlight(color:String):void
	{	
		if(color && color == 'none') {
			
			_highlightMarker.visible = false;
			return;
		}
			
		var graph:Graphics = _highlightMarker.graphics;
		
		graph.clear()
		graph.lineStyle(2, Number(color));
		graph.drawRect(0, 0, width, height);
		
		bringOnTop();
		
		_highlightMarker.visible = true;
	}
	
	override mx_internal function createContentPane():void
	{
		if (contentPane)
			return;

		creatingContentPane = true;
		
		// Reparent the children.  Get the number before we create contentPane
		// because that changes logic of how many children we have
		var n:int = numChildren;
		
		var newPane:Sprite = new FlexSprite();
		newPane.name = "contentPane";
		newPane.tabChildren = true;

		// Place content pane above border and background image but below
		// all other chrome.
		var childIndex:int;
		
		if (border)
		{
			childIndex = rawChildren.getChildIndex(DisplayObject(border)) + 1;
			if (border is IRectangularBorder && IRectangularBorder(border).hasBackgroundImage)
				childIndex++;
		}
		else
		{
			childIndex = 0;
		}
		
		if(graphicsLayer && graphicsLayer.parent == this)
			childIndex = rawChildren.getChildIndex(DisplayObject(graphicsLayer)) + 1;
		
		rawChildren.addChildAt(newPane, childIndex);
		
		
		
		var allChildren:Array = getChildren();
		
		for each(var ch:* in allChildren)
		{
			// use super because contentPane now exists and messes up getChildAt();
			newPane.addChild(DisplayObject(ch));
			ch.parentChanged(newPane);
			_numChildren--; // required
		}

		contentPane = newPane;

		creatingContentPane = false

		// UIComponent sets $visible to false. If we don't make it true here,
		// nothing shows up. Making this true should be harmless, as the
		// container itself should be false, and so should all its children.
		contentPane.visible = true;
	}
	
	private function bringOnTop():void
	{	
		var highlightMarkerIndex:int = rawChildren.getChildIndex(_highlightMarker);
		var topIndex:int = rawChildren.numChildren-1;
		
		if(highlightMarkerIndex != topIndex)
			rawChildren.setChildIndex(_highlightMarker, topIndex);
	}
	private function scrollHandler(event:ScrollEvent):void
	{	
		dispatchEvent(new Event("vdomScroll"));
	}
}
}