import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.html.HTMLLoader;

import mx.collections.ArrayCollection;
import mx.controls.HTML;
import mx.core.UIComponent;
import mx.events.ColorPickerEvent;
import mx.events.ListEvent;
import mx.managers.PopUpManager;

import vdom.components.edit.containers.toolbarClasses.richTextToolsClasses.CharMap;
import vdom.components.edit.containers.toolbarClasses.richTextToolsClasses.CodeEditor;
import vdom.components.edit.containers.toolbarClasses.richTextToolsClasses.LinkSelection;

private var sample:HTMLLoader;
private var editableElement:HTML;

private var tinyMCE:*;
private var iFrame:*;
private var contentDocument:*

[Bindable]
private var font:ArrayCollection;
public function init(container:HTML):void {
		
	editableElement = container;
	
	sample = new HTMLLoader();
	sample.addEventListener(Event.HTML_DOM_INITIALIZE, HtmlDomInitalizeHandler);
	sample.loadString( 
		'<html><head><meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /><title>Script</title>' + 
		'<script language="javascript" type="text/javascript" src="libs/tinymce/jscripts/tiny_mce/tiny_mce_src.js"></script>' + 
		'<script>tinyMCE.init({mode : "none", theme : "advanced", browsers : "gecko", dialog_type : "modal", /*auto_resize:"true",*/ src_mode: "_src", height:\'100%\',  width:\'100%\'});</script>' + 
		'</head><body><div><textarea id="content" name="content" /></div></body></html>'
	);
}
private function HtmlDomInitalizeHandler(e:Event):void {
	
	sample.removeEventListener(Event.HTML_DOM_INITIALIZE, HtmlDomInitalizeHandler)
	sample.window.www = editableElement.domWindow.document.getElementById('xEditingArea');
	sample.window.setIFrame = setIFrame;
	sample.addEventListener(Event.COMPLETE, completeHandler);
}

private function completeHandler(e:Event):void {
	
	sample.removeEventListener(Event.COMPLETE, completeHandler);
	sample.window.tinyMCE.execCommand("mceAddControl", true, "content");
	
	tinyMCE = sample.window.tinyMCE;
	
	editableElement.addEventListener(KeyboardEvent.KEY_UP, editableElement_KeyUpHandler);
}

private function editableElement_KeyUpHandler(event:KeyboardEvent):void {
	
	var newHeight:Number = contentDocument.documentElement.offsetHeight;
	
	if(editableElement.height != newHeight) {
		
		editableElement.height = newHeight + 1;
		iFrame.style.height = newHeight + 'px'
	}
}

private function setIFrame(iFrameValue:*, contentDocumentValue:*):void {
	
	if(iFrameValue)
		iFrame = iFrameValue;
	
	if(contentDocumentValue)
		contentDocument = contentDocumentValue;
}

private function execCommand(commandName:String, commandAttributes:String = null):void {
	
	tinyMCE.execCommand(commandName, false, commandAttributes);
}

private function insertLink():void {
	
	var aaa:LinkSelection = new LinkSelection();
	aaa.addEventListener('linkSelected', linkSelectedHandler);
	PopUpManager.addPopUp(aaa, this);
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
	
	var aaa:CharMap = new CharMap();
	aaa.addEventListener('charSelected', charSelectedHandler);
	PopUpManager.addPopUp(aaa, this);
}

private function changeFont(event:ListEvent):void {
	
	var val:String = fontSelector.selectedItem.data
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
	PopUpManager.addPopUp(aaa, this);
}

private function updateCodeHandler(event:Event):void {
	
	event.currentTarget.removeEventListener('updateCode', updateCodeHandler);
	tinyMCE.setContent(event.currentTarget.code);
	PopUpManager.removePopUp(UIComponent(event.currentTarget));
}