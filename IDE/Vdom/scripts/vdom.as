import flash.display.DisplayObject;
import flash.events.Event;
import mx.managers.PopUpManager;
import mx.events.ListEvent;
import mx.core.IFlexDisplayObject;
import mx.core.Singleton;
import mx.containers.Canvas;
import mx.controls.List;
import mx.controls.Alert;
import mx.collections.XMLListCollection;

import vdom.managers.DataManager;
import vdom.connection.soap.SoapEvent;
import vdom.connection.soap.Soap;
import vdom.events.AuthEvent;
import vdom.MyLoader;
import vdom.Auth;
import vdom.Lang;

public var editorDataManager:DataManager;
public var publicData:Object;

[Bindable] private var XMLanguage:XML;
[Bindable] private var myXMLLC:XMLListCollection;
[Bindable] private var mtAuth:Auth;
[Bindable] private var mtLang:Lang;
[Bindable] private var applicationsList:XML;

private var myLoader:URLLoader;
private var myXML:XML;
private var myXMLL:XMLList;
private var soap:Soap;
private var ppm:Canvas;

private function init():void {
	
	Singleton.registerClass("vdom.components.editor.managers::IVdomDragManager", 
		Class(getDefinitionByName("vdom.components.editor.managers::VdomDragManagerImpl")));
	soap = Soap.getInstance();		
	var wsdl:String= 'http://192.168.0.23:82/vdom.wsdl';
	soap.init(wsdl);
	publicData = {};
}

private function checkAuth():void {
	
	ppm = new MyLoader();
	PopUpManager.addPopUp(ppm, this, true);
	PopUpManager.centerPopUp(ppm);
	mtAuth = new Auth();
	mtAuth.login(loginText.text, passwordText.text);
	mtAuth.addEventListener(AuthEvent.AUTH_COMPLETE, authComplete);
	mtAuth.addEventListener(AuthEvent.AUTH_ERROR, authError);
}

private function mainInitHandler(event:Event):void {
	
	applicationListContainer.addEventListener(ListEvent.CHANGE, appChangedHandler);
	applicationListContainer.dataProvider = applicationsList.Application;
	applicationListContainer.selectedIndex = 0;
	publicData['appId'] = applicationListContainer.selectedItem.@id;
}

private function appChangedHandler(event:ListEvent):void {
	publicData['appId'] = List(event.currentTarget).selectedItem.@id;
}

private function authComplete(event:Event):void {
	
	soap.addEventListener(SoapEvent.LIST_APLICATION_OK, listApplicationHandler)
	soap.listApplications();
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
	
	mtLang = new Lang();
	mtLang.loadLanguage(settings.languages.@default);
	viewstack.selectedChild=main;
	PopUpManager.removePopUp(ppm);
}

private function authError(event:Event):void {
	PopUpManager.removePopUp(ppm);
	passwordText.text = '';
	Alert.show('Ошибка! \n Неверные имя пльзователя или пароль');
}

private function getLangValue(mod:String, item:String):String {
	return (XMLanguage.section.(@module_name == mod).item.(@name == item));
}

private function changeEvt(evt:Event):void{
	mtLang.loadLanguage(evt.currentTarget.selectedItem.@id);
}
private function setDefaultLanguage():void {
	for (var i:uint=0; i < selectLang.dataProvider.length; i++ ){
		if(selectLang.dataProvider[i].@id == settings.languages.@default)
			selectLang.selectedItem = selectLang.dataProvider[i];
	}
}