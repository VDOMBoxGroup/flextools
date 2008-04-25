package vdom.utils {
	
import flash.events.Event;
import flash.utils.Dictionary;

import mx.core.BitmapAsset;
import mx.core.UIComponent;

import vdom.managers.FileManager;
	
public class IconUtil extends BitmapAsset {
	
	private static var dictionary:Dictionary;
	private var fileManager:FileManager;
	
	public static function getClass( target:UIComponent, data:Object):Class {
		
		if(!dictionary) {
			dictionary = new Dictionary(false);
		}
		
		dictionary[target] = { data:data };
		
		return IconUtil;
	}
	
	public function IconUtil():void {
		
		fileManager = FileManager.getInstance();
		addEventListener(Event.ADDED, addedHandler)
	}
	
	public function set resource(resource:*):void {
		if(!parent)
			return;
		bitmapData = resource.data.bitmapData;
		
		var component:UIComponent = parent as UIComponent;
		component.invalidateSize();
	}
	
	private function addedHandler(event:Event):void {
		
		if(parent)
			getData(parent);
	}
	
	private function getData(object:Object):void {
		
		var data:Object = dictionary[object];
		
		if(data) {
			
			var source:Object = data.data;
			fileManager.loadResource(source.TypeId, source.resourceId, this);
		}
	}
}
}