import flash.display.DisplayObject;
import flash.events.Event;

import mx.collections.XMLListCollection;
import mx.containers.Canvas;
import mx.controls.Alert;
import mx.controls.HorizontalList;
import mx.core.IFlexDisplayObject;
import mx.core.Singleton;
import mx.events.ListEvent;
import mx.managers.PopUpManager;

import vdom.Languages;
import vdom.MyLoader;
import vdom.components.loginForm.LoginForm;
import vdom.connection.soap.Soap;
import vdom.connection.soap.SoapEvent;
import vdom.events.AuthenticationEvent;
import vdom.managers.Authentication;
import vdom.managers.DataManager;

public var editorDataManager:DataManager;
public var publicData:Object;

[Bindable] private var listApplication:XML;
[Bindable] private var languages:Languages;

private var myLoader:URLLoader;
private var soap:Soap;
private var authentication:Authentication;
private var ppm:MyLoader;
private function initalizeHandler():void {
	
	Singleton.registerClass("vdom.managers::IVdomDragManager", 
		Class(getDefinitionByName("vdom.managers::VdomDragManagerImpl")));
	
	languages = Languages.getInstance();
	soap = Soap.getInstance();
	
	publicData = {};
	var defaultLanguage:String = 'EN';
	
	var wsdl:String= 'http://'+'127.0.0.1:81'+'/vdom.wsdl';
	//var wsdl:String= 'http://'+event.ip+'/vdom.wsdl';
	//soap.init(wsdl);
	
	languages.init(languagesTranslation, languageList, defaultLanguage);
	
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
	soap.addEventListener(SoapEvent.LIST_APLICATION_OK, listApplicationHandler);
	soap.listApplications();
}

private function mainInitHandler(event:Event):void {
	
	//applicationListContainer.selectedIndex = 0;
	publicData['applicationId'] = applicationListContainer.applicationID;
}

private function appChangedHandler(event:ListEvent):void {
	publicData['applicationId'] = applicationListContainer.applicationID;
	publicData['topLevelObjectId'] = null;
}

private function listApplicationHandler(event:SoapEvent):void {
	
	trace('begin listApplicationHandler');
	listApplication = event.result;
	soap.removeEventListener(SoapEvent.LIST_APLICATION_OK, listApplicationHandler);
	soap.addEventListener(SoapEvent.GET_ALL_TYPES_OK, getAllTypesHandler);
	soap.getAllTypes();
	trace('end listApplicationHandler');
}

private function getAllTypesHandler(event:SoapEvent):void {
	
	trace('begin getAllTypesHandler');
	publicData['types'] = event.result;
	//trace(publicData['types'])
	soap.removeEventListener(SoapEvent.GET_ALL_TYPES_OK, getAllTypesHandler);
	languages.parseLanguageData(publicData['types']);
	
	viewstack.selectedChild=main;
	
	PopUpManager.removePopUp(ppm);
	trace('end getAllTypesHandler');
}

private function changeLanguageHandler(event:Event):void {
	
	languages.changeLanguage(event.currentTarget.selectedItem.@Code);
}