// ActionScript file
/**
 * Resource Browser component action script file.
 * Developed by Vadim A. Usoltsev, Tomsk, Russia, 2008
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

import mx.charts.CategoryAxis;
import flash.utils.ByteArray;
import flash.events.KeyboardEvent;
import mx.core.Application;

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

private var resourcesListLoadedFlag:Boolean = false;

[Bindable]
private var filterDataProvider:Array;

[Bindable]
private var totalResources:int = 0;

[Bindable]
private var filteredResources:int = 0;


private var _manager:*;

public function set selectedItemID(itemID:String):void {
	_selectedItemID = itemID;
	if (resourcesListLoadedFlag) {
		showResourceSelection();
	}
}

public function get selectedItemID():String {
	return _selectedItemID;
}

public function set manager(ref:*):void {
	this.addEventListener(CloseEvent.CLOSE, closeHandler); 
	loadTypesIcons();
	listResourcesQuery();
	this.visible = true;
	Application.application.addEventListener(KeyboardEvent.KEY_DOWN, keyPressHandler);
}

private function listResourcesQuery():void {
	_manager.addEventListener(FileManagerEvent.RESOURCE_LIST_LOADED, getResourcesList);
	_manager.getListResources();
}

private function getResourcesList(fmEvent:*):void {
	_manager.removeEventListener(FileManagerEvent.RESOURCE_LIST_LOADED, getResourcesList);	
	resources = new XML(fmEvent.result.Resources);
	
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
//		case "svg":
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

	for each (var resource:XML in resources.Resource) {
		totalResources++;
		
		if (filter != '*') {
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

		/* To have access to view element by resource id, add element to the array */
		objects[resource.@id] = viewItem;		

		thumbsList.addChild(viewItem);			// add viewItem as child to initialise it
		viewItem.imageSource = waiting_Icon;	// set default, 'till new image is unknown (or while it is loading) 
		viewItem.objName = resource.@name;
		viewItem.objType = resource.@type;
		viewItem.objID = resource.@id;
		viewItem.addEventListener(MouseEvent.CLICK, selectThumbnail);
		
		if (isViewable(resource.@type)) {
			_manager.loadResource(_manager.currentApplicationId, resource.@id.toString(), viewItem);			
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
	if (_selectedItemID != '') {
		try {
			selectedThumb = objects[_selectedItemID];
			selectedThumb.selected = true;
			selectedItemName = selectedThumb.objName;
			showResource(); 
		}
		catch (err:Error) {
			Alert.show("Selected Resource is not found on the server!", "Resource Browser error");
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
		_manager.loadResource(_manager.currentApplicationId, _selectedItemID, preview);
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

private function keyPressHandler(keybEvent:KeyboardEvent):void {
	Application.application.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressHandler);
	
	switch (keybEvent.keyCode) {
		case 27: /* Escape Press */
			closeHandler(new CloseEvent(CloseEvent.CLOSE));
			break;
		case 13: /* Enter Press */
			doneHandler();
			break;
	}
}


private function closeHandler(cEvent:CloseEvent):void {
	PopUpManager.removePopUp(this);
}

private function filterCBxHandler():void {
	createResourcesViewObjects(__filterCBx.selectedItem.data);	
}
