import flash.events.Event;
import flash.events.MouseEvent;

import mx.controls.Button;
import mx.controls.TextInput;

import vdom.events.AuthenticationEvent;
import vdom.managers.LanguageManager;

[Embed(source='/assets/login/vectorGraphic.swf', symbol='LoginCube')]
[Bindable]
public var loginCube:Class;

[Embed(source='/assets/login/vectorGraphic.swf', symbol='LoginTitle')]
[Bindable]
public var loginTitle:Class;

[Bindable]
private var languageList:XMLList;

private var languageManager:LanguageManager;

private var dragged:Boolean = false;

private function creationCompleteHandler():void {
	
	languageManager = LanguageManager.getInstance();
	
	languageList = languageManager.languageList;
	
	var currentLocale:String = languageManager.currentLocale;
	
	var currentItem:XML = languageList.(@code == currentLocale)[0]
	
	if(currentItem)
		selectLang.selectedItem = currentItem;
	
	//resourceManager.localeChain = ['ru_RU', 'en_US'];
	//resourceManager.getLocales();
	//languageList = Application.application.languageList;
	//languages = Languages.getInstance();
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

private function languageChangeHandler(event:Event):void {
	
	languageManager.changeLocale(event.currentTarget.selectedItem.@code);
}

private function checkData():void {
	
	dispatchEvent(new Event('submitBegin'));
	var ae:AuthenticationEvent = new AuthenticationEvent(AuthenticationEvent.DATA_CHANGED);
	ae.username = _username.text;
	ae.password = _password.text;
	ae.ip = _ip.text;
	dispatchEvent(ae);
}

/* private function changeLanguageHandler(event:Event):void {
	
	languages.changeLanguage(event.currentTarget.selectedItem.@Code);
} */