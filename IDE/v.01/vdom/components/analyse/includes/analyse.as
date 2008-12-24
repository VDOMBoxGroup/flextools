import mx.controls.Alert;
import mx.core.IUITextField;
import mx.core.UIComponent;

import vdom.components.analyse.managers.DbgRenderManager;
import vdom.connection.SOAP;
import vdom.events.FileManagerEvent;
import vdom.events.SOAPEvent;
import vdom.managers.FileManager;

private var soap : SOAP = SOAP.getInstance();
private var dbgRenderManager : DbgRenderManager = DbgRenderManager.getInstance();
private var fileManager:FileManager = FileManager.getInstance();

private function _test() : void
{
	var uicomp : UIComponent;
	var txt : String = textAreaContainer.text;
	try
	{
		uicomp = dbgRenderManager.render( "", XML( txt ) );
	}
	catch( error : Error )
	{
		Alert.show( "Message: \n" + error.message, "Alert" );
		return;
	}
	
	if( !uicomp )
	{
		Alert.show( "Message: \n" + "Empty result", "Alert" );
		return;
	}
	
	res.removeAllChildren();
	res.addChild( uicomp );
	
}

private function creationCompleteHandler() : void 
{
	soap.addEventListener("loadWsdlComplete", soap_initCompleteHandler);
}

private function soap_initCompleteHandler( event : Event ) : void 
{
	soap.render_wysiwyg.addEventListener(SOAPEvent.RESULT, renderWysiwygOkHandler);
}

private function renderWysiwygOkHandler( event : SOAPEvent ) : void 
{
	try
	{
		var itemXMLDescription:XML = event.result.Result.*[0];
		textAreaContainer.text = itemXMLDescription.toString();
	}
	catch( error : Error ) {}
}

private function init():void
{
	var tf:IUITextField = textAreaContainer.mx_internal::getTextField();
	tf.alwaysShowSelection = true;
	
	fileManager.addEventListener(
		FileManagerEvent.RESOURCE_LIST_LOADED, 
		fileManager_resourceListLoaded
	);
	fileManager.getListResources();
}

private function fileManager_resourceListLoaded(event:FileManagerEvent):void
{
	fileManager.removeEventListener(
		FileManagerEvent.RESOURCE_LIST_LOADED, 
		fileManager_resourceListLoaded
	);
	
	resourceList.dataProvider = event.result.Resources.*
	resourceList.enabled = true;
}

private function insertResourceLink():void
{
	var textFiled:TextField = textAreaContainer.mx_internal::getTextField();
	var index:int = textFiled.selectionBeginIndex;
	
	textFiled.text = textFiled.text.substring(0, index) + "#Res(" + XML(resourceList.selectedItem).@id + ")" + textFiled.text.substring(index);
	textFiled.setSelection(index, index);
	textFiled.dispatchEvent( new Event( Event.CHANGE ) );
}