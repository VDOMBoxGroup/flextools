package vdom.controls.externalEditorButton
{
	import flash.display.DisplayObject;
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

	public class ExternalEditorButton extends HBox
	{
		private var _applicationID:String = "";
		private var _typeID:String = "";
		
		private var _valueLabel:Label;
		private var _openBtn:Button;
		
		private var ldr:SWFLoader;
		private var exEditor:*;
		private var applWindow:ApplicationWindow;
		
		private var _value:String; 

		public function ExternalEditorButton(applicationID:String, typeID:String) {
			super();

			this.horizontalScrollPolicy = "off";
			this.verticalScrollPolicy = "off";
			this.setStyle("horizontalGap", 1);
			this.setStyle("paddingLeft", 0);
			this.setStyle("paddingRight", 0);
			this.setStyle("verticalAlign", "middle");

			_applicationID = applicationID;
			_typeID = typeID;
		}
		
		public function set value(param:String):void {
			_value = param;
			if (_valueLabel)
				_valueLabel.text = _value;
		}
		
		override protected function createChildren():void {			
			super.createChildren();
			
			if (!_valueLabel) {
				_valueLabel = new Label(); 
				_valueLabel.width = this.width - 23;
				addChild(_valueLabel);
			}
			
			if (!_openBtn) {
				_openBtn = new Button();
				_openBtn.width = 22;
				_openBtn.height = 20;
				_openBtn.setStyle("cornerRadius", 0);
				_openBtn.setStyle("paddingLeft", 1);
				_openBtn.setStyle("paddingRight", 1);
				_openBtn.label = "...";
				_openBtn.addEventListener(MouseEvent.CLICK, openWindow);
				addChild(_openBtn);
			} 
		}

//		----- Loading and executing external application methods -----------------------------
				
        private function loadNestedAppl(appl:ByteArray):void {
        	var editorUrl:String = "C:/Users/koldoon/Documents/Flex Builder 3/dbStructureEditor/bin-debug/dbStructureEditor.swf";
        	ldr = new SWFLoader();
        	
        	ldr.addEventListener(Event.COMPLETE, applicationLoaded);  
//        	ldr.source = appl;
			ldr.load(editorUrl);
        }
        
		private function applicationLoaded(event:Event):void {
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
			loadNestedAppl(null);
		}
		
		private function applCloseHandler(event:Event):void {
			value = exEditor['value'];
			PopUpManager.removePopUp(applWindow);
		}
	}
}