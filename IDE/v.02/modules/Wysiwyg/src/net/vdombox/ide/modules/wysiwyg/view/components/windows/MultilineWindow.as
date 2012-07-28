//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.modules.wysiwyg.view.components.windows
{
	import flash.display.NativeWindowSystemChrome;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flashx.textLayout.elements.TextFlow;
	import mx.controls.ComboBox;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.events.AttributeEvent;
	import net.vdombox.ide.modules.wysiwyg.events.MultilineWindowEvent;
	import net.vdombox.ide.modules.wysiwyg.view.skins.MultilineWindowSkin;
	import net.vdombox.utils.WindowManager;
	import spark.components.ComboBox;
	import spark.components.RichEditableText;
	import spark.components.TitleWindow;
	import spark.components.Window;

	public class MultilineWindow extends Window
	{

		public function MultilineWindow()
		{
			super();

			systemChrome = NativeWindowSystemChrome.NONE;
			transparent = true;

			width = 790;
			height = 550;

			minWidth = 600;
			minHeight = 500;

			this.setFocus();

			addEventListener( KeyboardEvent.KEY_DOWN, cancel_close_window );
			addEventListener( Event.CLOSE, closeHandler );
		}

		[Bindable]
		public var attributeValue : String;

		[Bindable]
		public var focus : Boolean = false;

		[SkinPart( required = "true" )]
		public var textAreaContainer : RichEditableText;
		
		override public function stylesInitialized() : void
		{
			super.stylesInitialized();
			this.setStyle( "skinClass", MultilineWindowSkin );
		}

		public function cancel_close_window( event: KeyboardEvent ) : void
		{
			if ( event.charCode == Keyboard.ESCAPE )
				close();
		}

		public function closeHandler(event:Event) : void
		{
			removeEventListener( Event.CLOSE, closeHandler );

			WindowManager.getInstance().removeWindow(this);
		}

		/**
		 * @private
		 * close multilineWindow if down ESCAPE or if down button "Apply"
		 */
		public function ok_close_window() : void
		{
			dispatchEvent( new MultilineWindowEvent( MultilineWindowEvent.APPLY, textAreaContainer.text ) );

			close();
		}


		public function showResourceSelecterWindow() : void
		{
			dispatchEvent( new AttributeEvent( AttributeEvent.SELECT_RESOURCE ) );
		}
	}
}
