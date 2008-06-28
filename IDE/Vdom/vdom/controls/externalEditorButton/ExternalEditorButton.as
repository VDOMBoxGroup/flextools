package vdom.controls.externalEditorButton
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.ByteArray;
	
	import mx.containers.HBox;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.controls.SWFLoader;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import vdom.managers.DataManager;
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
		
		private var ldr:SWFLoader;
		private var objLdr:Loader = new Loader();
		private var exEditor:*;
		private var applWindow:ApplicationWindow;
		private var spinner:SpinnerScreen;
		
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

		private function set resource(resource:Object):void {
			objLdr.contentLoaderInfo.addEventListener(Event.COMPLETE, loadNestedAppl);
			objLdr.loadBytes(resource.data);
		}
				
        private function loadNestedAppl(appl:ByteArray):void {
//        	var editorUrl:String = "C:/Users/koldoon/Documents/Flex Builder 3/dbStructureEditor/bin-debug/dbStructureEditor.swf";
			objLdr.removeEventListener(Event.COMPLETE, loadNestedAppl);
        	if (!ldr)
        		ldr = new SWFLoader();
        	
        	ldr.addEventListener(Event.COMPLETE, applicationLoaded);  
        	ldr.source = objLdr.content;
//			ldr.load(editorUrl);
        }
        
		private function applicationLoaded(event:Event):void {
			ldr.removeEventListener(Event.COMPLETE, applicationLoaded);
			
			/* Remove spinner in case that application is already loaded */
			PopUpManager.removePopUp(spinner);
			
			/* create popup window and set its visual properties */
			applWindow = new ApplicationWindow();
			applWindow.visible = false;
			
	   		event.currentTarget.content.addEventListener(FlexEvent.APPLICATION_COMPLETE, applicationComplete);
    		applWindow.addChild(ldr);
    		
    		PopUpManager.addPopUp(applWindow, DisplayObject(Application.application), false);
    		applWindow.addEventListener(CloseEvent.CLOSE, applCloseHandler);
		}
 
		private function applicationComplete(event:Event):void {
			exEditor = event.target.application;
			
			PopUpManager.centerPopUp(applWindow);
			applWindow.visible = true;
			
			exEditor.addEventListener(CloseEvent.CLOSE, applCloseHandler);
    		exEditor['externalManager'] = null;		// not implemented yet
			exEditor['value'] = _value;
		}

		private function openWindow(event:Event):void {
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