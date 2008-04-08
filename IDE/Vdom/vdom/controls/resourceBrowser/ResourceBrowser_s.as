// ActionScript file

/**
 * Current tasks:
 * 3. Make filters
 * 4. Make search
 * 5. Make done
**/

import flash.events.MouseEvent;

import mx.controls.Label;
import mx.events.ItemClickEvent;
import mx.managers.PopUpManager;

import vdom.controls.resourceBrowser.ListItem;
import vdom.controls.resourceBrowser.PreviewContainer;
import vdom.controls.resourceBrowser.ThumbnailItem;
import vdom.events.FileManagerEvent;
import vdom.managers.DataManager;
import vdom.managers.FileManager;

include "typesIcons.as";
private const defaultView:String = "list";

/*
	Selected resource ID sets by property "selectedItemID" from the outside the Class.
	It is used to show which item is currently selected (or not, if it is null).
*/ 
private var _selectedItemID:String; 

private var _resources:XML;				// Getting by FileManager Class instance
private var _selectedThumb:Object;		// Currently selected Thumbnail (visual component)
private var _rTypes:Array;				// Avalible resources types (get during resources scanning)
private var _objects:Array;				// Associative (by id) array of resource objects	
private var _currentView:String;

[Bindable]
private var _totalResources:int = 0;

private var fileManager:FileManager = FileManager.getInstance();	// FileManager global Class instance
private var dataManager:DataManager = DataManager.getInstance();	// DataManager global Class instance

public function set selectedItemID(itemID:String):void {
	_selectedItemID = itemID;
}

public function get selectedItemID():String {
	return _selectedItemID;
}

private function creationComplete():void {
	loadTypesIcons();
	PopUpManager.centerPopUp(this)
	listResourcesQuery();
}

private function listResourcesQuery():void {
	fileManager.addEventListener(FileManagerEvent.RESOURCE_LIST_LOADED, getResourcesList);
	fileManager.getListResources();
}

private function getResourcesList(fmEvent:FileManagerEvent):void {	
	_resources = new XML(fmEvent.result.Resources.toXMLString());
	_currentView = defaultView;
	showResourcesList();
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

private function showResourcesList():void {
	thumbsList.removeAllChildren();
	_objects = new Array();
	_totalResources = 0;
	
	/* Select ThumbsArea initial width depending on ViewClass */
	expandHandler();
		
	var viewItem:*;
	
	for each (var resource:XML in _resources.Resource) {
		_totalResources++;
		
		switch (_currentView.toLowerCase()) {
			case "thumbnail":
				viewItem = new ThumbnailItem();
				break;
			case "list":
				viewItem = new ListItem();	
				break;
		}

		thumbsList.addChild(viewItem);
		viewItem.imageSource = waiting_Icon;	// default, 'till new image is unknown 
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

private function showResource():void {
	/* Fill in resource information in the info area */
	__rName.text = _selectedThumb.objName;
	__rType.text = _selectedThumb.objType.toUpperCase();
	
	/* Show large preview of the image */
	var preview:PreviewContainer = new PreviewContainer();
	__previewArea.removeAllChildren();
	__previewArea.addChild(preview);
	preview.heightLimit = 350;
	preview.widthLimit = 350;
	
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

private function changeView(event:ItemClickEvent):void {
	if (event.index == 0) {
		_currentView = "thumbnail";
		showResourcesList();
	} else {
		if (event.index == 1) {
			_currentView = "list";
			showResourcesList();
		}
	}
	
	/* Selecting active element */
	_selectedThumb = _objects[_selectedItemID];
	if (_selectedThumb != null) {
		_objects[_selectedItemID].selected = true;
	}
}

private function expandHandler():void {
	/* We create instances of objects below just in case to access to their properties */
	if (__expandBtn.selected) {
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
	}
}