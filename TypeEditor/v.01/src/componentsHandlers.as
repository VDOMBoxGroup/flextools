// ActionScript file
import ContextWindows.AddLanguageWindow;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.core.Application;
import mx.events.MenuEvent;
import mx.managers.PopUpManager;


/* Data Providers */
[Bindable] private var langsDataProvider:Array = [];


private function creationComplete():void {
	__mainMenuBar.dataProvider = menuDataProvider;
}


private function mainMenuHandler(mEvent:MenuEvent):void {
	
	switch (String(mEvent.item.@data)) {
		
		case "new":
			break;
		
		case "open":
			break;
		
		case "save":
			break;
		
		case "close":
			Application.application.close();
			break;
	}
}

private function colorSwitcherClickHandler(mEvt:MouseEvent):void {
	__grayColor.setStyle("borderThickness", 0);
	__redColor.setStyle("borderThickness", 0);
	__greenColor.setStyle("borderThickness", 0);
	__blueColor.setStyle("borderThickness", 0);
	
	mEvt.currentTarget.setStyle("borderThickness", 2);
}


/* --------- Object Supported languages section --------- */

private var AddLangContextWnd:AddLanguageWindow = new AddLanguageWindow();

private function addObjectLanguageBtnClickHandler():void {
	PopUpManager.addPopUp(AddLangContextWnd, this, true);
	PopUpManager.centerPopUp(AddLangContextWnd);
	AddLangContextWnd.addEventListener(Event.COMPLETE, addObjectLanguage); 
}

private function addObjectLanguage(event:Event):void {
	AddLangContextWnd.removeEventListener(Event.COMPLETE, addObjectLanguage);
	langsDataProvider.push( { label:AddLangContextWnd.lngLabelStr, data:AddLangContextWnd.lngIsoStr } );
	PopUpManager.removePopUp(AddLangContextWnd);
	__langsComboBox.invalidateDisplayList();
	__langSelection.invalidateDisplayList();
}

private function removeObjectLanguageBtnClickHandler():void {
	var newLangsProvider:Array = [];
	
	for (var i:int = 0; i < langsDataProvider.length; i++) {
		if (langsDataProvider[i] != __langsComboBox.selectedItem)
			newLangsProvider.push(langsDataProvider[i]);
	}
	
	
	langsDataProvider = newLangsProvider;
	__langsComboBox.invalidateDisplayList();
	__langSelection.invalidateDisplayList();
	
}


/* -------------------------------------------------------- */
