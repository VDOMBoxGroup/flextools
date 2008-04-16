package vdom.managers {

import flash.events.EventDispatcher;
import flash.events.MouseEvent;

import mx.controls.ToolTip;
import mx.core.Container;
import mx.managers.CursorManager;
import mx.managers.ToolTipManager;
import mx.styles.StyleManager;

import vdom.containers.IItem;
import vdom.events.ResizeManagerEvent;
import vdom.events.TransformMarkerEvent;
import vdom.managers.resizeClasses.TransformMarker;
import vdom.utils.DisplayUtil;
			
[Event(name="RESIZE_COMPLETE", type="vdom.events.ResizeManagerEvent")]

public class ResizeManager extends EventDispatcher {
	
	private static var instance:ResizeManager;
	
	private var tip:ToolTip;
	
	private var _resizeMode:String;
	private var _moveMode:Boolean;
	
	private var dataManager:DataManager;
	
	private var _topLevelItem:Container;
	
	private var selectMarker:TransformMarker;
	
	public var itemTransform:Boolean;
	
	//private var highlightedObject:Item;
	
	private var highlightedItem:Container;
	
	private var caughtItem:Container;
	
	private var selectedItem:Container;
	
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
	
	public function init(topLevelItem:Container):void {
		
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
			selectMarker = new TransformMarker(this);
		
		selectMarker.visible = false;
		
		//_topLevelItem.addChild(selectMarker);
		
		selectMarker.addEventListener(TransformMarkerEvent.TRANSFORM_BEGIN, transformBeginHandler);
		selectMarker.addEventListener(TransformMarkerEvent.TRANSFORM_COMPLETE, transformCompleteHandler);
		selectMarker.addEventListener(TransformMarkerEvent.TRANSFORM_MARKER_SELECTED, markerSelectedHandler);
		selectMarker.addEventListener(TransformMarkerEvent.TRANSFORM_MARKER_UNSELECTED, markerUnSelectedHandler);
		
		//itemTransform = false;
		
		
		
		filterFunction = function(item:IItem):Boolean {
			
			return !item.isStatic;
		}
		
		destroyToolTip();
		createToolTip();
		
		//_topLevelItem.rawChildren.addChild(highlightMarker);
		//
	}
	
	public function selectItem( item:Container, 
								showMarker:Boolean = false, 
								moveMode:Boolean = false, 
								resizeMode:String = '0'):Container {
									
		var newSelectedItem:Container;
		
		if(item && item.parent) {
			
			if(selectMarker.parent)
				Container(selectMarker.parent).removeChild(selectMarker)
				
			if(showMarker) {
				
				_topLevelItem.addChild(selectMarker);
				
				selectMarker.resizeMode = resizeMode;
				selectMarker.moveMode = moveMode;
				selectMarker.item = item;
				selectMarker.visible = true;
			} else {
				
				selectMarker.item = null;
				selectMarker.visible = false;
			}
			
			selectedItem = newSelectedItem = item;
			
		} else {
			newSelectedItem = null;
			selectMarker.visible = false;
		}
			
		return newSelectedItem;
	}
	
	public function highlightItem(item:Container, showMarker:String = 'none'):void {
		
		if(cursorID) {
			CursorManager.removeCursor(cursorID);
			cursorID = NaN;
		}
		
		if(item && !itemTransform) {
			
			if(highlightedItem)
				IItem(highlightedItem).drawHighlight('none');
			
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
					
					IItem(item).drawHighlight('0x666666');
				break
			}
			
			highlightedItem = item;
			
		} else {
			
			if(highlightedItem)
				IItem(highlightedItem).drawHighlight('none');
				
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
		
		var newSelectedItem:Container;
		
		if(_topLevelItem != highlightedItem.parent) {
			
			trace('not selected');
			
			var objectType:XML = dataManager.getTypeByObjectId(IItem(highlightedItem).objectId);
			
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
		
		var itemUnderMouse:Container = getItemUnderMouse();
		
		if(itemUnderMouse == highlightedItem)
			return;
		
		if(itemUnderMouse && itemUnderMouse.parent != _topLevelItem) {
			
			var objectDescription:XML = dataManager.getObject(IItem(itemUnderMouse).objectId);
			
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
	
	private function getItemUnderMouse():Container {
		
		var targetList:Array =
			DisplayUtil.getObjectsUnderMouse(_topLevelItem.parent, 'vdom.containers::IItem', filterFunction);
		
		if(targetList.length == 0)
			return null;
		
		var itemUnderMouse:Container = null;
		
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
		
		rmEvent.item = event.item;
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