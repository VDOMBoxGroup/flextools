package vdom.components.editor.containers
{
import mx.containers.Canvas;
import flash.display.DisplayObject;
import flash.events.MouseEvent;
import vdom.components.editor.managers.ResizeManager;
import vdom.components.editor.events.ResizeManagerEvent;
import flash.events.Event;
	
public class Workspace extends Canvas
{
	
	public var selectedElement:String;
	
	private var resizer:ResizeManager;
	
	private var _elements:Object;
	
	public function Workspace()
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
		resizer.item = _elements[selectedElement];
	}
	
	public function destroyElements():void {
		selectedElement = null;
		removeAllChildren();
	}
	
	public function set dataProvider(objects:Object):void {
		
	}
	
	public function get dataProvider():Object {
		return new Object();
	}
	
	public function addItem(objectAttributes:XML):void {
		
		var elementId:String = objectAttributes.@ID;
		
		var element:Item = new Item(elementId);
		
		var elWidth:int = objectAttributes.Attributes.Attribute.(@Name == 'width')[0];
		var elHeight:int = objectAttributes.Attributes.Attribute.(@Name == 'height')[0];
		
		element.width = (elWidth == 0) ? 50 : elWidth;
		element.height = (elHeight == 0) ? 50 : elHeight;
		
		element.x = objectAttributes.Attributes.Attribute.(@Name == 'left')[0];
		element.y = objectAttributes.Attributes.Attribute.(@Name == 'top')[0];
		
		/* for each(var attr:XML in objectAttributes.Attributes.Attribute) {
			element[attr.@Name] = attr;
		} */
		
		element.addEventListener(MouseEvent.CLICK, elementClickHandler);
		_elements[objectAttributes.@ID] = element
		addChild(element);
	}
	
	private function resizeCompleteHandler(event:ResizeManagerEvent):void {
		
	}
	
	private function elementClickHandler(event:MouseEvent):void {
	
		if(selectedElement) {
			selectedElement = null;
			removeChild(resizer);
		}
		
		selectedElement = Item(event.currentTarget).elementId;
		_elements[selectedElement].content.setFocus();
		
		resizer.item = _elements[selectedElement];
		addChild(resizer);
		event.stopPropagation();
		dispatchEvent(new Event('objectChange'));
	}
	
	private function mainClickHandler(event:MouseEvent):void
	{
		if(event.target == event.currentTarget && selectedElement) {
			setFocus();
			selectedElement = null;
			removeChild(resizer);
			dispatchEvent(new Event('objectChange'));
		}
	}
}
}