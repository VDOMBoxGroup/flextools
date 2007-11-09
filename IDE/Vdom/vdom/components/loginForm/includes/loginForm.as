import mx.core.Application;

import vdom.Languages;
import vdom.events.AuthenticationEvent;
import flash.events.Event;


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
	
	dispatchEvent(new Event('submitBegin'));
	var ae:AuthenticationEvent = new AuthenticationEvent(AuthenticationEvent.DATA_CHANGED);
	ae.username = _username.text;
	ae.password = _password.text;
	ae.ip = _ip.text;
	dispatchEvent(ae);
}

private function changeLanguageHandler(event:Event):void {
	
	languages.changeLanguage(event.currentTarget.selectedItem.@Code);
}