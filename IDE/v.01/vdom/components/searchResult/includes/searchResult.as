import mx.collections.HierarchicalData;

import vdom.events.SearchResultEvent;
import vdom.managers.DataManager;

[ Bindable ]
private var resultList : XMLList;

[ Bindable ]
public var _applicationName : String;

private var dataManager : DataManager = DataManager.getInstance();

public function set dataProvider( value : XMLList ) : void
{
	if ( !value || value.length() == 0 )
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

	searchDataGrid.dataProvider = new HierarchicalData( value );
	searchDataGrid.selectedIndex = 0;
	searchDataGrid.validateNow();

}

private function expandAll() : void
{
	searchDataGrid.validateNow();
	searchDataGrid.expandAll();
}

private function collapseAll() : void
{
	searchDataGrid.validateNow();
	searchDataGrid.collapseAll();
}

private function goToEdit() : void
{
	var element : XML = XML( searchDataGrid.selectedItem );
	var pageID : String, objectID : String, applicationID : String;

	if ( element.name() == 'Object' )
	{
		applicationID = element.parent().parent().@ID;
		pageID = element.parent().@ID;
		objectID = element.@ID;
	}
	else if ( element.name() == 'Container' )
	{
		applicationID = element.parent().@ID;
		pageID = objectID = element.@ID;
	}
	else if ( element.name() == 'Application' )
	{
		applicationID = element.@ID;
	}

	var sre : SearchResultEvent = new SearchResultEvent( SearchResultEvent.SEARCH_OBJECT_SELECTED );
	sre.applicationId = applicationID;
	sre.pageId = pageID;
	sre.objectId = objectID;

	dispatchEvent( sre );
}

private function clear() : void
{
	dispatchEvent( new SearchResultEvent( SearchResultEvent.SEARCH_CLOSE ) );
}

private function labelFunction( item : Object, column : AdvancedDataGridColumn ) : String
{
	var xmlData : XML = item as XML;

	if ( xmlData == null )
		return "";

	if ( xmlData.name() == "Application" )
		return "Application: " + xmlData.@Name;
	
	else if ( xmlData.name() == "Container" )
		return "Page: " + xmlData.@Name;
	
	else if ( xmlData.name() == "Object" )
		return "Object: " + xmlData.@Name;
	
	return xmlData.@Name;
}

private function styleFunction( data : Object, column : AdvancedDataGridColumn ) : Object
{
	var xmlData : XML = data as XML;

	if ( xmlData == null )
		return {};

	if ( xmlData.name() == "Application" )
		return { fontWeight : "bold" };

	return {};
}