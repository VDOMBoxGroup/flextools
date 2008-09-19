// ActionScript file
import ContextWindows.AddLanguageWindow;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.core.Application;
import mx.events.MenuEvent;
import mx.managers.PopUpManager;
import mx.utils.UIDUtil;
import mx.controls.Alert;
import flash.filesystem.File;
import mx.events.FileEvent;
import flash.desktop.Icon;
import mx.controls.Image;
import ContextWindows.DropDownMenuEditor;

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

/* --------- Object Supported languages section ----------- */
/* -------------------------------------------------------- */

private var AddLangContextWnd:AddLanguageWindow = new AddLanguageWindow();

private function addObjectLanguageBtnClickHandler():void {
	PopUpManager.addPopUp(AddLangContextWnd, this, true);
	PopUpManager.centerPopUp(AddLangContextWnd);
	AddLangContextWnd.addEventListener(Event.COMPLETE, addObjectLanguage);
	AddLangContextWnd.onShow();
}

private function addObjectLanguage(event:Event):void {
	AddLangContextWnd.removeEventListener(Event.COMPLETE, addObjectLanguage);
	PopUpManager.removePopUp(AddLangContextWnd);
	
	var langStr:String = AddLangContextWnd.langStr; 
	
	/* Check for dublicate langs */
	for each (var language:Object in langsProvider) {
		if (language['label'] == langStr) {
			Alert.show('The language with the same parameter(s) is already exist!', 'Name conflict');
			return;
		}
	}
	
	langsProvider.push( { label:langStr } );

	__langsComboBox.invalidateDisplayList();
	__langSelection.invalidateDisplayList();
	
	/* Ensure that at least one language selected */
	if (langsProvider.length > 0) {
		formEnabled(true);
		
		if (__langSelection.selectedItem == null)
			__langSelection.selectedIndex = 1;
			
	}
	
	if (langsProvider.length == 1) {
		selectedLang = langsProvider[0]['label'];
	}
}

private function removeObjectLanguageBtnClickHandler():void {
	var needUpdate:Boolean = __langsComboBox.text == __langSelection.text;
	var newLangsProvider:Array = [];
	
	for (var i:int = 0; i < langsProvider.length; i++) {
		if (langsProvider[i] != __langsComboBox.selectedItem)
			newLangsProvider.push(langsProvider[i]);
	}
	
	langsProvider = newLangsProvider;
	
	__langsComboBox.invalidateDisplayList();
	__langSelection.invalidateDisplayList();
	
	if (langsProvider.length == 0)
		formEnabled(false);
	
	if (needUpdate) {
		selectedLang = __langSelection.text;
		loadAttrProp();
		loadInformationTabData();
	}
}

private function selectPreviousObjLanguage():void {
	if (__langSelection.selectedIndex > 0)
		__langSelection.selectedIndex = __langSelection.selectedIndex - 1;
	changeLangSelection(); 
}

private function selectNextObjLanguage():void {
	if (__langSelection.selectedIndex < langsProvider.length - 1)
		__langSelection.selectedIndex = __langSelection.selectedIndex + 1;
	changeLangSelection();
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
	__editorIconBtn.enabled = value;
	__structIconBtn.enabled = value;
	__objIconBtn.enabled = value;
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
	attrsListProvider[sI]['panelInterface'];
	try {
		attrsListProvider[sI][sL]['attrDispName'] = __attrDispName.text;
		attrsListProvider[sI][sL]['regExValidationErrStr'] = __regExValidationErrStr.text;
		attrsListProvider[sI][sL]['panelInterfaceParams'] = '';
	}
	catch (err:Error) {
		attrsListProvider[sI][sL] = {};
		attrsListProvider[sI][sL]['attrDispName'] = __attrDispName.text;
		attrsListProvider[sI][sL]['regExValidationErrStr'] = __regExValidationErrStr.text;
		attrsListProvider[sI][sL]['panelInterfaceParams'] = '';
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

/* --------- Change Icons Procedures ---------------------- */
/* -------------------------------------------------------- */

private var iconFile:File = new File();
private var imagesFilter:FileFilter = new FileFilter("Images (*.jpg;*.jpeg;*.gif;*.png)", "*.jpg;*.jpeg;*.gif;*.png");
private var selectedIcon:Image;

private function changeObjectIconClickHandler(imgRef:Image):void {
	iconFile = new File();
	iconFile.addEventListener(Event.SELECT, changeObjectIcon);
	try {
		iconFile.browseForOpen("Choose image for Icon", [imagesFilter]);
	}
	catch (err:Error) {
		iconFile.removeEventListener(Event.SELECT, changeObjectIcon);
		return;
	}
	
	selectedIcon = imgRef;
}

private function changeObjectIcon(e:Event):void {
	iconFile.removeEventListener(Event.SELECT, changeObjectIcon);
	try {
		if (iconFile && !iconFile.isDirectory) {
			var srcBytes:ByteArray = new ByteArray();
			var srcStream:FileStream = new FileStream();
			
			try {
				srcStream.open(iconFile, FileMode.READ);
				
				if (srcStream.bytesAvailable == 0) {
					Alert.show("File is empty", "Could not apply image");
					return; 
				}
				
				srcStream.readBytes(srcBytes, 0, srcStream.bytesAvailable);
				srcStream.close();
				
				selectedIcon.source = srcBytes;
			}
			catch (err:Error) {
				Alert.show('Could not open file!', 'IO Error');
				return;
			}
		}
	}
	catch (err:Error) { }
}

/* --------- Additional attr parameters ------------------- */
/* -------------------------------------------------------- */

private function changeAttrPanelInterfaceHandler():void {
	var type:String = __attrPanelInterface.text;
	var typeReg:RegExp = /^([a-zA-Z]+)\((.*)\)/;
	
	var typeName:String = '';
	var typeParams:String = '';
	
	var matchRes:Array = type.match(typeReg);
	if (matchRes) {
		typeName = matchRes[1];
		typeParams = matchRes[2];
		__params.text = typeName + "()";
		__attrValuesBtn.enabled = typeParams.length > 0;
	}
}

private function attrInterfaceTypeValuesClickHandler():void {
	var type:String = __attrPanelInterface.text;
	var typeReg:RegExp = /^([a-zA-Z]+)\((.*)\)/;
	
	var typeName:String = '';
	var typeParams:String = '';

	var matchRes:Array = type.match(typeReg);
	if (matchRes) {
		typeName = matchRes[1];
		typeParams = matchRes[2];
		
		switch (typeName) {
			case 'DropDown':
				var ddeditor:DropDownMenuEditor = new DropDownMenuEditor();
				PopUpManager.addPopUp(ddeditor, this);
				PopUpManager.centerPopUp(ddeditor);
				break;
		}
	}
}