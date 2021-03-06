	// ActionScript file
import ContextWindows.AddLanguageWindow;
import ContextWindows.DropDownMenuEditor;
import ContextWindows.ExternaleditorEditor;
import ContextWindows.MultiLineEditor;
import ContextWindows.NumberRangeEditor;
import ContextWindows.ObjectListEditor;
import ContextWindows.TextFieldEditor;

import flash.events.Event;
import flash.filesystem.File;

import mx.controls.Alert;
import mx.controls.Image;
import mx.core.Application;
import mx.events.MenuEvent;
import mx.managers.PopUpManager;
import mx.utils.UIDUtil;



private var ddeditor:DropDownMenuEditor = new DropDownMenuEditor();
private var tfeditor:TextFieldEditor = new TextFieldEditor();
private var nreditor:NumberRangeEditor = new NumberRangeEditor();
private var mleditor:MultiLineEditor = new MultiLineEditor();
private var oleditor:ObjectListEditor = new ObjectListEditor();
private var eeeditor:ExternaleditorEditor = new ExternaleditorEditor();


private function creationComplete():void
{
	__mainMenuBar.dataProvider = menuDataProvider;
	formEnabled(false);
	
	/* Add permanent event listeners */
	tfeditor.addEventListener(Event.COMPLETE, textFieldEditorCompleteHandler);
	nreditor.addEventListener(Event.COMPLETE, numberRangeEditorCompleteHandler);
	mleditor.addEventListener(Event.COMPLETE, multiLineEditorCompleteHandler);
	ddeditor.addEventListener(Event.COMPLETE, dropDownEditCompleteHandler); 
	eeeditor.addEventListener(Event.COMPLETE, externalEditorCompleteHandler); 
	eeeditor.addEventListener(Event.SELECT, addResAtExternalEditorHandler);
}

private function mainMenuHandler(mEvent:MenuEvent):void
{
	
	switch (String(mEvent.item.@data)) {
		
		case "new":
			break;
		
		case "open":
			loadXmlDocument();
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
	oleditor.addEventListener(Event.COMPLETE, objectListEditorCompleteHandler);

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
		objectListTypeId		:'',
		numberMinValue			:0.0,
		numberMaxValue			:0.0,
		multiLineLength			:0,
		externalEditorTitle		:[],	/* [LanguageField] = str */
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
			__attrCodeInterface.selectedIndex = 0;
			codeInterfaceString = 'TextField ( ' + currentAttrObj['textFieldLength'] + ' )';
			__attrValuesBtn.enabled = true;
			break;
			
		case 'number':
			__attrCodeInterface.selectedIndex = 1;
			codeInterfaceString = 'Number ( ' + currentAttrObj['numberMinValue'] + ', ' + currentAttrObj['numberMaxValue'] + ' )';
			__attrValuesBtn.enabled = true;
			break;
			
		case 'multiline':
			__attrCodeInterface.selectedIndex = 2;
			codeInterfaceString = 'MultiLine ( ' + currentAttrObj['multiLineLength'] + ' )';
			__attrValuesBtn.enabled = true;
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
			codeInterfaceString = 'ObjectList ( ' + currentAttrObj['objectListTypeId'] + ' )';
			__attrValuesBtn.enabled = true;
			break;
			
		case 'externaleditor':
			__attrCodeInterface.selectedIndex = 11;
			
			var resourceName:String = '';
			var ok:Boolean = false;
			for each (var resource:Object in resourcesProvider) {
				if (resource.resourceid == currentAttrObj['externalEditorInfo']) {
					ok = true;
					resourceName = resource.name;
				}
			}
			
			if (!ok && currentAttrObj['externalEditorInfo'] != '')
				resourceName = 'Resource unavaliable!';
			
			codeInterfaceString = 'ExternalEditor ( ' + currentAttrObj['externalEditorTitle'][selectedLang]
								+ ', ' + resourceName + ' )';
								
			__attrValuesBtn.enabled = true;
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

	/* We use parameter with current selected image just to short code and not to write several the same functions */ 	
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


private function attrInterfaceTypeValuesClickHandler():void
{
	if (selectedAttrIndex < 0)
		return;
	
	var type:String = __attrCodeInterface.selectedItem.data;
	
	switch (type) {
		case 'textfield':
			PopUpManager.addPopUp(tfeditor, this);
			PopUpManager.centerPopUp(tfeditor); 
			
			tfeditor.textFieldLength = currentAttrObj['textFieldLength'];
			tfeditor.onShow();
			break;

		case 'number':
			PopUpManager.addPopUp(nreditor, this);
			PopUpManager.centerPopUp(nreditor); 
			
			nreditor.numberMinValue = currentAttrObj['numberMinValue'];
			nreditor.numberMaxValue = currentAttrObj['numberMaxValue'];
			nreditor.onShow();
			break;
			
		case 'multiline':
			PopUpManager.addPopUp(mleditor, this);
			PopUpManager.centerPopUp(mleditor); 
			
			mleditor.multiLineLength = currentAttrObj['multiLineLength'];
			mleditor.onShow();
			break;

		case 'dropdown':
			PopUpManager.addPopUp(ddeditor, this);
			PopUpManager.centerPopUp(ddeditor);

			ddeditor.langsProvider = langsProvider;
			ddeditor.exampleLang = langsProvider[0].label;
			ddeditor.editableLang = selectedLang;
			ddeditor.currentAttrObj = this.currentAttrObj;
			ddeditor.onShow();
			break;

		case 'objectlist2':
			PopUpManager.addPopUp(oleditor, this);
			PopUpManager.centerPopUp(oleditor); 
			
			oleditor.typeId = currentAttrObj['objectListTypeId'];
			oleditor.onShow();
			break;

		case 'externaleditor':
			PopUpManager.addPopUp(eeeditor, this);
			PopUpManager.centerPopUp(eeeditor);

			eeeditor.titleProvider = currentAttrObj['externalEditorTitle'];
			eeeditor.selectedLang = this.selectedLang;
			eeeditor.langsProvider = langsProvider;
			eeeditor.resourcesProvider = this.resourcesProvider;
			eeeditor.externalEditorInfo = currentAttrObj['externalEditorInfo'];
			eeeditor.onShow();
			break;

	}
}


private function dropDownEditCompleteHandler(event:Event):void
{
	currentAttrObj = ddeditor.currentAttrObj;
	PopUpManager.removePopUp(ddeditor);
	loadCodeInterfaceData();
}


private function textFieldEditorCompleteHandler(event:Event):void
{
	currentAttrObj['textFieldLength'] = tfeditor.textFieldLength;
	PopUpManager.removePopUp(tfeditor);
	loadCodeInterfaceData();
}


private function numberRangeEditorCompleteHandler(event:Event):void
{
	currentAttrObj['numberMinValue'] = nreditor.numberMinValue;
	currentAttrObj['numberMaxValue'] = nreditor.numberMaxValue;
	PopUpManager.removePopUp(nreditor);
	loadCodeInterfaceData();
}


private function multiLineEditorCompleteHandler(event:Event):void
{
	currentAttrObj['multiLineLength'] = mleditor.multiLineLength;
	PopUpManager.removePopUp(mleditor);
	loadCodeInterfaceData();
}


private function objectListEditorCompleteHandler(event:Event):void
{
	currentAttrObj['objectListTypeId'] = oleditor.typeId;
	PopUpManager.removePopUp(oleditor);
	loadCodeInterfaceData();
}


private function externalEditorCompleteHandler(event:Event):void
{
	currentAttrObj['externalEditorTitle'] = eeeditor.titleProvider;
	currentAttrObj['externalEditorInfo'] = eeeditor.externalEditorInfo;
	this.resourcesProvider = eeeditor.resourcesProvider;
	PopUpManager.removePopUp(eeeditor);
	loadCodeInterfaceData();
}


/* -------- object resources ------------------------------------------------- */

private var fileForUpload:File;

/* -------- add new Resource func -------------------------------------------- */

private function addResource():void
{
	if (!fileForUpload)
		fileForUpload = new File();
		
	var allFilesFilter:FileFilter = new FileFilter("All Files (*.*)", "*.*");
	var imagesFilter:FileFilter = new FileFilter('Images (*.jpg;*.jpeg;*.gif;*.png)', '*.jpg;*.jpeg;*.gif;*.png');
	var docFilter:FileFilter = new FileFilter('Documents (*.pdf;*.doc;*.txt)', '*.pdf;*.doc;*.txt');
	
	fileForUpload.addEventListener(Event.SELECT, fileSelectHandler);
	fileForUpload.addEventListener(Event.CANCEL, fileCancelHandler);
	fileForUpload.browseForOpen("Choose file to upload", [imagesFilter, docFilter, allFilesFilter]);
}

private function fileCancelHandler(e:Event):void
{
	fileForUpload.removeEventListener(Event.SELECT, fileSelectHandler);
	fileForUpload.removeEventListener(Event.CANCEL, fileCancelHandler);
}

private function fileSelectHandler(event:Event):void
{
	fileForUpload.removeEventListener(Event.SELECT, fileSelectHandler);
	fileForUpload.removeEventListener(Event.CANCEL, fileCancelHandler);
			
	if (fileForUpload  && !fileForUpload.isDirectory) {
		var srcBytes:ByteArray = new ByteArray();
		var srcStream:FileStream = new FileStream();
		var fileSize:int = 0;
		
		try {

			srcStream.open(fileForUpload, FileMode.READ);
			
			if (srcStream.bytesAvailable == 0) {
				Alert.show("File is empty", "File can not be used!");
				return; 
			}
			
			fileSize = srcStream.bytesAvailable;
			srcStream.readBytes(srcBytes, 0, srcStream.bytesAvailable);
			srcStream.close();
		}
		catch (err:Error) {
			Alert.show('Could not open file!', 'IO Error');
			return;
		}
			
		var fileType:String = "";
		try {		
			fileType = fileForUpload.type.substr(1);
		}
		catch (err:Error) {
			fileType = fileForUpload.extension;
		}
		
		try {
			var fileName:String = fileForUpload.name.substr(0, fileForUpload.name.length - fileType.length - 1);
						
			var resourceObj:Object = {
				name:	fileName,
				data:	srcBytes,
				type:	fileType,
				size:	fileSize,
				resourceid: UIDUtil.createUID()
			}
			
			resourcesProvider.push(resourceObj);
		}
		catch (err:Error) {
			Alert.show ('Unexpected error', 'Could not use selected file!');
			return;
		}
		
		if (__resTable)
			__resTable.dataProvider = resourcesProvider;
	}	
}


/* ------ EOF add new Resource func ----------------------------------------------- */


/* ------- remove Resource func ---------------------------------------------------- */

private function removeResource(resourceID:String):void
{
	var newResourcesProvider:Array = [];
	
	for each (var resourceObj:Object in resourcesProvider) {
		if (resourceID != resourceObj.resourceid)
			newResourcesProvider.push(resourceObj);
	}
	
	resourcesProvider = newResourcesProvider;
	
	if (__resTable)
		__resTable.dataProvider = resourcesProvider;
	
	try { loadCodeInterfaceData(); }
	catch (err:Error) { }
}


private function removeResourceBtnClickHandler():void
{
	if (!__resTable)
		return;
		
	if (!__resTable.selectedItem)
		return;
		
	removeResource(__resTable.selectedItem.resourceid);
}

/* ------- EOF remove Resource func ------------------------------------------------- */


/* ------- replace Resource func ---------------------------------------------------- */

private function replaceResourceBtnClickHandler():void {
	if (!__resTable)
		return;
		
	if (!__resTable.selectedIndex < 0)
		return;

	if (!fileForUpload)
		fileForUpload = new File();
		
	var allFilesFilter:FileFilter = new FileFilter("All Files (*.*)", "*.*");
	var imagesFilter:FileFilter = new FileFilter('Images (*.jpg;*.jpeg;*.gif;*.png)', '*.jpg;*.jpeg;*.gif;*.png');
	var docFilter:FileFilter = new FileFilter('Documents (*.pdf;*.doc;*.txt)', '*.pdf;*.doc;*.txt');
	
	fileForUpload.addEventListener(Event.SELECT, replace_fileSelectHandler);
	fileForUpload.addEventListener(Event.CANCEL, replace_fileCancelHandler);
	fileForUpload.browseForOpen("Choose file to upload", [imagesFilter, docFilter, allFilesFilter]);
	
	try { loadCodeInterfaceData(); }
	catch (err:Error) { }
}


private function replace_fileCancelHandler(e:Event):void
{
	fileForUpload.removeEventListener(Event.SELECT, replace_fileSelectHandler);
	fileForUpload.removeEventListener(Event.CANCEL, replace_fileCancelHandler);
}

private function replace_fileSelectHandler(event:Event):void
{
	fileForUpload.removeEventListener(Event.SELECT, replace_fileSelectHandler);
	fileForUpload.removeEventListener(Event.CANCEL, replace_fileCancelHandler);
			
	if (fileForUpload  && !fileForUpload.isDirectory) {
		var srcBytes:ByteArray = new ByteArray();
		var srcStream:FileStream = new FileStream();
		var fileSize:int = 0;
		
		try {

			srcStream.open(fileForUpload, FileMode.READ);
			
						
			if (srcStream.bytesAvailable == 0) {
				Alert.show("File is empty", "File can not be used!");
				return; 
			}
			
			fileSize = srcStream.bytesAvailable;
			srcStream.readBytes(srcBytes, 0, srcStream.bytesAvailable);
			srcStream.close();
		}
		catch (err:Error) {
			Alert.show('Could not open file!', 'IO Error');
			return;
		}
			
		var fileType:String = "";
		try {		
			fileType = fileForUpload.type.substr(1);
		}
		catch (err:Error) {
			fileType = fileForUpload.extension;
		}
		
		try {
			var fileName:String = fileForUpload.name.substr(0, fileForUpload.name.length - fileType.length - 1);
			
			resourcesProvider[__resTable.selectedIndex].name = fileName;
			resourcesProvider[__resTable.selectedIndex].data = srcBytes;
			resourcesProvider[__resTable.selectedIndex].type = fileType;
			resourcesProvider[__resTable.selectedIndex].size = fileSize;
			resourcesProvider[__resTable.selectedIndex].resourceid = UIDUtil.createUID(); 

		}
		catch (err:Error) {
			Alert.show ('Unexpected error', 'Could not use selected file!');
			return;
		}
		
		if (__resTable)
			__resTable.dataProvider = resourcesProvider;
	}	
}


/* ------- EOF replace Resource func ------------------------------------------------- */


private function resourcesTableClickHandler():void
{
	if (__resTable.selectedItem)
		__tableResourceId.text = __resTable.selectedItem.resourceid;
	else
		__tableResourceId.text = '';
}


private function addResAtExternalEditorHandler(e:Event):void
{
	addResource();
} 