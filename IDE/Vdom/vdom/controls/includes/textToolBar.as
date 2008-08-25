import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.collections.IViewCursor;
import mx.collections.Sort;
import mx.collections.SortField;

import vdom.containers.IItem;
import vdom.controls.wysiwyg.EditableText;

private const editableStyles:Array = 
	[
		["color", "color"],
		["fontfamily", "fontFamily"],
		["fontsize", "fontSize"],
		["fontweight", "fontWeight"],
		["fontstyle", "fontStyle"],
		["align", "textAlign"],
		["textdecoration", "textDecoration"]
	]

private var fonts:ArrayCollection = new ArrayCollection(
	[
		{label:"Andale Mono", data:"andale mono"},
		{label:"Arial", data:"arial"},
		{label:"Arial Black", data:"arial black"},
		{label:"Book Antiqua", data:"book antiqua"},
		{label:"Comic Sans MS", data:"comic sans ms"},
		{label:"Courier New", data:"courier new"},
		{label:"Georgia", data:"georgia"},
		{label:"Helvetica", data:"helvetica"},
		{label:"Impact", data:"impact"},
		{label:"Symbol", data:"symbol"},
		{label:"Tahoma", data:"tahoma"},
		{label:"Terminal", data:"terminal"},
		{label:"Times New Roman", data:"times new roman"},
		{label:"Times", data:"times"},
		{label:"Verdana", data:"verdana"},
		{label:"Webdings", data:"webdings"},
		{label:"Wingdings", data:"wingdings"}
	]
);
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
	
	fonts.sort = new Sort();
	fonts.sort.fields = [new SortField("data")];
	fonts.refresh();
	
	fontSelector.dataProvider = fonts;
	fontSelector.validateNow();
	
	var cursor:IViewCursor = fonts.createCursor();
	
	if(_style.hasOwnProperty("fontfamily"))
	{
		if(cursor.findFirst({data:_style["fontfamily"].toLowerCase()}))
			fontSelector.selectedItem = cursor.current;
	}
	
	if(_style.hasOwnProperty("fontweight"))
	{
		if(_style["fontweight"] == "bold")
			weightButton.selected = true;
		else
			weightButton.selected = false;
	}
	
	if(_style.hasOwnProperty("fontstyle"))
	{
		if(_style["fontstyle"] == "italic")
			styleButton.selected = true;
		else
			styleButton.selected = false;
	}
	
	if(_style.hasOwnProperty("textdecoration"))
	{
		if(_style["textdecoration"] == "underline")
			decorationButton.selected = true;
		else
			decorationButton.selected = false;
	}
	
	if(_style.hasOwnProperty("align"))
	{
		if(_style["align"] == "left")
		{
			leftButton.selected = true;
			centerButton.selected = false;
			rightButton.selected = false;
		}
		
		if(_style["align"] == "center")
		{
			leftButton.selected = false;
			centerButton.selected = true;
			rightButton.selected = false;
		}
		
		if(_style["align"] == "right")
		{
			leftButton.selected = false;
			centerButton.selected = false;
			rightButton.selected = true;
		}
	}
	
	selectedItem = item;
	elementForEditing = container;
	
	elementForEditing.editable = true;
	elementForEditing.selectable = true;
}

private function changeWeight():void
{
	if(weightButton.selected)
		elementForEditing.setStyle("fontWeight", "normal");
	else
		elementForEditing.setStyle("fontWeight", "bold");
	
	weightButton.selected = !weightButton.selected;
}

private function changeStyle():void
{
	if(styleButton.selected)
		elementForEditing.setStyle("fontStyle", "normal");
	else
		elementForEditing.setStyle("fontStyle", "italic");
	
	styleButton.selected = !styleButton.selected;
}

private function changeDecoration():void
{
	if(decorationButton.selected)
		elementForEditing.setStyle("textDecoration", "none");
	else
		elementForEditing.setStyle("textDecoration", "underline");
	
	decorationButton.selected = !decorationButton.selected;
}

private function changeAlign(value:String):void
{
	switch (value)
	{
		case "left":
		{
			elementForEditing.setStyle("textAlign", "left");
			
			leftButton.selected = true;
			centerButton.selected = false;
			rightButton.selected = false;
			
			break;
		}
		case "center":
		{
			elementForEditing.setStyle("textAlign", "center");
			
			leftButton.selected = false;
			centerButton.selected = true;
			rightButton.selected = false;
			
			break;
		}
		case "right":
		{
			elementForEditing.setStyle("textAlign", "right");
			
			leftButton.selected = false;
			centerButton.selected = false;
			rightButton.selected = true;
			
			break;
		}
	}
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
	
	//color fix
	
	if(attributes["color"])
	{
		var hexColor:String = Number(attributes["color"]).toString(16).toUpperCase();
		
		var i:int = 6 - hexColor.length;
		
		while (--i >= 0) 
			hexColor = "0" + hexColor;
		
		attributes["color"] = hexColor;
	}
	
	registerEvent(false);
	elementForEditing.editable = false;
	elementForEditing.selectable = false;
}

private function invalidateStyles():void
{
	
}

private function registerEvent(flag:Boolean):void
{	
	
}

private function execCommand(commandName:String, commandAttributes:String = null):void
{	
	
}