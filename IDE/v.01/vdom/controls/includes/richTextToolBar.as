import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.HTMLUncaughtScriptExceptionEvent;
import flash.html.HTMLLoader;

import mx.core.Application;
import mx.core.Container;
import mx.core.UIComponent;
import mx.events.ColorPickerEvent;
import mx.events.ListEvent;
import mx.managers.PopUpManager;

import vdom.containers.IItem;
import vdom.controls.richTextToolBarClasses.CharMap;
import vdom.controls.richTextToolBarClasses.CodeEditor;
import vdom.controls.richTextToolBarClasses.LinkSelection;
import vdom.controls.wysiwyg.EditableHTML;

private var HTMLEditorLoader : HTMLLoader;
//private var editableHTML : EditableHTML;
private var _selectedItem : IItem;

private var oldValue : String = "";

//private var editableHTMLLoaded : Boolean;

//private var tinyMCE : *;
//private var elementForEditing : *;

private var _selfChanged : Boolean = false;

//private var currentRange : *;
//private var isOpened : Boolean = false;

public function get selfChanged() : Boolean
{	
	return _selfChanged;
}

public function get selectedItem() : IItem 
{
	return _selectedItem;
}

public function set selectedItem( value : IItem ) : void 
{
	_selectedItem = value;
}

private function get editableHTML() : EditableHTML 
{
	var edHTML : EditableHTML;
	
	try
	{
		edHTML = _selectedItem.editableAttributes[0].sourceObject;
	}
	catch( error : Error ) {}
	
	return edHTML;
}

private function get bodyTag() : *
{
	var bdTag : *;
	try
	{
		bdTag = editableHTML.domWindow.document.getElementsByTagName( "body" )[0];
	}
	catch( error : Error ) {}
	
	return bdTag;
}

private function get tinyMCE() : * 
{
	var tnMCE : *;
	try
	{
		tnMCE = HTMLEditorLoader.window.tinyMCE;
	}
	catch( error : Error ) {}
	
	return tnMCE;
}

private function get elementForEditing() : * 
{
	var efEditing : *;
	try
	{
		efEditing = editableHTML.domWindow.document.getElementById( "xEditingArea" );
	}
	catch( error : Error ) {}
	
	return efEditing;
}

private var currentRange : *;

public function init( item : IItem ) : void
{
	trace("init");
	registerEvent( false );
	HTMLEditorLoader = null;
	HTMLEditorLoader = new HTMLLoader();
	HTMLEditorLoader.placeLoadStringContentInApplicationSandbox = true;
	
	if( !item.editableAttributes[0].sourceObject )
	{
		selectedItem = null
		return;
	}
	
	if( selectedItem && selectedItem.editableAttributes[0].sourceObject ===  item.editableAttributes[0].sourceObject )
	{
		item.editableAttributes[0].sourceObject.editabledText = oldValue;
	}
	
	selectedItem = item;
	
	/* HTMLEditorLoader.addEventListener(
		Event.HTML_DOM_INITIALIZE,
		HTMLEditorLoader_HTMLDomInitalizeHandler ); */
	
	HTMLEditorLoader.addEventListener(
		HTMLUncaughtScriptExceptionEvent.UNCAUGHT_SCRIPT_EXCEPTION,
		HTMLEditorLoader_uncaughtScriptException );
	
	//HTMLEditorLoader.addEventListener( Event.COMPLETE, HTMLEditorLoader_completeHandler );
	
	oldValue = editableHTML.editabledText;
	
	if( !editableHTML.loaded )
		editableHTML.addEventListener( Event.COMPLETE, editableHTML_completeHandler );
	else
		editableHTML_completeHandler( new Event( "true" ) );

}

public function close() : void
{	
	trace("close");
	registerEvent( false );
	
	var value : *;
	
	if( tinyMCE )
		
		if( elementForEditing )
		{
			value = tinyMCE.getContent();
		}
		else
		{
			value = editableHTML.editabledText;
		}
	else
		value = oldValue;
	
	if( !value )
	{
		if( bodyTag && bodyTag.innerText != "" )
			value = bodyTag.innerText;
	}
	
	editableHTML.editabledText = value;
	
	selectedItem.editableAttributes[0].attributes["value"] = value;
}

private function registerEvent( flag : Boolean ) : void
{	
	if( flag )
	{
		HTMLEditorLoader.addEventListener(
			Event.HTML_DOM_INITIALIZE,
			HTMLEditorLoader_HTMLDomInitalizeHandler
		);
	}
	else
	{
		if( editableHTML )
		{
			editableHTML.removeEventListener( Event.COMPLETE, editableHTML_completeHandler );
			editableHTML.removeEventListener( KeyboardEvent.KEY_UP, editableElement_KeyUpHandler );
		}
		
		if( HTMLEditorLoader )
		{
			HTMLEditorLoader.removeEventListener(
				Event.HTML_DOM_INITIALIZE,
				HTMLEditorLoader_HTMLDomInitalizeHandler );
				
			HTMLEditorLoader.removeEventListener( Event.COMPLETE, HTMLEditorLoader_completeHandler );
		}
	} 
}

private function setIFrame( iFrameValue : *, contentDocumentValue : * ) : void
{	
	if( iFrameValue )
		var iFrame : * = iFrameValue;
	
	if( contentDocumentValue )
		var contentDocument : * = contentDocumentValue;
}

private function recalculateSize() : void
{
	if( !elementForEditing || !elementForEditing.contentDocument )
		return;
		
	var hght : Number = 0;
	var chi : * = elementForEditing.contentDocument.body.lastChild;
	
	var i : uint = 0;
	while( chi[i] )
	{
		hght += chi[i].offsetHeight + chi[i].offsetTop;
		i++;
	}
	
	if( chi.offsetHeight )
		hght = chi.offsetHeight + chi.offsetTop + 15;
	else
		hght = elementForEditing.contentDocument.body.offsetHeight + elementForEditing.contentDocument.body.offsetTop + 15;
//	hght = elementForEditing.contentDocument.body.offsetHeight;
	
	//var iFrame : * = elementForEditing.contentDocument.body
	
	//var newHeight : Number = elementForEditing.contentDocument.documentElement.offsetHeight;
	
	if( editableHTML.height != hght && hght > 10 )
	{	
		editableHTML.height = hght;
		Container( selectedItem ).invalidateSize();
	}
}



private function execCommand( commandName : String, commandAttributes : String = null ) : void
{	
	tinyMCE.execCommand( commandName, false, commandAttributes );
}

private function insertLink() : void
{	
	var currentSelection : * = elementForEditing.contentWindow.getSelection();
	try
	{
		currentRange = currentSelection.getRangeAt( 0 );
	}
	catch( error : Error )
	{}
	
	var linkSelection : LinkSelection = new LinkSelection();
	linkSelection.addEventListener( "linkSelected", linkSelection_linkSelectedHandler );
	
	PopUpManager.addPopUp( linkSelection, DisplayObject( Application.application ), true );
	PopUpManager.centerPopUp( linkSelection );
}

private function linkSelection_linkSelectedHandler( event : Event ) : void
{	
	event.currentTarget.removeEventListener( "linkSelected", linkSelection_linkSelectedHandler );
	
	var currentSelection : * = elementForEditing.contentWindow.getSelection();
	currentSelection.addRange( currentRange );
	
	tinyMCE.themes["advanced"]._insertLink( event.currentTarget.url, "_blank" );
	
	PopUpManager.removePopUp( UIComponent( event.currentTarget ) );	
}

private function unLink() : void
{	
	tinyMCE.execCommand( "unlink", false );
}

private function insertChar() : void
{	
	var charMap : CharMap = new CharMap();
	charMap.addEventListener( "charSelected", charSelectedHandler );
	
	PopUpManager.addPopUp( charMap, DisplayObject( Application.application ), true );
	PopUpManager.centerPopUp( charMap );
}

private function changeFont( event : ListEvent ) : void
{	
	var val : String = fontSelector.selectedItem.data
	tinyMCE.execCommand( "FontName", false, val );
	recalculateSize();
}

private function colorFillChanged( event : ColorPickerEvent ) : void
{	
	var hexValue : String = event.color.toString( 16 ); 
	var hexLength : int = hexValue.length;
	for ( var i : int = hexLength; i < 6; i++ )
		hexValue = "0" + hexValue;
	
	tinyMCE.execCommand( "HiliteColor", false, hexValue );
}

private function colorTextChanged( event : ColorPickerEvent ) : void
{	
	var hexValue : String = event.color.toString( 16 ); 
	var hexLength : int = hexValue.length;
	
	for ( var i : int = hexLength; i < 6; i++ )
	{
		hexValue = "0" + hexValue;
	}
	
	tinyMCE.execCommand( "forecolor", false, hexValue );
}

private function charSelectedHandler( event : Event ) : void {
	
	event.currentTarget.removeEventListener( "charSelected", charSelectedHandler );
	
	tinyMCE.execCommand( "mceInsertContent", false, event.currentTarget.charCode );
	PopUpManager.removePopUp( UIComponent( event.currentTarget ) );
	recalculateSize();
}

private function openCodeEditor() : void
{	
	var codeEditor : CodeEditor = new CodeEditor();
	codeEditor.code = tinyMCE.getContent( tinyMCE.getWindowArg( "editor_id" ) );
	codeEditor.addEventListener( "updateCode", updateCodeHandler );
	
	PopUpManager.addPopUp( codeEditor, DisplayObject( Application.application ), true );
	PopUpManager.centerPopUp( codeEditor );
}

private function updateCodeHandler( event : Event ) : void
{	
	event.currentTarget.removeEventListener( "updateCode", updateCodeHandler );
	
	tinyMCE.setContent( event.currentTarget.code );
	PopUpManager.removePopUp( UIComponent( event.currentTarget ) );
	recalculateSize();
}

private function editableHTML_completeHandler( event : Event ) : void
{	
	trace( "(1)HTMLEditorLoader "+HTMLEditorLoader.name );
	editableHTML.removeEventListener( Event.COMPLETE, editableHTML_completeHandler );
	
	HTMLEditorLoader.addEventListener(
		Event.HTML_DOM_INITIALIZE,
		HTMLEditorLoader_HTMLDomInitalizeHandler );
	
	HTMLEditorLoader.addEventListener(
		Event.COMPLETE, HTMLEditorLoader_completeHandler );
	
	HTMLEditorLoader.loadString( template );
//	HTMLEditorLoader.load( new URLRequest( "app:/libs/template.html" ) );
}

private function HTMLEditorLoader_HTMLDomInitalizeHandler( event : Event ) : void
{	
	trace( "(1.5)HTMLEditorLoader " + HTMLEditorLoader.name );
	HTMLEditorLoader.removeEventListener(
		Event.HTML_DOM_INITIALIZE,
		HTMLEditorLoader_HTMLDomInitalizeHandler );
	
	if( !bodyTag )
		return;
	
	bodyTag.innerHTML = "<span id=\"xEditingArea\">" + bodyTag.innerHTML + "</span>";
	
	HTMLEditorLoader.window.elementForEditing = bodyTag.firstChild;
	HTMLEditorLoader.window.setIFrame = setIFrame;
	//HTMLEditorLoader.window.setHTML = setHTML;
}

private function HTMLEditorLoader_completeHandler( event : Event ) : void
{
	HTMLEditorLoader.removeEventListener(
		Event.COMPLETE, HTMLEditorLoader_completeHandler );
	
	if ( !tinyMCE || !HTMLEditorLoader.loaded )
	{
		trace( "alert!!!" );
		init( selectedItem );
		return;
	}
	
	trace( "(2)HTMLEditorLoader "+HTMLEditorLoader.name );
	trace( "HTMLEditorLoader_completeHandler" );
	
	tinyMCE.execCommand( "mceAddControl", true, "content" );
	
	if( !elementForEditing )
		return;
	
	elementForEditing.focus();
	
	editableHTML.addEventListener( KeyboardEvent.KEY_UP, editableElement_KeyUpHandler );
	
	var body : * = elementForEditing.contentWindow.document.getElementsByTagName( "body" )[0];
	body.style.marginLeft = "5px";
	body.style.marginRight = "5px";
	body.style.paddingTop = "5px";
	body.style.paddingBottom = "5px";
	
//	var dummy : * = HTMLEditorLoader.window.document.getElementById("bodyTag");
	
	callLater( recalculateSize );
}

private function HTMLEditorLoader_uncaughtScriptException( 
	event : HTMLUncaughtScriptExceptionEvent ) : void 
{
	var dummy : * = "";
}

private function editableElement_KeyUpHandler( event : KeyboardEvent ) : void
{	
	recalculateSize();
}