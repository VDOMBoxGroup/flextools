import flash.events.Event;

import mx.controls.Alert;
import mx.core.Application;
import mx.events.FlexEvent;
import mx.rpc.events.FaultEvent;

import vdom.connection.soap.Soap;
import vdom.events.AuthenticationEvent;
import vdom.events.DataManagerEvent;
import vdom.events.LoginFormEvent;
import vdom.managers.AlertManager;
import vdom.managers.AuthenticationManager;
import vdom.managers.CacheManager;
import vdom.managers.DataManager;
import vdom.managers.FileManager;
import vdom.managers.LanguageManager;

[Embed(source="/assets/main/vdom_logo.png")]
[Bindable]
public var vdomLogo:Class;

[Bindable]
private var dataManager:DataManager = DataManager.getInstance();

[Bindable]
private var authenticationManager:AuthenticationManager = AuthenticationManager.getInstance();

private var languageManager:LanguageManager = LanguageManager.getInstance();

private var fileManager:FileManager = FileManager.getInstance();
private var cacheManager:CacheManager = CacheManager.getInstance();
private var alertManager:AlertManager= AlertManager.getInstance();

private var soap:Soap = Soap.getInstance();

private var tempStorage:Object = {};

private function changeLanguageHandler(event:Event):void
{	
	languageManager.changeLocale(event.currentTarget.selectedItem.@code);
}

private function preinitalizeHandler():void
{	
	languageManager.init(languageList);
	cacheManager.init();
	
	dataManager.addEventListener(DataManagerEvent.CLOSE, dataManager_close);
}

private function showLoginFormHandler():void
{	
	Application.application.nativeWindow.restore();
	Application.application.showStatusBar = false;
	Application.application.showGripper = false;
	Application.application.minWidth = 800;
	Application.application.minHeight = 600;
	Application.application.width = 800;
	Application.application.height = 600;
}

private function showMainHandler():void
{	
	Application.application.showStatusBar = true;
	Application.application.showGripper = true;
	Application.application.minWidth = 1000;
	Application.application.minHeight = 800;
}

private function submitLogin(event:LoginFormEvent):void
{	
	soap.addEventListener(FaultEvent.FAULT, soap_faultHandler);
	alertManager.showMessage("Authentication process");
	
	var hostname:String = event.formData.hostname;
	
	tempStorage = event.formData;
	
	var wsdl:String = "http://" + hostname + "/vdom.wsdl";
	soap.addEventListener("loadWsdlComplete", soap_initCompleteHandler);
	soap.init(wsdl);
}

private function switchToLogin():void
{	
	if(viewstack)
	{ 
		if(viewstack.selectedChild)
			viewstack.selectedChild.dispatchEvent(new FlexEvent(FlexEvent.HIDE));
		
		viewstack.selectedChild = loginForm;
	}
}

private function soap_initCompleteHandler(event:Event):void
{
	var username:String = tempStorage.username
	var password:String = tempStorage.password
	var hostname:String = tempStorage.ip
	
	authenticationManager.addEventListener(
		AuthenticationEvent.LOGIN_COMPLETE, 
		authenticationManager_loginComleteHandler
	);
	//сделать проверку error;
	authenticationManager.login(hostname, username, password);
}

private function authenticationManager_loginComleteHandler(event:Event):void
{	
	authenticationManager.removeEventListener(
		AuthenticationEvent.LOGIN_COMPLETE, 
		authenticationManager_loginComleteHandler
	);
	
	dataManager.addEventListener(DataManagerEvent.INIT_COMPLETE, dataManager_initCompleteHandler);
	dataManager.init();
}

private function dataManager_initCompleteHandler(event:DataManagerEvent):void
{
	dataManager.removeEventListener(DataManagerEvent.INIT_COMPLETE, dataManager_initCompleteHandler);
	
	alertManager.showMessage("Load Types");
	
	dataManager.addEventListener(DataManagerEvent.TYPES_LOADED, dataManager_typesLoadedHandler);
	dataManager.loadTypes();	
}

private function dataManager_typesLoadedHandler(event:DataManagerEvent):void
{
	dataManager.removeEventListener(DataManagerEvent.TYPES_LOADED, dataManager_typesLoadedHandler);
	alertManager.showMessage("");
	viewstack.selectedChild = main;
}

private function dataManager_close(event:DataManagerEvent):void
{
	switchToLogin();
}
	
private function soap_faultHandler(event:FaultEvent):void
{
	Alert.show(event.fault.faultString, "Error");
	soap.removeEventListener(FaultEvent.FAULT, soap_faultHandler);
	alertManager.showMessage("");
	dataManager.close();
}