package vdom.components.editor.containers.typesClasses {

import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.ByteArray;

import mx.containers.VBox;
import mx.controls.Image;
import mx.controls.Label;
import mx.core.DragSource;
import mx.utils.Base64Decoder;

import vdom.managers.VdomDragManager;

public class Type extends VBox {
	protected var _id:String;
	
	private var typeIcon:Image;
	private var typeLabel:Label;
	
	private var loader:Loader;
	private var iconData:Bitmap;
	
	public function Type(id:String, iconSource:String, label:String) {
		
		super();
		this._id = id;
		if(iconSource != '') {
			typeIcon = new Image();
			typeIcon.width = 40;
			typeIcon.height = 40;
			typeIcon.setStyle('backgroundColor', '#FF00FF');
		}
		
		typeLabel = new Label();
		typeLabel.text = label;
		typeLabel.truncateToFit = true;
		typeLabel.width = 90;
		
		addChild(typeIcon);
		addChild(typeLabel);
		
		this.addEventListener(MouseEvent.MOUSE_DOWN, dragIt);
	}
	
	public function set resource(imageResource:String):void {
		
		var decoder:Base64Decoder = new Base64Decoder();
		decoder.decode(imageResource);
		
		var imageSource:ByteArray = decoder.drain();
		imageSource.uncompress();
		
		loader = new Loader();
		loader.loadBytes(imageSource);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
	}
	
	private function loadComplete(event:Event):void {
		
		iconData = Bitmap(loader.content);
		typeIcon.source = Bitmap(iconData);
	}
	
	private function dragIt(event:MouseEvent):void {
		
		var dragInitiator:Type = Type(event.currentTarget);
		var ds:DragSource = new DragSource();
		var dataObject:Object = {typeId:_id, offX:dragInitiator.mouseX, offY:dragInitiator.mouseY};
		ds.addData(dataObject, 'Object');
		
		var proxy:Image = new Image();
		proxy.setStyle('backgroundColor', '#FF00FF');
		proxy.width = 40;
		proxy.height = 40;
		proxy.source = new Bitmap(iconData.bitmapData);
		
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