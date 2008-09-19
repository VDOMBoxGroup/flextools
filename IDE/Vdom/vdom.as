import flash.events.Event;

import mx.controls.Alert;
import mx.core.Application;
import mx.core.Singleton;
import mx.core.UIComponent;
import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;
import mx.managers.PopUpManager;
import mx.rpc.Fault;
import mx.rpc.events.FaultEvent;

import vdom.connection.SOAP;
import vdom.events.AuthenticationEvent;
import vdom.events.DataManagerErrorEvent;
import vdom.events.DataManagerEvent;
import vdom.events.LoginFormEvent;
import vdom.managers.AlertManager;
import vdom.managers.AuthenticationManager;
import vdom.managers.CacheManager;
import vdom.managers.DataManager;
import vdom.managers.FileManager;
import vdom.managers.LanguageManager;
import vdom.utils.StringUtil;

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

private var soap:SOAP = SOAP.getInstance();

private var tempStorage:Object = {};

public function switchToModule(moduleName:String):void
{
	switch(moduleName.toLowerCase())
	{
		case "applicationmanagment":
		{
			moduleTabNavigator.selectedChild = applicationManagmentModule;
			break;	
		}
		
		case "editor":
		{
			moduleTabNavigator.selectedChild = editorModule;
			break;
		}
	}
}

private function switchToLogin():void
{
	if(viewstack)
	{ 
		if(viewstack.selectedChild != loginForm)
			moduleTabNavigator.selectedChild.dispatchEvent(new FlexEvent(FlexEvent.HIDE));
		
		viewstack.selectedChild = loginForm;
	}
}

private function checkError(fault:Fault):void
{
	var errorCode:String = StringUtil.getLocalName(fault.faultCode);
	
	switch(errorCode)
	{
		case "i101":
		{
			
			break;
		}
		case "203":
		{
			switchToModule("applicationmanagment");
			break;
		}
		default :
		{
			dataManager.close();
			break;
		}
	}
	
	alertManager.showAlert(fault.faultString);
	alertManager.showMessage("");
}

private function preinitalizeHandler():void
{	
	Singleton.registerClass("vdom.managers::IVdomDragManager", 
		Class(getDefinitionByName("vdom.managers::VdomDragManagerImpl")));
	
	languageManager.init(languageList);
	cacheManager.init();
	
	dataManager.addEventListener(DataManagerEvent.CLOSE, dataManager_close);
	dataManager.addEventListener(DataManagerErrorEvent.GLOBAL_ERROR, dataManager_globalErrorHandler);
	
	soap.addEventListener(FaultEvent.FAULT, soap_faultHandler);
}

private function creationCompleteHandler():void
{
	moduleTabNavigator.addEventListener(IndexChangedEvent.CHANGE, moduleChangedHandler);
}

private function moduleChangedHandler(event:IndexChangedEvent):void
{
	while(systemManager.popUpChildren.numChildren > 0)
	{
		PopUpManager.removePopUp(UIComponent(systemManager.popUpChildren.getChildAt(0)));
	}
	
	/* for (var i:int = systemManager.numChildren-1; i>=0; i–-)
	{
		if(getQualifiedClassName(systemManager.getChildAt(i))=="Popup"){
			systemManager.removeChildAt(i);
		}
	} */
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
	
//	userName.text = "USER: " + authenticationManager.username.toUpperCase()+ " - VDOM IDE";
}

private function changeLanguageHandler(event:Event):void
{	
	languageManager.changeLocale(event.currentTarget.selectedItem.@code);
}

private function submitBeginHandler(event:LoginFormEvent):void
{	
	alertManager.showMessage("Authentication process");
	
	var hostname:String = event.formData.hostname;
	
	tempStorage = event.formData;
	
	var wsdl:String = "http://" + hostname + "/vdom.wsdl";
	soap.addEventListener("loadWsdlComplete", soap_initCompleteHandler);
	soap.init(wsdl);
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
private function authenticationManager_loginErrorHandler(event:Event):void
{
	authenticationManager.addEventListener(
		AuthenticationEvent.LOGIN_ERROR, 
		authenticationManager_loginErrorHandler
	);
	
	Alert.show("Login Error", "Login Error");
	alertManager.showMessage("");
	dataManager.close();
}
private function dataManager_initCompleteHandler(event:DataManagerEvent):void
{
	dataManager.removeEventListener(DataManagerEvent.INIT_COMPLETE, dataManager_initCompleteHandler);
	
	alertManager.showMessage("Load Types");
	
	dataManager.addEventListener(DataManagerEvent.LOAD_TYPES_COMPLETE, dataManager_typesLoadedHandler);
	dataManager.loadTypes();	
}

private function dataManager_typesLoadedHandler(event:DataManagerEvent):void
{
	dataManager.removeEventListener(DataManagerEvent.LOAD_TYPES_COMPLETE, dataManager_typesLoadedHandler);
	alertManager.showMessage("");
	
	languageManager.parseLanguageData(dataManager.listTypes);
	
	viewstack.selectedChild = main;
	
	if(moduleTabNavigator)
	{
		if(moduleTabNavigator.selectedIndex != 0)
			moduleTabNavigator.selectedIndex = 0;
		else
			moduleTabNavigator.selectedChild.dispatchEvent(new FlexEvent(FlexEvent.SHOW));
	}
}

private function dataManager_close(event:DataManagerEvent):void
{
	switchToLogin();
}

private function soap_initCompleteHandler(event:Event):void
{
	fileManager.init();
	
	var username:String = tempStorage.username;
	var password:String = tempStorage.password;
	var hostname:String = tempStorage.hostname;
	
	authenticationManager.addEventListener(
		AuthenticationEvent.LOGIN_COMPLETE,
		authenticationManager_loginComleteHandler
	);
	
	authenticationManager.addEventListener(
		AuthenticationEvent.LOGIN_ERROR, 
		authenticationManager_loginErrorHandler
	);
	
	authenticationManager.login(hostname, username, password);
}

private function logoutHandler():void
{
	if(moduleTabNavigator && moduleTabNavigator.selectedChild)
		moduleTabNavigator.selectedChild.dispatchEvent(new FlexEvent(FlexEvent.HIDE));
	dataManager.close();
} 

private function soap_faultHandler(event:FaultEvent):void
{
	checkError(event.fault);
}

private function dataManager_globalErrorHandler(event:DataManagerErrorEvent):void
{
	checkError(event.fault);
	
}