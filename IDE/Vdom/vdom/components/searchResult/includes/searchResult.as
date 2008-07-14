import mx.collections.HierarchicalData;

import vdom.events.SearchResultEvent;

[Bindable]
private var resultList:XMLList;

private var applicationId:String;


public function set dataProvider(value:XMLList):void
{
	if(!value.length())
		return;
	
	applicationName.text = value.Name;
	applicationId = value[0].@ID;
	
	searchDataGrid.dataProvider = new HierarchicalData(value.*);
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
		
	var sre:SearchResultEvent = 
		new SearchResultEvent(SearchResultEvent.SEARCH_OBJECT_SELECTED);
	
	sre.applicationId = applicationId;
	sre.pageId = pageId;
	sre.objectId = objectId;
	
	dispatchEvent(sre);
}

private function showHandler():void
{
	
}

