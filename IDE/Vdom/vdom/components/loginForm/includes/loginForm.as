import mx.core.Application;

import vdom.Languages;
import vdom.events.AuthenticationEvent;
import flash.events.Event;
import flash.events.MouseEvent;
import mx.controls.Button;
import mx.core.UITextField;
import mx.controls.TextInput;

[Embed(source='/assets/login/vectorGraphic.swf', symbol='LoginCube')]
[Bindable]
public var loginCube:Class;

[Embed(source='/assets/login/vectorGraphic.swf', symbol='LoginTitle')]
[Bindable]
public var loginTitle:Class;

[Bindable]
private var languageList:XML;
[Bindable]
private var languages:Languages;

private var dragged:Boolean = false;

private function init():void {
	
	languageList = Application.application.languageList;
	languages = Languages.getInstance();
}

private function show():void {
	
}

private function hide():void {
		
}

private function mouseDownHdlr(event:MouseEvent):void {
	
	if(event.target is Button || event.target.parent is TextInput)
		return
			
	loginFormPanel.startDrag();
}

private function mouseUpHdlr(event:MouseEvent):void {
	
	loginFormPanel.setStyle('horizontalCenter', undefined);
	loginFormPanel.setStyle('verticalCenter', undefined);
			
	loginFormPanel.stopDrag();
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