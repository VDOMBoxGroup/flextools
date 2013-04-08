package net.vdombox.ide.modules.wysiwyg.view.components.toolbars.richTextToolbarClasses
{
	import flash.display.NativeWindowSystemChrome;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;

	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.modules.wysiwyg.model.business.PagesManager;
	import net.vdombox.utils.WindowManager;

	import spark.components.DropDownList;
	import spark.components.TextInput;
	import spark.components.Window;

	public class LinkSelection extends Window
	{
		public function LinkSelection()
		{
			super();

			systemChrome = NativeWindowSystemChrome.NONE;
			transparent = true;

			width = 400;
			height = 160;

			minWidth = 400;
			minHeight = 160;

			this.setFocus();

			addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
			addEventListener( Event.CLOSE, closeHandler );
		}

		private var currentValue : String;

		private var _hostName : String;

		public static const EVENT_LINK_SELECTED : String = "linkSelected";

		private const HTTP_PREFIX : String = "http://";

		private const PAGE_PREFIX : String = "/";

		private const PAGE_POSTFIX : String = ".vdom";

		[SkinPart( required = "true" )]
		public var linkURL : TextInput;

		[SkinPart( required = "true" )]
		public var pageURL : DropDownList;

		override public function stylesInitialized() : void
		{
			super.stylesInitialized();
			this.setStyle( "skinClass", LinkSelectionWindowSkin );
		}

		public function get url() : String
		{
			return currentValue;
		}

		[Bindable]
		public function get hostName() : String
		{
			if ( !_hostName )
				return "";

			return _hostName;
		}

		public function set hostName( aHostName : String ) : void
		{
			_hostName = aHostName;
		}

		private function get isLinkUrl() : Boolean
		{
			if ( currentValue.indexOf( HTTP_PREFIX ) >= 0 )
			{
				return true;
			}

			return false;
		}

		private function get isPageUrl() : Boolean
		{
			if ( currentValue.indexOf( PAGE_PREFIX ) == 0 && currentValue.indexOf( PAGE_POSTFIX ) >= 0 )
			{
				return true;
			}

			return false;
		}

		public function closeWithSave() : void
		{
			if ( linkURL.visible )
			{
				if ( !linkURL.text )
				{
					closeHandler();
					return;
				}

				currentValue = HTTP_PREFIX + linkURL.text;
			}
			else
			{
				currentValue = PAGE_PREFIX + PageVO( pageURL.selectedItem ).name + PAGE_POSTFIX;
			}

			dispatchEvent( new Event( EVENT_LINK_SELECTED ) );

			closeHandler();
		}

		public function closeHandler( event : * = null ) : void
		{
			removeHandlers();

			removeEventListener( Event.CLOSE, closeHandler );
			WindowManager.getInstance().removeWindow( this );
		}

		private function addHandlers() : void
		{
			addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		}

		private function removeHandlers() : void
		{
			removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		}

		private function onKeyDown( keyEvent : KeyboardEvent ) : void
		{
			switch ( keyEvent.keyCode )
			{
				case Keyboard.ESCAPE:
				{
					keyEvent.stopImmediatePropagation();

					closeHandler();
					break;
				}

			}

		}

		private function creationCompleteHandler( event : FlexEvent = null ) : void
		{
			removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );

			addHandlers();

			pageURL.dataProvider = new ArrayCollection( PagesManager.pages );
		}
	}
}
