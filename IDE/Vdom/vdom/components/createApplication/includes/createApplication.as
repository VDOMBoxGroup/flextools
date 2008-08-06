import flash.display.DisplayObject;

import mx.core.Application;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;

import vdom.MyLoader;
import vdom.controls.ApplicationDescription;
import vdom.events.ApplicationEditorEvent;
import vdom.events.DataManagerEvent;
import vdom.events.FileManagerEvent;
import vdom.managers.DataManager;
import vdom.managers.FileManager;

private var dataManager:DataManager = DataManager.getInstance();
private var fileManager:FileManager = FileManager.getInstance();

private var ppm:MyLoader;
private var applicationDescription:ApplicationDescription;

private function showHandler():void
{
	registerEvent(true);
	applicationEditor.dispatchEvent(new FlexEvent(FlexEvent.SHOW));
}		

private function hideHandler():void
{
	registerEvent(false);
	applicationEditor.dispatchEvent(new FlexEvent(FlexEvent.HIDE));
}

private function registerEvent(flag:Boolean):void
{	
	if(flag)
	{
		applicationEditor.addEventListener(
			ApplicationEditorEvent.APPLICATION_PROPERTIES_CHANGED, propertiesChangedHandler
		);
		applicationEditor.addEventListener(
			ApplicationEditorEvent.APPLICATION_PROPERTIES_CANCELED, propertiesCanceledHandler
		);	
	}
	else
	{
		applicationEditor.removeEventListener(
			ApplicationEditorEvent.APPLICATION_PROPERTIES_CHANGED, propertiesChangedHandler
		);
		applicationEditor.removeEventListener(
			ApplicationEditorEvent.APPLICATION_PROPERTIES_CANCELED, propertiesCanceledHandler
		);
	}
}

private function propertiesChangedHandler(event:ApplicationEditorEvent):void
{	
	applicationDescription = event.applicationDescription;
	
	ppm = new MyLoader();
	ppm.showText = 'Create Application';
	PopUpManager.addPopUp(ppm, DisplayObject(Application.application), true);
	PopUpManager.centerPopUp(ppm);
	
	dataManager.addEventListener(DataManagerEvent.APPLICATION_CREATED, dataManager_applicationCreatedHandler);
	dataManager.createApplication();
}

private function propertiesCanceledHandler(event:ApplicationEditorEvent):void
{
	dispatchEvent(new Event('applicationCreated'));
}

private function dataManager_applicationCreatedHandler(event:DataManagerEvent):void
{	
	dataManager.removeEventListener(DataManagerEvent.APPLICATION_CREATED, dataManager_applicationCreatedHandler);
	applicationDescription.id = event.result.Application.@ID;
	
	dataManager.changeCurrentApplication(applicationDescription.id);
	
	dataManager.addEventListener(DataManagerEvent.APPLICATION_DATA_LOADED, dataManager_applicationLoadedHandler);
	dataManager.loadApplication(applicationDescription.id);
}

private function dataManager_applicationLoadedHandler(event:DataManagerEvent):void
{
	dataManager.removeEventListener(DataManagerEvent.APPLICATION_DATA_LOADED, dataManager_applicationLoadedHandler);
	ppm.showText = 'Send icon';
	
	fileManager.addEventListener(FileManagerEvent.RESOURCE_SAVED, fileManager_resourceSavedHandler);
	fileManager.setResource('png', 'applicationIcon', applicationDescription.icon, applicationDescription.id);
} 

private function fileManager_resourceSavedHandler(event:FileManagerEvent):void
{	
	fileManager.removeEventListener(FileManagerEvent.RESOURCE_SAVED, fileManager_resourceSavedHandler);
	applicationDescription.iconId = event.result.Resource.@id;
	
	ppm.showText = 'Send information';
	
	var attributes:XML = 
		<Attributes>
    		<Name>{applicationDescription.name}</Name>
    		<Description>{applicationDescription.description}</Description>
    		<Icon>{applicationDescription.iconId}</Icon>
		</Attributes>

	dataManager.addEventListener(
		DataManagerEvent.APPLICATION_INFO_CHANGED, 
		dataManager_applicationInfoChangedHandler
	);
	
	dataManager.setApplicationInformation(applicationDescription.id, attributes);
} 

private function dataManager_applicationInfoChangedHandler(event:DataManagerEvent):void 
{
	dataManager.removeEventListener(
		DataManagerEvent.APPLICATION_INFO_CHANGED, 
		dataManager_applicationInfoChangedHandler
	);
	
	ppm.showText = 'Create Page';
	
	var topLevelTypes:XMLList = dataManager.getTopLevelTypes();
	var HTMLType:XML = topLevelTypes.Information.(Name == 'htmlcontainer').parent();
	var typeId:String = HTMLType.Information.ID;
	var attributes:XML =
		<Attributes>
    		<Attribute Name="title">Home Page</Attribute>
		</Attributes>;
	
	dataManager.addEventListener(
		DataManagerEvent.OBJECTS_CREATED, 
		dataManager_objectsCreatedHandler
	);
	
	dataManager.createObject(typeId, '', 'Home_Page', attributes, applicationDescription.id);
} 

private function dataManager_objectsCreatedHandler(event:DataManagerEvent):void
{
//	dataManager.changeCurrentApplication(applicationDescription.id);
	
	PopUpManager.removePopUp(ppm);
	dispatchEvent(new Event('applicationCreated'));
}