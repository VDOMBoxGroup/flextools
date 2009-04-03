import flash.display.DisplayObject;
import flash.events.Event;

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

private var defaultValues:ApplicationDescription;
private var newValues:ApplicationDescription;

private var changeResource:Boolean = false;
private var changeInformation:Boolean = false;

private function showHandler():void
{
	registerEvent(true);
	
	defaultValues = new ApplicationDescription();
	
	var applicationInformation:XML = dataManager.currentApplicationInformation;
	
	defaultValues.id = applicationInformation.Id;
	defaultValues.name = applicationInformation.Name;
	defaultValues.description = applicationInformation.Description;
	defaultValues.iconId = applicationInformation.Icon;
	defaultValues.scriptlanguage = applicationInformation.Scriptinglanguage;
	
	applicationEditor.defaultValues = defaultValues;
	applicationEditor.dispatchEvent(new FlexEvent(FlexEvent.SHOW));
}

private function hideHandler():void
{
	registerEvent(false);
	applicationEditor.dispatchEvent(new FlexEvent(FlexEvent.HIDE));
}

private function registerEvent(flag:Boolean):void
{	
	if(flag) {
		
		applicationEditor.addEventListener(
			ApplicationEditorEvent.APPLICATION_PROPERTIES_CHANGED, 
			applicationEditorChangedHandler
		);
		applicationEditor.addEventListener(
			ApplicationEditorEvent.APPLICATION_PROPERTIES_CANCELED, 
			applicationEditorCanceledHandler
		);
	} else {
		
		applicationEditor.removeEventListener(
			ApplicationEditorEvent.APPLICATION_PROPERTIES_CHANGED, 
			applicationEditorChangedHandler
		);
		applicationEditor.removeEventListener(
			ApplicationEditorEvent.APPLICATION_PROPERTIES_CANCELED, 
			applicationEditorCanceledHandler
		);
	}
}

private function setResource():void
{
	ppm.showText = 'Send icon';
	
	fileManager.addEventListener(FileManagerEvent.RESOURCE_SAVED, fileManager_resourceSavedHandler);
	fileManager.setResource('png', 'applicationIcon', newValues.icon, newValues.id);
}

private function setInformation():void
{
	ppm.showText = 'Send information';
	
	var attributes:XML = <Attributes />;
	
	if(newValues.name != defaultValues.name)
		attributes.appendChild(<Name>{newValues.name}</Name>);
	
	if(newValues.description != defaultValues.description)
		attributes.appendChild(<Description>{newValues.description}</Description>);
	
	if(newValues.scriptlanguage != defaultValues.scriptlanguage)
		attributes.appendChild(<Scriptinglanguage>{newValues.scriptlanguage}</Scriptinglanguage>);
	
	if(newValues.iconId && newValues.iconId != defaultValues.iconId)
		attributes.appendChild(<Icon>{newValues.iconId}</Icon>);
	
	dataManager.addEventListener(
		DataManagerEvent.SET_APPLICATION_INFO_COMPLETE, 
		dataManager_applicationInfoChangedHandler
	);
	
	dataManager.setApplicationInformation(newValues.id, attributes);
}

private function applicationEditorChangedHandler(event:ApplicationEditorEvent):void
{
	newValues = event.applicationDescription;
	
	if(newValues.icon)
		changeResource = changeInformation = true;
	
	if(
		newValues.name != defaultValues.name ||
		newValues.description != defaultValues.description ||
		newValues.scriptlanguage != defaultValues.scriptlanguage
	)
		changeInformation = true;
	
	ppm = new MyLoader();
	PopUpManager.addPopUp(ppm, DisplayObject(Application.application), true);
	PopUpManager.centerPopUp(ppm);
	
	if(changeResource) {
		
		setResource();
		return;
	}
	
	if(changeInformation) {
		
		setInformation();
		return;
	}
	
	dispatchEvent(new Event('applicationEdited'));
}

private function applicationEditorCanceledHandler(event:ApplicationEditorEvent):void
{
	dispatchEvent(new Event('applicationEdited'));
}

private function fileManager_resourceSavedHandler(event:FileManagerEvent):void
{
	changeResource = false;
	newValues.iconId = event.result.Resource.@id;
	
	setInformation();
}

private function dataManager_applicationInfoChangedHandler(event:DataManagerEvent):void
{
	changeInformation = false;
	
	ppm.showText = '';
	PopUpManager.removePopUp(ppm);
	dispatchEvent(new Event('applicationEdited'));
}