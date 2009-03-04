import flash.display.Loader;

import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.events.FlexEvent;

import vdom.managers.ExternalManager;
import vdom.managers.FileManager;

private var externalEditor : DisplayObject;
private var isCreationComplete : Boolean = false;

private var _value : *;

private var _applicationID : String;
private var _objectID : String;
private var _resourceID : String;

private var loader : Loader;

public function get value() : *
{
	return _value
}

public function set value( value : * ) : void
{
	_value = value;
}

public function set applicationID( value : String ) : void
{
	_applicationID = value;
}

public function set objectID( value : String ) : void
{
	_objectID = value;
}

public function set resourceID( value : String ) : void
{
	_resourceID = value;
}

public function set resource( resource : Object ) : void
{
	if ( !resource || !resource.data )
	{
//		if ( window && !window.closed )
//			window.close();
		return ;
	}

	if ( !loader )
		loader = new Loader();

	loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loader_completeHandler );

	var loaderContext : LoaderContext = new LoaderContext();
	loaderContext.allowLoadBytesCodeExecution = true;

	loader.loadBytes( resource.data, loaderContext );
}

public function addExternalEditor( editor : DisplayObject ) : void
{
	if ( isCreationComplete )
	{
		placement.rawChildren.addChild( editor );
		selectedChild =  mainScreen;
	}
	else
	{
		externalEditor = editor;
	}
}

private function creationCompleteHandler() : void
{
	isCreationComplete = true;
	var fileManager : FileManager = FileManager.getInstance();
	fileManager.loadResource( _applicationID, _resourceID, this );
}

private function done_clickHandler() : void
{
	var closeEvent : CloseEvent = new CloseEvent( CloseEvent.CLOSE );
	dispatchEvent( closeEvent );
}

private function applCloseHandler( event : Event ) : void
{
	externalEditor.visible = false;
	
	try
	{
		//value = exEditor[ "value" ];
	}
	catch ( err : Error )
	{
		Alert.show( "External Editor doesn\"t allow to read from \"value\" property!",
					"External Editor Error!" );
	}
}

private function loader_completeHandler( event : Event ) : void
{
	loader.removeEventListener( Event.COMPLETE, loader_completeHandler );

	event.currentTarget.content.addEventListener( FlexEvent.APPLICATION_COMPLETE,
												  applicationComplete );

	addExternalEditor( loader );

//	window.width = loader.content.width;
//	window.height = loader.content.height;
//	window.addChild( externalEditor );
}

private function applicationComplete( event : Event ) : void
{
	var exEditor : Object = event.target.application;
//
//	exEditor.addEventListener( CloseEvent.CLOSE, applCloseHandler );
	
	try
	{
		exEditor[ "externalManager" ] = new ExternalManager( _applicationID, _objectID );
		exEditor[ "value" ] = _value;
	}
	catch ( err : Error )
	{
		/* error002 */
		Alert.show( "External editor returned an error. Could not execute a command.",
					"External Editor Error! (002)" );
	}
}