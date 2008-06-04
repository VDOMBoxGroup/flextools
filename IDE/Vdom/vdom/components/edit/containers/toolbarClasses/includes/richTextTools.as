import flash.events.Event;
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
[Bindable]
private var font:ArrayCollection;
public function init(container:HTML):void {
		
	editableElement = container;
	var fontString:String = 
			'Andale Mono=andale mono,times;Arial=arial,helvetica,sans-serif;Arial Black=arial black,avant garde;' + 
			'Book Antiqua=book antiqua,palatino;Comic Sans MS=comic sans ms,sans-serif;' + 
			'Courier New=courier new,courier;Georgia=georgia,palatino;Helvetica=helvetica;Impact=impact,chicago;' + 
			'Symbol=symbol;Tahoma=tahoma,arial,helvetica,sans-serif;Terminal=terminal,monaco;' + 
			'Times New Roman=times new roman,times;Trebuchet MS=trebuchet ms,geneva;' + 
			'Verdana=verdana,geneva;Webdings=webdings;Wingdings=wingdings,zapf dingbats';
	var fontArray:Array = fontString.split(';');
	var fontArrayLength:uint = fontArray.length
	font = new ArrayCollection();
	for (var i:uint=0; i<fontArrayLength; i++) {
		if (fontArray[i] != '') {
			var parts:Array = fontArray[i].split('=');
			font.addItem({label:parts[0], data:parts[1]});
		}
	}
	sample = new HTMLLoader();
	sample.addEventListener(Event.HTML_DOM_INITIALIZE, cHandler);
	sample.loadString( 
		'<html><head><meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /><title>Script</title>' + 
		'<script language="javascript" type="text/javascript" src="libs/tinymce/jscripts/tiny_mce/tiny_mce_src.js"></script>' + 
		'<script>tinyMCE.init({mode : "none", theme : "advanced", browsers : "gecko", dialog_type : "modal", ' + 
		'src_mode: "_src", width:\'100%\', height:\'100%\'});</script>' + 
		'</head><body><div><textarea id="content" name="content" /></div></body></html>');
	
	//(new URLRequest('sample.html'));
}

private function cHandler(e:Event):void {
	
	sample.window.www = editableElement.domWindow.document.getElementById('xEditingArea');
	sample.addEventListener(Event.COMPLETE, compHandler);
}

private function compHandler(e:Event):void {

	sample.window.tinyMCE.execCommand("mceAddControl", true, "content");
	tinyMCE = sample.window.tinyMCE;
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