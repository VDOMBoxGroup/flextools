// ActionScript file

/**
 * Current tasks:
 * 1. Low down resolution on waiting.swf
 * 2. Make preview mode
 * 3. Make filters
 * 4. Make search
 * 5. Make done
**/

import flash.events.MouseEvent;

import mx.controls.Alert;
import mx.events.ItemClickEvent;
import mx.managers.PopUpManager;

import vdom.controls.resourceBrowser.ListItem;
import vdom.controls.resourceBrowser.ThumbnailItem;
import vdom.events.FileManagerEvent;
import vdom.managers.DataManager;
import vdom.managers.FileManager;

include "typesIcons.as";

/*
	Selected resource ID sets by property "selectedItemID" from the outside the Class.
	It is used to show which item is currently selected (or not, if it is null).
*/ 
private var _selectedItemID:String; 

private var _resources:XML;				// Getting by FileManager Class instance
private var _types:Array;				// Avalible resources types (get during resources scanning)
private var _selectedThumb:Object;		// Currently selected Thumbnail (visual component) 

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
	_types = new Array();
	showResourcesList("thumbnail");	
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

private function showResourcesList(viewClass:String):void {
	thumbsList.removeAllChildren();
	
	/* We create instances of objects below just in case to access to their properties */
	var tItem:ThumbnailItem = new ThumbnailItem();
	var lItem:ListItem = new ListItem();

	/* Select ThumbsArea initial width depending on ViewClass */
	switch (viewClass.toLowerCase()) {
		case "thumbnail":
			thumbsList.width = tItem.width + 28;
			thumbsList.minWidth = tItem.width + 28;
			break;
		case "list":
			thumbsList.width = lItem.width + 28;
			thumbsList.minWidth = lItem.width + 28;
			break;
	}
	
	var viewItem:*;
	
	for each (var resource:XML in _resources.Resource) {
		switch (viewClass.toLowerCase()) {
			case "thumbnail":
				viewItem = new ThumbnailItem();
				break;
			case "list":
				viewItem = new ListItem();	
				break;
		}

		thumbsList.addChild(viewItem);
		viewItem.imageSource = waiting_Icon;
		viewItem.objName = resource.@name;
		viewItem.objType = resource.@type;
		viewItem.objID = resource.@id;
		viewItem.addEventListener(MouseEvent.CLICK, selectThumbnail);		
		
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
	if (_selectedThumb != null) {
		_selectedThumb.selected = false;
	}
	mEvent.currentTarget.selected = true;
	_selectedThumb = mEvent.currentTarget;
}

private function changeView(event:ItemClickEvent):void {
	if (event.index == 0) {
		showResourcesList("thumbnail");
	} else {
		if (event.index == 1) {
			showResourcesList("list");
		}
	}
}

private function dividerRelease():void {
	
}


private function showResource():void {
	
}