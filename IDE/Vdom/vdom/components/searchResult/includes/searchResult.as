import mx.collections.HierarchicalData;

import vdom.events.SearchResultEvent;
import vdom.managers.DataManager;

[Bindable]
private var resultList:XMLList;

[Bindable]
public var _applicationName:String;

private var applicationId:String;

private var dataManager:DataManager = DataManager.getInstance();

public function set dataProvider(value:XMLList):void
{
	if(!value[0] || value[0].*.length() == 0)
	{
		expandButton.enabled = false;
		collapseButton.enabled = false;
		goToEditorButton.enabled = false;
	}
	else
	{
		expandButton.enabled = true;
		collapseButton.enabled = true;
		goToEditorButton.enabled = true;
	}
	
	_applicationName = value.@Name;
	applicationId = value[0].@ID;
	
	searchDataGrid.dataProvider = new HierarchicalData(value.*);
	searchDataGrid.validateNow();
	searchDataGrid.selectedIndex = 0;
	
}

private function expandAll():void
{
	searchDataGrid.validateNow();
	searchDataGrid.expandAll();
}

private function collapseAll():void
{
	searchDataGrid.validateNow();
	searchDataGrid.collapseAll();
}

private function goToEdit():void
{
	var element:XML = XML(searchDataGrid.selectedItem); 
	var pageId:String, objectId:String;
	
	if(element.name() == 'Object') {
		
		pageId = element.parent().@ID;
		objectId = element.@ID;
	}
	else if(element.name() == 'Container') {
		
		pageId = objectId = element.@ID;
	}
	
	var sre:SearchResultEvent = new SearchResultEvent(SearchResultEvent.SEARCH_OBJECT_SELECTED);
	sre.applicationId = applicationId;
	sre.pageId = pageId;
	sre.objectId = objectId;
	
	dispatchEvent(sre);
}

private function clear():void
{
	dispatchEvent(new SearchResultEvent(SearchResultEvent.SEARCH_CLOSE));
}

private function showHandler():void
{
	
}