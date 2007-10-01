import flash.events.Event;

import mx.controls.Alert;
import mx.core.Application;
import mx.managers.PopUpManager;

import vdom.Languages;
import vdom.MyLoader;
import vdom.connection.soap.Soap;
import vdom.connection.soap.SoapEvent;
import vdom.events.AuthenticationEvent;

[Bindable]
private var languageList:XML;
[Bindable]
private var languages:Languages;
private var ppm:MyLoader;
private var soap:Soap;

private function init():void {
	
	soap = Soap.getInstance();
	languageList = Application.application.languageList;
	languages = Languages.getInstance();
}

private function show():void {
	
}

private function hide():void {
	
}

private function submitLogin(event:Event):void {

	soap.addEventListener(SoapEvent.LOGIN_OK, loginHandler);
	soap.addEventListener(SoapEvent.LOGIN_ERROR, loginErrorHandler);
	soap.login(username.text, password.text);
}

private function loginHandler(event:SoapEvent):void {
	
	soap.removeEventListener(SoapEvent.LOGIN_OK, loginHandler);
	dispatchEvent(new Event(AuthenticationEvent.AUTH_COMPLETE));
}

private function loginErrorHandler(event:SoapEvent):void {
	
}

private function changeLanguageHandler(event:Event):void {
	
	languages.changeLanguage(event.currentTarget.selectedItem.@id);
}