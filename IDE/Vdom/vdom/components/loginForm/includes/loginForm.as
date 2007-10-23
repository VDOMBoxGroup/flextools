import mx.core.Application;

import vdom.Languages;
import vdom.events.AuthenticationEvent;


[Bindable]
private var languageList:XML;
[Bindable]
private var languages:Languages;

private function init():void {
	
	languageList = Application.application.languageList;
	languages = Languages.getInstance();
}

private function show():void {
	
}

private function hide():void {
		
}

private function checkData():void {
	
	var ae:AuthenticationEvent = new AuthenticationEvent(AuthenticationEvent.AUTH_DATA_CHANGED);
	ae.username = _username.text;
	ae.password = _password.text;
	ae.ip = _ip.text;
	dispatchEvent(ae);
}

private function changeLanguageHandler(event:Event):void {
	
	languages.changeLanguage(event.currentTarget.selectedItem.@Code);
}