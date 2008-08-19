import flash.events.MouseEvent;

import vdom.containers.IItem;
import vdom.controls.wysiwyg.EditableText;

private const editableStyles:Array = 
	[
		["color", "color"],
		["fontfamily", "fontFamily"],
		["fontsize", "fontSize"],
		["fontweight", "fontWeight"],
		["fontstyle", "fontStyle"],
		["align", "textAlign"]
	]

private var selectedItem:IItem;

private var oldValue:String = '';

private var elementForEditing:EditableText;
private var _selfChanged:Boolean = false;
private var currentRange:*;

private var _style:Object = {};

private var attributes:Object;

public function get selfChanged():Boolean {
	
	return _selfChanged;
}

public function init(item:IItem):void
{	
	var container:EditableText = item.editableAttributes[0].sourceObject;
	attributes = item.editableAttributes[0].attributes;
	
	var attributeValue:String;
	for each (var attribute:Array in editableStyles)
	{
		if (attributes.hasOwnProperty([attribute[0]]))
		{
			 attributeValue = container.getStyle(attribute[1]);
			 if(attributeValue)
			 	_style[attribute[0]] = attributeValue;
		}
	}
	
	oldValue = container.text;
	
	selectedItem = item;
	elementForEditing = container;
	
	elementForEditing.editable = true;
	elementForEditing.selectable = true;
}

private function zzz(event:MouseEvent):void
{
	event.stopImmediatePropagation();	
}

public function close():void
{	
	attributes["value"] = elementForEditing.text;
	
	for (var attributeName:String in _style)
		attributes[attributeName] = _style[attributeName];
	
	registerEvent(false);
	elementForEditing.editable = false;
	elementForEditing.selectable = false;
}

private function registerEvent(flag:Boolean):void
{	
	
}

private function execCommand(commandName:String, commandAttributes:String = null):void
{	
	
}