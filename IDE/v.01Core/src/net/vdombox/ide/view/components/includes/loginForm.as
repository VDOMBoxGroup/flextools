import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.net.SharedObject;

import mx.controls.Button;
import mx.controls.TextInput;
import mx.events.FlexEvent;

[Embed( source="/assets/login/vectorGraphic.swf", symbol = "LoginCube" )]
[Bindable]
private var loginCube : Class;

[Embed( source="/assets/login/vectorGraphic.swf", symbol = "LoginTitle" )]
[Bindable]
private var loginTitle : Class;

private var dragged : Boolean = false;

private var _isListenersEnabled : Boolean;

private function registerEvents( flag : Boolean ) : void
{
	if ( flag == _isListenersEnabled )
		return;

	if ( flag )
	{

//		addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
		addEventListener( KeyboardEvent.KEY_DOWN, loginForm_keyDownHandler );
		_isListenersEnabled = true;

	}
	else
	{

//		removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		removeEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
		removeEventListener( KeyboardEvent.KEY_DOWN, loginForm_keyDownHandler );
		_isListenersEnabled = false;
	}
}

private function hideHandler() : void
{
	registerEvents( false );

	username.text = "";
	password.text = "";
	hostname.text = "";
}

private function loginForm_keyDownHandler( event : KeyboardEvent ) : void
{
//	if ( event.keyCode == 13 )
//		checkData();
}

private function mouseDownHandler( event : MouseEvent ) : void
{

	if ( event.target is Button || event.target.parent is TextInput )
		return;
		
	stage.nativeWindow.startMove();

	event.stopImmediatePropagation();
}

private function mouseUpHandler( event : MouseEvent ) : void
{
	loginFormPanel.setStyle( "horizontalCenter", undefined );
	loginFormPanel.setStyle( "verticalCenter", undefined );
}