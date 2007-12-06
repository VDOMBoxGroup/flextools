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
import vdom.components.editor.containers.workAreaClasses.Item;
import vdom.components.editor.containers.workAreaClasses.WysiwygRadioButton;
import vdom.components.editor.containers.workAreaClasses.WysiwygCheckBox;
import mx.controls.Button;
import mx.controls.Text;
import mx.controls.Image;
import vdom.components.editor.managers.ResizeManager;
import vdom.components.editor.containers.workAreaClasses.WysiwygImage;

public class RenderManager implements IEventDispatcher
{
	private static var instance:RenderManager;
	
	private var soap:Soap;
	private var dispatcher:EventDispatcher;
	private var publicData:Object;
	private var resourceManager:ResourceManager;
	
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
		resourceManager = ResourceManager.getInstance();
	}
	
	public function renderWYSIWYG(applicationId:String, objectId:String):void {
		
		var parentId:String = '';
		var dyn:String = '1';
		
		soap.addEventListener(SoapEvent.RENDER_WYSIWYG_OK, renderWysiwygOkHandler);
		soap.renderWysiwyg(applicationId, objectId, parentId, dyn);
	}
	
	private function render(parentContainer:Item, source:XML):void {
		
		for each(var item:XML in source.*) {
			
			var objectName:String = item.name().localName;
			var objectID:String = item.@guid.toString();
			var parentID:String = parentContainer.objectID;
			
			switch(objectName) {
				
				case 'object':
				
					var viewObject:Item = new Item(item.@guid);
					
					viewObject.horizontalScrollPolicy = 'off';
					viewObject.verticalScrollPolicy = 'off';
					
					viewObject.x = item.@left;
					viewObject.y = item.@top;
						
					viewObject.parentID = parentContainer.objectID;
					
					parentContainer.addChild(viewObject);
					
					this.render(viewObject, item);
					
				break;
				
				case 'rectangle':
				
					var viewRectangle:Canvas = new Canvas()
					
					//properties
					viewRectangle.x = item.@left;
					viewRectangle.y = item.@top;
					viewRectangle.width = item.@width;
					viewRectangle.height = item.@height;
					viewRectangle.setStyle('borderStyle', 'solid');
					viewRectangle.setStyle('borderThickness', item.@border);
					viewRectangle.setStyle('borderColor', item.@color);
					viewRectangle.setStyle('backgroundColor', '#'+item.@fill);
					
					parentContainer.addChild(viewRectangle);
					
				break;
				
				case 'radiobutton':
					
					var viewRadiobutton:WysiwygRadioButton = new WysiwygRadioButton()
					
					viewRadiobutton.x = item.@left;
					viewRadiobutton.y = item.@top;
					viewRadiobutton.width = item.@width;
					viewRadiobutton.height = item.@height;
					viewRadiobutton.value = item.@value;
					viewRadiobutton.label = item.@label;
					
					if(item.@state == 'checked')
						viewRadiobutton.selected = true;
					
					
					viewRadiobutton.setStyle('fontStyle ', item.@font);
					viewRadiobutton.setStyle('color ', item.@color);
					
					parentContainer.addChild(viewRadiobutton);
					
				break;
				
				case 'checkbox':
				
					var viewCheckbox:WysiwygCheckBox = new WysiwygCheckBox()
					
					viewCheckbox.x = item.@left;
					viewCheckbox.y = item.@top;
					viewCheckbox.width = item.@width;
					viewCheckbox.height = item.@height;
					viewCheckbox.label = item.@label;
					if(item.@state == 'checked')
						viewCheckbox.selected = true;
					
					viewCheckbox.setStyle('fontStyle ', item.@font);
					viewCheckbox.setStyle('color ', item.@color);
					
					parentContainer.addChild(viewCheckbox);
					
				break;
				
				case 'button':
				
					var viewButton:Button = new Button()
							
					viewButton.x = item.@left;
					viewButton.y = item.@top;
					viewButton.width = item.@width;
					viewButton.height = item.@height;
					viewButton.label = item.@label;
					
					viewButton.setStyle('fontStyle ', item.@font);
					viewButton.setStyle('color ', item.@color);
					
					parentContainer.addChild(viewButton);
					
				break;
				
				case 'text':
					
					var viewText:Text = new Text()
					
					viewText.x = item.@left;
					viewText.y = item.@top;
					viewText.width = item.@width;
					viewText.height = item.@height;
					viewText.htmlText = item;
					viewText.selectable = false;
					viewText.setStyle('fontStyle ', item.@font);
					viewText.setStyle('color ', item.@color);
					
					parentContainer.addChild(viewText);
					
				break;
				
				case 'image':
					
					var viewImage:Image = new WysiwygImage()
					
					viewImage.x = item.@left;
					viewImage.y = item.@top;
					viewImage.width = item.@width;
					viewImage.height = item.@height;
					viewImage.maintainAspectRatio = false;
					
					resourceManager.loadResource(parentID, objectID, viewImage, 'source', true);
					
					parentContainer.addChild(viewImage);
				break;
			}
		}
	}
	
	private function renderWysiwygOkHandler(event:SoapEvent):void {
		
		var result:XML = event.result;
		var objectId:String = result.object.@guid;
		var mainContainer:Item = new Item(objectId);
		mainContainer.setStyle('backgroundColor', '#ffffff');
		mainContainer.setStyle('backgroundAlpha', '0');
		render(mainContainer, result);
		
		var rme:RenderManagerEvent = new RenderManagerEvent(RenderManagerEvent.RENDER_COMPLETE);
		rme.result = mainContainer;
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