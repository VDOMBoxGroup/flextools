import flash.events.Event;

import mx.binding.utils.BindingUtils;
import mx.binding.utils.ChangeWatcher;
import mx.core.Application;
import mx.events.ListEvent;

import vdom.events.DataManagerEvent;
import vdom.events.SearchPanelEvent;
import vdom.events.SearchResultEvent;
import vdom.managers.AlertManager;
import vdom.managers.DataManager;

[Bindable]
private var dataManager:DataManager = DataManager.getInstance();

private var watchers:Array = [];
private var alertManager:AlertManager = AlertManager.getInstance();

private var applicationId:String;
private var pageId:String;
private var objectId:String;


/* private function creationCompleteHandler():void
{	
	dispatchEvent( new FlexEvent( FlexEvent.SHOW ));
} */

private function showHandler():void
{	
	registerEvent( true );
	registerWatchers( true );
	
	listApplicationContainer.enabled = true;
	searchPanel.enabled = true;
	
	selectedChild = components;
	
	if( listApplicationContainer.applicationId )
		mainViewStack.selectedChild = applicationProperties;
	else
		mainViewStack.selectedIndex = 0;
}

private function hideHandler():void
{
	registerEvent( false );
	registerWatchers( false );
	
	listApplicationContainer.dataProvider = null;
	mainViewStack.selectedIndex = 0;
	selectedChild = initModule;
}

private function registerEvent( flag : Boolean ) : void
{	
	if( flag )
	{
		searchPanel.addEventListener( SearchPanelEvent.SEARCH_PARAM_CHANGED, searchPanel_searchHandler );
		listApplicationContainer.addEventListener( "applicationChanged", applicationChangedHandler );
		
		createApplication.addEventListener( "createApplication", createApplicationHandler );
		createApplication.addEventListener( "applicationCreated", switchToProperties );
		applicationProperties.addEventListener( "editCurrentApplication", switchToEdit );
		editApplication.addEventListener( "applicationEdited", switchToProperties );
		searchResult.addEventListener( SearchResultEvent.SEARCH_OBJECT_SELECTED, searchResult_searchHandler );
		searchResult.addEventListener( SearchResultEvent.SEARCH_CLOSE, switchToProperties );
	}
	else
	{
		searchPanel.removeEventListener( SearchPanelEvent.SEARCH_PARAM_CHANGED, searchPanel_searchHandler );
		listApplicationContainer.removeEventListener( "applicationChanged", applicationChangedHandler );
		
		createApplication.removeEventListener( "createApplication", createApplicationHandler );
		createApplication.removeEventListener( "applicationCreated", switchToProperties );
		applicationProperties.removeEventListener( "editCurrentApplication", switchToEdit );
		editApplication.removeEventListener( "applicationEdited", switchToProperties );
		searchResult.removeEventListener( SearchResultEvent.SEARCH_OBJECT_SELECTED, searchResult_searchHandler );
		searchResult.removeEventListener( SearchResultEvent.SEARCH_CLOSE, switchToProperties );
	}
}

private function registerWatchers( flag:Boolean ) : void
{	
	if( flag )
	{
		watchers.push(
			BindingUtils.bindProperty( searchPanel, "listApplication", dataManager, "listApplication" ),
			BindingUtils.bindProperty( searchPanel, "applicationId", dataManager, "currentApplicationId" ),
			BindingUtils.bindProperty( listApplicationContainer, "dataProvider", dataManager, "listApplication" ),
			BindingUtils.bindProperty( listApplicationContainer, "applicationId", dataManager, "currentApplicationId" ),
			BindingUtils.bindProperty( applicationInformation, "dataProvider", dataManager, "currentApplicationInformation" )
		 );
	}
	else
	{
		for each( var watcher : ChangeWatcher in watchers )
		{
			watcher.unwatch();
		}
	}
}

private function switchToCreate():void
{
	listApplicationContainer.enabled = false;
	searchPanel.enabled = false;
	mainViewStack.selectedChild = createApplication
}

private function switchToEdit( event:Event ):void
{
	listApplicationContainer.enabled = false;
	searchPanel.enabled = false;
	mainViewStack.selectedChild = editApplication;
}

private function switchToProperties( event:Event ):void
{
	listApplicationContainer.enabled = true;
	searchPanel.enabled = true;
	mainViewStack.selectedChild = applicationProperties;
}

private function switchToSearch( event:Event ):void
{
	listApplicationContainer.enabled = false;
	searchPanel.enabled = true;
	mainViewStack.selectedChild = searchResult;
}

private function createApplicationHandler( event:Event ):void
{	
	mainViewStack.selectedChild = mainCanvas;
}

private function applicationChangedHandler( event:ListEvent ):void
{	
	dataManager.changeCurrentApplication( listApplicationContainer.applicationId );
}

private function searchPanel_searchHandler( event:SearchPanelEvent ):void
{
	dataManager.addEventListener( DataManagerEvent.SEARCH_COMPLETE, dataManager_searchCompleteHandler );
	dataManager.search( event.applicationId, event.searchString );
}

private function searchResult_searchHandler( event:SearchResultEvent ):void
{
	mainViewStack.selectedIndex = 0;
	
	applicationId = event.applicationId;
	pageId = event.pageId;
	objectId = event.objectId;
	
	dataManager.addEventListener(
		DataManagerEvent.LOAD_APPLICATION_COMPLETE,
		dataManager_applicationDataLoaded
	 );
	
	alertManager.showMessage( "Load Application Data" );
	
	dataManager.loadApplication( applicationId );
}

private function dataManager_searchCompleteHandler( event:DataManagerEvent ):void
{
	dataManager.removeEventListener( DataManagerEvent.SEARCH_COMPLETE, dataManager_searchCompleteHandler );
	searchResult.dataProvider = event.result.*;
	switchToSearch( new Event( "z" ));
}

private function dataManager_applicationDataLoaded( event:DataManagerEvent ):void
{
	dataManager.removeEventListener(
		DataManagerEvent.LOAD_APPLICATION_COMPLETE,
		dataManager_applicationDataLoaded
	 );
	
	if( !pageId )
	{
		Application.application.switchToModule( "editor" );
		return;
	}
	
	dataManager.addEventListener(
		DataManagerEvent.PAGE_CHANGED,
		dataManager_pageChanged
	 );
	
	alertManager.showMessage( "Load Page Data" );
	
	dataManager.changeCurrentPage( pageId );
}

private function dataManager_pageChanged( event:DataManagerEvent ):void
{
	dataManager.removeEventListener(
		DataManagerEvent.PAGE_CHANGED,
		dataManager_pageChanged
	 );
	
	dataManager.addEventListener(
		DataManagerEvent.OBJECT_CHANGED,
		dataManager_objectChanged
	 );
	
	dataManager.changeCurrentObject( objectId );
}

private function dataManager_objectChanged( event:DataManagerEvent ):void
{
	dataManager.removeEventListener(
		DataManagerEvent.OBJECT_CHANGED,
		dataManager_objectChanged
	 );
	
	dispatchEvent( new SearchResultEvent( SearchResultEvent.SEARCH_OBJECT_SELECTED ));
	
	alertManager.showMessage( "" );
	
	Application.application.switchToModule( "editor" );
}
