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

private var _resources:XML;				// XML, Getting by FileManager Class instance
private var _selectedThumb:Object;		// Currently selected Thumbnail (visual component)
private var _rTypes:Array;				// Avalible resources types (get during resources scanning)
private var _objects:Array;				// Associative (by id) array of resource objects	
private var _currentView:String;
private var _fileForUpload:File;

private var _resourcesListLoadedFlag:Boolean = false;

[Bindable]
private var _filterDataProvider:Array;

[Bindable]
private var _totalResources:int = 0;

[Bindable]
private var _filteredResources:int = 0;

private var fileManager:FileManager = FileManager.getInstance();	// FileManager global Class instance
private var dataManager:DataManager = DataManager.getInstance();	// DataManager global Class instance
private var soap:Soap = Soap.getInstance();

public function set selectedItemID(itemID:String):void {
	_selectedItemID = itemID;
	if (_resourcesListLoadedFlag) {
		showResourceSelection();
	}
}

public function get selectedItemID():String {
	return _selectedItemID;
}

private function creationComplete():void {
	this.addEventListener(CloseEvent.CLOSE, closeHandler); 
	loadTypesIcons();
	PopUpManager.centerPopUp(this);
	listResourcesQuery();
}

private function listResourcesQuery():void {
	fileManager.addEventListener(FileManagerEvent.RESOURCE_LIST_LOADED, getResourcesList);
	fileManager.getListResources();
}

private function getResourcesList(fmEvent:FileManagerEvent):void {
	fileManager.removeEventListener(FileManagerEvent.RESOURCE_LIST_LOADED, getResourcesList);	
	_resources = new XML(fmEvent.result.Resources.toXMLString());
	
	_currentView = defaultView;
	createResourcesViewObjects();
	_resourcesListLoadedFlag = true;
	showResourceSelection();
	determineResourcesTypes();	
}

private function determineResourcesTypes():void {
	_rTypes = new Array();

	for each (var resource:XML in _resources.Resource) {
		_rTypes[resource.@type] = resource.@type;
	}
	
	createFilters();
}

private function createFilters():void {
	_filterDataProvider = new Array();
	
	_filterDataProvider.push({label:"None", data:"*"});
	
	for each (var type:String in _rTypes) {
		_filterDataProvider.push({label:type.toUpperCase(), data:type.toLowerCase()});
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
		case "swf":
			return true;
		default:
			return false;
	}
}

private function createResourcesViewObjects(filter:String = "*"):void {	
	thumbsList.removeAllChildren();
	_objects = new Array();
	_totalResources = 0;
	_filteredResources = 0;
	
	/* Select ThumbsArea initial width depending on ViewClass */
	/* By default Expand button is turned off */
	expandHandler();
		
	var viewItem:*;
	
	for each (var resource:XML in _resources.Resource) {
		_totalResources++;
		
		if (filter != "*") {
			if (resource.@type.toLowerCase() == filter) {
				_filteredResources++;
			} else {
				continue;
			}
		}
		
		switch (_currentView.toLowerCase()) {
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
		_objects[resource.@id] = viewItem;		
		
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

private function selectThumbnail(mEvent:MouseEvent):void {
	/* Highlight selected thumbnail */
	if (_selectedThumb != null) {
		_selectedThumb.selected = false;
	}
	mEvent.currentTarget.selected = true;
	
	_selectedItemID = mEvent.currentTarget.objID;
	_selectedThumb = mEvent.currentTarget;
	
	showResource();	
}

private function showResourceSelection():void { 	// uses when property set
	if (_selectedItemID != "") {
		if (_objects[_selectedItemID] == null) {
			Alert.show("Selected Resource is not found on the server!", "Resource Browser error"); 
		} else {
			_selectedThumb = _objects[_selectedItemID];
			_selectedThumb.selected = true;
			showResource(); 
		}
	}
}

private function showResource():void {
	/* Fill in resource information in the info area */
	__rName.text = _selectedThumb.objName;
	__rType.text = _selectedThumb.objType.toUpperCase();
	
	/* Create & Show large preview of the image */	
	__previewArea.removeAllChildren();	// Clear up the space

	var preview:PreviewContainer = new PreviewContainer();
	__previewArea.addChild(preview);
	preview.heightLimit = __previewArea.height - 15;
	preview.widthLimit = __previewArea.width - 15;
	
	if (isViewable(_selectedThumb.objType)) {
		preview.imageSource = waiting_Icon;
		fileManager.loadResource(dataManager.currentApplicationId, _selectedItemID, preview);
		__iResolution.text = _selectedThumb.imageWidth.toString() + " x " + _selectedThumb.imageHeight.toString();
	} else {
		preview.imageSource = _selectedThumb.imageSource;
		__iResolution.text = "Can not determine";
		var msg:Label = new Label();
		__previewArea.addChild(msg);
		msg.text = "No preview avalible for this type."
	}
}

private function applyView(event:ItemClickEvent = null):void {
	if (event != null) {
		if (event.index == 0) {
			_currentView = "thumbnail";
		} else {
		
			if (event.index == 1) {
				_currentView = "list";
			} else {
				_currentView = defaultView;
			}
		}		
		createResourcesViewObjects();
	}
	
	/* Selecting active element */
	if (_objects[_selectedItemID] != null) {
		_selectedThumb = _objects[_selectedItemID];
		_objects[_selectedItemID].selected = true;
	}
}

private function expandHandler():void {
	/* We create instances of objects below just in case to access to their properties */
	if (__expandBtn.selected) {
		__previewArea.width = 380; // ~
		thumbsList.percentWidth = 100;		
	} else {
		switch (_currentView.toLowerCase()) {
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
	if (_objects[_selectedItemID] != null) {
		_selectedThumb = _objects[_selectedItemID];
		showResource();
	} 
}

private function doneHandler():void {
	this.dispatchEvent(ResourceBrowserEvent(new ResourceBrowserEvent(ResourceBrowserEvent.RESOURCE_SELECTED, _selectedItemID)));
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
	if (_fileForUpload == null) {
		_fileForUpload = new File();
	}
	
	_fileForUpload.addEventListener(Event.SELECT, fileSelectHandler);
	_fileForUpload.browseForOpen("Choose file to upload", [ new FileFilter("All FIles", "*.*") ]);
}

private function fileSelectHandler(event:Event):void {
	_fileForUpload.removeEventListener(Event.SELECT, fileSelectHandler);

	if (_fileForUpload != null && !_fileForUpload.isDirectory) {
		var srcBytes:ByteArray = new ByteArray();
		var srcStream:FileStream = new FileStream();
		
		srcStream.open(_fileForUpload, FileMode.READ);
		srcStream.readBytes(srcBytes, 0, srcStream.bytesAvailable);
		srcStream.close();
		
		var compressedData:ByteArray = new ByteArray();
		compressedData.writeBytes(srcBytes);
		compressedData.compress();
		
		var base64Data:Base64Encoder = new Base64Encoder();
		base64Data.encodeBytes(compressedData);
		
		var fileType:String = _fileForUpload.type.substr(1);
		var fileName:String = _fileForUpload.name.substr(0, _fileForUpload.name.length - _fileForUpload.type.length);
		setResource(fileType, fileName, base64Data.toString());
	}	
}

private function setResource(resType:String, resName:String, resData:String):void {
	soap.setResource(dataManager.currentApplicationId, resType, resName, resData);
	soap.addEventListener(SoapEvent.SET_RESOURCE_OK , setResourceOkHandler);
	soap.addEventListener(SoapEvent.SET_RESOURCE_ERROR, setResourceErrorHandler);
}

private function setResourceOkHandler(spEvt:SoapEvent):void {
	soap.removeEventListener(SoapEvent.SET_RESOURCE_OK, setResourceOkHandler);
	soap.removeEventListener(SoapEvent.SET_RESOURCE_ERROR, setResourceErrorHandler);
	listResourcesQuery();
	//var result:XML = spEvt.result;
	//_resourceID = result.Resource.@id;
}

private function setResourceErrorHandler(spEvt:SoapEvent):void {
	trace('Resource browser: ERROR at sending resource');
	//image.source = defaultPicture;
	 	
	soap.removeEventListener(SoapEvent.SET_RESOURCE_OK, setResourceOkHandler);
	soap.removeEventListener(SoapEvent.SET_RESOURCE_ERROR, setResourceErrorHandler);
}