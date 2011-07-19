package net.vdombox.ide.modules.wysiwyg.view.components.windows
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import flashx.textLayout.elements.TextFlow;
	
	import mx.controls.ComboBox;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.MultilineWindowEvent;
	import net.vdombox.ide.modules.wysiwyg.view.skins.MultilineWindowSkin;
	
	import spark.components.ComboBox;
	import spark.components.RichEditableText;
	import spark.components.TitleWindow;
	public class MultilineWindow extends TitleWindow
	{

		[Bindable]
		public var attributeValue : String;
	
		[SkinPart( required="true" )]
		public var textAreaContainer : RichEditableText;
	
/*		[SkinPart( required="true" )]
		public var pageList : mx.controls.ComboBox;*/
	
/*		[SkinPart( required="true" )]
		public var resourceList : mx.controls.ComboBox;*/
	
		public function MultilineWindow()
		{
			super();
			init();
		}
	
		override public function stylesInitialized():void {
			super.stylesInitialized();
			this.setStyle( "skinClass", MultilineWindowSkin );
		}
	
		/**
		 * @private
		 * close multilineWindow if down ESCAPE or if down button "Apply"
		 */ 
		public function ok_close_window( event: KeyboardEvent = null ) : void
		{
			if ( event != null )
				if ( event.charCode != Keyboard.ESCAPE )
					return
					dispatchEvent( new MultilineWindowEvent( "apply", textAreaContainer.text ) );			
		}
	
		public function insertPageLink() : void
		{
			var textFlow: TextFlow = textAreaContainer.textFlow;
		
			var index : int = textAreaContainer.selectionAnchorPosition;
			if ( index < 0 ) index = 0;
			var text:String = textFlow.getText(index);
			
			//textAreaContainer.text = textFlow.getText(0, index) +  "/" + pageList.selectedLabel + ".vdom" +  text;
			textAreaContainer.setFocus();
		}
	
		public function insertResourceLink() : void
		{
			var textFlow: TextFlow = textAreaContainer.textFlow;
		
			var index : int = textAreaContainer.selectionAnchorPosition;
			if ( index < 0 ) index = 0;
			var text:String = textFlow.getText(index);
		
			//textAreaContainer.text = textFlow.getText(0, index) +  "#Res(" + resourceList.selectedItem["data"] + ")" +  text;
			textAreaContainer.setFocus();
		}
	
		public function titlewindow1_closeHandler( event : CloseEvent ) : void
		{
			PopUpManager.removePopUp( this );
		}
	
		private function init() : void
		{
			this.setFocus();
			addEventListener( KeyboardEvent.KEY_DOWN, ok_close_window );				
		}
	}
}