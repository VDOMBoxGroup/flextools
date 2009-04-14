package net.vdombox.ide.view.containers
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import mx.containers.HBox;
	import mx.controls.Button;
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.view.controls.ActionButton;

	public class ControlPanel extends HBox
	{
		private var _buttons : Array;
		private var _selectedItem : Button;

		public function ControlPanel() : void
		{
			super();

			_buttons = new Array();
			addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
			addEventListener( FlexEvent.SHOW, showHandler );
		}

		private function showHandler( event : FlexEvent ) : void
		{
			try
			{
				if ( _selectedItem )
					_selectedItem.selected = false;
				_selectedItem = _buttons[ 0 ];
				_selectedItem.selected = true;
			}
			catch ( error : Error )
			{
			}
		}

		override public function addChild( child : DisplayObject ) : DisplayObject
		{
			super.addChild( child );

			if ( child is ActionButton )
			{
				if ( ActionButton( child ).switched )
				{

					child.addEventListener( MouseEvent.CLICK, clickHandler );
					Button( child ).toggle = true;
					_buttons.push( child );
				}
			}

			return child;
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
			_selectedItem = _buttons[ 0 ];
			_selectedItem.selected = true;
		}

		private function clickHandler( event : MouseEvent ) : void
		{

			var childIndex : int = _buttons.indexOf( event.currentTarget );

			if ( _selectedItem )
				_selectedItem.selected = false;

			if ( childIndex != -1 )
				_selectedItem = _buttons[ childIndex ];
		}
	}
}