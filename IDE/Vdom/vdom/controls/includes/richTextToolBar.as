import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.html.HTMLLoader;

import mx.core.Application;
import mx.core.UIComponent;
import mx.events.ColorPickerEvent;
import mx.events.ListEvent;
import mx.managers.PopUpManager;

import vdom.containers.IItem;
import vdom.controls.richTextToolBarClasses.CharMap;
import vdom.controls.richTextToolBarClasses.CodeEditor;
import vdom.controls.richTextToolBarClasses.LinkSelection;
import vdom.controls.wysiwyg.EditableHTML;

private var HTMLEditorLoader:HTMLLoader;
private var editableHTML:EditableHTML;
private var selectedItem:IItem;

private var oldValue:String = '';

private var editableHTMLLoaded:Boolean;

private var tinyMCE:*;
private var elementForEditing:*;
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
	addEventListener(MouseEvent.MOUSE_DOWN, zzz);
	
	var container:Object = item.editableAttributes[0].sourceObject;
	
	oldValue = container.editabledText;
	editableHTMLLoaded = false;
	
	editableHTML = EditableHTML(container);
	selectedItem = item;
	
	if(!editableHTML.loaded)
		editableHTML.addEventListener(Event.COMPLETE, editableHTML_completeHandler);
	else
		editableHTML_completeHandler(new Event('true'));
}

private function zzz(event:MouseEvent):void
{
	event.stopImmediatePropagation();	
}

public function close():void
{	
	registerEvent(false);
	
	var value:*;
	
	if(editableHTMLLoaded)
		value = tinyMCE.getContent();
	else
		value = oldValue;
	
	editableHTMLLoaded = false;
	
	editableHTML.editabledText = value;
	
	selectedItem.editableAttributes[0].attributes["value"] = value;
}

private function registerEvent(flag:Boolean):void
{	
	if(!flag)
	{
		editableHTML.removeEventListener(Event.COMPLETE, editableHTML_completeHandler);
		editableHTML.removeEventListener(KeyboardEvent.KEY_UP, editableElement_KeyUpHandler);
		
		HTMLEditorLoader.removeEventListener(
			Event.HTML_DOM_INITIALIZE,
			HTMLEditorLoader_HTMLDomInitalizeHandler
		);
		HTMLEditorLoader.removeEventListener(Event.COMPLETE, HTMLEditorLoader_completeHandler);
	} 
}

private function setIFrame(iFrameValue:*, contentDocumentValue:*):void
{	
	if(iFrameValue)
		var iFrame:* = iFrameValue;
	
	if(contentDocumentValue)
		var contentDocument:* = contentDocumentValue;
}

private function setHTML(value:*):void
{	
	editableHTML.domWindow.document.getElementsByTagName('body').innerHTML = 
		'<span id="xEditingArea">' + value + '</span>';
}

private function recalculateSize():void
{
	if(!elementForEditing || !elementForEditing.contentDocument)
		return;
	
	var newHeight:Number = elementForEditing.contentDocument.documentElement.offsetHeight;
	
	if(editableHTML.height != newHeight && newHeight > 10)
	{	
		editableHTML.height = newHeight;
		DisplayObject(selectedItem).dispatchEvent(new Event('refreshComplete'));
	}
}

private function editableHTML_completeHandler(event:Event):void
{	
	editableHTML.removeEventListener(Event.COMPLETE, editableHTML_completeHandler);
	
	HTMLEditorLoader = new HTMLLoader();
	HTMLEditorLoader.addEventListener(
		Event.HTML_DOM_INITIALIZE,
		HTMLEditorLoader_HTMLDomInitalizeHandler
	);
	HTMLEditorLoader.loadString(template);
}

private function HTMLEditorLoader_HTMLDomInitalizeHandler(event:Event):void
{	
	HTMLEditorLoader.removeEventListener(
		Event.HTML_DOM_INITIALIZE, 
		HTMLEditorLoader_HTMLDomInitalizeHandler
	)
	
	var content:* = editableHTML.domWindow.document.getElementsByTagName('body')[0];
	content.innerHTML = '<span id="xEditingArea">' + content.innerHTML + '</span>';
	
	elementForEditing = content.firstChild;
	HTMLEditorLoader.window.elementForEditing = elementForEditing;
	HTMLEditorLoader.window.setIFrame = setIFrame;
	HTMLEditorLoader.window.setHTML = setHTML;
	
	HTMLEditorLoader.addEventListener(Event.COMPLETE, HTMLEditorLoader_completeHandler);
}

private function HTMLEditorLoader_completeHandler(event:Event):void
{	
	HTMLEditorLoader.removeEventListener(Event.COMPLETE, HTMLEditorLoader_completeHandler);
//	var d:* = HTMLEditorLoader.window.tinyMCE;
	HTMLEditorLoader.window.tinyMCE.execCommand("mceAddControl", true, "content");
	
	elementForEditing = editableHTML.domWindow.document.getElementById('xEditingArea');
	elementForEditing.focus();
	
	tinyMCE = HTMLEditorLoader.window.tinyMCE;
	editableHTML.addEventListener(KeyboardEvent.KEY_UP, editableElement_KeyUpHandler);
	
	var body:* = elementForEditing.contentWindow.document.getElementsByTagName('body')[0];
	body.style.paddingTop = "5px";
	body.style.paddingBottom = "5px";
		
	this.callLater(recalculateSize);
	
	editableHTMLLoaded = true;
}

private function editableElement_KeyUpHandler(event:KeyboardEvent):void
{	
	recalculateSize();
}

private function execCommand(commandName:String, commandAttributes:String = null):void
{	
	tinyMCE.execCommand(commandName, false, commandAttributes);
}

private function insertLink():void
{	
	var currentSelection:* = elementForEditing.contentWindow.getSelection();
	try
	{
		currentRange = currentSelection.getRangeAt(0);
	}
	catch(error:Error)
	{}
	
	var linkSelection:LinkSelection = new LinkSelection();
	linkSelection.addEventListener('linkSelected', linkSelection_linkSelectedHandler);
	
	PopUpManager.addPopUp(linkSelection, DisplayObject(Application.application), true);
	PopUpManager.centerPopUp(linkSelection);
}

private function linkSelection_linkSelectedHandler(event:Event):void
{	
	event.currentTarget.removeEventListener('linkSelected', linkSelection_linkSelectedHandler);
	
	var currentSelection:* = elementForEditing.contentWindow.getSelection();
	currentSelection.addRange(currentRange);
	
	tinyMCE.themes['advanced']._insertLink(event.currentTarget.url, '_blank');
	
	PopUpManager.removePopUp(UIComponent(event.currentTarget));	
}

private function unLink():void
{	
	tinyMCE.execCommand("unlink", false);
}

private function insertChar():void
{	
	var charMap:CharMap = new CharMap();
	charMap.addEventListener('charSelected', charSelectedHandler);
	
	PopUpManager.addPopUp(charMap, DisplayObject(Application.application), true);
	PopUpManager.centerPopUp(charMap);
}

private function changeFont(event:ListEvent):void
{	
	var val:String = fontSelector.selectedItem.data
	tinyMCE.execCommand('FontName', false, val);
	recalculateSize();
}

private function colorFillChanged(event:ColorPickerEvent):void
{	
	var hexValue:String = event.color.toString(16); 
	var hexLength:int = hexValue.length;
	for (var i:int = hexLength; i < 6; i++)
		hexValue = '0' + hexValue;
	
	tinyMCE.execCommand('HiliteColor', false, hexValue);
}

private function colorTextChanged(event:ColorPickerEvent):void
{	
	var hexValue:String = event.color.toString(16); 
	var hexLength:int = hexValue.length;
	
	for (var i:int = hexLength; i < 6; i++)
	{
		hexValue = '0' + hexValue;
	}
	
	tinyMCE.execCommand('forecolor', false, hexValue);
}

private function charSelectedHandler(event:Event):void {
	
	event.currentTarget.removeEventListener('charSelected', charSelectedHandler);
	
	tinyMCE.execCommand("mceInsertContent", false, event.currentTarget.charCode);
	PopUpManager.removePopUp(UIComponent(event.currentTarget));
	recalculateSize();
}

private function openCodeEditor():void
{	
	var codeEditor:CodeEditor = new CodeEditor();
	codeEditor.code = tinyMCE.getContent(tinyMCE.getWindowArg('editor_id'));
	codeEditor.addEventListener('updateCode', updateCodeHandler);
	
	PopUpManager.addPopUp(codeEditor, DisplayObject(Application.application), true);
	PopUpManager.centerPopUp(codeEditor);
}

private function updateCodeHandler(event:Event):void
{	
	event.currentTarget.removeEventListener('updateCode', updateCodeHandler);
	
	tinyMCE.setContent(event.currentTarget.code);
	PopUpManager.removePopUp(UIComponent(event.currentTarget));
	recalculateSize();
}