//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.events.Event;

	import mx.core.UIComponent;

	import net.vdombox.ide.modules.wysiwyg.events.AttributeEvent;
	import net.vdombox.ide.modules.wysiwyg.events.MultilineWindowEvent;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.MultilineWindow;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.ResourceSelectorWindow;
	import net.vdombox.utils.WindowManager;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	/**
	 * MultiLineWindowMediator is wrapper on WindowMediator.mxml.
	 * Get Resources and Pages and set it in combobox for chose.
	 * @author Elena Kotlova
	 */
	public class MultiLineWindowMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "MultiLineWindowMediator";

		public function MultiLineWindowMediator( multilineWindow : MultilineWindow ) : void
		{
			this.multilineWindow = multilineWindow;
			viewComponent = multilineWindow;
			super( NAME, viewComponent );
		}

		private var multilineWindow : MultilineWindow;

		override public function handleNotification( notification : INotification ) : void
		{

		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			return interests;
		}

		override public function onRegister() : void
		{
			multilineWindow.addEventListener( MultilineWindowEvent.APPLY, removeYourself, false, 0, true );
			multilineWindow.addEventListener( MultilineWindowEvent.CLOSE, removeYourself, false, 0, true );
			multilineWindow.addEventListener( Event.CLOSE, closeHandler, false, 0, true );
			multilineWindow.addEventListener( AttributeEvent.SELECT_RESOURCE, selectResourceHandler, false, 0, true );
		}

		override public function onRemove() : void
		{
			multilineWindow.removeEventListener( MultilineWindowEvent.APPLY, removeYourself, false );
			multilineWindow.removeEventListener( MultilineWindowEvent.CLOSE, removeYourself, false );
			multilineWindow.removeEventListener( Event.CLOSE, closeHandler, false );
			multilineWindow.removeEventListener( AttributeEvent.SELECT_RESOURCE, selectResourceHandler, false );

		}

		private function applyHandler( event : Event ) : void
		{
			var resourceSelectorWindow : ResourceSelectorWindow = event.target as ResourceSelectorWindow;
			var str1 : String = multilineWindow.textAreaContainer.text;

			if ( multilineWindow.focus )
			{
				multilineWindow.textAreaContainer.insertText( "|%" + resourceSelectorWindow.value );
				multilineWindow.focus = false;
			}
			else
				multilineWindow.textAreaContainer.text += resourceSelectorWindow.value;

			var str2 : String = multilineWindow.textAreaContainer.text;

			multilineWindow.attributeValue = autoPasteCommon( str1, str2 );
		}

		private function autoPasteCommon( str1 : String, str2 : String ) : String
		{
			var index : int;


			for ( index = 0; index < str1.length; index++ )
			{
				if ( str1.charAt( index ) != str2.charAt( index ) )
					break;
			}

			if ( str2.charAt( index ) == "|" )
				str2 = str2.substr( 0, index ) + str2.substr( index + 2, str2.length - index );
			else if ( str2.charAt( index ) == "%" )
			{
				str2 = str2.substr( 0, index - 1 ) + str2.substr( index + 1, str2.length - index );
				index--;
			}

			var index2 : int;

			for ( index2 = index - 1; index2 > 0 && str1.charAt( index2 ) == " "; index2-- )
			{
			};

			if ( index2 >= 41 )
			{
				if ( str1.charAt( index2 ) == ")" && str1.substr( index2 - 41, 4 ) == "#Res" )
					str2 = str2.substr( 0, index2 + 1 ) + ", " + str2.substr( index, str2.length - index );
			}

			if ( index < str1.length )
			{
				var interval : int = str2.length - str1.length;

				for ( index2 = index; index2 < str1.length - 1 && str1.charAt( index2 ) == " "; index2++ )
				{
				};

				if ( index2 + 41 < str2.length )
				{
					if ( str1.substr( index2, 4 ) == "#Res" )
						str2 = str2.substr( 0, index + interval ) + ", " + str2.substr( index2 + interval, str2.length );
				}

				if ( str2.charAt( index - 1 ) == "," )
					str2 = str2.substr( 0, index ) + " " + str2.substr( index, str2.length - index );
			}
			return str2;
		}

		private function closeHandler( event : Event ) : void
		{
			facade.removeMediator( NAME );

			WindowManager.getInstance().removeWindow( multilineWindow );
		}

		private function removeYourself( event : MultilineWindowEvent ) : void
		{
			facade.removeMediator( NAME );

			WindowManager.getInstance().removeWindow( multilineWindow );
		}

		private function selectResourceHandler( event : AttributeEvent ) : void
		{
			var windowManager : WindowManager = WindowManager.getInstance();
			var multilineWindow : MultilineWindow = event.target as MultilineWindow;
			var resourceSelectorWindow : ResourceSelectorWindow = new ResourceSelectorWindow();
			var resourceSelectorWindowMediator : ResourceSelectorWindowMediator = new ResourceSelectorWindowMediator( resourceSelectorWindow );

			facade.registerMediator( resourceSelectorWindowMediator );

			resourceSelectorWindow.multiSelect = true;

			resourceSelectorWindow.addEventListener( Event.CHANGE, applyHandler, false, 0, true );

			windowManager.addWindow( resourceSelectorWindow, UIComponent( multilineWindow ), true );
		}
	}
}