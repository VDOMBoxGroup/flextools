package vdom.controls.externalEditorButton
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.LoaderContext;
	
	import mx.containers.HBox;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.managers.PopUpManagerChildList;
	
	import vdom.events.FileManagerEvent;
	import vdom.managers.DataManager;
	import vdom.managers.ExternalManager;
	import vdom.managers.FileManager;
	import flash.net.URLRequest;

	public class ExternalEditorButton extends HBox
	{
		private var fileManager:FileManager = FileManager.getInstance();
		private var dataManager:DataManager = DataManager.getInstance();
		private var applicationID:String = '';
		private var objectID:String = '';
		private var resourceID:String = '';
		
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
		
		public function set value(value:String):void {
			
			_value = value;
			if (__valueLabel)
				__valueLabel.text = _value;
		}
		
		public function get value():String {
			
			return _value;
		}
		
		override protected function createChildren():void {
						
			super.createChildren();
			
			if (!__valueLabel) {
				__valueLabel = new Label();
				addChild(__valueLabel); 
				__valueLabel.percentWidth = 100;
				__valueLabel.truncateToFit = true;
			}
			
			if (!__openBtn) {
				__openBtn = new Button();
				addChild(__openBtn);
				__openBtn.width = 22;
				__openBtn.height = 20;
				__openBtn.setStyle("cornerRadius", 0);
				__openBtn.setStyle("paddingLeft", 1);
				__openBtn.setStyle("paddingRight", 1);
				__openBtn.label = "...";
				__openBtn.addEventListener(MouseEvent.CLICK, openWindow);
			}
			
			invalidateDisplayList();
			invalidateSize();
		}

//		----- Loading and executing external application ------------------------------------- 

		public function set resource(resource:Object):void {			
			/* Loading nested application */
			if (!ldr)
        		ldr = new Loader();
        		
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, applicationLoaded);
			
			var loaderContext:LoaderContext = new LoaderContext();
			loaderContext.allowLoadBytesCodeExecution = true;
			
			/* Temporary procedures for testing local external components */ 
//			var dbExtEditor:URLRequest = new URLRequest("/home/CSD/koldoon/workspace/dbStructureEditor/bin-debug/dbStructureEditor.swf");
//			var dbExtEditor:URLRequest = new URLRequest("/home/CSD/koldoon/workspace/dbDataEditor/bin-debug/dbDataEditor.swf");
//			ldr.load(dbExtEditor, loaderContext);
			/* end of -- Temporary procedures for testing local external components */
			
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
     		
    		PopUpManager.addPopUp(applWindow, DisplayObject(Application.application), false, PopUpManagerChildList.POPUP);
    		applWindow.addEventListener(CloseEvent.CLOSE, applCloseHandler);
		}
 
		private function applicationComplete(event:Event):void {
			exEditor = event.target.application;
			
			PopUpManager.centerPopUp(applWindow);
			applWindow.visible = true;
			
			exEditor.addEventListener(CloseEvent.CLOSE, applCloseHandler);
			
			/* Create external manager for this component */
			if (!externalManager)
				externalManager = new ExternalManager(applicationID, objectID);
			
			/* Applying properties to external components */
			try {
    			exEditor['externalManager'] = externalManager;
				exEditor['value'] = _value;
			}
			catch (err:Error) {
				/* error002 */
				Alert.show("External editor returned an error. Could not execute a command.", "External Editor Error! (002)");
			}
		}

		private function openWindow(event:Event):void {
			/* Pop up spinner while external application is loading... */
			if (!spinner)
				spinner = new SpinnerScreen();
				
			PopUpManager.addPopUp(spinner, DisplayObject(Application.application), true);
			PopUpManager.centerPopUp(spinner);
			spinner.visible = true;
			
			/* Init loading application */
			fileManager.addEventListener(FileManagerEvent.RESOURCE_LOADING_ERROR, resourceLoadingErrorHandler); 
			fileManager.loadResource(dataManager.currentApplicationId, resourceID, this)
		}
		
		private function resourceLoadingErrorHandler(event:FileManagerEvent):void {
			fileManager.removeEventListener(FileManagerEvent.RESOURCE_LOADING_ERROR, resourceLoadingErrorHandler);

			PopUpManager.removePopUp(spinner);
			Alert.show("External editor not found for this type!", "Resource loading error!");
		}
		
		
		private function applCloseHandler(event:Event):void {
			applWindow.visible = false;
			PopUpManager.removePopUp(applWindow);
			try {
				value = exEditor['value'];
			}
			catch (err:Error) {
				Alert.show("External Editor doesnt allow to read from 'value' property!", "External Editor Error!");
			}
		}		
	}
}