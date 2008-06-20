import flash.events.Event;

import mx.core.Application;
import mx.core.Singleton;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;

import vdom.MyLoader;
import vdom.components.loginForm.events.LoginFormEvent;
import vdom.connection.soap.Soap;
import vdom.events.AuthenticationEvent;
import vdom.events.DataManagerEvent;
import vdom.managers.AuthenticationManager;
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
private var soap:Soap;


private var ppm:MyLoader;

private var tempStorage:Object;

private function applicationCompleteHandler():void {
	
	//this.stage.nativeWindow.maximize();
}

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
	
	languageManager.init(languageList);
	
	tempStorage = {};
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
	PopUpManager.addPopUp(ppm, this, true);
	PopUpManager.centerPopUp(ppm);
}

private function submitLogin(event:LoginFormEvent):void {
	
	trace('begin submitLogin');
	
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
	
	trace('begin authComleteHandler');
	authenticationManager.removeEventListener(AuthenticationEvent.LOGIN_COMPLETE, authComleteHandler);
	
	dataManager.addEventListener(DataManagerEvent.INIT_COMPLETE, dataManagerInitComplete);
	dataManager.init();
}

private function dataManagerInitComplete(event:DataManagerEvent):void {
	
	dataManager.removeEventListener(DataManagerEvent.INIT_COMPLETE, dataManagerInitComplete);
	viewstack.selectedChild=main;
	//applicationManagmentModule.dispatchEvent(new FlexEvent(FlexEvent.SHOW));
	PopUpManager.removePopUp(ppm);
}

/* private function mainInitHandler(event:Event):void {
	
	//applicationListContainer.selectedIndex = 0;
	//publicData['applicationId'] = applicationListContainer.applicationID;
} */

/* private function applicationChangedHandler(event:ListEvent):void {
	
	dataManager.changeApplication(listApplicationContainer.applicationID);
} */

/* private function listApplicationHandler(event:SoapEvent):void {
	
	trace('begin ;Handler');
	listApplication = event.result;
	publicData['applicationId'] = listApplication.Application[0].@id.toString();
	
	soap.removeEventListener(SoapEvent.LIST_APLICATION_OK, listApplicationHandler);
	soap.addEventListener(SoapEvent.GET_ALL_TYPES_OK, getAllTypesHandler);
	soap.getAllTypes();
	trace('end listApplicationHandler');
} */

/* private function getAllTypesHandler(event:SoapEvent):void {
	
	trace('begin getAllTypesHandler');
	publicData['types'] = event.result;
	//trace(publicData['types'])
	soap.removeEventListener(SoapEvent.GET_ALL_TYPES_OK, getAllTypesHandler);
	languages.parseLanguageData(publicData['types']);
	
	viewstack.selectedChild=main;
	
	PopUpManager.removePopUp(ppm);
	trace('end getAllTypesHandler');
} */

/* private function changeLanguageHandler(event:Event):void {
	
	languages.changeLanguage(event.currentTarget.selectedItem.@Code);
} */