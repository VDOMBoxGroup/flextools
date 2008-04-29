package vdom.components.edit.containers.typeAccordionClasses{

import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.ByteArray;

import mx.containers.VBox;
import mx.controls.Image;
import mx.controls.Label;
import mx.core.DragSource;

import vdom.managers.VdomDragManager;

public class Type extends VBox {
	protected var _id:String;
	
	private var typeIcon:Image;
	private var typeLabel:Label;
	
	private var loader:Loader;
	private var iconData:ByteArray;
	
	public var aviableContainers:String;
	
	public function Type(typeDescription:XML) {
		
		super();
		this.visible = true;
		this._id = typeDescription.Information.ID;
		if(typeDescription.Information.Icon != '') {
			typeIcon = new Image();
			typeIcon.width = 58;
			typeIcon.height = 58;
			typeIcon.setStyle('backgroundColor', '#FF00FF');
		}
		
		var phraseRE:RegExp = /#Lang\((\w+)\)/;
		var displayName:String = typeDescription.Information.DisplayName.toString();
		
		var phraseID:String = displayName.match(phraseRE)[1];
			
		typeLabel = new Label();
		typeLabel.text = resourceManager.getString(typeDescription.Information.Name, phraseID);
		typeLabel.truncateToFit = true;
		typeLabel.width = 90;
		
		addChild(typeIcon);
		addChild(typeLabel);
		
		this.addEventListener(MouseEvent.MOUSE_DOWN, dragIt);
	}
	
	/* private function getLanguagePhrase(typeID:String, phraseID:String):String {
		
		var phraseRE:RegExp = /#Lang\((\w+)\)/;
		phraseID = phraseID.match(phraseRE)[1];
		var languageID:String = typeID + '-' + phraseID;
		//var languages:LanguageManager = LanguageManager.getInstance();
		return ''//languages.language.(@ID == languageID)[0];
	} */
	
	public function set resource(imageResource:Object):void {
		
		iconData = imageResource.data;
		typeIcon.source = iconData;
		this.visible = true;
		/* var decoder:Base64Decoder = new Base64Decoder();
		decoder.decode(imageResource);
		
		var imageSource:ByteArray = decoder.drain();
		imageSource.uncompress();
		
		loader = new Loader();
		loader.loadBytes(imageSource);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete); */
	}
	
	/* private function loadComplete(event:Event):void {
		
		iconData = Bitmap(loader.content);
		typeIcon.source = Bitmap(iconData);
	} */
	
	private function dragIt(event:MouseEvent):void {
		
		var dragInitiator:Type = Type(event.currentTarget);
		var ds:DragSource = new DragSource();
		
		var dataObject:Object = {
			typeId:_id, 
			aviableContainers:aviableContainers, 
			offX:dragInitiator.mouseX, 
			offY:dragInitiator.mouseY
		};
		
		ds.addData(dataObject, 'typeDescription');
		
		var proxy:Image = new Image();
		//proxy.setStyle('backgroundColor', '#FF00FF');
		proxy.width = 58;
		proxy.height = 58;
		proxy.source = iconData;
		
		VdomDragManager.doDrag(
			dragInitiator, 
			ds, 
			event, 
			proxy, 
			proxy.width/2 - dragInitiator.mouseX, 
			proxy.height/2 - dragInitiator.mouseY
		);
		
	}
}
}