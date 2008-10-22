// ActionScript file
import vdom.managers.FileManager;
import vdom.events.FileManagerEvent;
import vdom.events.ResourceBrowserEvent;
import mx.managers.PopUpManager;
import mx.core.Application;
import vdom.controls.resourceBrowser.TypesIcons;
import vdom.components.edit.containers.typeAccordionClasses.Type;
import mx.core.IFactory;
import mx.core.ClassFactory;
import vdom.containers.Thumbnail;
import vdom.managers.DataManager;
import mx.controls.List;
import mx.controls.Alert;

/**
 * Resource Browser component action script file.
 * Developed by Vadim A. Usoltsev, Tomsk, Russia, 2008
**/

private const defaultView:String = "list";


/**
 * Variables
**/

/*
	Selected resource ID sets by property "selectedItemID" from the outside the Class.
	It is used to show which item is currently selected (or not, if it is null).
*/ 
private var typesIcons:TypesIcons = new TypesIcons();
private var _selectedItemID:String = '';
private var	allResourcesList:XML;				// XML, Getting by FileManager Class instance
private var rTypes:Array;						// Avalible resources types (get during resources scanning)

private var fileForUpload:File;
private var resourcesListLoadedFlag:Boolean = false;
private var fileManager:FileManager = FileManager.getInstance();	// FileManager global Class instance
private var dataManager:DataManager = DataManager.getInstance();

[Bindable]
private var filterDataProvider:Array;

private var listDataProvider:Array; /* of Object */

[Bindable]
private var totalResources:int = 0;

[Bindable]
private var filteredResources:int = 0;


public function set selectedItemID(itemID:String):void
{
	_selectedItemID = itemID;
	
	if (resourcesListLoadedFlag) {
		applyFilterHandler();
		showResource();
	}
}


public function get selectedItemID():String
{
	return _selectedItemID;
}


private function creationComplete():void
{
	addEventListener(CloseEvent.CLOSE, closeHandler);
	listResourcesQuery();
	this.visible = true;
	Application.application.addEventListener(KeyboardEvent.KEY_DOWN, keyPressHandler);
}


private function keyPressHandler(keybEvent:KeyboardEvent):void
{
	Application.application.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressHandler);
	
	switch (keybEvent.keyCode)
	{
		case 27: /* Escape Press */
			closeHandler(new CloseEvent(CloseEvent.CLOSE));
			break;
		case 13: /* Enter Press */
			doneHandler();
			break;
	}
}


private function doneHandler():void
{
	this.dispatchEvent(
		ResourceBrowserEvent(
			new ResourceBrowserEvent(
				ResourceBrowserEvent.RESOURCE_SELECTED,
				__thumbsList.selectedItem.@id, 
				__thumbsList.selectedItem.@name
			)
		)
	);
	var cEvent:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
	this.dispatchEvent(cEvent); 
}


private function listResourcesQuery():void
{
	fileManager.addEventListener(FileManagerEvent.RESOURCE_LIST_LOADED, getResourcesListHandler);
	fileManager.getListResources();
}


private function getResourcesListHandler(fmEvent:FileManagerEvent):void
{
	fileManager.removeEventListener(FileManagerEvent.RESOURCE_LIST_LOADED, getResourcesListHandler);	
	allResourcesList = new XML(fmEvent.result.Resources);
	
	try {
		totalResources = allResourcesList.Resource.length();
	}
	catch (err:Error) {
		trace("Resource browser exception occured! :: " + err.message);
	}
	
	resourcesListLoadedFlag = true;
	determineResourcesTypes();
	showResource();
}

private function determineResourcesTypes():void
{
	rTypes = [];
	
	try {
		for each (var resource:XML in allResourcesList.Resource) {
			rTypes[resource.@type] = resource.@type;
		}
	}
	catch (err:Error) { return; }
	
	createFilters();
}


private function createFilters():void
{
	filterDataProvider = [];
	
	filterDataProvider.push( {label:'None', data:'*'} );
	
	for each (var type:String in rTypes) {
		filterDataProvider.push( {label:type.toUpperCase(), data:type.toLowerCase()} );
	}
	
	__filterCBx.selectedIndex = 0;
	__filterCBx.selectedItem = __filterCBx.selectedItem;	// :-) Don't worry, it's ok! Just in case...
	
	applyFilterHandler(); 		//  !!!  Create actual thumbs (at start and later)  !!!
}


private function applyFilterHandler():void {
	var i:int = 0;
	
	filteredResources = 0;
	
	if (__filterCBx.selectedItem.data == '*') {
		
		__thumbsList.dataProvider = allResourcesList.Resource;
		
		for (i = 0; i < allResourcesList.Resource.length(); i++) {
			if (allResourcesList.Resource[i].@id == _selectedItemID) {
				__thumbsList.selectedIndex = i;
			}
		}
		
	} else {
		
		var newResourcesList:XML = new XML(<Resources />);
		
		for each (var resourceItem:XML in allResourcesList.Resource) {
			if (resourceItem.@type == __filterCBx.selectedItem.data) {
				filteredResources++;
				newResourcesList.appendChild(resourceItem);
			}
		}

		__thumbsList.dataProvider = newResourcesList.Resource;

		for (i = 0; i < newResourcesList.Resource.length(); i++) {
			if (newResourcesList.Resource[i].@id == _selectedItemID) {
				__thumbsList.selectedIndex = i;
			}
		}

	}
}


private function closeHandler(cEvent:CloseEvent):void
{
	PopUpManager.removePopUp(this);
}

private function showResource():void {
	_selectedItemID = __thumbsList.selectedItem.@id;
	
	/* Fill in resource information in the info area */
	__rName.text = __thumbsList.selectedItem.@name;
	__rType.text = String(__thumbsList.selectedItem.@type).toUpperCase();
	
	if (typesIcons.isViewable(__thumbsList.selectedItem.@type)) {
		
		__preview.__image.source = typesIcons.spinner;
		__preview.addEventListener(Event.COMPLETE, setImageProperties);
		__preview.objID = __thumbsList.selectedItem.@id;
		
	} else {
		
		if (typesIcons.icon[__thumbsList.selectedItem.@type])
			__preview.imageSource = typesIcons.icon[__thumbsList.selectedItem.@type];
		else
			__preview.imageSource = typesIcons.blank_Icon;
			
		__iResolution.text = "Can not determine";
	}
}


private function setImageProperties(event:Event):void {
	__iResolution.text = event.currentTarget.imageWidth.toString() + " x " + event.currentTarget.imageHeight.toString();
}


private function fileUploadHandler():void {
	if (fileForUpload == null) {
		fileForUpload = new File();
	}
	
	var allFilesFilter:FileFilter = new FileFilter("All Files (*.*)", "*.*");
	var imagesFilter:FileFilter = new FileFilter("Images (*.jpg;*.jpeg;*.gif;*.png)", "*.jpg;*.jpeg;*.gif;*.png");
	var docFilter:FileFilter = new FileFilter("Documents (*.pdf;*.doc;*.txt)", "*.pdf;*.doc;*.txt");
	
	fileForUpload.addEventListener(Event.SELECT, fileSelectHandler);
	fileForUpload.browseForOpen("Choose file to upload", [imagesFilter, docFilter, allFilesFilter]);
}


private function fileSelectHandler(event:Event):void {
	fileForUpload.removeEventListener(Event.SELECT, fileSelectHandler);

	if (fileForUpload  && !fileForUpload.isDirectory) {
		var srcBytes:ByteArray = new ByteArray();
		var srcStream:FileStream = new FileStream();
		
		try {

			srcStream.open(fileForUpload, FileMode.READ);
			
			if (srcStream.bytesAvailable == 0) {
				Alert.show("File is empty", "Could not send file");
				return; 
			}
			
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
			setResource(fileType, fileName, srcBytes);
		}
		catch (err:Error) {
			Alert.show ('Unexpected error', 'Could not upload selected resource!');
			return;
		}
	}	
}


private function setResource(resType:String, resName:String, resData:ByteArray):void {
	fileManager.addEventListener(FileManagerEvent.RESOURCE_SAVED, setResourceOkHandler);
	fileManager.addEventListener(FileManagerEvent.RESOURCE_SAVED_ERROR, setResourceErrorHandler);
	fileManager.setResource(resType, resName, resData);	
}


private function setResourceOkHandler(fmEvent:FileManagerEvent):void {
	fileManager.removeEventListener(FileManagerEvent.RESOURCE_SAVED, setResourceOkHandler);
	fileManager.removeEventListener(FileManagerEvent.RESOURCE_SAVED_ERROR, setResourceErrorHandler);	

	try {
		var result:XML = XML(fmEvent.result);
		_selectedItemID = result.Resource.@id.toString();
		listResourcesQuery();
	}
	catch (err:Error) {
		Alert.show("Unknown response from server", "Resource Id getting error");
	}
}


private function setResourceErrorHandler(fmEvent:FileManagerEvent):void {
	trace('Resource browser: ERROR at sending resource');
	fileManager.removeEventListener(FileManagerEvent.RESOURCE_SAVED, setResourceOkHandler);
	fileManager.removeEventListener(FileManagerEvent.RESOURCE_SAVED_ERROR, setResourceErrorHandler);
	Alert.show("Could not send resource to server!", "Sending resource error");
}