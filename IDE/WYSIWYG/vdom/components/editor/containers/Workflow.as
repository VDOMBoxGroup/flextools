package vdom.components.editor.containers
{
import mx.containers.Canvas;
import flash.display.DisplayObject;
import flash.events.MouseEvent;
import vdom.components.editor.managers.ResizeManager;
import vdom.components.editor.events.ResizeManagerEvent;
import flash.events.Event;
	
public class Workflow extends Canvas
{
	
	public var selectedItem:Item;
	
	private var resizer:ResizeManager;
	
	private var _elements:Object;
	
	public function Workflow()
	{
		super();
		
		
		_elements = [];
		resizer = new ResizeManager();
		resizer.addEventListener(ResizeManagerEvent.RESIZE_COMPLETE, resizeCompleteHandler);
		addEventListener(MouseEvent.CLICK, mainClickHandler, false);
	}
	
	public function updateElement(elementAttr:Object):void {
		
		var elementId:int = elementAttr.@ID;
		
		var element:Item = _elements[elementId];
		
		for each(var attr:XML in elementAttr.Attributes.Attribute) {
			element[attr.Name] = attr.Value;
		}
		resizer.item = selectedItem;
	}
	
	public function set dataProvider(objects:Object):void {
		
	}
	
	public function get dataProvider():Object {
		return new Object();
	}
	
	public function addItem(objectAttributes:Object):void {
		
		var elementId:int = int(objectAttributes.@ID);
		
		var element:Item = new Item(elementId);

		for each(var attr:XML in objectAttributes.Attributes.Attribute) {
			element[attr.@Name] = attr;
		}
		
		element.addEventListener(MouseEvent.CLICK, elementClickHandler);
		_elements[objectAttributes.@ID] = element
		addChild(element);
	}
	
	private function resizeCompleteHandler(event:ResizeManagerEvent):void {
		
	}
	
	private function elementClickHandler(event:MouseEvent):void {
	
		if(selectedItem) {
			selectedItem = null;
			removeChild(resizer);
		}
		
		selectedItem = Item(event.currentTarget);
		selectedItem.content.setFocus();
		resizer.item = selectedItem;
		addChild(resizer);
		event.stopPropagation();
		dispatchEvent(new Event('objectChange'));
	}
	
	private function mainClickHandler(event:MouseEvent):void
	{
		if(event.target == event.currentTarget && selectedItem) {
			setFocus();
			selectedItem = null;
			removeChild(resizer);
			dispatchEvent(new Event('objectChange'));
		}
	}
}
}