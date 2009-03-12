import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.net.SharedObject;

import mx.controls.Button;
import mx.controls.TextInput;
import mx.events.FlexEvent;

import vdom.events.LoginFormEvent;
import vdom.managers.LanguageManager;

[Embed( source="/assets/login/vectorGraphic.swf", symbol = "LoginCube" )]
[Bindable]
private var loginCube : Class;

[Embed( source="/assets/login/vectorGraphic.swf", symbol = "LoginTitle" )]
[Bindable]
private var loginTitle : Class;

[Bindable]
private var languageList : XMLList;

private var languageManager : LanguageManager = LanguageManager.getInstance();

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

private function checkData() : void
{
	var lfe : LoginFormEvent = new LoginFormEvent( LoginFormEvent.SUBMIT_BEGIN );
	lfe.formData = { username : _username.text, password : _password.text, hostname : _hostname.text };
	var so : SharedObject = SharedObject.getLocal( "userData" );
	so.data[ "username" ] = _username.text;
//	so.data["password"] = _password.text;
	so.data[ "hostname" ] = _hostname.text;

	if ( selectLang.selectedItem )
	{
		so.data[ "locale" ] = languageManager.currentLocale;
	}

	dispatchEvent( lfe );
}

private function creationCompleteHandler() : void
{
	languageList = languageManager.languageList;

	_isListenersEnabled = false;

	dispatchEvent( new FlexEvent( FlexEvent.SHOW ) );
}

private function showHandler() : void
{
	registerEvents( true );
	_username.setFocus();

	var so : SharedObject = SharedObject.getLocal( "userData" );

	_username.text = so.data[ "username" ];
//	_password.text = so.data["password"];
	_hostname.text = so.data[ "hostname" ];

	var currentLocale : String = so.data[ "locale" ];

	var currentItem : XML = languageList.( @code == currentLocale )[ 0 ];

	if ( currentItem )
	{
		languageManager.changeLocale( currentLocale );
	}
	else
	{
		currentLocale = languageManager.currentLocale;
		currentItem = languageList.( @code == currentLocale )[ 0 ]
	}

	if ( currentItem )
		selectLang.selectedItem = currentItem;
}

private function hideHandler() : void
{
	registerEvents( false );

	_username.text = "";
	_password.text = "";
	_hostname.text = "";
}

private function selectLang_changeHandler( event : Event ) : void
{
	languageManager.changeLocale( event.currentTarget.selectedItem.@code );
}

private function loginForm_keyDownHandler( event : KeyboardEvent ) : void
{
	if ( event.keyCode == 13 )
		checkData();
}

private function submitButton_clickHandler() : void
{
	checkData();
}

private function quitButton_clickHandler() : void
{
	var lfe : LoginFormEvent = new LoginFormEvent( LoginFormEvent.QUIT );
	dispatchEvent( lfe );
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