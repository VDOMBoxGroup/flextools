import flash.events.Event;

import mx.events.FlexEvent;

import vdom.controls.ApplicationDescription;
import vdom.events.ApplicationEditorEvent;
import vdom.managers.DataManager;

private var dataManager:DataManager = DataManager.getInstance();

private function showHandler():void
{
	registerEvent(true);
	
	var defaultValues:ApplicationDescription = new ApplicationDescription();
	
	defaultValues.id = dataManager.currentApplicationInformation.Id;
	defaultValues.name = dataManager.currentApplicationInformation.Name;
	defaultValues.description = dataManager.currentApplicationInformation.Description;
	defaultValues.iconId = dataManager.currentApplicationInformation.Icon;
	
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
			applicationEditorChanceledHandler
		);
	} else {
		
		applicationEditor.removeEventListener(
			ApplicationEditorEvent.APPLICATION_PROPERTIES_CHANGED, 
			applicationEditorChangedHandler
		);
		applicationEditor.removeEventListener(
			ApplicationEditorEvent.APPLICATION_PROPERTIES_CANCELED, 
			applicationEditorChanceledHandler
		);
	}
}

private function applicationEditorChangedHandler(event:ApplicationEditorEvent):void
{
	var d:* = '';
}

private function applicationEditorChanceledHandler(event:ApplicationEditorEvent):void
{
	dispatchEvent(new Event('applicationEdited'));
}