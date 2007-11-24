package vdom.managers
{
import flash.events.IEventDispatcher;

import vdom.connection.soap.Soap;
import flash.events.Event;
import mx.core.Application;
import flash.events.EventDispatcher;
import vdom.connection.soap.SoapEvent;
import mx.containers.Canvas;
import flash.display.DisplayObject;
import mx.charts.CandlestickChart;
import mx.states.SetStyle;
import vdom.events.RenderManagerEvent;

public class RenderManager implements IEventDispatcher
{
	private static var instance:RenderManager;
	
	private var soap:Soap;
	private var dispatcher:EventDispatcher;
	private var publicData:Object;
	public var src:Canvas;
	
	/**
	 * 
	 * @return instance of RenderManager class (Singleton)
	 * 
	 */
	public static function getInstance():RenderManager {
		
		if (!instance) {
			
			instance = new RenderManager();
		}

		return instance;
	}
	
	public function RenderManager() {
		
		if (instance)
			throw new Error("Instance already exists.");
		
		dispatcher = new EventDispatcher();
		soap = Soap.getInstance();
		publicData = mx.core.Application.application.publicData;
	}
	
	public function getWysiwyg(applicationId:String, objectId:String):void {
		
		var parentId:String = '';
		var dyn:String = '1';
		
		soap.addEventListener(SoapEvent.RENDER_WYSIWYG_OK, renderWysiwygComleteHandler);
		soap.renderWysiwyg(applicationId, objectId, parentId, dyn);
	}
	
	private function render(source:XML, parent:Canvas = null):void {
		
		for each(var item:XML in source.*) {
			
			var name:String = item.name().localName;
			
			switch(name) {
				
				case 'rectangle':
					var rectangle:Canvas = new Canvas()
					parent.addChild(rectangle);
					rectangle.x = item.@left;
					rectangle.y = item.@left;
					rectangle.width = item.@width;
					rectangle.height = item.@height;
					//trace('--> rectangle: '+rectangle.x+'|'+rectangle.y+'|'+rectangle.width+'|'+rectangle.height);
					rectangle.setStyle('backgroundColor', '#ff00ff');
					//rectangle.setStyle('borderThickness', '1');
					rectangle.setStyle('backgroundAlpha', '.3');
					//rectangle.setStyle('borderColor', '#00ff00');
					//rectangle.setStyle('borderStyle', 'solid');
					
				break;
				case 'text':
					var text:Canvas = new Canvas()
					parent.addChild(text);
					text.x = item.@left;
					text.y = item.@top;
					text.width = item.@width;
					text.height = item.@height;
					//trace('--> text: '+text.x+'|'+text.y+'|'+text.width+'|'+text.height);
					text.setStyle('backgroundColor', '#ffff00');
					//text.setStyle('borderThickness', '1');
					text.setStyle('backgroundAlpha', '.3');
					//text.setStyle('borderColor', '#00ff00');
					//text.setStyle('borderStyle', 'solid');
					
				break;
				case 'object':
					var obj:Canvas = new Canvas();
					obj.horizontalScrollPolicy = 'off';
					obj.verticalScrollPolicy = 'off';
					parent.addChild(obj);
					obj.x = item.@left;
					obj.y = item.@top;
					if(int(item.@width) != 0)
						obj.width = item.@width;
					if(int(item.@height) != 0)
						obj.height = item.@height;
					//trace('--> obj: '+obj.x+'|'+obj.y+'|'+obj.width+'|'+obj.height);
					obj.setStyle('backgroundColor', '#000000');
					//obj.setStyle('borderThickness', '1');
					obj.setStyle('backgroundAlpha', '.3');
					//obj.setStyle('borderColor', '#000000');
					//obj.setStyle('borderStyle', 'solid');
					this.render(item, obj);
				break;
			}
		}
	}
	
	private function renderWysiwygComleteHandler(event:SoapEvent):void {
		
		var result:XML = event.result;
		
		src = new Canvas();
		render(result, src);
		
		var rme:RenderManagerEvent = new RenderManagerEvent(RenderManagerEvent.RENDER_COMPLETE);
		rme.result = src;
		
		dispatchEvent(rme);
	}
	
	
	
	/**
     *  @private
     */
	public function addEventListener(
		type:String, 
		listener:Function, 
		useCapture:Boolean = false, 
		priority:int = 0, 
		useWeakReference:Boolean = false):void {
			dispatcher.addEventListener(type, listener, useCapture, priority);
	}
    /**
     *  @private
     */
	public function dispatchEvent(evt:Event):Boolean{
		return dispatcher.dispatchEvent(evt);
	}
    
	/**
     *  @private
     */
	public function hasEventListener(type:String):Boolean{
		return dispatcher.hasEventListener(type);
	}
    
	/**
     *  @private
     */
	public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
		dispatcher.removeEventListener(type, listener, useCapture);
	}
    
    /**
     *  @private
     */            
	public function willTrigger(type:String):Boolean {
		return dispatcher.willTrigger(type);
	}
}
}