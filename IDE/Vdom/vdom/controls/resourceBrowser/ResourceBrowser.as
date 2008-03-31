// ActionScript file
import vdom.events.FileManagerEvent;
import vdom.managers.FileManager;


[Bindable]
public var dataProvider:String;

private var fileManager:FileManager = FileManager.getInstance();

private function Main():void {

}

private function listResourcesQuery():void {
	fileManager.getListResources();
	fileManager.addEventListener(FileManagerEvent.RESOURCE_LIST_LOADED, getResourcesList);
}

private function getResourcesList(fmEvent:FileManagerEvent):void {	
	fmEvent.result;
}

private function showResource(resourceID:String):void {
	
}