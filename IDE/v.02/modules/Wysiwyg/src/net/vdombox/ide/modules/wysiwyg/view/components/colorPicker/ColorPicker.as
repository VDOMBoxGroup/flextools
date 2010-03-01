package net.vdombox.ide.modules.wysiwyg.view.components.colorPicker
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	
	import net.vdombox.ide.modules.wysiwyg.events.ColorPickerEvent;

	public class ColorPicker extends Canvas
	{

		private var _color : String = "0";
		private var _colorInNumber : uint = 0;

		public function ColorPicker()
		{
			super();

			buttonMode = true;

			addEventListener( MouseEvent.CLICK, mouseClickandler );

			addEventListener( "apply", colorCompleteHandler );
			addEventListener( "cancel", colorCompleteHandler );

			setStyle( "borderStyle", "solid" );

		}

		[Bindable( event="valueCommit" )]
		public function get color() : String
		{
			return _color;
		}

		public function set color( colorValue : String ) : void
		{
			var newColor : uint = uint( ( colorValue == "" ) ? "0" : "0x" + colorValue )

			setStyle( 'backgroundColor', newColor );
			_color = colorValue;
			_colorInNumber = newColor;

			dispatchEvent( new Event( "valueCommit" ) );
		}

		private function mouseClickandler( event : MouseEvent ) : void
		{
//		var colorInt:uint = Number('0x' + _color/* .substring(1) */);
			ColorPickerWindow.show_window( this, _colorInNumber, true );
		}

		private function colorCompleteHandler( event : ColorPickerEvent ) : void
		{
			if ( event.type == 'apply' )
			{
				color = event.hexcolor;
//				_colorInNumber = event.color;
			}
		}
	}
}