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

[Bindable] private var applicationsList:XML;
[Bindable] private var languages:Languages;

private var myLoader:URLLoader;
private var soap:Soap;
private var authentication:Authentication;

private function initalizeHandler():void {
	
	Singleton.registerClass("vdom.managers::IVdomDragManager", 
		Class(getDefinitionByName("vdom.managers::VdomDragManagerImpl")));
	
	publicData = {};
	
	var defaultLanguage:String = 'EN';
	languages = Languages.getInstance();
	languages.init(languagesTranslation, languageList, defaultLanguage);
	
	
}

private function submitLogin(event:AuthenticationEvent):void {
	
	trace('begin submitLogin');
	soap = Soap.getInstance();
	var wsdl:String= 'http://'+event.ip+'/vdom.wsdl';
	soap.init(wsdl);
	
	var username:String = event.username;
	var password:String = event.password;
	
	authentication = Authentication.getInstance();
	authentication.addEventListener(AuthenticationEvent.AUTH_COMPLETE, authComleteHandler);
	authentication.login(username, password);
}

private function authComleteHandler(event:Event):void {
	
	trace('begin authComleteHandler');
	authentication.removeEventListener(AuthenticationEvent.AUTH_COMPLETE, authComleteHandler);
	soap.addEventListener(SoapEvent.LIST_APLICATION_OK, listApplicationHandler);
	soap.listApplications();
}

private function mainInitHandler(event:Event):void {
	
	applicationListContainer.addEventListener(ListEvent.CHANGE, appChangedHandler);
	applicationListContainer.dataProvider = applicationsList.Application;
	applicationListContainer.selectedIndex = 0;
	publicData['applicationId'] = applicationListContainer.selectedItem.@id;
}

private function appChangedHandler(event:ListEvent):void {
	publicData['applicationId'] = HorizontalList(event.currentTarget).selectedItem.@id;
	publicData['topLevelObjectId'] = null;
}

private function listApplicationHandler(event:SoapEvent):void {
	
	trace('begin listApplicationHandler');
	applicationsList = event.result;
	soap.removeEventListener(SoapEvent.LIST_APLICATION_OK, listApplicationHandler);
	soap.addEventListener(SoapEvent.GET_ALL_TYPES_OK, getAllTypesHandler);
	soap.getAllTypes();
	trace('end listApplicationHandler');
}

private function getAllTypesHandler(event:SoapEvent):void {
	
	trace('begin getAllTypesHandler');
	publicData['types'] = event.result;
	soap.removeEventListener(SoapEvent.GET_ALL_TYPES_OK, getAllTypesHandler);
	languages.parseLanguageData(publicData['types']);
	
	viewstack.selectedChild=main;
	trace('end getAllTypesHandler');
}

private function changeLanguageHandler(event:Event):void {
	
	languages.changeLanguage(event.currentTarget.selectedItem.@Code);
}