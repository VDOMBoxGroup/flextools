import flash.events.Event;

import mx.binding.utils.BindingUtils;
import mx.binding.utils.ChangeWatcher;
import mx.events.FlexEvent;

import vdom.events.AttributesPanelEvent;
import vdom.events.ClosablePanelEvent;
import vdom.events.DataManagerErrorEvent;
import vdom.events.DataManagerEvent;
import vdom.events.WorkAreaEvent;
import vdom.managers.AlertManager;
import vdom.managers.DataManager;

[ Bindable ]
private var dataManager : DataManager = DataManager.getInstance();

[ Bindable ]
private var help : String;

private var alertManager : AlertManager = AlertManager.getInstance();

private var objectsXML : XML;
private var publicData : Object;
private var applicationId : String;
private var topLevelObjectId : String;
private var watchers : Array;

override protected function updateDisplayList( unscaledWidth : Number, unscaledHeight : Number ) : void
{
	super.updateDisplayList( unscaledWidth, unscaledHeight );
	types.height = unscaledHeight;
	mainArea.height = unscaledHeight;
	panelContainer.height = unscaledHeight;
}

private function showHandler() : void
{
	watchers = [];

	registerEvent( true );
	
	mainArea.selectedChild.dispatchEvent( new FlexEvent( FlexEvent.SHOW ) );
	
	watchers.push( BindingUtils.bindProperty( types, "dataProvider", dataManager,
											  "listTypes" ), BindingUtils.bindProperty( pageList,
																						"dataProvider",
																						dataManager,
																						"listPages" ),
				   BindingUtils.bindProperty( pageList, "currentObject", dataManager,
											  "currentObject" ), BindingUtils.bindProperty( workArea,
																							"pageId",
																							dataManager,
																							"currentPageId" ),
				   BindingUtils.bindProperty( workArea, "objectId", dataManager,
											  "currentObjectId" ), BindingUtils.bindProperty( xmlEditor,
																							  "objectId",
																							  dataManager,
																							  "currentObjectId" ),
				   BindingUtils.bindProperty( attributesPanel, "dataProvider", dataManager,
											  "currentObject" ) );
}

private function hideHandler() : void
{
	for each ( var watcher : ChangeWatcher in watchers )
		watcher.unwatch();

	mainArea.selectedChild = workArea;
	mainArea.selectedChild.dispatchEvent( new FlexEvent( FlexEvent.HIDE ) );

	registerEvent( false );
}

private function registerEvent( flag : Boolean ) : void
{
	if ( flag )
	{
		workArea.addEventListener( WorkAreaEvent.CREATE_OBJECT, workArea_createObjectHandler );

		workArea.addEventListener( WorkAreaEvent.CHANGE_OBJECT, workArea_changeObjectHandler );

		workArea.addEventListener( WorkAreaEvent.PROPS_CHANGED, workArea_attributeChangedHandler );

//		panelContainer.addEventListener(
//			ClosablePanelEvent.PANEL_COLLAPSE,
//			panelContainer_panelOpeningHandler, true );

//		dataManager.addEventListener( DataManagerEvent.PAGE_DATA_LOADED, pageDataLoadedHandler );

		dataManager.addEventListener( DataManagerEvent.CREATE_OBJECT_COMPLETE, dataManager_objectCreatedHandler );

		dataManager.addEventListener( DataManagerEvent.OBJECT_CHANGED, dataManager_objectChangedHandler );

		dataManager.addEventListener( DataManagerEvent.DELETE_OBJECT_COMPLETE, dataManager_objectDeletedHandler );

		dataManager.addEventListener( DataManagerErrorEvent.SET_NAME_ERROR, dataManager_setNameErrorHandler );

		dataManager.addEventListener( DataManagerEvent.UPDATE_ATTRIBUTES_BEGIN, dataManager_updateAttributesBeginHandler );

		dataManager.addEventListener( DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE,
									  dataManager_updateAttributesCompleteHandler );

		dataManager.addEventListener( DataManagerEvent.MODIFY_RESOURCE_COMPLETE,
									  dataManager_updateAttributesCompleteHandler );

		attributesPanel.addEventListener( "propsChanged", attributesChangedHandler );

		attributesPanel.addEventListener( AttributesPanelEvent.DELETE_OBJECT, deleteObjectHandler );
	}
	else
	{
		workArea.removeEventListener( WorkAreaEvent.CREATE_OBJECT, workArea_createObjectHandler );

		workArea.removeEventListener( WorkAreaEvent.CHANGE_OBJECT, workArea_changeObjectHandler );

		workArea.removeEventListener( WorkAreaEvent.PROPS_CHANGED, workArea_attributeChangedHandler );

//		panelContainer.removeEventListener(
//			ClosablePanelEvent.PANEL_COLLAPSE,
//			panelContainer_panelOpeningHandler, true );

//		dataManager.removeEventListener( DataManagerEvent.PAGE_DATA_LOADED, pageDataLoadedHandler );

		dataManager.removeEventListener( DataManagerEvent.CREATE_OBJECT_COMPLETE,
										 dataManager_objectCreatedHandler );

		dataManager.removeEventListener( DataManagerEvent.OBJECT_CHANGED, dataManager_objectChangedHandler );

		dataManager.removeEventListener( DataManagerEvent.DELETE_OBJECT_COMPLETE,
										 dataManager_objectDeletedHandler );

		dataManager.removeEventListener( DataManagerErrorEvent.SET_NAME_ERROR, dataManager_setNameErrorHandler );

		dataManager.removeEventListener( DataManagerEvent.UPDATE_ATTRIBUTES_BEGIN,
										 dataManager_updateAttributesBeginHandler );

		dataManager.removeEventListener( DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE,
										 dataManager_updateAttributesCompleteHandler );

		dataManager.removeEventListener( DataManagerEvent.MODIFY_RESOURCE_COMPLETE,
										 dataManager_updateAttributesCompleteHandler );

		attributesPanel.removeEventListener( "propsChanged", attributesChangedHandler );

		attributesPanel.removeEventListener( AttributesPanelEvent.DELETE_OBJECT,
											 deleteObjectHandler );
	}
}

/* private function pageDataLoadedHandler( event : Event ) : void
   {
   workArea.visible = true;
 } */

private function attributesChangedHandler( event : Event ) : void
{
	dataManager.updateAttributes();
//attributesPanel.dataProvider = dataManager.currentObject; //FIXME <-- исправить!!!!!!
}


private function deleteObjectHandler( event : AttributesPanelEvent ) : void
{
	if ( event.objectId )
		;
	dataManager.deleteObject( event.objectId );
}

/* private function panelContainer_panelOpeningHandler(event : ClosablePanelEvent) : void
   {
   var dummy : * = "";
   //	event.stopPropagation();
 } */

private function workArea_createObjectHandler( event : Event ) : void
{
	var wae : WorkAreaEvent = WorkAreaEvent( event );
	dataManager.createObject( wae.typeId, wae.objectId, "", wae.props );
}

private function workArea_changeObjectHandler( event : WorkAreaEvent ) : void
{
	if ( event.objectId )
		dataManager.changeCurrentObject( event.objectId );
	else
		dataManager.changeCurrentObject( null );
}

private function workArea_attributeChangedHandler( event : WorkAreaEvent ) : void
{
	dataManager.updateAttributes( event.objectId, event.props );
}

private function dataManager_updateAttributesBeginHandler( event : DataManagerEvent ) : void
{
	var attrName : String;

	if ( !event.result )
	{
		workArea.lockItem( dataManager.currentObjectId );
		return ;
	}

	for each ( var attr : XML in event.result.* )
	{
		attrName = attr.@Name;
		if ( attrName == "top" || attrName == "left" )
			continue;

		workArea.lockItem( dataManager.currentObjectId );
		break;
	}
}

private function dataManager_updateAttributesCompleteHandler( event : DataManagerEvent ) : void
{
	workArea.updateObject( event.objectId );
//xmlEditor.dispatchEvent( new FlexEvent( FlexEvent.SHOW )); // <------ Error!
}

private function dataManager_objectCreatedHandler( event : DataManagerEvent ) : void
{
	workArea.createObject( event.result );
}

private function dataManager_objectChangedHandler( event : DataManagerEvent ) : void
{
	if ( !dataManager.currentPageId )
		return ;

	if ( !dataManager.currentObjectId )
		dataManager.changeCurrentObject( dataManager.currentPageId );
}

private function dataManager_objectDeletedHandler( event : DataManagerEvent ) : void
{
	workArea.deleteObject( event.objectId );
}

private function dataManager_setNameErrorHandler( event : DataManagerErrorEvent ) : void
{
	alertManager.showAlert( event.fault.faultString );
	var objectId : String = XML( event.fault.faultDetail ).ObjectID;
	workArea.updateObject( objectId );
}
