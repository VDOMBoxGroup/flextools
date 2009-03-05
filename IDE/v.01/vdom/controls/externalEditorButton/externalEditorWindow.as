import flash.display.DisplayObject;
import flash.display.Loader;
import flash.events.Event;

import mx.controls.Alert;
import mx.core.EdgeMetrics;
import mx.core.Window;
import mx.events.CloseEvent;
import mx.events.FlexEvent;

import vdom.managers.ExternalManager;
import vdom.managers.FileManager;

private var isCreationComplete : Boolean = false;

private var _value : *;

private var _applicationID : String;
private var _objectID : String;
private var _resourceID : String;

private var loader : Loader;

private var externalEditor : DisplayObject;

private var window : Window;

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

private function addExternalEditor( editor : Loader ) : void
{
	if ( isCreationComplete )
	{
		placement.width = editor.contentLoaderInfo.width;
		placement.height = editor.contentLoaderInfo.height;
		
//		editor.mask = null;
		placement.rawChildren.addChild( editor );
		selectedChild =  mainScreen;
	}
	else
	{
		externalEditor = editor;
	}
}

private function closeEditor() : void 
{
	try
	{
		value = externalEditor[ "value" ];
	}
	catch( error : Error ) {}
	
	dispatchEvent( new CloseEvent( CloseEvent.CLOSE ) );
	if( window && !window.closed )
		window.close();
}

override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
{
	super.updateDisplayList( unscaledWidth, unscaledHeight );
	if( window )
	{
		var vm : EdgeMetrics = window.viewMetricsAndPadding;
		window.width = mainScreen.measuredWidth + vm.left + vm.right;
		window.height = mainScreen.measuredHeight + vm.top + vm.bottom;
	}
}

private function creationCompleteHandler() : void
{
	isCreationComplete = true;
	var fileManager : FileManager = FileManager.getInstance();
	fileManager.loadResource( _applicationID, _resourceID, this );
	
	window = Window.getWindow( this );
	window.addEventListener( Event.CLOSE, window_closeHandler )
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
	externalEditor = event.target.application;
	externalEditor.addEventListener( CloseEvent.CLOSE, externalEditor_closeHandler );
	
	try
	{
		externalEditor[ "externalManager" ] = new ExternalManager( _applicationID, _objectID );
		externalEditor[ "value" ] = _value;
	}
	catch ( err : Error )
	{
		/* error002 */
		Alert.show( "External editor returned an error. Could not execute a command.",
					"External Editor Error! (002)" );
	}
}

private function done_clickHandler() : void
{
	closeEditor();
}

private function window_closeHandler( event : Event ) : void 
{
	closeEditor();
}

private function externalEditor_closeHandler( event : CloseEvent ) : void 
{
	closeEditor();
}