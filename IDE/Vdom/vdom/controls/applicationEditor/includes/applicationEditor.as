import flash.display.DisplayObject;
import flash.utils.ByteArray;

import mx.core.Application;
import mx.core.BitmapAsset;
import mx.events.ValidationResultEvent;
import mx.graphics.codec.PNGEncoder;
import mx.managers.PopUpManager;

import vdom.MyLoader;
import vdom.controls.ApplicationDescription;
import vdom.controls.ImageChooser;
import vdom.events.ApplicationEditorEvent;
import vdom.events.ImageChooserEvent;
import vdom.managers.FileManager;

private var fileManager:FileManager = FileManager.getInstance();

[Bindable]
public var formName:String = '';

public var defaultValues:ApplicationDescription;

[Bindable]
private var _source:ByteArray;

private var _name:String = 'Application Icon';
private var _applicationId:String;

private var imageChooser:ImageChooser;
private var ppm:MyLoader;

private var iconChanged:Boolean;

public function set source(value:ByteArray):void {
	
	_source = value;
}

private function changeImage():void 
{	
	imageChooser = new ImageChooser();
	imageChooser.addEventListener(ImageChooserEvent.APPLY, imageChooser_applyHandler);
	
	PopUpManager.addPopUp(imageChooser, DisplayObject(Application.application), true);
	PopUpManager.centerPopUp(imageChooser);
}

private function resetImage():void
{
	var iconClass:Class = Application.application.getStyle('appIconPersonalPages');
	var ba:BitmapAsset = new iconClass();
	var pnge:PNGEncoder = new PNGEncoder();
	_source = pnge.encode(ba.bitmapData);
	if(defaultValues.iconId && !iconChanged)
		iconChanged = true;
}

private function showHandler():void 
{	
	if(!defaultValues) {
		submitButton.label = "CREATE";
		defaultValues = new ApplicationDescription();
	} else {
		
		submitButton.label = "EDIT";
	}
		
	applicationName.text = defaultValues.name;
	applicationDescription.text = defaultValues.description;
	iconChanged = false;
	
	
	if(defaultValues.id && defaultValues.iconId){
		
		fileManager.loadResource(defaultValues.id, defaultValues.iconId, this, 'source', true);
	} else {
		
		var iconClass:Class = Application.application.getStyle('appIconPersonalPages'); 
		var ba:BitmapAsset = new iconClass();
		var pnge:PNGEncoder = new PNGEncoder();
		var byteArray:ByteArray = pnge.encode(ba.bitmapData);
		_source = byteArray;
		iconChanged = true;
	}
}

private function hideHandler():void
{
	defaultValues = null;
	iconChanged = false;
}

private function processValues():void
{	
	if(
		applicationName.text == defaultValues.name &&
		applicationDescription.text == defaultValues.description &&
		!iconChanged
	) {
		
		dispatchEvent(
			new ApplicationEditorEvent(
				ApplicationEditorEvent.APPLICATION_PROPERTIES_CANCELED
			)
		);
		return;
	}
	
	var aee:ApplicationEditorEvent = new ApplicationEditorEvent(
		ApplicationEditorEvent.APPLICATION_PROPERTIES_CHANGED);
	
	var ad:ApplicationDescription = new ApplicationDescription();
	
	ad.id = defaultValues.id;
	ad.name = applicationName.text;
	ad.description = applicationDescription.text;
	if(iconChanged)
		ad.icon = _source;
	
	aee.applicationDescription = ad;
	
	dispatchEvent(aee);
}

private function chancelValues():void
{
	dispatchEvent(
		new ApplicationEditorEvent(
			ApplicationEditorEvent.APPLICATION_PROPERTIES_CANCELED
		)
	);
}

private function handleValid(event:ValidationResultEvent):void
{
	if(event.type==ValidationResultEvent.VALID)
		submitButton.enabled = true;
	else
		submitButton.enabled = false;
}

private function imageChooser_applyHandler(event:ImageChooserEvent):void
{	
	imageChooser.removeEventListener(ImageChooserEvent.APPLY, imageChooser_applyHandler);
	_source = event.resource;
	iconChanged = true;
}