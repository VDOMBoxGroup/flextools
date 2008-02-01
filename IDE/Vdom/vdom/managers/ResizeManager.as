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
	
	private var highlightedObject:Item;
	
	private var selectedObject:Item;
	
	private var highlightedItem:Item;
	
	public function ResizeManager() {
		
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
		
		dataManager = DataManager.getInstance();
		
		//_workArea = topLevelItem.parent;
		
		//if(!highlightMarker)
			//highlightMarker = new Canvas();
		
		//highlightMarker.visible = false;
		_topLevelItem.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		_topLevelItem.addEventListener(MouseEvent.CLICK, mouseClickHandler);
			//highlightMarker.addEventListener(TransformMarkerEvent.TRANSFORM_COMPLETE, resizeCompleteHandler);
		
		//highlightMarker.visible = false;
		
		if(!selectMarker)
			selectMarker = new TransformMarker();
		
		selectMarker.visible = false;
		
		//_topLevelItem.addChild(selectMarker);
		
		//selectMarker.addEventListener(TransformMarkerEvent.TRANSFORM_BEGIN, resizeBeginHandler);
		selectMarker.addEventListener(TransformMarkerEvent.TRANSFORM_COMPLETE, resizeCompleteHandler);
		//selectMarker.addEventListener('markerSelected', markerSelectedHandler);
		//selectMarker.addEventListener('markerUnSelected', markerUnSelectedHandler);
		
		//itemTransform = false;
		
		_topLevelItem.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
		
		destroyToolTip();
		createToolTip();
		
		//_topLevelItem.rawChildren.addChild(highlightMarker);
		//
	}
	
	public function selectItem(item:UIComponent, moveMode:Boolean = false, resizeMode:String = '0'):void {
		
		if(item) {
			
			if(!item.parent)
				return;
			item.parent.addChild(selectMarker);
			//bringOnTop();
			selectMarker.item = item;
			selectMarker.resizeMode = resizeMode;
			selectMarker.moveMode = moveMode;
			selectMarker.visible = true;
			
		} else {
			if(selectMarker.parent)
				selectMarker.parent.removeChild(selectMarker)
			
			selectMarker.item = null;
			selectMarker.visible = false;
		}
		//selectMarker.addEventListener(ResizeEvent.RESIZE, resizeCompleteHandler);
	}
	
	public function highlightItem(item:Item, moveMode:Boolean = false, toolTipText:String = ''):void {
		
		if(item && !itemTransform) {
			
			if(highlightedItem)
				highlightedItem.highlight(false);
			
			highlightedItem = item;
			highlightedItem.highlight(true);
			
			/* bringOnTop();
			
			//highlightMarker.item = item;
			//highlightMarker.moveMode = moveMode;
			//highlightMarker.resizeMode = '0';
			highlightMarker.visible = true;
			
			var graph:Graphics = highlightMarker.graphics;
			
			var rect:Rectangle = item.getRect(_topLevelItem);
			highlightMarker.move(rect.x, rect.y);
			graph.clear();
			graph.lineStyle(1);
			graph.drawRect(
				0, 0, 
				rect.width, rect.height
			); */
			
			if(toolTipText != '') {
				
				tip.text = toolTipText;
				tip.visible = true;
				
			} else {
				
				tip.visible = false;
			}
			
		} else {
			
			//item.highlight = false;
			if(highlightedItem)
				highlightedItem.highlight(false);
				
			highlightedItem = null;
			
			tip.visible = false;
			//_topLevelItem.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
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
		//var one:* = _topLevelItem.numChildren-1;

		
		
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
	
	private function mouseClickHandler(event:MouseEvent):void {
		
		if(!highlightedObject)
			return;
		
		selectedObject = highlightedObject;
		
		//
		
		//var selectionResult:Item;
		
		//itemStack =	DisplayUtil.getObjectsUnderMouse(this, 'vdom.components.editor.containers.workAreaClasses::Item');
		
		//selectionResult = Item(itemStack[0]);
		
		//if(!selectionResult) return;
		
		//selectionResult.setFocus();
		
		if(_topLevelItem.objectID != selectedObject.objectID) {
			
			var objectType:XML = dataManager.getTypeByObjectId(selectedObject.objectID);
			
			selectItem(
					selectedObject, 
					objectType.Information.Moveable,
					objectType.Information.Resizable)
		} else
			selectItem(null);
		var rme:ResizeManagerEvent = new ResizeManagerEvent(ResizeManagerEvent.ITEM_SELECTED);
		rme.item = selectedObject;
		dispatchEvent(rme);
	}
	
	private function mouseMoveHandler(event:MouseEvent):void {
		
		/* if(resizeBegin)
			return; */
		
		//trace('mouseMoveHandler');
		
		if(tip) {
			
			tip.x = event.stageX + 15;
			tip.y = event.stageY + 15;
		}
		
		var targetList:Array =
			DisplayUtil.getObjectsUnderMouse(_topLevelItem, 'vdom.components.editor.containers.workAreaClasses::Item');
			
		if(targetList.length == 0)
			return
			
		if(highlightedObject == targetList[0])
			return
		
		highlightedObject = targetList[0];
		
		if(
			_topLevelItem != targetList[0] &&
			selectedObject != targetList[0]
		  ) {
				
			var objectName:String = dataManager.getObject(highlightedObject.objectID).@Name;
			
			var tipText:String = "Name:" + objectName;
			highlightItem(highlightedObject, true, tipText);
			
		} else {
			
			highlightItem(null);	
		}
		
		
	}
	
	private function resizeBeginHandler(event:TransformMarkerEvent):void {
		
		itemTransform = true;
		var rmEvent:ResizeManagerEvent = new ResizeManagerEvent(ResizeManagerEvent.RESIZE_BEGIN);
		dispatchEvent(rmEvent);
	}
	
	private function resizeCompleteHandler(event:TransformMarkerEvent):void {
		
		itemTransform = false;
		
		var rmEvent:ResizeManagerEvent = new ResizeManagerEvent(ResizeManagerEvent.RESIZE_COMPLETE);
		
		rmEvent.item = selectedObject;
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