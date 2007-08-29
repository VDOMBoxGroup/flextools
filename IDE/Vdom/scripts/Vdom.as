
import vdom.Auth;
import vdom.Lang;
import vdom.components.editor.managers.DataManager;
import mx.collections.XMLListCollection;
import vdom.events.AuthEvent;
import com.connection.soap.Soap;
import com.connection.soap.SoapEvent;
import mx.events.ListEvent;
import flash.events.Event;
import vdom.MyLoader;
import mx.managers.PopUpManager;
import mx.core.IFlexDisplayObject;
import flash.display.DisplayObject;
import mx.containers.Canvas;
import mx.controls.List;
import mx.core.Singleton

private var myLoader:URLLoader;
private var myXML:XML;
private var myXMLL:XMLList;
[Bindable]
private var XMLanguage:XML;
[Bindable]
private var myXMLLC:XMLListCollection;
[Bindable]
private var mtAuth:Auth;
[Bindable]
private var mtLang:Lang;
[Bindable]
private var applicationsList:XML;

private var soap:Soap;

public var editorDataManager:DataManager;

public var publicData:Object;

private var ppm:Canvas;

private function init():void {
	
	Singleton.registerClass("vdom.components.editor.managers::IVdomDragManager", Class(getDefinitionByName("vdom.components.editor.managers::VdomDragManagerImpl")));
	
	soap = Soap.getInstance();
			
	var wsdl:String= 'http://192.168.0.23:82/vdom.wsdl';

	soap.init(wsdl);
	
	publicData = {};
	
	//applicationsList = null;
	
	//
	
	//editorDataManager = new DataManager();
	
	//editorDataManager.init();
}

private function resizeHandler(event:Event):void {
	//width = stage.width;
	//height = stage.height;
}

private function mainInitHandler(event:Event):void {
	
	applicationListContainer.addEventListener(ListEvent.CHANGE, appChangedHandler);
	applicationListContainer.dataProvider = applicationsList.Application;
	applicationListContainer.selectedIndex = 0;
	publicData['appId'] = applicationListContainer.selectedItem.@id;
	trace(publicData['appId']);
}

private function appChangedHandler(event:ListEvent):void {
	publicData['appId'] = List(event.currentTarget).selectedItem.@id;
}

private function initCompleteHandler(event:Event):void {
	
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

private function authComplete(event:Event):void {
	
	//editorDataManager = DataManager.getInstance();
	
	//editorDataManager.addEventListener('initComplete', initCompleteHandler);
	//editorDataManager.init();
	
	soap.addEventListener(SoapEvent.LIST_APLICATION_OK, listApplicationHandler)
	soap.listApplications();
}

private function listApplicationHandler(event:SoapEvent):void {
	
	applicationsList = event.result;
	soap.removeEventListener(SoapEvent.LIST_APLICATION_OK, listApplicationHandler);
	
	
	soap.addEventListener(SoapEvent.GET_ALL_TYPES_OK, getAllTypesHandler);
	soap.getAllTypes();
	
	trace('applicationsList'+applicationsList);
	
}
	
/**
 * Получение результатов запроса всех типов. 
 * Попытка загрузить всех объектов верхнего уровня
 * @param event
 * 
 */

private function getAllTypesHandler(event:SoapEvent):void {
	//trace('getAllTypesHandler');
	
	publicData['types'] = event.result;
	//trace('_types: '+_types);
	
	soap.removeEventListener(SoapEvent.GET_ALL_TYPES_OK, getAllTypesHandler);
	
	mtLang = new Lang();
	mtLang.loadLanguage(settings.languages.@default);
	viewstack.selectedChild=main;
	PopUpManager.removePopUp(ppm);
}

private function authError(event:Event):void {
	//Alert.show('Ошибка! \n Неверные имя пльзователя или пароль');
	passwordText.text = '';
	trace('authError');
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