import mx.events.ListEvent;
import mx.managers.PopUpManager;
import mx.core.Singleton;

import vdom.MyLoader;
import vdom.connection.soap.Soap;
import vdom.events.AuthenticationEvent;
import vdom.events.DataManagerEvent;
import vdom.managers.Authentication;
import vdom.managers.DataManager;
import vdom.managers.LanguageManager;

[Bindable]
private var dataManager:DataManager;

private var languageManager:LanguageManager;

private var soap:Soap;
private var authentication:Authentication;

private var ppm:MyLoader;

private function initalizeHandler():void {
	
	Singleton.registerClass("vdom.managers::IVdomDragManager", 
		Class(getDefinitionByName("vdom.managers::VdomDragManagerImpl")));
	
	languageManager = LanguageManager.getInstance();
	languageManager.init(languageList);
	dataManager = DataManager.getInstance();
	
	soap = Soap.getInstance();
}

private function lockStage():void {
	
	ppm = new MyLoader();
	PopUpManager.addPopUp(ppm, this, true);
	PopUpManager.centerPopUp(ppm);
}

private function submitLogin(event:AuthenticationEvent):void {
	
	trace('begin submitLogin');
	
	var wsdl:String= 'http://'+event.ip+'/vdom.wsdl';
	
	soap.init(wsdl);
	
	var username:String = event.username;
	var password:String = event.password;
	
	authentication = Authentication.getInstance();
	authentication.addEventListener(AuthenticationEvent.LOGIN_COMPLETE, authComleteHandler);
	authentication.login(username, password);
}

private function authComleteHandler(event:Event):void {
	
	trace('begin authComleteHandler');
	authentication.removeEventListener(AuthenticationEvent.LOGIN_COMPLETE, authComleteHandler);
	
	dataManager.addEventListener(DataManagerEvent.INIT_COMPLETE, dataManagerInitComplete);//...
	dataManager.new_init();
	
	//soap.addEventListener(SoapEvent.LIST_APLICATION_OK, listApplicationHandler);
	//soap.listApplications();
}

private function dataManagerInitComplete(event:DataManagerEvent):void {
	
	viewstack.selectedChild=main;
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