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
	import net.vdombox.ide.modules.wysiwyg.events.AttributeEvent;
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
	
		public function MultilineWindow()
		{
			super();
			this.setFocus();
			addEventListener( KeyboardEvent.KEY_DOWN, cancel_close_window );	
		}
	
		override public function stylesInitialized():void {
			super.stylesInitialized();
			this.setStyle( "skinClass", MultilineWindowSkin );
		}
	
		/**
		 * @private
		 * close multilineWindow if down ESCAPE or if down button "Apply"
		 */ 
		public function ok_close_window(event: KeyboardEvent = null ) : void
		{
			dispatchEvent( new MultilineWindowEvent( MultilineWindowEvent.APPLY, textAreaContainer.text ) );
		}
		
		public function cancel_close_window(event: KeyboardEvent = null ) : void
		{			
			if ( event != null)
				if ( event.charCode != Keyboard.ESCAPE)
					return;
			dispatchEvent( new MultilineWindowEvent( MultilineWindowEvent.CLOSE, "" ) );
		}
	
		/*public function insertPageLink() : void
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
		}*/
		public function showResourceSelecterWindow():void
		{
			dispatchEvent( new AttributeEvent( AttributeEvent.SELECT_RESOURCE ) );
		}
	
		public function titlewindow1_closeHandler( event : CloseEvent ) : void
		{
			PopUpManager.removePopUp( this );
		}
	}
}