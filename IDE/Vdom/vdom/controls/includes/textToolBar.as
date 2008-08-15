import flash.events.MouseEvent;

import vdom.containers.IItem;
import vdom.controls.wysiwyg.EditableText;

//private var HTMLEditorLoader:HTMLLoader;
//private var editableHTML:EditableHTML;
private var selectedItem:IItem;

private var oldValue:String = '';

//private var editableHTMLLoaded:Boolean;

//private var tinyMCE:*;
private var elementForEditing:EditableText;
//private var iFrame:*;
//private var contentDocument:*
//
private var _selfChanged:Boolean = false;

//
//[Bindable]
//private var font:ArrayCollection;

private var currentRange:*;

public function get selfChanged():Boolean {
	
	return _selfChanged;
}

/* private function get editableElement():EditableHTML
{
	return _editableElement;
}

private function set editableElement(value:EditableHTML):void
{
	_editableElement = value;
} */

public function init(item:IItem):void
{	
	var container:EditableText = item.editableAttributes[0].sourceObject;
	
	oldValue = container.text;
	
	selectedItem = item;
	elementForEditing = container;
	
	elementForEditing.editable = true;
	elementForEditing.selectable = true;
	
	/* EditableText(container).addEventListener(
		KeyboardEvent.KEY_UP,
		editableElement_KeyUpHandler
	); */
}

private function zzz(event:MouseEvent):void
{
	event.stopImmediatePropagation();	
}

public function close():void
{	
	registerEvent(false);
	elementForEditing.editable = false;
	elementForEditing.selectable = false;
}

private function registerEvent(flag:Boolean):void
{	
	
}

private function execCommand(commandName:String, commandAttributes:String = null):void
{	
//	tinyMCE.execCommand(commandName, false, commandAttributes);
}

//private function recalculateSize():void
//{
//	var tf:IUITextField = elementForEditing.textContainer;
//	
//	if(!tf)
//		return;
//	
//	elementForEditing.height = tf.textHeight + 10;
//	var d:* = "";
//	var newHeight:Number = elementForEditing.contentDocument.documentElement.offsetHeight;
	
//	if(editableHTML.height != newHeight && newHeight > 10)
//	{	
//		editableHTML.height = newHeight;
//		DisplayObject(selectedItem).dispatchEvent(new Event('refreshComplete'));
//	}
//}


/* private function editableElement_KeyUpHandler(event:KeyboardEvent):void
{	
	recalculateSize();
} */