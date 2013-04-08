package vdom.controls.externalEditorButton
{
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.HBox;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.core.Window;
	import mx.events.CloseEvent;
	
	import vdom.managers.PopUpWindowManager;

	public class ExternalEditorButton extends HBox
	{
		private var externalEditorWindow : ExternalEditorWindow;
		private var applicationID : String = "";
		private var objectID : String = "";
		private var resourceID : String = "";

		private var __valueLabel : Label;
		private var openButton : Button;

		private var _value : String;
		private var _title : String;
		
		private var window : Window;
		
		public function ExternalEditorButton( applicationID : String, objectID : String,
											  resourceID : String )
		{

			super();

			horizontalScrollPolicy = "off";
			verticalScrollPolicy = "off";
			setStyle( "horizontalGap", 1 );
			setStyle( "paddingLeft", 0 );
			setStyle( "paddingRight", 0 );
			setStyle( "verticalAlign", "middle" );

			this.applicationID = applicationID;
			this.objectID = objectID;
			this.resourceID = resourceID;
		}
		
		public function set title( value : String ) : void
		{
			_title = value;
		}
		
		public function set value( value : String ) : void
		{

			_value = value;
			if ( __valueLabel )
				__valueLabel.text = _value;
		}

		public function get value() : String
		{

			return _value;
		}
		
		override protected function createChildren() : void
		{

			super.createChildren();

			if ( !__valueLabel )
				__valueLabel = new Label();
			
			__valueLabel.percentWidth = 100;
			__valueLabel.truncateToFit = true;
			addChild( __valueLabel );


			if ( !openButton )
				openButton = new Button();

			openButton.width = 22;
			openButton.height = 20;
			openButton.setStyle( "cornerRadius", 0 );
			openButton.setStyle( "paddingLeft", 1 );
			openButton.setStyle( "paddingRight", 1 );
			openButton.label = "...";
			openButton.addEventListener( MouseEvent.CLICK, openButton_clickHandler );
			addChild( openButton );

			invalidateDisplayList();
			invalidateSize();
		}
		
		private function openButton_clickHandler( event : Event ) : void
		{
			/* Pop up spinner while external application is loading... */
			
			var puwm : PopUpWindowManager = PopUpWindowManager.getInstance();
			
			externalEditorWindow = new ExternalEditorWindow();
			
			externalEditorWindow.applicationID = applicationID;
			externalEditorWindow.objectID = objectID;
			externalEditorWindow.resourceID = resourceID;
			
			externalEditorWindow.value = _value;
			externalEditorWindow.addEventListener( CloseEvent.CLOSE, externalEditorWindow_closeHandler );
			
			var nwio : NativeWindowInitOptions = new NativeWindowInitOptions();
			nwio.resizable = false;
			nwio.systemChrome = NativeWindowSystemChrome.NONE;
			nwio.transparent = true;
			nwio.maximizable = false;
			nwio.minimizable = false;
			
			window = puwm.addPopUp( externalEditorWindow, _title, this, true, null, nwio);
			window.showStatusBar = false;
			window.showGripper = false;
		}
		
		private function externalEditorWindow_closeHandler( event : Event ) : void 
		{
			value = event.currentTarget.value;
		}
	}
}