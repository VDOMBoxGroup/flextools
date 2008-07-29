// ActionScript file
/**
 * Resource Browser component action script file.
 * Developed by Vadim A. Usoltsev, Tomsk, Russia, 2008
**/

/**
 * Current tasks:
 * 1. Implement upload resource to server
 * 2. Implement delete resource from server
**/

import flash.events.Event;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import mx.controls.Alert;
import mx.controls.Label;
import mx.events.CloseEvent;
import mx.events.ItemClickEvent;
import mx.managers.PopUpManager;
import mx.utils.Base64Encoder;

import vdom.connection.soap.Soap;
import vdom.connection.soap.SoapEvent;
import vdom.controls.resourceBrowser.ListItem;
import vdom.controls.resourceBrowser.PreviewContainer;
import vdom.controls.resourceBrowser.ThumbnailItem;
import vdom.events.FileManagerEvent;
import vdom.events.ResourceBrowserEvent;
import vdom.managers.DataManager;
import vdom.managers.FileManager;

include "typesIcons.as";

private const defaultView:String = "list";

/*
	Selected resource ID sets by property "selectedItemID" from the outside the Class.
	It is used to show which item is currently selected (or not, if it is null).
*/ 
private var _selectedItemID:String = "";
private var selectedItemName:String = ""; 

private var resources:XML;				// XML, Getting by FileManager Class instance
private var selectedThumb:Object;		// Currently selected Thumbnail (visual component)
private var rTypes:Array;				// Avalible resources types (get during resources scanning)
private var objects:Array;				// Associative (by id) array of resource objects	
private var currentView:String;
private var fileForUpload:File;

private var resourcesListLoadedFlag:Boolean = false;

[Bindable]
private var filterDataProvider:Array;

[Bindable]
private var totalResources:int = 0;

[Bindable]
private var filteredResources:int = 0;

private var fileManager:FileManager = FileManager.getInstance();	// FileManager global Class instance
private var dataManager:DataManager = DataManager.getInstance();	// DataManager global Class instance
private var soap:Soap = Soap.getInstance();

public function set selectedItemID(itemID:String):void {
	_selectedItemID = itemID;
	if (resourcesListLoadedFlag) {
		showResourceSelection();
	}
}

public function get selectedItemID():String {
	return _selectedItemID;
}

private function creationComplete():void {
	this.addEventListener(CloseEvent.CLOSE, closeHandler); 
	loadTypesIcons();
	listResourcesQuery();
	this.visible = true;
}

private function listResourcesQuery():void {
	fileManager.addEventListener(FileManagerEvent.RESOURCE_LIST_LOADED, getResourcesList);
	fileManager.getListResources();
}

private function getResourcesList(fmEvent:FileManagerEvent):void {
	fileManager.removeEventListener(FileManagerEvent.RESOURCE_LIST_LOADED, getResourcesList);	
	resources = new XML(fmEvent.result.Resources.toXMLString());
	
	currentView = defaultView;
	createResourcesViewObjects();
	resourcesListLoadedFlag = true;
	showResourceSelection();
	determineResourcesTypes();	
}

private function determineResourcesTypes():void {
	rTypes = [];
	
	try {
		for each (var resource:XML in resources.Resource) {
			rTypes[resource.@type] = resource.@type;
		}
	}
	catch (err:Error) { return; }
	
	createFilters();
}

private function createFilters():void {
	filterDataProvider = [];
	
	filterDataProvider.push( {label:'None', data:'*'} );
	
	for each (var type:String in rTypes) {
		filterDataProvider.push( {label:type.toUpperCase(), data:type.toLowerCase()} );
	}
	
	__filterCBx.selectedIndex = 0;
	__filterCBx.selectedItem = __filterCBx.selectedItem;	// :-) Don't worry, it's ok! Just in case...
}

private function isViewable(extension:String):Boolean {
	switch (extension.toLowerCase()) {
		case "jpg":
		case "jpeg":
		case "png":
		case "gif":
		case "svg":
			return true;
		default:
			return false;
	}
}

private function createResourcesViewObjects(filter:String = "*"):void {	
	thumbsList.removeAllChildren();
	objects = [];
	totalResources = 0;
	filteredResources = 0;
	
	/* Select ThumbsArea initial width depending on ViewClass */
	/* By default Expand button is turned off */
	expandHandler();
		
	var viewItem:*;

	try {
		
		for each (var resource:XML in resources.Resource) {
			totalResources++;
			
			if (filter != "*") {
				if (resource.@type.toLowerCase() == filter) {
					filteredResources++;
				} else {
					continue;
				}
			}
			
			switch (currentView.toLowerCase()) {
				case "thumbnail":
					viewItem = new ThumbnailItem();
					break;
				case "list":
					viewItem = new ListItem();	
					break;
			}
	
			thumbsList.addChild(viewItem);			// add viewItem as child to initialise it
			viewItem.imageSource = waiting_Icon;	// set default, 'till new image is unknown (or while it is loading) 
			viewItem.objName = resource.@name;
			viewItem.objType = resource.@type;
			viewItem.objID = resource.@id;
			viewItem.addEventListener(MouseEvent.CLICK, selectThumbnail);
			
			/* To have access to view element by resource id, add element to the array */
			objects[resource.@id] = viewItem;		
			
			if (isViewable(resource.@type)) {
				fileManager.loadResource(dataManager.currentApplicationId, resource.@id.toString(), viewItem);			
			} else { // if not viewable
				if (typesIcons[resource.@type] != null) {
					viewItem.imageSource = typesIcons[resource.@type];	
				} else {
					viewItem.imageSource = blank_Icon;
				}
			}
		}
		
	}
	catch (err:Error) {
		/* error01 */
		Alert.show("Unexpected error (01). Please reopen Resource browser.", "Getting resources error"); 
		return;
	}
}

private function selectThumbnail(mEvent:MouseEvent):void {
	/* Highlight selected thumbnail */
	if (selectedThumb != null) {
		selectedThumb.selected = false;
	}
	mEvent.currentTarget.selected = true;
	
	_selectedItemID = mEvent.currentTarget.objID;
	selectedItemName = mEvent.currentTarget.objName;
	selectedThumb = mEvent.currentTarget;
	
	showResource();	
}

private function showResourceSelection():void { 	// uses when property set
	if (_selectedItemID != "") {
		if (objects[_selectedItemID] == null) {
			Alert.show("Selected Resource is not found on the server!", "Resource Browser error"); 
		} else {
			selectedThumb = objects[_selectedItemID];
			selectedThumb.selected = true;
			selectedItemName = selectedThumb.objName;
			showResource(); 
		}
	}
}

private function showResource():void {
	/* Fill in resource information in the info area */
	__rName.text = selectedThumb.objName;
	__rType.text = selectedThumb.objType.toUpperCase();
	
	/* Create & Show large preview of the image */	
	__previewArea.removeAllChildren();	// Clear up the space

	var preview:PreviewContainer = new PreviewContainer();
	__previewArea.addChild(preview);
	preview.heightLimit = __previewArea.height - 15;
	preview.widthLimit = __previewArea.width - 15;
	
	if (isViewable(selectedThumb.objType)) {
		preview.imageSource = waiting_Icon;
		preview.addEventListener(Event.COMPLETE, setImageProperties);
		fileManager.loadResource(dataManager.currentApplicationId, _selectedItemID, preview);
	} else {
		preview.imageSource = selectedThumb.imageSource;
		__iResolution.text = "Can not determine";
		var msg:Label = new Label();
		__previewArea.addChild(msg);
		msg.text = "No preview avalible for this type."
	}
}

private function setImageProperties(event:Event):void {
	__iResolution.text = event.currentTarget.imageWidth.toString() + " x " + event.currentTarget.imageHeight.toString();
}

private function applyView(event:ItemClickEvent = null):void {
	if (event != null) {
		if (event.index == 0) {
			currentView = "thumbnail";
		} else {	
			if (event.index == 1) {
				currentView = "list";
			} else {
				currentView = defaultView;
			}
		}		
		createResourcesViewObjects();
	}
	
	/* Selecting active element */
	if (objects[_selectedItemID] != null) {
		selectedThumb = objects[_selectedItemID];
		objects[_selectedItemID].selected = true;
	}
}

private function expandHandler():void {
	/* We create instances of objects below just in case to access to their properties */
	if (__expandBtn.selected) {
		__previewArea.width = 380;	// ~
		thumbsList.percentWidth = 100;		
	} else {
		switch (currentView.toLowerCase()) {
			case "thumbnail":
				var tItem:ThumbnailItem = new ThumbnailItem();
				thumbsList.width = tItem.width + 28;
				break;
			case "list":
				var lItem:ListItem = new ListItem();
				thumbsList.width = lItem.width + 28;
				break;
		}
		__previewArea.width = __midArea.width - thumbsList.width - 2;
	}
	
	/* Redraw preview */
	if (objects[_selectedItemID] != null) {
		selectedThumb = objects[_selectedItemID];
		showResource();
	} 
}

private function doneHandler():void {
	this.dispatchEvent(
		ResourceBrowserEvent(
			new ResourceBrowserEvent(ResourceBrowserEvent.RESOURCE_SELECTED, _selectedItemID, selectedItemName)
		)
	);
	var cEvent:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
	this.dispatchEvent(cEvent);
}

private function closeHandler(cEvent:CloseEvent):void {
	PopUpManager.removePopUp(this);
}

private function filterCBxHandler():void {
	createResourcesViewObjects(__filterCBx.selectedItem.data);	
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

	if (fileForUpload != null && !fileForUpload.isDirectory) {
		var srcBytes:ByteArray = new ByteArray();
		var srcStream:FileStream = new FileStream();
		
		srcStream.open(fileForUpload, FileMode.READ);
		srcStream.readBytes(srcBytes, 0, srcStream.bytesAvailable);
		srcStream.close();
		
		var compressedData:ByteArray = new ByteArray();
		compressedData.writeBytes(srcBytes);
		compressedData.compress();
		
		var base64Data:Base64Encoder = new Base64Encoder();
		base64Data.encodeBytes(compressedData);
		
		var fileType:String = "";
		try {		
			fileType = fileForUpload.type.substr(1);
		}
		catch (err:Error) {
			fileType = fileForUpload.extension;
		}
		var fileName:String = fileForUpload.name.substr(0, fileForUpload.name.length - fileType.length - 1);
		setResource(fileType, fileName, base64Data.toString());
	}	
}


/* Functions below will be replaced with new ones when fileManager will support such operations */
private function setResource(resType:String, resName:String, resData:String):void {
	soap.setResource(dataManager.currentApplicationId, resType, resName, resData);
	soap.addEventListener(SoapEvent.SET_RESOURCE_OK , setResourceOkHandler);
	soap.addEventListener(SoapEvent.SET_RESOURCE_ERROR, setResourceErrorHandler);
}

private function setResourceOkHandler(spEvt:SoapEvent):void {
	soap.removeEventListener(SoapEvent.SET_RESOURCE_OK, setResourceOkHandler);
	soap.removeEventListener(SoapEvent.SET_RESOURCE_ERROR, setResourceErrorHandler);
	var result:XML = spEvt.result;
	_selectedItemID = result.Resource.@id.toString();
	listResourcesQuery();
}

private function setResourceErrorHandler(spEvt:SoapEvent):void {
	trace('Resource browser: ERROR at sending resource');
	soap.removeEventListener(SoapEvent.SET_RESOURCE_OK, setResourceOkHandler);
	soap.removeEventListener(SoapEvent.SET_RESOURCE_ERROR, setResourceErrorHandler);
}