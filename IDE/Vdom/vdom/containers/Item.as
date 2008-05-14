package vdom.containers {

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;

import mx.containers.Canvas;
import mx.core.FlexSprite;
import mx.core.UIComponent;

import vdom.managers.wc;	

use namespace mx.core.mx_internal;

public class Item extends Canvas implements IItem {
	
	private var _objectId:String;
	private var _waitMode:Boolean;
	private var _highlightMarker:Canvas;
	private var _graphicsLayer:Canvas;
	private var _waitLayout:UIComponent;
	private var _isStatic:Boolean;
	private var _editableAttributes:Array;
	
	
	public function Item(objectId:String) {
		
		super();
		
		_graphicsLayer = new Canvas();
		_objectId = objectId;
		editableAttributes = [];
		_isStatic = false;
	}
	
	public function get objectId():String {
		
		return _objectId;
	}
	
	public function get waitMode():Boolean {
		
		return _waitMode;
	}
	
	public function set waitMode(mode:Boolean):void {
		
		if(mode) {
			
			removeAllChildren();
			_waitLayout.width = width;
			_waitLayout.height = height;
			_waitLayout.visible = true;
			
		} else {
			
			_waitLayout.visible = false;
		}
	}
	
	public function get editableAttributes():Array {
		
		return _editableAttributes;
	}
	
	public function set editableAttributes(attributesArray:Array):void {
		
		_editableAttributes = attributesArray;
	}
	
	public function get isStatic():Boolean {
		
		return _isStatic;
	}
	
	public function set isStatic(flag:Boolean):void {
		
		_isStatic = flag;
	}
	
	override protected function createChildren():void {
		
		super.createChildren();
		
		if(!_graphicsLayer)
			_graphicsLayer = new Canvas();
		
		rawChildren.addChild(_graphicsLayer);
		
		if(!_highlightMarker)
			_highlightMarker = new Canvas();
		
		_highlightMarker.visible = false;
		
		rawChildren.addChild(_highlightMarker);
		
		if(!_waitLayout)
			_waitLayout = new wc();
		
		
		_waitLayout.visible = true;
		rawChildren.addChild(_waitLayout);
		_waitLayout.width = 0;
		_waitLayout.height = 0;
	}
	
	override public function removeAllChildren():void {
		
		super.removeAllChildren();
		
		var count:uint = graphicsLayer.rawChildren.numChildren;
		
		while (count > 0) {
			graphicsLayer.rawChildren.removeChildAt(0);
			count--;
		}
			
	}
	
	public function get graphicsLayer():Canvas {
		
		return _graphicsLayer;
	}
	
	public function drawHighlight(color:String):void {
		
		if(color && color == 'none') {
			
			_highlightMarker.visible = false;
			return;
		}
			
		var graph:Graphics = _highlightMarker.graphics;
		
		graph.clear()
		//graph.beginFill(0xFFFFFF, .0);
		graph.lineStyle(2, Number(color));
		graph.drawRect(0, 0, width, height);
		
		bringOnTop();
		
		_highlightMarker.visible = true;
	}
	
	override mx.core.mx_internal function createContentPane():void {
		
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
    
        childIndex = rawChildren.getChildIndex(DisplayObject(graphicsLayer)) + 1;
        
        rawChildren.addChildAt(newPane, childIndex);
        
        var allChildren:Array = getChildren();
        
        for each(var ch:* in allChildren)
        {
            // use super because contentPane now exists and messes up getChildAt();
            //var child:IUIComponent =
               // IUIComponent(super.getChildAt(0));
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
	
	private function bringOnTop():void {
		
		var highlightMarkerIndex:int = rawChildren.getChildIndex(_highlightMarker);
		var topIndex:int = rawChildren.numChildren-1;
		
		if(highlightMarkerIndex != topIndex) {
			rawChildren.setChildIndex(_highlightMarker, topIndex);
		}
	}
}
}