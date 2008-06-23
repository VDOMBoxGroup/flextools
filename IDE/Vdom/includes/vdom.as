import flash.events.Event;

import mx.controls.Alert;
import mx.core.Application;
import mx.core.Singleton;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;

import vdom.MyLoader;
import vdom.components.loginForm.events.LoginFormEvent;
import vdom.connection.soap.Soap;
import vdom.events.AuthenticationEvent;
import vdom.events.DataManagerEvent;
import vdom.managers.AuthenticationManager;
import vdom.managers.CacheManager;
import vdom.managers.DataManager;
import vdom.managers.FileManager;
import vdom.managers.LanguageManager;

[Embed(source='/assets/main/vdom_logo.png')]
[Bindable]
public var vdomLogo:Class;

[Bindable]
private var dataManager:DataManager;

private var languageManager:LanguageManager;
private var authenticationManager:AuthenticationManager;
private var fileManager:FileManager;
private var cacheManager:CacheManager;
private var soap:Soap;


private var ppm:MyLoader;

private var tempStorage:Object;

private function changeLanguageHandler(event:Event):void {
	
	languageManager.changeLocale(event.currentTarget.selectedItem.@code);
}

private function preinitalizeHandler():void {
	
	Singleton.registerClass("vdom.managers::IVdomDragManager", 
		Class(getDefinitionByName("vdom.managers::VdomDragManagerImpl")));
	
	authenticationManager = AuthenticationManager.getInstance();
	languageManager = LanguageManager.getInstance();
	dataManager = DataManager.getInstance();
	soap = Soap.getInstance();
	fileManager = FileManager.getInstance();
	cacheManager = CacheManager.getInstance();
	
	languageManager.init(languageList);
	cacheManager.init();
	
	tempStorage = {};
	
	soap.addEventListener(FaultEvent.FAULT, soap_faultHandler);
}

private function showLoginFormHandler():void {
	
	Application.application.showStatusBar = false;
	Application.application.showGripper = false;
	Application.application.minWidth = 800;
	Application.application.minHeight = 600;
	Application.application.width = 800;
	Application.application.height = 600;
}

private function showMainHandler():void {
	
	applicationManagmentModule.dispatchEvent(new FlexEvent(FlexEvent.SHOW));
	Application.application.showStatusBar = true;
	Application.application.showGripper = true;
	Application.application.minWidth = 1000;
	Application.application.minHeight = 800;
}

private function lockStage():void {
	
	ppm = new MyLoader();
	ppm.setStyle('modalTransparencyDuration', 0);
	ppm.setStyle('modalTransparencyBlur', 0);
	ppm.setStyle('modalTransparency', 0);
	PopUpManager.addPopUp(ppm, this, true);
	PopUpManager.centerPopUp(ppm);
}

private function submitLogin(event:LoginFormEvent):void {
		
	lockStage();
	
	var username:String = event.formData.username
	var password:String = event.formData.password
	var ip:String = event.formData.ip
	
	authenticationManager.changeAuthenticationInformation(
		username,
		password,
		ip
	)
	
	authenticationManager.addEventListener(AuthenticationEvent.LOGIN_COMPLETE, authComleteHandler);
	authenticationManager.login();
}

private function authComleteHandler(event:Event):void {
	
	authenticationManager.removeEventListener(AuthenticationEvent.LOGIN_COMPLETE, authComleteHandler);
	
	dataManager.addEventListener(DataManagerEvent.INIT_COMPLETE, dataManagerInitComplete);
	dataManager.init();
}

private function dataManagerInitComplete(event:DataManagerEvent):void {
	
	dataManager.removeEventListener(DataManagerEvent.INIT_COMPLETE, dataManagerInitComplete);
	viewstack.selectedChild=main;
	PopUpManager.removePopUp(ppm);
}

private function soap_faultHandler(event:FaultEvent):void {
	
	Alert.show(event.fault.faultString, 'Error');
	
	PopUpManager.removePopUp(ppm);
	dataManager.close();
	authenticationManager.changeAuthenticationInformation(null, null, null);
	viewstack.selectedChild=loginForm;
}