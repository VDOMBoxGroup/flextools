// ActionScript file
import ContextWindows.AddLanguageWindow;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.core.Application;
import mx.events.MenuEvent;
import mx.managers.PopUpManager;
import flash.utils.describeType;
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
	
	if (langsDataProvider.length == 0)
		formEnabled(false);
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
	showAttrProps();
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
	showAttrProps();
}

private var previousSelectedAttr:int = -1;

private function showAttrProps():void {
	if (__attrsList.selectedIndex < 0 || __attrsList.selectedIndex >= attrsListProvider.length) {
		__attrName.text = '';
		__attrDispName.text = '';
		__defValue.text = '';
		__regExValidationStr.text = '';
		__regExValidationErrStr.text = '';
		__attrInterfaceType.selectedIndex = 0;
		__attrPanelInterface.selectedIndex = 0;
		__attrVisible.selectedIndex = 0;
		previousSelectedAttr = -1;
		return; /* Incorrect index */
	}

	var si:int = __attrsList.selectedIndex;
	var ps:int = previousSelectedAttr;
	var sl:String = __langSelection.text;
		
	/* write changed properties */
	if (previousSelectedAttr >= 0 && previousSelectedAttr < attrsListProvider.length) {
		attrsListProvider[ps]['label'] = __attrName.text;
		attrsListProvider[ps][sl]['attrDispName'] = __attrDispName.text;
		attrsListProvider[ps]['defValue'] = __defValue.text;
		attrsListProvider[ps]['regExValidationStr'] = __regExValidationStr.text;
		attrsListProvider[ps][sl]['regExValidationErrStr'] = __regExValidationErrStr.text;
	}
	
	/* load selected propertie parameters */
	__attrName.text = attrsListProvider[si]['label'];
	__attrDispName.text = attrsListProvider[si][sl]['attrDispName'];
	__defValue.text = attrsListProvider[si]['defValue'];
	__regExValidationStr.text = attrsListProvider[si]['regExValidationStr'];
	__regExValidationErrStr.text = attrsListProvider[si][sl]['regExValidationErrStr'];
	
	previousSelectedAttr = si;
	__attrsList.dataProvider = attrsListProvider;
	__attrsList.selectedIndex = si;
}
	
/* -------------------------------------------------------- */

