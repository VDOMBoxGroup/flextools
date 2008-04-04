// ActionScript file
import mx.managers.PopUpManager;

import vdom.controls.resourceBrowser.Thumbnail;
import vdom.events.FileManagerEvent;
import vdom.managers.DataManager;
import vdom.managers.FileManager;

[Bindable]
public var dataProvider:String;

private var __resources:XML;
private var __types:Array;
private var __thumbs:Array = new Array();

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


public function set resource(obj:Object):void
{
	var ID:String = obj.resourceID;
	
	__thumbs[ID] = new Thumbnail();
	thumbsList.addChild(__thumbs[ID]);
	__thumbs[ID].image = obj.data;
} 

private function getResourcesList(fmEvent:FileManagerEvent):void {	
	__resources = new XML(fmEvent.result.Resources.toXMLString());
	__types = new Array();
	
	for each (var resource:XML in __resources.Resource) {
		if ((resource.@type.toString() == ".jpg") || (resource.@type.toString() == "jpg")) {
			var __thumb:Thumbnail = new Thumbnail();			
			//trace (resource.@id.toString() + " --> " + __thumb + "(" + resource.toXMLString() + ")");
			thumbsList.addChild(__thumb);
			fileManager.loadResource(dataManager.currentApplicationId, resource.@id.toString(), __thumb);
		}   	
	}
}

private function showResource():void {
	
}