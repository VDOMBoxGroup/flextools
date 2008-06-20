import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.html.HTMLLoader;

import mx.collections.ArrayCollection;
import mx.core.Application;
import mx.core.Container;
import mx.core.UIComponent;
import mx.events.ColorPickerEvent;
import mx.events.ListEvent;
import mx.managers.PopUpManager;

import vdom.containers.IItem;
import vdom.controls.EditableHTML;
import vdom.controls.richTextToolBarClasses.CharMap;
import vdom.controls.richTextToolBarClasses.CodeEditor;
import vdom.controls.richTextToolBarClasses.LinkSelection;

private var sample:HTMLLoader;
private var _editableElement:EditableHTML;
private var selectedItem:Container;

private var tinyMCE:*;
private var iFrame:*;
private var contentDocument:*

private var _selfChanged:Boolean = false;

[Bindable]
private var font:ArrayCollection;

private function get editableElement():EditableHTML {

	return _editableElement;
}

private function set editableElement(value:EditableHTML):void {
	
	_editableElement = value;
}

public function init(item:IItem, container:*):void {
	
	editableElement = container;
	selectedItem = Container(item);
	
	if(!editableElement.loaded)
		editableElement.addEventListener(Event.COMPLETE, editableElement_completeHandler);
	else
		editableElement_completeHandler(new Event('true'))
}

public function get selfChanged():Boolean {
	
	return _selfChanged;
}

private function editableElement_completeHandler(event:Event):void {
	
	editableElement.removeEventListener(Event.COMPLETE, editableElement_completeHandler);
	
	sample = new HTMLLoader();
	sample.addEventListener(Event.HTML_DOM_INITIALIZE, HtmlDomInitalizeHandler);
	sample.loadString( 
		'<html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /><title>Script</title>' + 
		'<script language="javascript" type="text/javascript" src="libs/tinymce/jscripts/tiny_mce/tiny_mce_src.js"></script>' + 
		'<script>tinyMCE.init({mode : "none", force_br_newlines : "true", theme : "advanced", browsers : "gecko", dialog_type : "modal", src_mode: "_src", height:\'100%\',  width:\'100%\'});</script>' + 
		'</head><body><div><textarea id="content" name="content" /></div></body></html>'
	);
}

public function close():void {
	
	var value:* = tinyMCE.getContent();
	/* var xEditingArea:* = editableElement.domWindow.document.getElementById('xEditingArea');
	xEditingArea.parentNode.removeChild(xEditingArea);
	var eee:* = editableElement.domWindow.document.getElementsByTagName('body')[0];
	eee.innerHTML = '<span id="xEditingArea">' + value + '</span>';
	//editableElement.domWindow.document.firstChild.lastChild.innerHtml = '<span id="xEditingArea">' + value + '</span>';;
	editableElement.htmlText = editableElement.domWindow.document.firstChild.innerHTML; */
	/* editableElement.htmlText = 
		'<html><head>' + 
		'<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />' +
		'</head>' +
		'<body style="padding:5px;" id="xEditingArea">' +
		value +
		'</body></html>'; */
	editableElement.editabledText = value;
}

private function HtmlDomInitalizeHandler(e:Event):void {
	
	sample.removeEventListener(Event.HTML_DOM_INITIALIZE, HtmlDomInitalizeHandler)
	
	var content:* = editableElement.domWindow.document.getElementsByTagName('body')[0];
	
	content.innerHTML = '<span id="xEditingArea">' + content.innerHTML + '</span>';
	
	var www:* = content.firstChild;
	sample.window.www = www;
	sample.window.setIFrame = setIFrame;
	sample.window.setHTML = setHTML;
	
	sample.addEventListener(Event.COMPLETE, completeHandler);
}

private function completeHandler(e:Event):void {
	
	sample.removeEventListener(Event.COMPLETE, completeHandler);
	sample.window.tinyMCE.execCommand("mceAddControl", true, "content");
	
	tinyMCE = sample.window.tinyMCE;
	
	editableElement.addEventListener(KeyboardEvent.KEY_UP, editableElement_KeyUpHandler);
	
	var newHeight:Number = contentDocument.documentElement.offsetHeight;
	if(editableElement.height != newHeight) {
		
		editableElement.height = newHeight + 10;
		iFrame.style.height = newHeight + 'px'
		selectedItem.dispatchEvent(new Event('refreshComplete'));
	}
}

private function editableElement_KeyUpHandler(event:KeyboardEvent):void {
	
	
	var d:* = editableElement.domWindow.document.getElementById('xEditingArea');
	var newHeight:Number = d.contentDocument.documentElement.offsetHeight;
	if(editableElement.height != newHeight) {
		
		editableElement.height = newHeight + 10;
		iFrame.style.height = newHeight + 'px'
		selectedItem.dispatchEvent(new Event('refreshComplete'));
	}
}

private function setIFrame(iFrameValue:*, contentDocumentValue:*):void {
	
	if(iFrameValue)
		iFrame = iFrameValue;
	
	if(contentDocumentValue)
		contentDocument = contentDocumentValue;
}

private function setHTML(value:*):void {
	
	editableElement.domWindow.document.getElementsByTagName('body').innerHTML = 
		'<span id="xEditingArea">' + value + '</span>';
}

private function execCommand(commandName:String, commandAttributes:String = null):void {
	
	tinyMCE.execCommand(commandName, false, commandAttributes);
}

private function insertLink():void {
	
	var aaa:LinkSelection = new LinkSelection();
	aaa.addEventListener('linkSelected', linkSelectedHandler);
	PopUpManager.addPopUp(aaa, DisplayObject(Application.application), true);
	PopUpManager.centerPopUp(aaa);
}

private function linkSelectedHandler(event:Event):void {
	
	event.currentTarget.removeEventListener('linkSelected', linkSelectedHandler);
	tinyMCE.themes['advanced']._insertLink(event.currentTarget.url, '_blank');
	PopUpManager.removePopUp(UIComponent(event.currentTarget));
	
}

private function unLink():void {
	
	tinyMCE.execCommand("unlink", false);
}
private function insertChar():void {
	
	var www:CharMap = new CharMap();
	www.addEventListener('charSelected', charSelectedHandler);
	PopUpManager.addPopUp(www, DisplayObject(Application.application), true);
	PopUpManager.centerPopUp(www);
}

private function changeFont(event:ListEvent):void {
	
	var val:String //= fontSelector.selectedItem.data
	tinyMCE.execCommand('FontName', false, val)
}

private function colorFillChanged(event:ColorPickerEvent):void {
	
	var hexValue:String = event.color.toString(16); 
	var hexLength:int = hexValue.length;
	for (var i:int = hexLength; i < 6; i++)
		hexValue = '0' + hexValue;
	
	tinyMCE.execCommand('HiliteColor', false, hexValue);
}

private function colorTextChanged(event:ColorPickerEvent):void {
	
	var hexValue:String = event.color.toString(16); 
	var hexLength:int = hexValue.length;
	for (var i:int = hexLength; i < 6; i++)
		hexValue = '0' + hexValue;
	
	tinyMCE.execCommand('forecolor', false, hexValue);
}

private function charSelectedHandler(event:Event):void {
	
	event.currentTarget.removeEventListener('charSelected', charSelectedHandler);
	tinyMCE.execCommand("mceInsertContent", false, event.currentTarget.charCode);
	PopUpManager.removePopUp(UIComponent(event.currentTarget));
}

private function openCodeEditor():void {
	
	var aaa:CodeEditor = new CodeEditor();
	aaa.code = tinyMCE.getContent(tinyMCE.getWindowArg('editor_id'));
	aaa.addEventListener('updateCode', updateCodeHandler);
	PopUpManager.addPopUp(aaa, DisplayObject(Application.application), true);
	PopUpManager.centerPopUp(aaa);
}

private function updateCodeHandler(event:Event):void {
	
	event.currentTarget.removeEventListener('updateCode', updateCodeHandler);
	tinyMCE.setContent(event.currentTarget.code);
	PopUpManager.removePopUp(UIComponent(event.currentTarget));
}