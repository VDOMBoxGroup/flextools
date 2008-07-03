import flash.display.Bitmap;
import flash.display.DisplayObject;

import mx.core.Application;
import mx.graphics.codec.PNGEncoder;
import mx.managers.PopUpManager;

import vdom.MyLoader;
import vdom.controls.ImageChooser;
import vdom.events.DataManagerEvent;
import vdom.events.FileManagerEvent;
import vdom.events.ImageChooserEvent;
import vdom.managers.DataManager;
import vdom.managers.FileManager;

private var dataManager:DataManager;
private var fileManager:FileManager = FileManager.getInstance();

[Bindable]
private var _source:Bitmap;
private var _name:String = 'Application Icon';
private var _applicationId:String;

private var imageChooser:ImageChooser;
private var ppm:MyLoader;

private function creationCompleteHandler():void {
	
	dataManager = DataManager.getInstance();
}

private function showHandler():void {
	
	var iconClass:Class = Application.application.getStyle('appIconFile'); 
	_source = new iconClass(); 
}

private function hideHandler():void {
	
	applicationName.text = '';
	applicationDescription.text = '';
}

private function changeImage():void {
	
	imageChooser = new ImageChooser();
	imageChooser.addEventListener(ImageChooserEvent.APPLY, imageChooser_applyHandler);
	PopUpManager.addPopUp(imageChooser, DisplayObject(Application.application), true);
	PopUpManager.centerPopUp(imageChooser);
}

private function imageChooser_applyHandler(event:ImageChooserEvent):void {
	
	imageChooser.removeEventListener(ImageChooserEvent.APPLY, imageChooser_applyHandler);
	_source = event.resource;
	_name = event.name;
}

private function createApplication():void {
	
	ppm = new MyLoader();
	ppm.showText = 'Create Application';
	PopUpManager.addPopUp(ppm, DisplayObject(Application.application));
	PopUpManager.centerPopUp(ppm);
	
	var name:String = applicationName.text;
	var description:String = applicationDescription.text;
	
	dataManager.addEventListener(DataManagerEvent.APPLICATION_CREATED, dataManager_applicationCreatedHandler);
	dataManager.createApplication();
}

private function dataManager_applicationCreatedHandler(event:DataManagerEvent):void {
	
	dataManager.removeEventListener(DataManagerEvent.APPLICATION_CREATED, dataManager_applicationCreatedHandler);
	_applicationId = event.result.Application.@ID;
	
	ppm.showText = 'Send icon';
	
	var pnge:PNGEncoder = new PNGEncoder();
	var iconByteArray:ByteArray = pnge.encode(_source.bitmapData);
	
	fileManager.addEventListener(FileManagerEvent.RESOURCE_SAVED, fileManager_resourceSavedHandler);
	fileManager.setResource('png', _name, iconByteArray, _applicationId);
}

private function fileManager_resourceSavedHandler(event:FileManagerEvent):void {
	
	fileManager.removeEventListener(FileManagerEvent.RESOURCE_SAVED, fileManager_resourceSavedHandler);
	var resourceId:String = event.result.Resource.@id;
	
	ppm.showText = 'Apply properties';
	
	var attibutes:XML = 
		<Attributes>
    		<Name>{applicationName.text}</Name>
    		<Description>{applicationDescription.text}</Description>
    		<Icon>{resourceId}</Icon>
		</Attributes>

	dataManager.addEventListener(
		DataManagerEvent.APPLICATION_INFO_CHANGED, 
		dataManager_applicationInfoChangedHandler
	);
	
	dataManager.setApplicationInformation(_applicationId, attibutes);
}

private function dataManager_applicationInfoChangedHandler(event:DataManagerEvent):void {
	
	ppm.showText = '';
	PopUpManager.removePopUp(ppm);
}




