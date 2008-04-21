import flash.events.Event;
import flash.events.MouseEvent;

import mx.controls.Button;
import mx.controls.TextInput;
import mx.core.IWindow;

import vdom.components.loginForm.events.LoginFormEvent;
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

private function get window():IWindow {
				
	return IWindow(Application.application);
}

private function creationCompleteHandler():void {
	
	addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
	
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
	
	event.stopImmediatePropagation();
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
	
	var lfe:LoginFormEvent = new LoginFormEvent(LoginFormEvent.SUBMIT_BEGIN);
	lfe.formData = {
		username:_username.text, 
		password:_password.text, 
		ip:_ip.text
	};
	
	dispatchEvent(lfe);
}

private function mouseDownHandler(event:MouseEvent):void {
	if(event.target == this) {
			
		window.nativeWindow.startMove();
		event.stopPropagation();
	}
}

/* private function changeLanguageHandler(event:Event):void {
	
	languages.changeLanguage(event.currentTarget.selectedItem.@Code);
} */