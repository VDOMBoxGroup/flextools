package vdom.managers
{
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;

import mx.containers.Canvas;
import mx.controls.Button;
import mx.controls.Image;
import mx.controls.Text;
import mx.controls.TextArea;
import mx.core.Application;
import mx.core.Container;
import mx.core.UIComponent;
import mx.events.DragEvent;

import vdom.components.editor.containers.workAreaClasses.Item;
import vdom.components.editor.containers.workAreaClasses.WysiwygCheckBox;
import vdom.components.editor.containers.workAreaClasses.WysiwygImage;
import vdom.components.editor.containers.workAreaClasses.WysiwygRadioButton;
import vdom.components.editor.managers.ResizeManager;
import vdom.connection.soap.Soap;
import vdom.connection.soap.SoapEvent;
import vdom.events.RenderManagerEvent;
import mx.collections.XMLListCollection;
import mx.collections.Sort;
import mx.collections.SortField;

public class RenderManager implements IEventDispatcher
{
	private static var instance:RenderManager;
	
	private var soap:Soap;
	private var dispatcher:EventDispatcher;
	private var publicData:Object;
	private var resourceManager:ResourceManager;
	
	private var _container:Container;
	private var applicationId:String;
	private var _items:Object;
	private var _source:XML;
	
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
		_items = {};
		soap.addEventListener(SoapEvent.RENDER_WYSIWYG_OK, renderWysiwygOkHandler);
	}
	
	/* public function renderWYSIWYG(applicationId:String, objectId:String, parentId:String):void {
		
		var dyn:String = '1';
		
		soap.addEventListener(SoapEvent.RENDER_WYSIWYG_OK, renderWysiwygOkHandler);
		soap.renderWysiwyg(applicationId, objectId, parentId, dyn);
	} */
	
	public function removeItem(id:String):void {
		
		
	}
	
	public function refreshItem(objectID:String, parentId:String):void {
		
		
	}
	
	public function init(destContainer:Container, applicationId:String = null):void {
		
		_container = destContainer;
		
		if(!applicationId)
			this.applicationId = publicData['applicationId'];
			
	}
	
	public function addItem(objectId:String, parentId:String):void {
		
		var item:Item = new Item(objectId);
		_items[objectId] = item;
		_items[parentId].addChild(item);
		item.visible = false;
		
		item.setStyle('backgroundColor', '#ffffff');
		item.setStyle('backgroundAlpha', '0');
		
		soap.renderWysiwyg(publicData['applicationId'], objectId, parentId);
	}
	
	public function deleteItem(objectId:String, parentId:String):void {
		
		
	}
	
	public function updateItem(objectId:String, parentId:String):void {
		
		if(parentId == '') {
			
			_container.removeAllChildren();
			
			var mainItem:Item = new Item(objectId);
			
			_container.addChild(mainItem);
			
			mainItem.setStyle('backgroundColor', '#ffffff');
			mainItem.setStyle('backgroundAlpha', '0');
			mainItem.visible = false;
			_items[objectId] = mainItem;
			
		} else {
			
			_items[objectId].removeAllChildren();
		}
		
		soap.renderWysiwyg(applicationId, objectId, parentId);
			
	}
	
	private function renderWysiwygOkHandler(event:SoapEvent):void {
		
		_source = event.result;
		
		var objectId:String = _source.object.@guid;
		
		var container:Item = _items[objectId];
		
		container.x = _source.object.@left;
		container.y = _source.object.@top;
			
		if(_source.@width.length())
			container.width = _source.@width;
			
		if(_source.@height.length())
			container.height = _source.@height;
		
		var staticContainer:Boolean = false;
		//trace(_source);
		if(_source.object.@contents == 'static')
			staticContainer = true
		
		render(container, _source.object[0], staticContainer);
		_items[objectId].visible = true;
		var rme:RenderManagerEvent = new RenderManagerEvent(RenderManagerEvent.RENDER_COMPLETE);
		rme.result = container;
		//dispatchEvent(rme);
	}
	
	private function render(parentContainer:DisplayObjectContainer, source:XML, staticContainer:Boolean):void {
		
		var itemList:XMLListCollection = new XMLListCollection();
		
		for each(var item:XML in source.*) {
			
			var objectName:String = item.name().localName;
			var objectID:String = item.@guid.toString();
			var parentID:String = item.parent().@guid; 
			
			switch(objectName) {
				
				case 'object':
					
					itemList.addItem(item);
					
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
					
					var viewText:TextArea = new TextArea()
					
					viewText.x = item.@left;
					viewText.y = item.@top;
					viewText.width = item.@width;
					if(item.@height.length())
						viewText.height = item.@height;
					viewText.htmlText = item;
					viewText.selectable = false;
					viewText.setStyle('fontStyle', item.@font);
					viewText.setStyle('color', item.@color);
					
					viewText.setStyle('borderStyle', 'solid');
					viewText.setStyle('borderColor', '#cccccc');
					viewText.setStyle('borderAlpha', .3);
					viewText.setStyle('backgroundAlpha', 0);
					viewText.focusEnabled = false;
					
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
		
		if(itemList.length > 1) {
		
			var sort:Sort = new Sort();
			sort.fields = [new SortField('@zindex'), new SortField('@hierarchy')];
			itemList.sort = sort;
			itemList.refresh();
		}
		
		for each (var collectionItem:XML in itemList) {
			
			var objectID1:String = collectionItem.@guid.toString();
			var parentID1:String = collectionItem.parent().@guid;
			
			var viewObject:Container;
			
			if(!staticContainer) {
				
				viewObject = new Item(objectID1);
				_items[objectID] = viewObject;
				
			} else
				viewObject = new Canvas();
				
			viewObject.setStyle('backgroundColor', '#ffffff');
			viewObject.setStyle('backgroundAlpha', '0');
			
			viewObject.clipContent = true;
			
			viewObject.x = collectionItem.@left;
			viewObject.y = collectionItem.@top;
			
			if(collectionItem.@width.length())
				viewObject.width = collectionItem.@width;
			
			if(collectionItem.@height.length())
						viewObject.height = collectionItem.@height;
			
			if(parentID && viewObject is Item)	
				Item(viewObject).parentID = parentID1;
			
			parentContainer.addChild(viewObject);
			
			if(staticContainer || collectionItem.@contents == 'static')
				staticContainer = true;
			
			this.render(viewObject, collectionItem, staticContainer);
		}
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