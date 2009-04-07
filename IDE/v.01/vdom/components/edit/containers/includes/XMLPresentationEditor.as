import mx.controls.Alert;
import mx.events.FlexEvent;

import vdom.events.DataManagerErrorEvent;
import vdom.events.DataManagerEvent;
import vdom.events.EditAreaEvent;
import vdom.events.SOAPEvent;
import vdom.managers.DataManager;

private var _objectId : String

public function set objectId( value : String ) : void
{
	_objectId = value;

	if ( !visible )
		return;

	if ( _objectId )
	{
		enableElement( false );
		loadXMLPresentation();
	}
}

private var dataManager : DataManager = DataManager.getInstance();

private var _enabledElements : Boolean;

private function initalizeHandler() : void
{
	_enabledElements = true;
}

private function loadXMLPresentation() : void
{
	if ( _objectId )
		dataManager.getObjectScriptPresentation();
}

private function registerEvent( flag : Boolean ) : void
{
	if ( flag )
	{
		editArea.addEventListener( EditAreaEvent.SAVE, editArea_saveHandler );

		dataManager.addEventListener( DataManagerEvent.GET_OBJECT_SCRIPT_PRESENTATION_COMPLETE,
									  dataManager_getObjectScriptPresentationCompleteHandler );

		dataManager.addEventListener( DataManagerEvent.SUBMIT_OBJECT_SCRIPT_PRESENTATION_COMPLETE,
									  dataManager_submitObjectScriptPresentationCompleteHandler );

		dataManager.addEventListener( DataManagerErrorEvent.SUBMIT_OBJECT_SCRIPT_PRESENTATION_ERROR,
									  dataManager_submitObjectScriptPresentationErrorHandler );


	}
	else
	{
		editArea.removeEventListener( EditAreaEvent.SAVE, editArea_saveHandler );

		dataManager.removeEventListener( DataManagerEvent.GET_OBJECT_SCRIPT_PRESENTATION_COMPLETE,
										 dataManager_getObjectScriptPresentationCompleteHandler );

		dataManager.removeEventListener( DataManagerEvent.SUBMIT_OBJECT_SCRIPT_PRESENTATION_COMPLETE,
										 dataManager_submitObjectScriptPresentationCompleteHandler );

		dataManager.removeEventListener( DataManagerErrorEvent.SUBMIT_OBJECT_SCRIPT_PRESENTATION_ERROR,
										 dataManager_submitObjectScriptPresentationErrorHandler );
	}
}

private function showHandler() : void
{
	editArea.dispatchEvent( new FlexEvent( FlexEvent.SHOW ) );
	enableElement( false );
	registerEvent( true );
	editArea.enabled = true;
	if ( _objectId )
	{
		//saveButton.label = "Loading..."
		editArea.enabled = false;
		loadXMLPresentation();
	}
}

private function hideHandler() : void
{

	editArea.dispatchEvent( new FlexEvent( FlexEvent.HIDE ) );
	registerEvent( false );
	enableElement( false );
	//scriptEditor.code = "";
}

private function editArea_saveHandler( ...arg ) : void
{
	if ( !editArea.content )
	{
		Alert.show( "Empty description", "Alert" );
		return;
	}
	enableElement( false );
	//saveButton.label = "Saving...";
	var code : String = editArea.content;
	dataManager.submitObjectScriptPresentation( code );
}

private function dataManager_getObjectScriptPresentationCompleteHandler( event : DataManagerEvent ) : void
{

	XML.prettyPrinting = true;
	XML.prettyIndent = 4;
	var result : String = event.result[ 0 ].toXMLString();
	editArea.content = result;
	//saveButton.label = "Save";
	editArea.enabled = true;
	enableElement( true );
}

private function dataManager_submitObjectScriptPresentationErrorHandler( event : DataManagerErrorEvent ) : void
{
	Alert.show( "Wrong data", "Alert" );
	if ( _objectId )
	{
		//saveButton.label = "Loading..."
		editArea.enabled = false;
		loadXMLPresentation();
	}
	else
	{
		editArea.content = "";
	}

}

private function dataManager_submitObjectScriptPresentationCompleteHandler( event : DataManagerEvent ) : void
{
	if ( event is SOAPEvent && SOAPEvent( event ).result.Error[ 0 ] )
		Alert.show( "Data not saved.", "Description Error" );

	enableElement( true );
	//saveButton.label = "Save";
}

private function enableElement( flag : Boolean ) : void
{

	if ( flag )
	{

		//saveButton.enabled = true;
		editArea.enabled = true;

	}
	else
	{

		//saveButton.enabled = false;
		editArea.enabled = false;
	}
}