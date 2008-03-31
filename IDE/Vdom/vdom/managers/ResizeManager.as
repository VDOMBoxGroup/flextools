package vdom.managers {

import flash.display.CapsStyle;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.containers.Canvas;
import mx.controls.ToolTip;
import mx.core.Application;
import mx.core.Container;
import mx.core.EdgeMetrics;
import mx.core.IUIComponent;
import mx.core.UIComponent;
import mx.events.FlexEvent;
import mx.managers.CursorManager;
import mx.managers.ToolTipManager;

import vdom.events.TransformMarkerEvent;
import vdom.managers.resizeClasses.TransformMarker;
import vdom.events.ResizeManagerEvent;
import vdom.utils.DisplayUtil;
import vdom.components.edit.containers.workAreaClasses.Item;
import flash.display.DisplayObjectContainer;
import mx.styles.StyleManager;
			
[Event(name="RESIZE_COMPLETE", type="vdom.events.ResizeManagerEvent")]

public class ResizeManager extends EventDispatcher {
	
	private static var instance:ResizeManager;
	
	private var tip:ToolTip;
	
	private var _resizeMode:String;
	private var _moveMode:Boolean;
	
	private var dataManager:DataManager;
	
	private var _topLevelItem:Item;
	
	private var selectMarker:TransformMarker;
	
	private var itemTransform:Boolean;
	
	//private var highlightedObject:Item;
	
	private var highlightedItem:Item;
	
	private var caughtItem:Item;
	
	private var selectedItem:Item;
	
	private var filterFunction:Function;
	
	private var styleManager:StyleManager;
	private var moveCursor:Class;
	private var cursorID:int;
	
	private var beforeTransform:Object;
	
	private var markerSelected:Boolean;
	
	public function ResizeManager() {
		
		styleManager = new StyleManager();
		
		moveCursor = StyleManager.getStyleDeclaration('global').getStyle('moveCursor');
		
		dataManager = DataManager.getInstance();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public static function getInstance():ResizeManager {
		
		if (!instance)
			instance = new ResizeManager();

		return instance;
	}
	
	public function init(topLevelItem:Item):void {
		
		_topLevelItem = topLevelItem;
		
		//_workArea = topLevelItem.parent;
		
		//if(!highlightMarker)
			//highlightMarker = new Canvas();
		
		//highlightMarker.visible = false;
		_topLevelItem.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		_topLevelItem.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		_topLevelItem.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		_topLevelItem.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		//highlightMarker.addEventListener(TransformMarkerEvent.TRANSFORM_COMPLETE, resizeCompleteHandler);
		
		//highlightMarker.visible = false;
		
		
		CursorManager.removeAllCursors();
		
		if(!selectMarker)
			selectMarker = new TransformMarker();
		
		selectMarker.visible = false;
		
		//_topLevelItem.addChild(selectMarker);
		
		selectMarker.addEventListener(TransformMarkerEvent.TRANSFORM_BEGIN, transformBeginHandler);
		selectMarker.addEventListener(TransformMarkerEvent.TRANSFORM_COMPLETE, transformCompleteHandler);
		selectMarker.addEventListener(TransformMarkerEvent.TRANSFORM_MARKER_SELECTED, markerSelectedHandler);
		selectMarker.addEventListener(TransformMarkerEvent.TRANSFORM_MARKER_UNSELECTED, markerUnSelectedHandler);
		
		//itemTransform = false;
		
		
		
		filterFunction = function(item:Item):Boolean {
			
			return !item.isStatic;
		}
		
		destroyToolTip();
		createToolTip();
		
		//_topLevelItem.rawChildren.addChild(highlightMarker);
		//
	}
	
	public function selectItem( item:Item, 
								showMarker:Boolean = false, 
								moveMode:Boolean = false, 
								resizeMode:String = '0'):Item {
									
		var newSelectedItem:Item;
		
		if(item && item.parent) {
			
			if(selectMarker.parent)
				selectMarker.parent.removeChild(selectMarker)
				
			if(showMarker) {
				
				item.parent.addChild(selectMarker);
				
				selectMarker.resizeMode = resizeMode;
				selectMarker.moveMode = moveMode;
				selectMarker.item = item;
				selectMarker.visible = true;
			} else {
				
				selectMarker.item = null;
			}
			
			selectedItem = newSelectedItem = item;
			
		} else
			newSelectedItem = null;
			//selectMarker.item = null;
			
		return newSelectedItem;
	}
	
	public function highlightItem(item:Item, showMarker:String = 'none'):void {
		
		if(cursorID) {
			CursorManager.removeCursor(cursorID);
			cursorID = NaN;
		}
		
		if(item && !itemTransform) {
			
			if(highlightedItem)
				highlightedItem.highlight(false);
			
			if(cursorID) {
				CursorManager.removeCursor(cursorID);
				cursorID = NaN;
			}
			
			if(item == selectedItem) {
				
				highlightedItem = null;
				return;
			}
				
			
			switch(showMarker) {
				
				case 'move':
					
					cursorID = CursorManager.setCursor(moveCursor, 2, -10, -10);
					
				case 'select':
					
					item.highlight(true);
				break
			}
			
			highlightedItem = item;
			
		} else {
			
			if(highlightedItem)
				highlightedItem.highlight(false);
				
			highlightedItem = null;
		}
	}
	
	private function showToolTip(text:String = ''):void {
		
		if(text != '') {
				
				tip.text = text;
				tip.visible = true;
				
			} else {
				
				tip.visible = false;
			}
	}
	
	private function bringOnTop():void {
		
		var selectMarkerIndex:int = _topLevelItem.getChildIndex(selectMarker);
		//var highlightMarkerIndex:int = _topLevelItem.rawChildren.getChildIndex(highlightMarker);
		var topIndex:int = _topLevelItem.numChildren-1;
		//var one:* = _topLevelItem.numChildren;
		//var two:* = _topLevelItem.rawChildren.numChildren;
		//var three:* = _topLevelItem.rawChildren;
		//var four:* = _topLevelItem._topLevelItem.getChildAt(_topLevelItem.numChildren);
		//var five:* = _topLevelItem.getChildAt(_topLevelItem.numChildren-1);
		//var one:* = _topLevelItem.numChildren - 1;

		
		
		if(selectMarkerIndex != topIndex) {
			
			_topLevelItem.setChildIndex(selectMarker, topIndex);
		}
		
		/* if(highlightMarkerIndex != topIndex) {
			_topLevelItem.rawChildren.setChildIndex(highlightMarker, topIndex);
		} */
	}
	
	private function createToolTip():void {
		
		tip = ToolTip(ToolTipManager.createToolTip("", 0, 0, null, _topLevelItem));
		tip.setStyle("backgroundColor", 0xFFFFFF);
		tip.setStyle("fontSize", 9);
		tip.setStyle("cornerRadius", 0);
		tip.visible = false;
	}
	
	private function destroyToolTip():void {
		
		if(tip) {
			
			ToolTipManager.destroyToolTip(tip);
			tip = null;
		}
	}
	
	private function mouseDownHandler(event:MouseEvent):void {
		
		trace('ResizeManager MD');
		
		if(!highlightedItem)
			return;
		
		trace('highlighted');
		
		var newSelectedItem:Item;
		
		if(_topLevelItem != highlightedItem) {
			
			trace('not selected');
			
			var objectType:XML = dataManager.getTypeByObjectId(highlightedItem.objectID);
			
			newSelectedItem = selectItem(	highlightedItem,
											true,
											objectType.Information.Moveable,
											objectType.Information.Resizable);
						
		} else if(selectedItem == highlightedItem)
			return;
			
		else
			newSelectedItem = selectItem(highlightedItem, false);
		
		if(newSelectedItem) {
			var rme:ResizeManagerEvent = new ResizeManagerEvent(ResizeManagerEvent.ITEM_SELECTED);
			rme.item = newSelectedItem;
			dispatchEvent(rme);
		}
	}
	
	private function mouseUpHandler(event:MouseEvent):void {
		
		if(!highlightedItem)
			return;
		
		//
		
		//var selectionResult:Item;
		
		//itemStack =	DisplayUtil.getObjectsUnderMouse(this, 'vdom.components.editor.containers.workAreaClasses::Item');
		
		//selectionResult = Item(itemStack[0]);
		
		//if(!selectionResult) return;
		
		//selectionResult.setFocus();
		
		/* var newSelectedItem:Item;
		
		if(_topLevelItem.objectID != highlightedItem.objectID) {
			
			var objectType:XML = dataManager.getTypeByObjectId(highlightedItem.objectID);
			
			newSelectedItem = selectItem(	highlightedItem,
											true,
											objectType.Information.Moveable,
											objectType.Information.Resizable);
						
		} else
			newSelectedItem = selectItem(highlightedItem, false);
		
		
		if(newSelectedItem) {
			var rme:ResizeManagerEvent = new ResizeManagerEvent(ResizeManagerEvent.ITEM_SELECTED);
			rme.item = newSelectedItem;
			dispatchEvent(rme);
		} */
	}
	
	private function mouseMoveHandler(event:MouseEvent):void {
		
		if(tip) {
			
			tip.x = event.stageX + 15;
			tip.y = event.stageY + 15;
		}
		
		if(itemTransform || markerSelected)
			return;
		
		var itemUnderMouse:Item = getItemUnderMouse();
		
		if(itemUnderMouse == highlightedItem)
			return;
		
		if(itemUnderMouse && itemUnderMouse != _topLevelItem) {
			
			var objectDescription:XML = dataManager.getObject(itemUnderMouse.objectID);
			
			var tipText:String = "Name:" + objectDescription.@Name;
			
			var moveable:String = objectDescription.Type.Information.Moveable;
				
			showToolTip(tipText);
			
			if(moveable == '1')
				highlightItem(itemUnderMouse, 'move');
			else
				highlightItem(itemUnderMouse, 'select');
			
		} else {
			
			showToolTip('');
			highlightItem(itemUnderMouse, 'none');
		}
	}
	
	private function getItemUnderMouse():Item {
		
		var targetList:Array =
			DisplayUtil.getObjectsUnderMouse(_topLevelItem.parent, 'vdom.components.edit.containers.workAreaClasses::Item', filterFunction);
		
		if(targetList.length == 0)
			return null;
		
		var itemUnderMouse:Item = null;
		
		if(targetList.length == 1) {
			
			if(targetList[0] == selectedItem)
				itemUnderMouse = null;
			
			else
				itemUnderMouse = targetList[0];
			
		} else if (targetList.length > 1) {
			
			if (targetList[0].contains(targetList[1])) {
					
				if(targetList[0] == highlightedItem) {
					
					if(targetList[1] != selectedItem)
						itemUnderMouse = targetList[1];
					else
						itemUnderMouse = null;
				
				} else {
					
					if(targetList[1] != selectedItem)
						itemUnderMouse = targetList[1];
					else
						itemUnderMouse = null;
				}
			
			} else if (targetList[1].contains(targetList[0])) {
				
				itemUnderMouse = targetList[0];
				
			} else {
				
				itemUnderMouse = targetList[0];
			}
		}
		
		return itemUnderMouse;
	}
	
	private function transformBeginHandler(event:TransformMarkerEvent):void {
		
		trace('transform begin');
		itemTransform = true;
		beforeTransform = event.properties;
	}
	
	private function transformCompleteHandler(event:TransformMarkerEvent):void {
		
		trace('transform complete');

		itemTransform = false;
		
		if(
			beforeTransform.top == event.properties.top &&
			beforeTransform.left == event.properties.left &&
			beforeTransform.width == event.properties.width &&
			beforeTransform.height == event.properties.height
		)
			return;
		
		var rmEvent:ResizeManagerEvent = new ResizeManagerEvent(ResizeManagerEvent.RESIZE_COMPLETE);
		
		rmEvent.item = selectedItem;
		rmEvent.properties = event.properties;
		dispatchEvent(rmEvent);
	}
	private function markerSelectedHandler(event:TransformMarkerEvent):void {
		
		trace('marker selected')
		markerSelected = true;
		highlightItem(null);
	}
	private function markerUnSelectedHandler(event:TransformMarkerEvent):void {
		trace('marker unselected')
		markerSelected = false;
	}
	private function rollOutHandler(event:MouseEvent):void {
		
		if(tip)
			tip.visible = false;
	}
}
}