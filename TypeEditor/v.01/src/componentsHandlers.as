// ActionScript file
import ContextWindows.AddLanguageWindow;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.core.Application;
import mx.events.MenuEvent;
import mx.managers.PopUpManager;
import mx.utils.UIDUtil;

private function creationComplete():void {
	__mainMenuBar.dataProvider = menuDataProvider;
	formEnabled(false);
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


/* --------- Object Supported languages section ----------- */
/* -------------------------------------------------------- */

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
	
	/* Ensure that at least one language selected */
	if (langsDataProvider.length > 0) {
		formEnabled(true);
		
		if (__langSelection.selectedItem == null)
			__langSelection.selectedIndex = 1;
			
	}
	
	if (langsDataProvider.length == 1) {
		selectedLang = langsDataProvider[0]['label'];
	}
}

private function removeObjectLanguageBtnClickHandler():void {
	var needUpdate:Boolean = __langsComboBox.text == __langSelection.text;
	var newLangsProvider:Array = [];
	
	for (var i:int = 0; i < langsDataProvider.length; i++) {
		if (langsDataProvider[i] != __langsComboBox.selectedItem)
			newLangsProvider.push(langsDataProvider[i]);
	}
	
	langsDataProvider = newLangsProvider;
	
	__langsComboBox.invalidateDisplayList();
	__langSelection.invalidateDisplayList();
	
	if (langsDataProvider.length == 0)
		formEnabled(false);
	
	if (needUpdate) {
		selectedLang = __langSelection.text;
		loadAttrProp();
		loadInformationTabData();
	}
}

/* -------------------------------------------------------- */

private function formEnabled(value:Boolean):void {
	__objName.enabled = value;
	__dispName.enabled = value;
	__objNameInXML.enabled = value;
	__renderType.enabled = value;
	__descript.enabled = value;
	__className.enabled = value;
	__containerType.enabled = value;
	__optimPrior.enabled = value;
	__version.enabled = value;
	__contsSupported.enabled = value;
	__remoteMethods.enabled = value;
	__handlers.enabled = value;
	__objInterfaceType.enabled = value;
	__category.enabled = value;
	__moviable.enabled = value;
	__resizable.enabled = value;
	__dynamic.enabled = value;
	__attrsCanvas.enabled = value;
	__resourcesCanvas.enabled = value;
	__refreshIDBtn.enabled = value;
}

private function refreshIDBtnClickHandler():void {
	__objectID.text = UIDUtil.createUID();
}

/* -------- Attributes operations ------------------------- */
/* -------------------------------------------------------- */

private function addAttrBtnClickHandler():void {
	var newAttr:Object = {
		label:'New Attribute',
		attrDispName:[],
		defValue:'',
		regExValidationStr:'',
		regExVadidationErrStr:[],
		interfaceType:0,
		colorGroup:1,
		codeInterface:'TextField(Length)',
		visible:true
	}
	
	attrsListProvider.push(newAttr);
	__attrsList.dataProvider = attrsListProvider;
	__attrsList.selectedIndex = attrsListProvider.length;
	changeAttrSelection();
}

private function removeAttrBtnClickHandler():void {
	var newAttrsListProvider:Array = [];
	var i:int = 0;
	
	for each (var attribute:Object in attrsListProvider) {
		if (i != __attrsList.selectedIndex)
			newAttrsListProvider.push(attribute);
		i++;
	}
	
	attrsListProvider = newAttrsListProvider;
	__attrsList.dataProvider = attrsListProvider;
	changeAttrSelection();
}

private var selectedAttrIndex:int = -1;
private var selectedLang:String = '';

private function validAttrIndex():Boolean {
	try {
		if (selectedAttrIndex < 0 || selectedAttrIndex >= attrsListProvider.length) {
			selectedAttrIndex = -1;
			__attrName.text = '';
			__attrDispName.text = '';
			__defValue.text = '';
			__regExValidationStr.text = '';
			__regExValidationErrStr.text = '';
			__attrInterfaceType.selectedIndex = 0;
			__attrPanelInterface.selectedIndex = 0;
			__attrVisible.selectedIndex = 0;
			return false;
		}
	}
	catch (err:Error) { return false; }	
	
	return true;	
}

private function writeAttrPropChanges():void {
	if (!validAttrIndex())
		return;

	var sI:int = selectedAttrIndex;
	var sL:String = selectedLang;
	
	/* write changed properties */
	attrsListProvider[sI]['label'] = __attrName.text;
	attrsListProvider[sI]['defValue'] = __defValue.text;
	attrsListProvider[sI]['regExValidationStr'] = __regExValidationStr.text;
	try {
		attrsListProvider[sI][sL]['attrDispName'] = __attrDispName.text;
		attrsListProvider[sI][sL]['regExValidationErrStr'] = __regExValidationErrStr.text;
	}
	catch (err:Error) {
		attrsListProvider[sI][sL] = {};
		attrsListProvider[sI][sL]['attrDispName'] = __attrDispName.text;
		attrsListProvider[sI][sL]['regExValidationErrStr'] = __regExValidationErrStr.text;
	}

	var storedIndex:int = __attrsList.selectedIndex;
	__attrsList.dataProvider = attrsListProvider;
	__attrsList.selectedIndex = storedIndex;
}

private function loadAttrProp():void {
	if (!validAttrIndex())
		return;

	var sI:int = selectedAttrIndex;
	var sL:String = selectedLang;

	/* load selected propertie parameters */
	__attrName.text = attrsListProvider[sI]['label'];
	__defValue.text = attrsListProvider[sI]['defValue'];
	__regExValidationStr.text = attrsListProvider[sI]['regExValidationStr'];
	
	try {
		__attrDispName.text = attrsListProvider[sI][sL]['attrDispName'];
		__regExValidationErrStr.text = attrsListProvider[sI][sL]['regExValidationErrStr'];
	}
	catch (err:Error) {
		__attrDispName.text = '';
		__regExValidationErrStr.text = '';
	}
}

private function changeAttrSelection():void {
	writeAttrPropChanges();
	selectedAttrIndex = __attrsList.selectedIndex;
	loadAttrProp();
}

/* --------- Information tab procedures ------------------- */
/* -------------------------------------------------------- */

private function writeInformationTabData():void {	
	objDisplayName[selectedLang] = __dispName.text;
	objDescription[selectedLang] = __descript.text;
}

private function loadInformationTabData():void {
	__dispName.text = objDisplayName[selectedLang];
	__descript.text = objDescription[selectedLang]; 
}

private function changeLangSelection():void {
	writeAttrPropChanges();
	writeInformationTabData();
	selectedLang = __langSelection.text;
	loadAttrProp();
	loadInformationTabData();
}