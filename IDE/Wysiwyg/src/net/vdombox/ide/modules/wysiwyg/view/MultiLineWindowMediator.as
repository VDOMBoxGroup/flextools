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

		override public function onRegister() : void
		{
			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();
		}
		
		private function addHandlers() : void
		{
			multilineWindow.addEventListener( MultilineWindowEvent.APPLY, closeHandler, false, 0, true );
			multilineWindow.addEventListener( MultilineWindowEvent.CLOSE, closeHandler, false, 0, true );
			multilineWindow.addEventListener( Event.CLOSE, closeHandler, false, 0, true );
			multilineWindow.addEventListener( AttributeEvent.SELECT_RESOURCE, selectResourceHandler, false, 0, true );
		}
		
		private function removeHandlers() : void
		{
			multilineWindow.removeEventListener( MultilineWindowEvent.APPLY, closeHandler, false );
			multilineWindow.removeEventListener( MultilineWindowEvent.CLOSE, closeHandler, false );
			multilineWindow.removeEventListener( Event.CLOSE, closeHandler, false );
			multilineWindow.removeEventListener( AttributeEvent.SELECT_RESOURCE, selectResourceHandler, false );
		}

		private function applyHandler( event : Event ) : void
		{
			var resourceSelectorWindow : ResourceSelectorWindow = event.target as ResourceSelectorWindow;
			var oldString : String = multilineWindow.textAreaContainer.text;

			if ( multilineWindow.focus )
			{
				multilineWindow.textAreaContainer.insertText( "|%" + resourceSelectorWindow.value );
				multilineWindow.focus = false;
			}
			else
				multilineWindow.textAreaContainer.text += resourceSelectorWindow.value;

			var newString : String = multilineWindow.textAreaContainer.text;

			multilineWindow.attributeValue = autoPasteCommon( oldString, newString );
		}

		private function autoPasteCommon( oldString : String, newString : String ) : String
		{
			var index : int;

			// доходим до места где имеются отличия
			for ( index = 0; index < oldString.length; index++ )
			{
				if ( oldString.charAt( index ) != newString.charAt( index ) )
					break;
			}

			// ищем специальный разделитель
			if ( newString.charAt( index ) == "|" )
				newString = newString.substr( 0, index ) + newString.substr( index + 2, newString.length - index );
			else if ( newString.charAt( index ) == "%" )
			{
				newString = newString.substr( 0, index - 1 ) + newString.substr( index + 1, newString.length - index );
				index--;
			}

			//Пропускаем пробелы
			var index2 : int;
			for ( index2 = index - 1; index2 > 0 && oldString.charAt( index2 ) == " "; index2-- )
			{
			};

			//41 - длина записи со ссылкой на ресурс
			// возможно мы вставляем ссылку на ресурс между двумя другимим ссылками на ресурсы
			
			//Проверка с левой стороны
			if ( index2 >= 41 )
			{
				if ( oldString.charAt( index2 ) == ")" && oldString.substr( index2 - 41, 4 ) == "#Res" )
					newString = newString.substr( 0, index2 + 1 ) + ", " + newString.substr( index, newString.length - index );
			}

			// Проверка с правой стороны
			if ( index < oldString.length )
			{
				var interval : int = newString.length - oldString.length;

				for ( index2 = index; index2 < oldString.length - 1 && oldString.charAt( index2 ) == " "; index2++ )
				{
				};

				if ( index2 + 41 < newString.length )
				{
					if ( oldString.substr( index2, 4 ) == "#Res" )
						newString = newString.substr( 0, index + interval ) + ", " + newString.substr( index2 + interval, newString.length );
				}

				if ( newString.charAt( index - 1 ) == "," )
					newString = newString.substr( 0, index ) + " " + newString.substr( index, newString.length - index );
			}
			
			return newString;
		}
		
		private function closeHandler( event : * ) : void
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
