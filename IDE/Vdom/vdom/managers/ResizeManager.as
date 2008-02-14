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
import vdom.components.editor.containers.workAreaClasses.Item;
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
		_topLevelItem.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
		//highlightMarker.addEventListener(TransformMarkerEvent.TRANSFORM_COMPLETE, resizeCompleteHandler);
		
		//highlightMarker.visible = false;
		
		
		
		if(!selectMarker)
			selectMarker = new TransformMarker();
		
		selectMarker.visible = false;
		
		//_topLevelItem.addChild(selectMarker);
		
		selectMarker.addEventListener(TransformMarkerEvent.TRANSFORM_BEGIN, transformBeginHandler);
		selectMarker.addEventListener(TransformMarkerEvent.TRANSFORM_COMPLETE, transformCompleteHandler);
		//selectMarker.addEventListener('markerSelected', markerSelectedHandler);
		//selectMarker.addEventListener('markerUnSelected', markerUnSelectedHandler);
		
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
				
			}
			
			selectedItem = newSelectedItem = item;
			
		} else
			newSelectedItem = null;
			
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
			
			switch(showMarker) {
				
				case 'move':
					
					cursorID = CursorManager.setCursor(moveCursor);
					
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
		
		if(!highlightedItem)
			return;
		
		var newSelectedItem:Item;
		
		if(_topLevelItem.objectID != highlightedItem.objectID) {
			
			var objectType:XML = dataManager.getTypeByObjectId(highlightedItem.objectID);
			
			newSelectedItem = selectItem(	highlightedItem,
											true,
											objectType.Information.Moveable,
											'0');
						
		} else
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
		
		var targetList:Array =
			DisplayUtil.getObjectsUnderMouse(_topLevelItem.parent, 'vdom.components.editor.containers.workAreaClasses::Item', filterFunction);
		
		if(targetList.length == 0)
			return
		
		var itemUnderMouse:Item;
		
		if(highlightedItem == targetList[0]) {
			
			if(targetList.length > 1 && targetList[0].contains(targetList[1]))
				itemUnderMouse = targetList[1];
			else
				return;
				
		} else
			itemUnderMouse = targetList[0];
			
		if(
			_topLevelItem != itemUnderMouse &&
			selectedItem != itemUnderMouse
		  ) {
			
			var objectDescription:XML = dataManager.getObject(itemUnderMouse.objectID);
			
			var tipText:String = "Name:" + objectDescription.@Name;
			
			var moveable:String = objectDescription.Type.Information.Moveable
			//trace('moveable: ' + moveable);
			showToolTip(tipText);
			if(moveable == '1')
				highlightItem(itemUnderMouse, 'move');
			else
				highlightItem(itemUnderMouse, 'select');
			
		} else {
			
			showToolTip('');
			highlightItem(itemUnderMouse);
		}
		
		
	}
	
	private function transformBeginHandler(event:TransformMarkerEvent):void {
		
		itemTransform = true;
	}
	
	private function transformCompleteHandler(event:TransformMarkerEvent):void {
		
		itemTransform = false;
		
		var rmEvent:ResizeManagerEvent = new ResizeManagerEvent(ResizeManagerEvent.RESIZE_COMPLETE);
		
		rmEvent.item = selectedItem;
		rmEvent.properties = event.properties;
		dispatchEvent(rmEvent);
	}
	/* private function markerSelectedHandler(event:TransformMarkerEvent):void {
		
		dispatchEvent(new ResizeManagerEvent('markerSelected'));
	}
	private function markerUnSelectedHandler(event:TransformMarkerEvent):void {
		
		dispatchEvent(new ResizeManagerEvent('markerUnSelected'));
	} */
	private function mouseOutHandler(event:MouseEvent):void {
		
		/* if(tip) {
			
			_workArea.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			trace('toolTipText false 3');
			tip.visible = false;
		}
		
		if(highlightMarker.visible)
			highlightMarker.visible = false; */
	}
}
}