package vdom.managers {

import flash.events.EventDispatcher;
import flash.events.MouseEvent;

import mx.controls.ToolTip;
import mx.core.Container;
import mx.events.ScrollEvent;
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
	
	public var itemDrag:Boolean;
	
	private var dataManager:DataManager;
	
	private var _topLevelItem:Container;

	private var highlightedItem:IItem;
	private var activeItem:IItem;
	private var _selectedItem:IItem;	

	private var moveCursor:Class;
	private var cursorID:int;
	
	private var selectMarker:TransformMarker;
	private var moveMarker:TransformMarker;
	private var filterFunction:Function;
	private var tip:ToolTip;
	
	public var itemTransform:Boolean;
//	private var beforeTransform:Object;
//	private var markerSelected:Boolean;
	private var itemMoved:Boolean;
	
	
	public function ResizeManager() {
		
		dataManager = DataManager.getInstance();
		moveCursor = StyleManager.getStyleDeclaration('global').getStyle('moveCursor');
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
	
	/* public function get itemTransform():Boolean {
	
		return _itemTransform;
	}
	
	public function set itemTransform(value:Boolean):void {
		
		_itemTransform = value;
		
		if(!selectMarker.item)
			return;
		
		var item:Container = selectMarker.item;
		
		 if(value) {

			beforeTransform = {
				left : item.x,
				top : item.y,
				width : item.width,
				height : item.height
			};
			
		} else {
			
			if(
				beforeTransform.top == item.x &&
				beforeTransform.left == item.y &&
				beforeTransform.width == item.width &&
				beforeTransform.height == item.height
			)
				return;
		 
		var rmEvent:ResizeManagerEvent = new ResizeManagerEvent(ResizeManagerEvent.RESIZE_COMPLETE);
		
		var properties:Object = {
			left : item.x,
			top : item.y,
			width : item.width,
			height : item.height
		};
		
		rmEvent.item = item;
		rmEvent.properties = properties;
		dispatchEvent(rmEvent);
		
	} */
	
	private function get selectedItem():IItem {
		
		return _selectedItem;
	}
	
	private function set selectedItem(value:IItem):void {
		
		if(value != _selectedItem) {
			
			_selectedItem = value;
			
			var rme:ResizeManagerEvent = new ResizeManagerEvent(ResizeManagerEvent.OBJECT_SELECT);
			rme.item = Container(_selectedItem);
			
			dispatchEvent(rme) 
		}
	}
	
	public function init(topLevelItem:Container):void {
		
		_topLevelItem = topLevelItem;
		
		_topLevelItem.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
		_topLevelItem.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, true);
		_topLevelItem.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		_topLevelItem.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		_topLevelItem.addEventListener(ScrollEvent.SCROLL, scrollHandler);
		
		CursorManager.removeAllCursors();
		
		if(!selectMarker)
			selectMarker = new TransformMarker(this);
			
		if(!moveMarker)
			moveMarker = new TransformMarker(this);
		
		selectMarker.visible = false;
		moveMarker.visible = false;
		
		moveMarker.addEventListener(TransformMarkerEvent.TRANSFORM_CHANGING, transformChangingHandler);
		selectMarker.addEventListener(TransformMarkerEvent.TRANSFORM_COMPLETE, transformCompleteHandler);
		selectMarker.addEventListener(TransformMarkerEvent.TRANSFORM_MARKER_SELECTED, markerSelectedHandler);
//		selectMarker.addEventListener(TransformMarkerEvent.TRANSFORM_MARKER_UNSELECTED, markerUnSelectedHandler);
		
		filterFunction = function(item:IItem):Boolean { return !item.isStatic;}
		
		destroyToolTip();
		createToolTip();
	}
	
	public function selectItem( item:IItem, 
								showMarker:Boolean = false, 
								moveMode:Boolean = false, 
								resizeMode:String = '0',
								actionMode:String = 'resize'):IItem {
									
		var newSelectedItem:IItem;
		var marker:TransformMarker = selectMarker;
		
		if(actionMode == 'move')
			marker = moveMarker;
		
		if(item && Container(item).parent) {
			
			if(marker.parent)
				marker.parent.removeChild(marker)
				
			if(showMarker) {
				
				_topLevelItem.addChild(marker);
				
				marker.resizeMode = resizeMode;
				marker.moveMode = moveMode;
				marker.item = Container(item);
				marker.visible = true;
			} else {
				
				marker.item = null;
				marker.visible = false;
			}
			
			newSelectedItem = item;
			
		} else {
			newSelectedItem = null;
			marker.visible = false;
			marker.item = null;
		}
			
		return newSelectedItem;
	}
	
	public function highlightItem(item:IItem, showMarker:String = 'none'):IItem {
		
		var newHighlightedItem:IItem;
		
		if(cursorID) {
			CursorManager.removeCursor(cursorID);
			cursorID = NaN;
		}
		
		if(item && !itemDrag && !(itemTransform && selectMarker.item)) {
			
			if(highlightedItem)
				highlightedItem.drawHighlight('none');
			
			if(item == selectedItem) 
				showMarker = 'none';
			else
				newHighlightedItem = item;
			
			switch(showMarker) {
				
				case 'move':
					
					cursorID = CursorManager.setCursor(moveCursor, 2, -10, -10);
					
				case 'select':
					
					item.drawHighlight('0x666666');
			}
			
			
		} else {
			
			if(highlightedItem)
				highlightedItem.drawHighlight('none');
		}
		
		return newHighlightedItem;
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
		var topIndex:int = _topLevelItem.numChildren-1;		
		
		if(selectMarkerIndex != topIndex) {
			
			_topLevelItem.setChildIndex(selectMarker, topIndex);
		}
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
		
		if(!highlightedItem || selectedItem == highlightedItem)
			return;
		
		activeItem = highlightedItem;
//		event.stopImmediatePropagation();
		/* if(_topLevelItem != highlightedItem.parent) {
			
			var objectType:XML = dataManager.getTypeByObjectId(IItem(highlightedItem).objectId);
			
			selectItem(	highlightedItem,
						true,
						objectType.Information.Moveable,
						objectType.Information.Resizable);
						
		}
		else
			selectItem(highlightedItem, false); */
	}
	
	private function mouseUpHandler(event:MouseEvent):void {
		
		if(activeItem) {
			
			if(itemMoved)
				selectItem(null, true, false, '0', 'move');
			
			else {
				
				if(Container(activeItem).parent != _topLevelItem) {
				
					var objectType:XML = dataManager.getTypeByObjectId(activeItem.objectId);
					
					selectedItem = selectItem(	activeItem,
												true,
												objectType.Information.Moveable,
												objectType.Information.Resizable);
						
				}
				else
					selectedItem = selectItem(activeItem, false);
				
				
			}
			
			activeItem = null;
		}

		itemMoved = false;
	}
	
	private function mouseMoveHandler(event:MouseEvent):void {
		
		if(tip) {
			
			tip.x = event.stageX + 15;
			tip.y = event.stageY + 15;
		}
			
		if(selectMarker.item && itemTransform || itemDrag || selectMarker.markerSelected )
			return;
		
		if(activeItem && Container(activeItem).parent != _topLevelItem) {
			
			var objectType:XML = dataManager.getTypeByObjectId(activeItem.objectId);
			selectItem(activeItem, true, objectType.Information.Moveable, '0', 'move');
			itemMoved = true;
			return;
		}
		
		var itemUnderMouse:IItem = getItemUnderMouse();
		
		if(itemUnderMouse == highlightedItem)
			return;
		
		if(itemUnderMouse && Container(itemUnderMouse).parent != _topLevelItem) {
			
			var objectDescription:XML = dataManager.getObject(itemUnderMouse.objectId);
			
			var tipText:String = "Name:" + objectDescription.@Name;
			
			var type:XML = dataManager.getTypeByObjectId(itemUnderMouse.objectId); 
			
			var moveable:String = type.Information.Moveable;
				
			showToolTip(tipText);
			
			if(moveable == '1')
				moveable = 'move';		
			else
				moveable = 'select';
				
			highlightedItem = highlightItem(itemUnderMouse, moveable);
			
		} else {
			
			showToolTip();
			highlightedItem = highlightItem(itemUnderMouse);
		}
		event.stopImmediatePropagation();
	}
	
	private function getItemUnderMouse():IItem {
		
		var targetList:Array =
			DisplayUtil.getObjectsUnderMouse(_topLevelItem.parent, 'vdom.containers::IItem', filterFunction);
		
		if(targetList.length == 0)
			return null;
		
		var itemUnderMouse:IItem;
		
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
	
	private function transformChangingHandler(event:TransformMarkerEvent):void {
		
		selectMarker.refresh();
	}
	
	 private function transformCompleteHandler(event:TransformMarkerEvent):void {
		
		var rmEvent:ResizeManagerEvent = new ResizeManagerEvent(ResizeManagerEvent.RESIZE_COMPLETE);
		
		rmEvent.item = event.item;
		rmEvent.properties = event.properties;
		dispatchEvent(rmEvent);
	}
	private function markerSelectedHandler(event:TransformMarkerEvent):void {
		
//		markerSelected = true;
		highlightedItem = highlightItem(null);
	}
	/* private function markerUnSelectedHandler(event:TransformMarkerEvent):void {
		
		markerSelected = false;
	} */
	
	private function scrollHandler(event:ScrollEvent):void {
		trace('scroll');
		if(selectMarker && selectMarker.item)
			selectMarker.refresh();
	}
	
	private function rollOutHandler(event:MouseEvent):void {
		
		if(tip)
			tip.visible = false;
	}
}
}