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
import vdom.managers.DataManager;

public var editorDataManager:DataManager;
public var publicData:Object;

[Bindable] private var applicationsList:XML;
[Bindable] private var languages:Languages;

private var myLoader:URLLoader;
private var soap:Soap;

private function initalizeHandler():void {
	
	Singleton.registerClass("vdom.managers::IVdomDragManager", 
		Class(getDefinitionByName("vdom.managers::VdomDragManagerImpl")));
		
	soap = Soap.getInstance();		
	var wsdl:String= 'http://192.168.0.24:82/vdom.wsdl';
	soap.init(wsdl);
	
	publicData = {};
	
	var defaultLanguage:String = 'EN';
	languages = Languages.getInstance();
	languages.init(languagesTranslation, defaultLanguage);
}

private function loginCreationComleteHandler(event:Event):void {
	
	var loginFormCanv:LoginForm = LoginForm(event.currentTarget);
	loginFormCanv.addEventListener(AuthenticationEvent.AUTH_COMPLETE, authComleteHandler);
}

private function authComleteHandler(event:Event):void {
	
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
	
	applicationsList = event.result;
	soap.removeEventListener(SoapEvent.LIST_APLICATION_OK, listApplicationHandler);
	soap.addEventListener(SoapEvent.GET_ALL_TYPES_OK, getAllTypesHandler);
	soap.getAllTypes();
}
	
/**
 * Получение результатов запроса всех типов. 
 * Попытка загрузить всех объектов верхнего уровня
 * @param event
 * 
 */

private function getAllTypesHandler(event:SoapEvent):void {
	
	publicData['types'] = event.result;
	soap.removeEventListener(SoapEvent.GET_ALL_TYPES_OK, getAllTypesHandler);
	
	viewstack.selectedChild=main;
}