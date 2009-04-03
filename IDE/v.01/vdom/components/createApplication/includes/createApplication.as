import mx.events.FlexEvent;

import vdom.controls.ApplicationDescription;
import vdom.events.ApplicationEditorEvent;
import vdom.events.DataManagerEvent;
import vdom.events.FileManagerEvent;
import vdom.managers.AlertManager;
import vdom.managers.DataManager;
import vdom.managers.FileManager;

private var dataManager : DataManager = DataManager.getInstance();
private var fileManager : FileManager = FileManager.getInstance();
private var alertManager : AlertManager = AlertManager.getInstance();

private var applicationDescription : ApplicationDescription;

private function registerEvent( flag : Boolean ) : void
{
	if ( flag )
	{
		applicationEditor.addEventListener( ApplicationEditorEvent.APPLICATION_PROPERTIES_CHANGED,
											propertiesChangedHandler );
		applicationEditor.addEventListener( ApplicationEditorEvent.APPLICATION_PROPERTIES_CANCELED,
											propertiesCanceledHandler );

		dataManager.addEventListener( DataManagerEvent.CREATE_APPLICATION_COMPLETE,
									  dataManager_applicationCreatedHandler );

		dataManager.addEventListener( DataManagerEvent.LOAD_APPLICATION_COMPLETE,
									  dataManager_applicationLoadedHandler );

		fileManager.addEventListener( FileManagerEvent.RESOURCE_SAVED, fileManager_resourceSavedHandler );

		dataManager.addEventListener( DataManagerEvent.SET_APPLICATION_INFO_COMPLETE,
									  dataManager_applicationInfoChangedHandler );

		dataManager.addEventListener( DataManagerEvent.CREATE_OBJECT_COMPLETE, dataManager_objectsCreatedHandler );
	}
	else
	{
		applicationEditor.removeEventListener( ApplicationEditorEvent.APPLICATION_PROPERTIES_CHANGED,
											   propertiesChangedHandler );
		applicationEditor.removeEventListener( ApplicationEditorEvent.APPLICATION_PROPERTIES_CANCELED,
											   propertiesCanceledHandler );

		dataManager.removeEventListener( DataManagerEvent.CREATE_APPLICATION_COMPLETE,
										 dataManager_applicationCreatedHandler );

		dataManager.removeEventListener( DataManagerEvent.LOAD_APPLICATION_COMPLETE,
										 dataManager_applicationLoadedHandler );

		fileManager.removeEventListener( FileManagerEvent.RESOURCE_SAVED, fileManager_resourceSavedHandler );

		dataManager.removeEventListener( DataManagerEvent.SET_APPLICATION_INFO_COMPLETE,
										 dataManager_applicationInfoChangedHandler );

		dataManager.removeEventListener( DataManagerEvent.CREATE_OBJECT_COMPLETE,
										 dataManager_objectsCreatedHandler );
	}
}

private function showHandler() : void
{
	registerEvent( true );
	applicationEditor.dispatchEvent( new FlexEvent( FlexEvent.SHOW ) );
}

private function hideHandler() : void
{
	registerEvent( false );
	applicationEditor.dispatchEvent( new FlexEvent( FlexEvent.HIDE ) );
}

private function propertiesChangedHandler( event : ApplicationEditorEvent ) : void
{
	applicationDescription = event.applicationDescription;

	alertManager.showMessage( "Create Application" );

	dataManager.createApplication();
}

private function propertiesCanceledHandler( event : ApplicationEditorEvent ) : void
{
	dispatchEvent( new Event( "applicationCreated" ) );
}

private function dataManager_applicationCreatedHandler( event : DataManagerEvent ) : void
{
	applicationDescription.id = event.result.Application.@ID;

	dataManager.changeCurrentApplication( applicationDescription.id );
	dataManager.loadApplication( applicationDescription.id );
}

private function dataManager_applicationLoadedHandler( event : DataManagerEvent ) : void
{
	alertManager.showMessage( "Send icon" );

	fileManager.setResource( "png", "applicationIcon", applicationDescription.icon,
							 applicationDescription.id );
}

private function fileManager_resourceSavedHandler( event : FileManagerEvent ) : void
{
	applicationDescription.iconId = event.result.Resource.@id;

	alertManager.showMessage( "Send information" );

	var attributes : XML =
		<Attributes>
			<Name>
				{applicationDescription.name}</Name>
			<Description>
				{applicationDescription.description}</Description>
			<Icon>
				{applicationDescription.iconId}</Icon>
			<ScriptingLanguage>
				{applicationDescription.scriptlanguage}</ScriptingLanguage>
		</Attributes>

	dataManager.setApplicationInformation( applicationDescription.id, attributes );
}

private function dataManager_applicationInfoChangedHandler( event : DataManagerEvent ) : void
{
	alertManager.showMessage( "Create Page" );

	var topLevelTypes : XMLList = dataManager.getTopLevelTypes();
	var HTMLType : XML = topLevelTypes.Information.( Name == "htmlcontainer" ).parent();
	var typeId : String = HTMLType.Information.ID;
	var attributes : XML =
		<Attributes>
			<Attribute Name="title">
				Home Page</Attribute>
		</Attributes>
		;

	dataManager.createObject( typeId, "", "Home_Page", attributes, applicationDescription.id );
}

private function dataManager_objectsCreatedHandler( event : DataManagerEvent ) : void
{
	alertManager.showMessage( "" );
	dispatchEvent( new Event( "applicationCreated" ) );
}