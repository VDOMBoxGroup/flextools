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
import mx.messaging.management.Attribute;
import ContextWindows.TextFieldEditor;

private function creationComplete():void
{
	__mainMenuBar.dataProvider = menuDataProvider;
	formEnabled(false);
}

private function mainMenuHandler(mEvent:MenuEvent):void
{
	
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

private function addObjectLanguageBtnClickHandler():void
{
	PopUpManager.addPopUp(AddLangContextWnd, this, true);
	PopUpManager.centerPopUp(AddLangContextWnd);
	AddLangContextWnd.addEventListener(Event.COMPLETE, addObjectLanguage);
	AddLangContextWnd.onShow();
}

private function addObjectLanguage(event:Event):void
{
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

private function removeObjectLanguageBtnClickHandler():void
{
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

private function selectPreviousObjLanguage():void
{
	if (__langSelection.selectedIndex > 0)
		__langSelection.selectedIndex = __langSelection.selectedIndex - 1;
	changeLangSelection(); 
}

private function selectNextObjLanguage():void
{
	if (__langSelection.selectedIndex < langsProvider.length - 1)
		__langSelection.selectedIndex = __langSelection.selectedIndex + 1;
	changeLangSelection();
}

/* -------------------------------------------------------- */

private function formEnabled(value:Boolean):void
{
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

private function refreshIDBtnClickHandler():void
{
	__objectID.text = UIDUtil.createUID();
}

/* -------- Attributes operations ------------------------- */
/* -------------------------------------------------------- */

/**
 * Attribute property include following values:
 * 
 * attrsProvider:
 *  |
 *  |--[0]
 * 	|   |--label = 'New Attribute' (attr Name)
 * 	|   |--defValue = ''
 * 	|   |--regExValidationStr = ''
 *  |   |--interfaceType = 0
 *  |   |--colorGroup = 1
 *  |   |--codeInterface = 'textfield' 
 *  |   |--visible = 1 
 *  |   |
 *  |   |--[attrDispName]
 *  |   |   |--languageField = str
 *  |   |   '--languageField = str
 *  |   |
 *  |   |--[regExValidationErrStr]
 *  |   |   |--languageField = str
 *  |   |   '--languageField = str
 *  |   |
 *  |   |--textFieldLength = 0
 *  |   |--numberMinValue = 0
 *  |   |--numberMaxValue = 0
 *  |   |--multiLineLength = 0
 *  |   |--externalEditorTitle = ''
 *  |   |--externalEditorInfo = ''
 *  |   |
 *  |   |--[dropDownValues]
 *  |   |   |--0 = value
 *  .   |   |--1 = value
 *  .   |   '--2 = value
 *  .   |   ...
 *      |
 *      '--[dropDownStrings]
 *          '--[languageField]
 *              |--0 = str
 *              |--1 = str
 *              '--2 = str
 *              ...
 **/ 


private function addAttrBtnClickHandler():void
{
	/* Setup new attr object */
	var newAttr:Object = {
		label					:'New Attribute',
		defValue				:'',
		regExValidationStr		:'',
		interfaceType			:0,
		colorGroup				:1,
		codeInterface			:'textfield',
		visible					:1,
		attrDispName			:[],	/* [LanguageField] = str */
		regExValidationErrStr	:[],	/* [LanguageField] = str */
		textFieldLength			:0,
		numberMinValue			:0,
		numberMaxValue			:0,
		multiLineLength			:0,
		externalEditorTitle		:'',
		externalEditorInfo		:'',
		dropDownValues			:[],	/* Array of values */
		dropDownStrings			:{}		/* [LanguageFiled] :: Array of Strings */
	}
	
	writeAttrPropChanges();
	
	attrsProvider.push(newAttr);
	__attrsList.dataProvider = attrsProvider;
	__attrsList.selectedIndex = attrsProvider.length - 1;
	selectedAttrIndex = attrsProvider.length - 1;
	loadAttrProp();
	
	/* -------------------------------------------------------------------------- */
}

private function removeAttrBtnClickHandler():void
{
	var newAttrsProvider:Array = [];
	var i:int = 0;
	
	for each (var attribute:Object in attrsProvider) {
		if (i != __attrsList.selectedIndex)
			newAttrsProvider.push(attribute);
		i++;
	}
	
	attrsProvider = newAttrsProvider;
	__attrsList.dataProvider = attrsProvider;
	changeAttrSelection();
}

private var selectedAttrIndex:int = -1;
private var selectedLang:String = '';

private function validAttrIndex():Boolean
{
	try {
		if (selectedAttrIndex < 0 || selectedAttrIndex >= attrsProvider.length) {
			selectedAttrIndex = -1;
			__attrName.text = '';
			__attrDispName.text = '';
			__defValue.text = '';
			__regExValidationStr.text = '';
			__regExValidationErrStr.text = '';
			__attrInterfaceType.selectedIndex = 0;
			__attrCodeInterface.selectedIndex = 0;
			__attrVisible.selectedIndex = 0;
			return false;
		}
	}
	catch (err:Error) { return false; }	
	
	return true;	
}

private var currentAttrObj:Object;

private function writeAttrPropChanges():void
{
	if (!validAttrIndex() || !currentAttrObj)
		return;

	var sL:String = selectedLang;
	
	/* write changed properties */
	currentAttrObj['label'] = __attrName.text;
	currentAttrObj['defValue'] = __defValue.text;
	currentAttrObj['regExValidationStr'] = __regExValidationStr.text;
	currentAttrObj['codeInterface'] = String(__attrCodeInterface.selectedItem.data);
	currentAttrObj['interfaceType'] = int(__attrInterfaceType.selectedItem.data);
	currentAttrObj['visible'] = __attrVisible.selectedItem.data;
	
	currentAttrObj['attrDispName'][sL] = __attrDispName.text;
	currentAttrObj['regExValidationErrStr'][sL] = __regExValidationErrStr.text;
	
	var storedIndex:int = __attrsList.selectedIndex;
	__attrsList.dataProvider = attrsProvider;
	__attrsList.selectedIndex = storedIndex;
}


private function loadAttrProp():void
{
	if (!validAttrIndex())
		return;
	
	currentAttrObj = attrsProvider[selectedAttrIndex];
	
	var sL:String = selectedLang;

	/* load selected propertie parameters */
	__attrName.text = currentAttrObj['label'];
	__defValue.text = currentAttrObj['defValue'];
	__regExValidationStr.text = currentAttrObj['regExValidationStr'];
	
	__attrInterfaceType.selectedIndex = int(currentAttrObj['interfaceType']);
	
	__attrVisible.selectedIndex = int(currentAttrObj['visible']) - 1;
		
	try {
		__attrDispName.text = currentAttrObj['attrDispName'][sL];
		__regExValidationErrStr.text = currentAttrObj['regExValidationErrStr'][sL];
	}
	catch (err:Error) {
		currentAttrObj['attrDispName'][sL] = '';
		currentAttrObj['regExValidationErrStr'][sL] = '';
		__attrDispName.text = '';
		__regExValidationErrStr.text = '';
	}
	
	loadCodeInterfaceData();
}

private function loadCodeInterfaceData():void
{
	__attrValuesBtn.enabled = false;	
	var codeInterfaceString:String = '';

	switch (currentAttrObj.codeInterface) {
		case 'textfield':
			codeInterfaceString = 'TextField ( ' + currentAttrObj['textFieldLength'] + ' )';
			__attrCodeInterface.selectedIndex = 0;
			__attrValuesBtn.enabled = true;	
			break;
			
		case 'number':
			__attrCodeInterface.selectedIndex = 1;
			break;
		case 'multiline':
			__attrCodeInterface.selectedIndex = 2;
			break;
		case 'font':
			__attrCodeInterface.selectedIndex = 3;
			break;
			
		case 'dropdown':
			codeInterfaceString = 'DropDown ( ';
			
			if (currentAttrObj && currentAttrObj['dropDownStrings'][selectedLang])
			{
				var i:int = 0;
				for each (var value:String in currentAttrObj['dropDownValues']) {
					codeInterfaceString += '(' + currentAttrObj['dropDownStrings'][selectedLang][i] + '|' + value + ') ';
					i++;
				}
			}
			
			codeInterfaceString += ')';
			__attrValuesBtn.enabled = true;	

			__attrCodeInterface.selectedIndex = 4;
			break;
			
		case 'file':
			__attrCodeInterface.selectedIndex = 5;
			break;
		case 'color':
			__attrCodeInterface.selectedIndex = 6;
			break;
		case 'pagelink':
			__attrCodeInterface.selectedIndex = 7;
			break;
		case 'linkedbase':
			__attrCodeInterface.selectedIndex = 8;
			break;
		case 'objectlist':
			__attrCodeInterface.selectedIndex = 9;
			break;
		case 'objectlist2':
			__attrCodeInterface.selectedIndex = 10;
			break;
		case 'externaleditor':
			__attrCodeInterface.selectedIndex = 11;
			break;
	}

	__codeInterfaceParams.text = codeInterfaceString;
}

private function changeAttrSelection():void
{
	writeAttrPropChanges();
	selectedAttrIndex = __attrsList.selectedIndex;
	loadAttrProp();
}

/* --------- Information tab procedures ------------------- */
/* -------------------------------------------------------- */

private function writeInformationTabData():void
{	
	objDisplayName[selectedLang] = __dispName.text;
	objDescription[selectedLang] = __descript.text;
}

private function loadInformationTabData():void
{
	__dispName.text = objDisplayName[selectedLang];
	__descript.text = objDescription[selectedLang]; 
}

private function changeLangSelection():void
{
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

private function changeObjectIconClickHandler(imgRef:Image):void
{
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

private function changeObjectIcon(e:Event):void
{
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

private function changeAttrCodeInterfaceHandler():void
{
	if (!currentAttrObj || !validAttrIndex())
		return;
	
	currentAttrObj.codeInterface = __attrCodeInterface.selectedItem.data;
	loadCodeInterfaceData();
}

private var ddeditor:DropDownMenuEditor = new DropDownMenuEditor();
private var tfeditor:TextFieldEditor = new TextFieldEditor();

private function attrInterfaceTypeValuesClickHandler():void
{
	if (selectedAttrIndex < 0)
		return;
	
	var type:String = __attrCodeInterface.selectedItem.data;
	
	switch (type) {
		case 'textfield':
			tfeditor.addEventListener(Event.COMPLETE, textFieldEditorCompleteHandler);
			PopUpManager.addPopUp(tfeditor, this);
			PopUpManager.centerPopUp(tfeditor); 
			
			tfeditor.textFieldLength = currentAttrObj['textFieldLength'];
			tfeditor.onShow();
			break;
			
		case 'dropdown':
			ddeditor.addEventListener(Event.COMPLETE, dropDownEditCompleteHandler); 
			PopUpManager.addPopUp(ddeditor, this);
			PopUpManager.centerPopUp(ddeditor);

			ddeditor.langsProvider = langsProvider;
			ddeditor.exampleLang = langsProvider[0].label;
			ddeditor.editableLang = selectedLang;
			ddeditor.currentAttrObj = this.currentAttrObj;
			ddeditor.onShow();
			break;
	}
}


private function dropDownEditCompleteHandler(event:Event):void
{
	ddeditor.removeEventListener(Event.COMPLETE, dropDownEditCompleteHandler);
	currentAttrObj = ddeditor.currentAttrObj;
	PopUpManager.removePopUp(ddeditor);
	loadCodeInterfaceData();
}


private function textFieldEditorCompleteHandler(event:Event):void
{
	tfeditor.removeEventListener(Event.COMPLETE, textFieldEditorCompleteHandler);
	currentAttrObj['textFieldLength'] = tfeditor.textFieldLength;
	PopUpManager.removePopUp(tfeditor);
	loadCodeInterfaceData();
}