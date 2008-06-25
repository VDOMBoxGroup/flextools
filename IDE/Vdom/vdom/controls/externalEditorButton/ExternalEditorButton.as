package vdom.controls.externalEditorButton
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.HBox;
	import mx.containers.TitleWindow;
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
		private var _defaultValue:String = "";
		
		private var _valueLabel:Label;
		private var _openBtn:Button;
		
		private var ldr:SWFLoader;
		private var exEditor:*;
		private var exEditorPopUpInstance:*;
		private var titleWnd:TitleWindow;

		public function ExternalEditorButton(applicationID:String, typeID:String) {
			super();

			this.horizontalScrollPolicy = "off";
			this.verticalScrollPolicy = "off";
			this.setStyle("horisontalGap", 1);
			this.setStyle("verticalAlign", "middle");

			_applicationID = applicationID;
			_typeID = typeID;
		}
		
		override protected function createChildren():void {			
			super.createChildren();
			
			if (!_valueLabel) {
				_valueLabel = new Label(); 
				_valueLabel.percentWidth = 100;
				_valueLabel.percentHeight = 100;
				_valueLabel.text = _applicationID;
				addChild(_valueLabel);
			}
			
			if (!_openBtn) {
				_openBtn = new Button();
				_openBtn.width = 22;
				_openBtn.percentHeight = 100;
				_openBtn.setStyle("cornerRadius", 0);
				_openBtn.setStyle("paddingLeft", 1);
				_openBtn.setStyle("paddingRight", 1);
				_openBtn.label = "...";
				_openBtn.addEventListener(MouseEvent.CLICK, openWindow);
				addChild(_openBtn);
			} 
		}

//		--------------------------------------------------------------------------------------
				
        private function loadNestedAppl():void {
        	var manager:String = "C:/Users/koldoon/Documents/Flex Builder 3/dbStructureEditor/bin-debug/dbStructureEditor.swf";
        	ldr = new SWFLoader();
        	
        	ldr.addEventListener(Event.COMPLETE, applicationLoaded);  
        	ldr.load(manager);
        }
        
		private function applicationLoaded(event:Event):void {
			titleWnd = new TitleWindow();
			titleWnd.visible = false;
			titleWnd.setStyle("paddingLeft", 0);	
			titleWnd.setStyle("paddingRight", 0);
			titleWnd.setStyle("paddingTop", 0);
			titleWnd.setStyle("paddingBottom", 0);
			titleWnd.setStyle("cornerRadius", 1);
						
    		titleWnd.title = "External Editor";
    		titleWnd.setStyle("horisontalAlign", "center");
    		titleWnd.setStyle("verticalAlign", "middle");
    		titleWnd.setStyle("borderAlpha", 0.9);
    		
    		event.currentTarget.content.addEventListener(FlexEvent.APPLICATION_COMPLETE, applicationComplete);
    		titleWnd.addChild(ldr);
    		ldr.setStyle("dropShadowEnabled", "false");
    		exEditorPopUpInstance = PopUpManager.addPopUp(titleWnd, DisplayObject(Application.application), true);
    		
		}
 
		private function applicationComplete(event:Event):void {
			exEditor = event.target.application;
			
			titleWnd.width = exEditor['width'] + 20;
			titleWnd.height = exEditor['height'] + 40;
			PopUpManager.centerPopUp(titleWnd);
			titleWnd.visible = true;
			
			exEditor.addEventListener(CloseEvent.CLOSE, applCloseHandler);

    		exEditor['externalManager'] = null;
			exEditor['value'] = 
				<TableStructure>
					<TableDef id="ac73b296-d4f0-4a3e-b64c-19fe3fde0a5b" name="dbtable_ac73b296_d4f0_4a3e_b64c_19fe3fde0a5b">
						<ColumnDef id="djhgfkshdgfkjds" name="id" type="text"/>
						<ColumnDef id="iueyhri843rhskj" name="name" type="text"/>
						<ColumnDef id="dkjhgkdjfhgkjfv" name="pic" type="blob"/>
					</TableDef>
					<ChangeLog />
				</TableStructure>;

		}

		private function openWindow(event:Event):void {
			loadNestedAppl();
		}
		
		private function applCloseHandler(event:Event):void {
			PopUpManager.removePopUp(titleWnd);
		}
	}
}