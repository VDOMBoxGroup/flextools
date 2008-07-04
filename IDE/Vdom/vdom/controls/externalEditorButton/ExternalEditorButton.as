package vdom.controls.externalEditorButton
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.LoaderContext;
	
	import mx.containers.HBox;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import vdom.events.ExternalManagerEvent;
	import vdom.managers.DataManager;
	import vdom.managers.ExternalManager;
	import vdom.managers.FileManager;

	public class ExternalEditorButton extends HBox
	{
		private var fileManager:FileManager = FileManager.getInstance();
		private var dataManager:DataManager = DataManager.getInstance();
		private var applicationID:String = "";
		private var objectID:String = "";
		private var resourceID:String = "";
		
		private var __valueLabel:Label;
		private var __openBtn:Button;
		
		private var ldr:Loader;
		private var exEditor:*;
		private var applWindow:ApplicationWindow;
		private var applUIComponent:UIComponent;
		private var spinner:SpinnerScreen;
		private var externalManager:ExternalManager;
		
		private var _value:String; 

		public function ExternalEditorButton(applicationID:String, objectID:String, resourceID:String) {
			super();

			this.horizontalScrollPolicy = "off";
			this.verticalScrollPolicy = "off";
			this.setStyle("horizontalGap", 1);
			this.setStyle("paddingLeft", 0);
			this.setStyle("paddingRight", 0);
			this.setStyle("verticalAlign", "middle");

			this.applicationID = applicationID;
			this.objectID = objectID;
			this.resourceID = resourceID;
		}
		
		public function set value(param:String):void {
			_value = param;
			if (__valueLabel)
				__valueLabel.text = _value;
		}
		
		override protected function createChildren():void {			
			super.createChildren();
			
			if (!__valueLabel) {
				__valueLabel = new Label(); 
				__valueLabel.width = this.width - 23;
				addChild(__valueLabel);
			}
			
			if (!__openBtn) {
				__openBtn = new Button();
				__openBtn.width = 22;
				__openBtn.height = 20;
				__openBtn.setStyle("cornerRadius", 0);
				__openBtn.setStyle("paddingLeft", 1);
				__openBtn.setStyle("paddingRight", 1);
				__openBtn.label = "...";
				__openBtn.addEventListener(MouseEvent.CLICK, openWindow);
				addChild(__openBtn);
			} 
		}

//		----- Loading and executing external application methods ----------------------------- 

		public function set resource(resource:Object):void {			
			/* Loading nested application */
			if (!ldr)
        		ldr = new Loader();
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, applicationLoaded);
			
			var loaderContext:LoaderContext = new LoaderContext();
			loaderContext.allowLoadBytesCodeExecution = true;
			
			ldr.loadBytes(resource.data, loaderContext);
		}
        
		private function applicationLoaded(event:Event):void {
			ldr.removeEventListener(Event.COMPLETE, applicationLoaded);
			
			/* Remove spinner in case that application is already loaded */
			PopUpManager.removePopUp(spinner);
			
			/* create popup window and set its visual properties */
			applWindow = new ApplicationWindow();
			applWindow.visible = false;
			
	   		event.currentTarget.content.addEventListener(FlexEvent.APPLICATION_COMPLETE, applicationComplete);
	   		
 	   		applUIComponent = new UIComponent();
 	   		applUIComponent.width = ldr.content.width;
 	   		applUIComponent.height = ldr.content.height;
			
			applWindow.addChild(applUIComponent);
	   		applUIComponent.addChild(ldr);
     		
    		PopUpManager.addPopUp(applWindow, DisplayObject(Application.application), false);
    		applWindow.addEventListener(CloseEvent.CLOSE, applCloseHandler);
		}
 
		private function applicationComplete(event:Event):void {
			exEditor = event.target.application;
			
			PopUpManager.centerPopUp(applWindow);
			applWindow.visible = true;
			
			exEditor.addEventListener(CloseEvent.CLOSE, applCloseHandler);
			
			if (!externalManager)
				externalManager = new ExternalManager(applicationID, objectID);
			
			externalManager.addEventListener(ExternalManagerEvent.CALL_COMPLETE, callCompleteHandler);
			externalManager.addEventListener(ExternalManagerEvent.CALL_ERROR, callErrorHandler); 
			externalManager.remoteMethodCall("get_structute", "");
			
    		exEditor['externalManager'] = externalManager;
			exEditor['value'] = _value;
		}
		
		/* Temporary method */
		private function callCompleteHandler(result:ExternalManagerEvent):void {
			trace(result);
		}
		
		/* Temporary method */
		private function callErrorHandler(result:ExternalManagerEvent):void {
			trace(result);
		} 

		private function openWindow(event:Event):void {
			/* ************************* */
			
			if (!externalManager)
				externalManager = new ExternalManager(applicationID, objectID);
			
			externalManager.addEventListener(ExternalManagerEvent.CALL_COMPLETE, callCompleteHandler); 
			externalManager.remoteMethodCall("get_structure", "");

			/* ************************* */

			
			/* Pop up spinner while external application is loading... */
			if (!spinner)
				spinner = new SpinnerScreen();
			PopUpManager.addPopUp(spinner, DisplayObject(Application.application), true);
			PopUpManager.centerPopUp(spinner);
			spinner.visible = true;
			
			/* Init loading application */
			fileManager.loadResource(dataManager.currentApplicationId, resourceID, this)
		}
		
		private function applCloseHandler(event:Event):void {
			applWindow.visible = false;
			PopUpManager.removePopUp(applWindow);
			value = exEditor['value'];
		}		
	}
}