import flash.net.URLRequest;
import flash.net.navigateToURL;

import mx.core.Window;

import vdom.controls.resourceBrowser.ResourceBrowser;
import vdom.events.DataManagerEvent;
import vdom.events.ResourceBrowserEvent;
import vdom.managers.AlertManager;
import vdom.managers.AuthenticationManager;
import vdom.managers.DataManager;
import vdom.managers.PopUpWindowManager;

private var dataManager : DataManager = DataManager.getInstance();
private var authenticationManager : AuthenticationManager = AuthenticationManager.getInstance();
private var alertManager : AlertManager = AlertManager.getInstance();

private function showPreview() : void
{
	var hostname : String = authenticationManager.hostname;
	var applicationId : String = dataManager.currentApplicationId;
	var pageId : String = dataManager.currentPageId;
	navigateToURL( new URLRequest( 'http://' + hostname + '/' + applicationId + '/' + pageId ),
				   '_blank' );
}

private function registerEvent( flag : Boolean ) : void
{
	if ( flag )
	{
		dataManager.addEventListener( DataManagerEvent.LOAD_APPLICATION_COMPLETE, dataManager_applicationDataLoaded );
		dataManager.addEventListener( DataManagerEvent.PAGE_CHANGED, dataManager_pageChanged );
		dataManager.addEventListener( DataManagerEvent.OBJECT_CHANGED, dataManager_objectChanged );
	}
	else
	{
		dataManager.removeEventListener( DataManagerEvent.LOAD_APPLICATION_COMPLETE, dataManager_applicationDataLoaded );
		dataManager.removeEventListener( DataManagerEvent.PAGE_CHANGED, dataManager_pageChanged );
		dataManager.removeEventListener( DataManagerEvent.OBJECT_CHANGED, dataManager_objectChanged );
	}
}

private function switchToEdit() : void
{
	alertManager.showMessage( '' );
	registerEvent( false );
	selectedChild = components;
	placeCanvas.selectedIndex = 1;
}

private function showHandler() : void
{
	registerEvent( true );

	var applicationId : String = dataManager.currentApplicationId;

	if ( !applicationId )
		return ;

	if ( !dataManager.applicationStatus( applicationId ) || true ) // FIXME сделать проверку загруженности апликухи.
	{
		loadApplicationData();
		return ;
	}

	var pageId : String = dataManager.currentPageId;

	if ( !pageId && !dataManager.pageStatus( applicationId, pageId ) )
	{
		selectPage();
		return;
	}

	var objectId : String = dataManager.currentObjectId;

	if ( !objectId )
	{
		selectObject();
		return ;
	}

	switchToEdit();
}

private function hideHandler() : void
{

	placeCanvas.selectedIndex = 0;
	selectedChild = initModule;
	registerEvent( false );
}

private function loadApplicationData() : void
{
	alertManager.showMessage( "Load Application Data" );
	dataManager.loadApplication( dataManager.currentApplicationId );
}

private function selectPage() : void
{
	if ( dataManager.listPages && dataManager.listPages.length() > 0 )
	{
		var pageIndex : String = "";

		if ( dataManager.currentApplicationInformation )
			pageIndex = dataManager.currentApplicationInformation.Index[ 0 ];

		var page : XML = dataManager.listPages.( @ID == pageIndex )[ 0 ];

		if ( page )
			dataManager.changeCurrentPage( pageIndex );
		else
			dataManager.changeCurrentPage( dataManager.listPages[ 0 ].@ID )
	}
	else
	{
		switchToEdit();
	}
}

private function selectObject() : void
{
	if ( dataManager.currentPageId )
		dataManager.changeCurrentObject( dataManager.currentPageId );
}

private function resourceButton_clickHandler() : void
{
	var popUpWindowManager : PopUpWindowManager = PopUpWindowManager.getInstance();
	var rb : ResourceBrowser = new ResourceBrowser();
	rb.minWidth = 800;
	rb.minHeight = 600;
	rb.percentWidth = 100;
	rb.percentHeight = 100;
	
	rb.addEventListener( ResourceBrowserEvent.RESOURCE_SELECTED, resourceBrowser_selectedHandler );
	rb.addEventListener( ResourceBrowserEvent.RESOURCE_CANCELED, resourceBrowser_canceledHandler );
	
	popUpWindowManager.addPopUp( rb, "Resource Browser", this, false );
}

private function resourceBrowser_selectedHandler( event : ResourceBrowserEvent ) : void
{
	var popUpWindowManager : PopUpWindowManager = PopUpWindowManager.getInstance();
	popUpWindowManager.removePopUp( event.currentTarget );
}

private function resourceBrowser_canceledHandler( event : ResourceBrowserEvent ) : void
{
	var popUpWindowManager : PopUpWindowManager = PopUpWindowManager.getInstance();
	popUpWindowManager.removePopUp( event.currentTarget );
}

private function dataManager_applicationDataLoaded( event : DataManagerEvent ) : void
{
	alertManager.showMessage( "Load Page Data" );
	selectPage();
}

private function dataManager_pageChanged( event : DataManagerEvent ) : void
{
	selectObject();
}

private function dataManager_objectChanged( event : DataManagerEvent ) : void
{
	switchToEdit();
}