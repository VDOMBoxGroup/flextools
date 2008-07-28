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
private var dataManager:DataManager = DataManager.getInstance();

[Bindable]
private var authenticationManager:AuthenticationManager = AuthenticationManager.getInstance();

private var languageManager:LanguageManager = LanguageManager.getInstance();

private var fileManager:FileManager = FileManager.getInstance();
private var cacheManager:CacheManager = CacheManager.getInstance();
private var soap:Soap = Soap.getInstance();


private var ppm:MyLoader;

private var tempStorage:Object = {};

public function switchToEditor():void
{
	tabPanel.selectedChild = editorModule;
}

private function changeLanguageHandler(event:Event):void
{	
	languageManager.changeLocale(event.currentTarget.selectedItem.@code);
}

private function preinitalizeHandler():void
{	
	Singleton.registerClass("vdom.managers::IVdomDragManager", 
		Class(getDefinitionByName("vdom.managers::VdomDragManagerImpl")));
	
	languageManager.init(languageList);
	cacheManager.init();
	
	soap.addEventListener(FaultEvent.FAULT, soap_faultHandler);
	dataManager.addEventListener(DataManagerEvent.CLOSE, dataManager_close);
}

private function showLoginFormHandler():void
{	
	Application.application.showStatusBar = false;
	Application.application.showGripper = false;
	Application.application.minWidth = 800;
	Application.application.minHeight = 600;
	Application.application.width = 800;
	Application.application.height = 600;
}

private function showMainHandler():void
{	
	applicationManagmentModule.dispatchEvent(new FlexEvent(FlexEvent.SHOW));
	Application.application.showStatusBar = true;
	Application.application.showGripper = true;
	Application.application.minWidth = 1000;
	Application.application.minHeight = 800;
}

private function lockStage(value:String):void
{	
	ppm = new MyLoader();
	ppm.setStyle('modalTransparencyDuration', 0);
	ppm.setStyle('modalTransparencyBlur', 0);
	ppm.setStyle('modalTransparency', 0);
	PopUpManager.addPopUp(ppm, this, true);
	PopUpManager.centerPopUp(ppm);
	ppm.showText = value;
}

private function submitLogin(event:LoginFormEvent):void
{		
	lockStage('Authentication process');
	
	var username:String = event.formData.username
	var password:String = event.formData.password
	var ip:String = event.formData.ip
	
	authenticationManager.changeAuthenticationInformation(
		username,
		password,
		ip
	)
	
	authenticationManager.addEventListener(
		AuthenticationEvent.LOGIN_COMPLETE, 
		authenticationManager_loginComleteHandler
	);
	
	authenticationManager.login();
}

private function switchToLogin():void
{
	if(tabPanel.selectedChild)
		tabPanel.selectedChild.dispatchEvent(new FlexEvent(FlexEvent.HIDE));
		
	tabPanel.selectedChild = applicationManagmentModule
	
	if(viewstack.selectedChild)
		viewstack.selectedChild.dispatchEvent(new FlexEvent(FlexEvent.HIDE));
	
	viewstack.selectedChild=loginForm;
	
	authenticationManager.changeAuthenticationInformation(null, null, null);
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
	
	ppm.showText = 'Load Types';
	
	dataManager.addEventListener(DataManagerEvent.TYPES_LOADED, dataManager_typesLoadedHandler);
	dataManager.loadTypes();	
}

private function dataManager_typesLoadedHandler(event:DataManagerEvent):void
{
	dataManager.removeEventListener(DataManagerEvent.TYPES_LOADED, dataManager_typesLoadedHandler);
	ppm.showText = '';
	PopUpManager.removePopUp(ppm);
	viewstack.selectedChild=main;
}

private function dataManager_close(event:DataManagerEvent):void
{
	switchToLogin();
}

private function soap_faultHandler(event:FaultEvent):void
{
	Alert.show(event.fault.faultString, 'Error');
	ppm.showText = '';
	PopUpManager.removePopUp(ppm);
	dataManager.close();
}