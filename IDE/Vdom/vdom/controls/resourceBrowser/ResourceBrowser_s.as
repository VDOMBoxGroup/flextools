// ActionScript file
import flash.events.MouseEvent;

import mx.controls.Alert;
import mx.managers.PopUpManager;

import vdom.controls.resourceBrowser.Thumbnail;
import vdom.events.FileManagerEvent;
import vdom.managers.DataManager;
import vdom.managers.FileManager;

[Bindable]
public var dataProvider:String; // Selected resource ID

private var _resources:XML;
private var _types:Array;
private var _thumbs:Array = new Array();
private var _selectedThumb:Object;

private var fileManager:FileManager = FileManager.getInstance();
private var dataManager:DataManager = DataManager.getInstance();

private function creationComplete():void {
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
	
	for each (var resource:XML in _resources.Resource) {
		if (resource.@type.toString() == "jpg") {
			var _thumb:Thumbnail = new Thumbnail();
						
			// trace (resource.@id.toString() + " --> " + __thumb + "(" + resource.toXMLString() + ")");

			thumbsList.addChild(_thumb);
			_thumb.text = resource.@name.toString();
			_thumb.objID = resource.@id.toString();
			_thumb.addEventListener(MouseEvent.CLICK, selectThumbnail);
			fileManager.loadResource(dataManager.currentApplicationId, resource.@id.toString(), _thumb);
		}   	
	}
}

private function selectThumbnail(mEvent:MouseEvent):void {
	// Alert.show("Object with id " + mEvent.currentTarget.objID + " selected.", "");
	if (_selectedThumb != null) {
		_selectedThumb.setStyle('backgroundColor', "#FFFFFF");
	}
	mEvent.currentTarget.setStyle('backgroundColor', "#E9E9E9");
	_selectedThumb = mEvent.currentTarget;
}

private function showResource():void {
	
}