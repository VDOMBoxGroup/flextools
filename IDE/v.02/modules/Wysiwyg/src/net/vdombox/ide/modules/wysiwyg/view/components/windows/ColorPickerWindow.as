package net.vdombox.ide.modules.wysiwyg.view.components.windows
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.controls.NumericStepper;
	import mx.controls.SWFLoader;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import net.vdombox.ide.modules.wysiwyg.events.ColorPickerEvent;
	import net.vdombox.ide.modules.wysiwyg.view.components.attributeRenderers.ColorHSB;
	import net.vdombox.ide.modules.wysiwyg.view.components.attributeRenderers.ColorPickerCanvas;
	import net.vdombox.ide.modules.wysiwyg.view.skins.ColorPickerWindowSkin;
	
	import spark.components.RadioButton;
	import spark.components.TextInput;
	import spark.components.TitleWindow;

	public class ColorPickerWindow extends TitleWindow
	{


		[Embed( source = "assets/colorPicker/assets.swf", symbol = "AxisHsbH" )]
		internal var osi_hsb_h : Class;

		[Embed( source = "assets/colorPicker/assets.swf", symbol = "AxisHsbS" )]
		internal var osi_hsb_s : Class;

		[Embed( source = "assets/colorPicker/assets.swf", symbol = "AxisHsbB" )]
		internal var osi_hsb_b : Class;

		[Embed( source = "assets/colorPicker/assets.swf", symbol = "AxisRgbR" )]
		internal var osi_rgb_r : Class;

		[Embed( source = "assets/colorPicker/assets.swf", symbol = "AxisRgbG" )]
		internal var osi_rgb_g : Class;

		[Embed( source = "assets/colorPicker/assets.swf", symbol = "AxisRgbB" )]
		internal var osi_rgb_b : Class;


		[Bindable]
		[Embed( source = 'assets/colorPicker/assets.swf', symbol = 'ColorPickerMarker' )]
		public var cc_marker : Class;

		[Bindable]
		[Embed( source = 'assets/colorPicker/assets.swf', symbol = 'MarkerLeft' )]
		public var cc_l_marker : Class;

		[Bindable]
		[Embed( source = 'assets/colorPicker/assets.swf', symbol = 'MarkerRight' )]
		public var cc_r_marker : Class;



		[SkinPart( required = "true" )]
		public var rb_r : RadioButton;

		[SkinPart( required = "true" )]
		public var rb_g : RadioButton;

		[SkinPart( required = "true" )]
		public var rb_b : RadioButton;

		[SkinPart( required = "true" )]
		public var rb_H : RadioButton

		[SkinPart( required = "true" )]
		public var rb_S : RadioButton;

		[SkinPart( required = "true" )]
		public var rb_B : RadioButton;

		[SkinPart( required = "true" )]
		public var ccc : ColorPickerCanvas;

		[SkinPart( required = "true" )]
		public var ccb : ColorPickerCanvas;

		[SkinPart( required = "true" )]
		public var ccm : SWFLoader;

		[SkinPart( required = "true" )]
		public var cclm : SWFLoader;

		[SkinPart( required = "true" )]
		public var ccrm : SWFLoader;

		/*[SkinPart( required="true" )]
		public var osi_view:SWFLoader;*/

		[SkinPart( required = "true" )]
		public var hexrgb : TextInput;

		[SkinPart( required = "true" )]
		public var tx_r : mx.controls.NumericStepper;

		[SkinPart( required = "true" )]
		public var tx_g : mx.controls.NumericStepper;

		[SkinPart( required = "true" )]
		public var tx_b : mx.controls.NumericStepper;

		[SkinPart( required = "true" )]
		public var tx_H : mx.controls.NumericStepper;

		[SkinPart( required = "true" )]
		public var tx_S : mx.controls.NumericStepper;

		[SkinPart( required = "true" )]
		public var tx_B : mx.controls.NumericStepper;

		private static var wnd : ColorPickerWindow = null;

		private var m_parent : DisplayObject       = null;

		private var position : Object              = { x: 0, y: 0, p: 0 };

		public function ColorPickerWindow()
		{
			super();
			on_initialize();
			//start_init();
		}

		public function on_initialize() : void
		{
			var i : uint = 0; //uint(App.get_so_prop("color_picker_window_mode", ""));	

			mode = ( i >> 8 ) & 1;

			var sel : uint = i & 0xFF;

			if ( sel > 2 )
				sel = 0;

			if ( mode == 0 )
				sel_rgb = sel;
			else
				sel_hsb = sel;
		}

		override public function stylesInitialized() : void
		{
			super.stylesInitialized();
			this.setStyle( "skinClass", ColorPickerWindowSkin );
		}

		public function start_init() : void
		{
			hsb = ColorHSB.rgb_to_hsb( color );
			update_hex_rgb();
			update_position();

			//ob_hsb = hsb.to_object();

			if ( mode == 0 )
			{
				if ( sel_rgb == 0 )
					rb_r.selected = true;
				else if ( sel_rgb == 1 )
					rb_g.selected = true;
				else if ( sel_rgb == 2 )
					rb_b.selected = true;
				on_rb_rgb_change();
			}
			else
			{
				if ( sel_hsb == 0 )
					rb_H.selected = true;
				else if ( sel_hsb == 1 )
					rb_S.selected = true;
				else if ( sel_hsb == 2 )
					rb_B.selected = true;
				on_rb_hsb_change();
			}
		}


		private static function rgb_to_position( color : uint, n : uint ) : Object
		{
			var r : uint = ( color >> 16 ) & 0xFF;
			var g : uint = ( color >> 8 ) & 0xFF;
			var b : uint = color & 0xFF;

			if ( n == 0 )
				return { p: r, x: b, y: g };

			if ( n == 1 )
				return { p: g, x: b, y: r };

			if ( n == 2 )
				return { p: b, x: r, y: g };

			return { p: 0, x: 0, y: 0 };
		}

		private static function position_to_rgb( pos : Object, n : uint ) : uint
		{
			var r : uint = 0, g : uint = 0, b : uint = 0;

			if ( n == 0 )
			{
				r = pos.p;
				b = pos.x;
				g = pos.y;
			}

			if ( n == 1 )
			{
				g = pos.p;
				b = pos.x;
				r = pos.y;
			}

			if ( n == 2 )
			{
				b = pos.p;
				r = pos.x;
				g = pos.y;
			}

			return ( ( r & 0xFF ) << 16 ) | ( ( g & 0xFF ) << 8 ) | ( b & 0xFF );
		}

		private var ba : ByteArray                 = new ByteArray();

		private function change_rcx2_rgb( color : uint, n : uint ) : void
		{
			if ( n > 3 )
				return;
			var dx : uint = 0;
			var dy : uint = 0;
			var clr : uint;

			
			if ( n == 0 )
			{
				clr = color & 0xFF0000 | 0x00FF00;
				dx = 0x000001;
				dy = 0x000100;
			}

			if ( n == 1 )
			{
				clr = color & 0x00FF00 | 0xFF0000;
				dx = 0x000001;
				dy = 0x010000;
			}

			if ( n == 2 )
			{
				clr = color & 0x0000FF | 0x00FF00;
				dx = 0x010000;
				dy = 0x000100;
			}

			var c : uint = clr;

			for ( var y : uint = 0; y < 256; y++ )
			{
				for ( var x : uint = 0; x < 256; x++ )
				{
					ba.writeInt( c );
					ccc.bd.setPixel( x, y, c );
					c += dx;
				}
				c = ( clr -= dy );
			}
			change_rcx2_rgb_matrix( color, n );
		}

		private function change_rcx2_rgb_matrix( color : uint, n : uint ) : void
		{
			if ( n > 3 )
				return;

			var r : uint  = ( color >> 16 ) & 0xFF;
			var g : uint  = ( color >> 8 ) & 0xFF;
			var b : uint  = color & 0xFF;

			var a : Array = [ 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0 ];

			if ( n == 0 )
			{
				a[ 0 ] = 0;
				a[ 4 ] = r;
			}

			if ( n == 1 )
			{
				a[ 6 ] = 0;
				a[ 9 ] = g;
			}

			if ( n == 2 )
			{
				a[ 12 ] = 0;
				a[ 14 ] = b;
			}

			var filter : ColorMatrixFilter = new ColorMatrixFilter( a );
			ccc.bd.applyFilter( ccc.bd, new Rectangle( 0, 0, 256, 256 ), new Point( 0, 0 ), filter );
		}


		private static function hsb_to_position( hsb : ColorHSB, n : uint ) : Object
		{
			if ( n > 3 )
				return { x: 0, y: 0, p: 0 };

			var dc : Object = { h: 360, s: 100, b: 100 };
			var cp : String, cx : String, cy : String;

			if ( n == 0 )
			{
				cp = 'h';
				cx = 's';
				cy = 'b';
			}

			if ( n == 1 )
			{
				cp = 's';
				cx = 'h';
				cy = 'b';
			}

			if ( n == 2 )
			{
				cp = 'b';
				cx = 'h';
				cy = 's';
			}

			var dx : uint = dc[ cx ];
			var dy : uint = dc[ cy ];
			var dp : uint = dc[ cp ];

			return { x: uint( hsb[ cx ] / dx * 255 ), y: uint( hsb[ cy ] / dy * 255 ), p: uint( hsb[ cp ] / dp * 255 ) };
		}

		private static function position_to_hsb( pos : Object, n : uint ) : ColorHSB
		{
			var h : uint = 0, s : uint = 0, b : uint = 0;

			if ( n == 0 )
			{
				h = pos.p;
				s = pos.x;
				b = pos.y;
			}

			if ( n == 1 )
			{
				s = pos.p;
				h = pos.x;
				b = pos.y;
			}

			if ( n == 2 )
			{
				b = pos.p;
				h = pos.x;
				s = pos.y;
			}

			return new ColorHSB( Math.round( h / 255 * 360 ), Math.round( s / 255 * 100 ), Math.round( b / 255 * 100 ) );
		}


		private function change_rcx2_hsb( hsb : ColorHSB, n : uint ) : void
		{
			if ( n > 3 )
				return;
			var o : ColorHSB = new ColorHSB( hsb.h, hsb.s, hsb.b );
			var dc : Object  = { h: 360, s: 100, b: 100 };
			var cx : String, cy : String;

			if ( n == 0 )
			{
				cx = 's';
				cy = 'b';
			}

			if ( n == 1 )
			{
				cx = 'h';
				cy = 'b';
			}

			if ( n == 2 )
			{
				cx = 'h';
				cy = 's';
			}

			var dx : uint = dc[ cx ];
			var dy : uint = dc[ cy ];
			var x : int, y : int;

			ba.position = 0;

			if ( n == 0 )
			{
				for ( y = 255; y >= 0; y-- )
				{
					o.b = ( Number( y ) / 255 ) * dy;

					for ( x = 0; x < 256; x++ )
					{
						o.s = ( Number( x ) / 255 ) * dx;
						ba.writeInt( ColorHSB.hsb_to_rgb( o ) );
					}
				}
			}
			else if ( n == 1 )
			{
				for ( y = 255; y >= 0; y-- )
				{
					o.b = ( Number( y ) / 255 ) * dy;

					for ( x = 0; x < 256; x++ )
					{
						o.h = ( Number( x ) / 255 ) * dx;
						ba.writeInt( ColorHSB.hsb_to_rgb( o ) );
					}
				}
			}
			else if ( n == 2 )
			{
				for ( y = 255; y >= 0; y-- )
				{
					o.s = ( Number( y ) / 255 ) * dy;

					for ( x = 0; x < 256; x++ )
					{
						o.h = ( Number( x ) / 255 ) * dx;
						ba.writeInt( ColorHSB.hsb_to_rgb( o ) );
					}
				}
			}

			ba.position = 0;
			ccc.bd.setPixels( new Rectangle( 0, 0, 256, 256 ), ba );
		}

		private function change_rcx1_rgb( color : uint, n : uint ) : void
		{
			if ( n > 3 )
				return;
			var dy : uint = 0x010101;
			var c : uint  = 0;

			for ( var y : int = 255; y >= 0; y--, c += dy )
			{
				for ( var x : int = 0; x < 20; x++ )
				{
					ccb.bd.setPixel( x, y, c );
				}
			}
			change_rcx1_rgb_matrix( color, n );
		}

		private function change_rcx1_rgb_matrix( color : uint, n : uint ) : void
		{
			if ( n > 3 )
				return;

			var r : uint  = ( color >> 16 ) & 0xFF;
			var g : uint  = ( color >> 8 ) & 0xFF;
			var b : uint  = color & 0xFF;

			var a : Array = [ 0, 0, 0, 0, r, 0, 0, 0, 0, g, 0, 0, 0, 0, b, 0, 0, 0, 1, 0 ];

			if ( n == 0 )
			{
				a[ 0 ] = 1;
				a[ 4 ] = 0;
			}

			if ( n == 1 )
			{
				a[ 6 ] = 1;
				a[ 9 ] = 0;
			}

			if ( n == 2 )
			{
				a[ 12 ] = 1;
				a[ 14 ] = 0;
			}

			var filter : ColorMatrixFilter = new ColorMatrixFilter( a );
			ccb.bd.applyFilter( ccb.bd, new Rectangle( 0, 0, 20, 256 ), new Point( 0, 0 ), filter );
		}


		private function change_rcx1_hsb( hsb : ColorHSB, n : uint ) : void
		{
			if ( n > 3 )
				return;
			var d : uint     = 0;
			var o : ColorHSB = new ColorHSB( hsb.h, hsb.s, hsb.b );
			var m : String   = "";

			if ( n == 0 )
			{
				m = "h";
				d = 360;
				o.s = 100;
				o.b = 100;
			}

			if ( n == 1 )
			{
				m = "s";
				d = 100;
			}

			if ( n == 2 )
			{
				m = "b";
				d = 100;
			}

			for ( var y : int = 0; y < 256; y++ )
			{
				o[ m ] = ( y / 255 ) * d;
				var c : uint = ColorHSB.hsb_to_rgb( o );

				for ( var x : int = 0; x < 20; x++ )
				{
					ccb.bd.setPixel( x, 255 - y, c );
				}
			}

		}

		private function set_cc_marker() : void
		{
			var x : uint ;
			var y : uint ;

			x = position.x;
			y = position.y;

			ccm.x = x + 8;
			ccm.y = 255 - y + 8;

			y = position.p;

			cclm.y = ccrm.y = 255 - y + 8 - 4;
			ccrm.x = 1;
			cclm.x = 30;
		}


		[Bindable]
		public var _color : uint                   = 0;
		
		[Bindable]
		public var colorValue : String;

		[Bindable]
		public var hsb : ColorHSB                  = new ColorHSB();

		//[Bindable]
		//private var ob_hsb:Object = hsb.to_object();


		[Bindable]
		private var mode : uint                    = 0;

		[Bindable]
		public var old_color : uint                = 0;
		
		[Bindable]
		public var oldColorValue : String;

		[Bindable]
		private var sel_rgb : uint                 = 0;

		[Bindable]
		private var sel_hsb : uint                 = 0;

		private function set color( c : uint ) : void
		{
			_color = c;
		}

		private function get color() : uint
		{
			return _color;
		}

		public static function get current_color() : uint
		{
			return ( wnd != null ) ? wnd._color : 0;
		}

		public function on_tx_hex_change() : void
		{
			var s : String = hexrgb.text.toUpperCase();
			var d : String = '';

			for ( var i : int = 0; i < s.length; i++ )
			{
				var c : int = s.charCodeAt( i );

				if ( ( c < 48 || c > 57 ) && ( c < 65 || c > 70 ) )
					continue;
				d += String.fromCharCode( c );
			}

			//hexrgb.text = colorValue = d;
			color = uint( d == '' ? 0 : '0x' + d );
			
			hsb = ColorHSB.rgb_to_hsb( color );

			update_position();
			redraw_bars();
		}


		public function on_rb_rgb_change() : void
		{
			sel_rgb = uint( -1 );
			mode = 0;

			var ic : Class;

			if ( rb_r.selected )
			{
				sel_rgb = 0;
				ic = osi_rgb_r;
			}
			else if ( rb_g.selected )
			{
				sel_rgb = 1;
				ic = osi_rgb_g;
			}
			else if ( rb_b.selected )
			{
				sel_rgb = 2;
				ic = osi_rgb_b;
			}

			position = rgb_to_position( color, sel_rgb );
			update_hex_rgb();
			redraw_bars();
		}


		public function on_rb_hsb_change() : void
		{
			sel_hsb = uint( -1 );
			mode = 1;

			var ic : Class;

			if ( rb_H.selected )
			{
				sel_hsb = 0;
				ic = osi_hsb_h;
			}
			else if ( rb_S.selected )
			{
				sel_hsb = 1;
				ic = osi_hsb_s;
			}
			else if ( rb_B.selected )
			{
				sel_hsb = 2;
				ic = osi_hsb_b;
			}

			position = hsb_to_position( hsb, sel_hsb );
			update_hex_rgb();
			redraw_bars();
		}


		public function on_tx_rgb_change() : void
		{
			color = ( ( tx_r.value & 0xFF ) << 16 ) + ( ( tx_g.value & 0xFF ) << 8 ) + ( tx_b.value & 0xFF )
			
			hsb = ColorHSB.rgb_to_hsb( color );
			
			update_hex_rgb();
			update_position();
			redraw_bars();
		}

		public function on_tx_hsb_change() : void
		{
			hsb = new ColorHSB( tx_H.value, tx_S.value, tx_B.value );
			
			color = ColorHSB.hsb_to_rgb( hsb );
			
			update_hex_rgb();
			update_position();
			redraw_bars();
		}

		private function redraw_bars() : void
		{
			if ( mode == 0 )
			{
				change_rcx1_rgb( color, sel_rgb );
				change_rcx2_rgb( color, sel_rgb );
				set_cc_marker();
			}
			else
			{
				change_rcx1_hsb( hsb, sel_hsb );
				change_rcx2_hsb( hsb, sel_hsb );
				set_cc_marker();
			}

		}

		private function update_position() : void
		{
			if ( mode == 0 )
				position = rgb_to_position( color, sel_rgb );
			else if ( mode == 1 )
				position = hsb_to_position( hsb, sel_hsb );
		}

		public function on_restore_color() : void
		{
			color = old_color;
			colorValue = oldColorValue;
			
			start_init();
		}

		private var f_apply_flag : Boolean         = false;

		public static function show_window( parent : DisplayObject, colorValue : String, modal : Boolean ) : void
		{
			if ( wnd == null )
			{
				wnd = new ColorPickerWindow();
				wnd.addEventListener( mx.events.CloseEvent.CLOSE, on_close_event );
			}

			wnd.m_parent = parent;
			wnd.colorValue = wnd.oldColorValue = colorValue;
			
			var colorInNumber : uint = uint( ( colorValue == "" ) ? "0" : "0x" + colorValue );
			wnd._color = wnd.old_color = colorInNumber;

			if ( !wnd.isPopUp )
			{
				PopUpManager.addPopUp( wnd, DisplayObject( UIComponent( parent ).parentApplication ), modal );
				PopUpManager.centerPopUp( wnd );
			}
			else
			{
				PopUpManager.bringToFront( wnd );
				wnd.start_init();
			}
		}
		
		public function ok_close_window() : void
		{
			f_apply_flag = true;
			close_window();
		}

		public function cancel_close_window() : void
		{
			close_window();
		}

		public function close_window() : void
		{
			dispatchEvent( new CloseEvent( mx.events.CloseEvent.CLOSE ) );
		}

		public static function hide_window() : void
		{
			if ( wnd != null )
				wnd.close_window();
		}

		private function with_last_preved() : void
		{
			if ( f_apply_flag )
			{
				if ( m_parent != null )
					m_parent.dispatchEvent( new ColorPickerEvent( ColorPickerEvent.APPLY, _color, hexrgb.text ) );
				return;
			}

			if ( _color != old_color )
			{
				_color = old_color;
				
				colorValue = oldColorValue;
			}

			if ( m_parent != null )
				m_parent.dispatchEvent( new ColorPickerEvent( "cancel", _color, hexrgb.text ) );
		}

		private static function on_close_event( event : CloseEvent ) : void
		{
			if ( wnd == null )
				return;

			wnd.with_last_preved();
			
			PopUpManager.removePopUp( wnd );
			wnd = null;
		}

		public function on_ccc_mouse_down( event : MouseEvent ) : void
		{
			stage.addEventListener( MouseEvent.MOUSE_MOVE, on_ccc_mouse_mov, true );
			stage.addEventListener( MouseEvent.MOUSE_UP, on_ccc_mouse_up, true );
			on_ccc_md();
		}

		public function on_ccc_mouse_up( event : MouseEvent ) : void
		{
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, on_ccc_mouse_mov, true );
			stage.removeEventListener( MouseEvent.MOUSE_UP, on_ccc_mouse_up, true );
			on_ccc_md();
		}

		public function on_ccc_mouse_mov( event : MouseEvent ) : void
		{
			if ( !event.buttonDown )
			{
				stage.removeEventListener( MouseEvent.MOUSE_MOVE, on_ccc_mouse_mov, true );
				stage.removeEventListener( MouseEvent.MOUSE_UP, on_ccc_mouse_up, true );
				return;
			}
			on_ccc_md();
		}


		public function on_ccb_mouse_down( event : MouseEvent ) : void
		{
			stage.addEventListener( MouseEvent.MOUSE_MOVE, on_ccb_mouse_mov, true );
			stage.addEventListener( MouseEvent.MOUSE_UP, on_ccb_mouse_up, true );
			on_ccb_md();
		}

		public function on_ccb_mouse_up( event : MouseEvent ) : void
		{
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, on_ccb_mouse_mov, true );
			stage.removeEventListener( MouseEvent.MOUSE_UP, on_ccb_mouse_up, true );
			on_ccb_md();
		}

		public function on_ccb_mouse_mov( event : MouseEvent ) : void
		{
			if ( event.buttonDown )
				on_ccb_md();
			else
			{
				stage.removeEventListener( MouseEvent.MOUSE_MOVE, on_ccb_mouse_mov, true );
				stage.removeEventListener( MouseEvent.MOUSE_UP, on_ccb_mouse_up, true );
			}
		}

		private var m_timer_count_init : int       = 20;

		private var m_timer_count : int            = m_timer_count_init;

		private var m_timer : Timer                = null;

		private function on_timer_redraw( fn : Function ) : void
		{
			if ( m_timer != null )
			{
				m_timer.stop();

				if ( --m_timer_count <= 0 )
				{
					m_timer = null;
					m_timer_count = m_timer_count_init;
					fn( new TimerEvent( "timer" ) );
					return;
				}
			}

			m_timer = new Timer( 10, 1 );
			m_timer.addEventListener( "timer", fn );
			m_timer.start();
		}


		private function on_ccc_md_draw() : void
		{
			m_timer = null;

			if ( mode == 0 )
				change_rcx1_rgb( color, sel_rgb );
			else
				change_rcx1_hsb( hsb, sel_hsb );
		}

		private function on_ccc_md() : void
		{
			var x : int = int( ccc.mouseX );
			var y : int = int( ccc.mouseY );

			if ( x < 0 )
				x = 0;

			if ( x > 255 )
				x = 255;

			if ( y < 0 )
				y = 0;

			if ( y > 255 )
				y = 255;

			position.x = x;
			position.y = 255 - y;

			if ( mode == 0 )
			{
				color = position_to_rgb( position, sel_rgb );
				hsb = ColorHSB.rgb_to_hsb( color );
			}
			else
			{
				hsb = position_to_hsb( position, sel_hsb );
				color = ColorHSB.hsb_to_rgb( hsb );
			}

			update_hex_rgb();
			set_cc_marker();

			if ( mode == 0 )
				change_rcx1_rgb_matrix( color, sel_rgb );
			else
				on_ccc_md_draw();
		}

		private function on_ccb_md_timer( event : TimerEvent ) : void
		{
			m_timer = null;

			if ( mode == 0 )
				change_rcx2_rgb_matrix( color, sel_rgb );
			else
				change_rcx2_hsb( hsb, sel_hsb );
		}


		private function on_ccb_md() : void
		{
			var x : int = int( ccb.mouseX );
			var y : int = int( ccb.mouseY );

			if ( x < 0 )
				x = 0;

			if ( x > 20 )
				x = 20;

			if ( y < 0 )
				y = 0;

			if ( y > 255 )
				y = 255;

			position.p = 255 - y;

			if ( mode == 0 )
			{
				color = position_to_rgb( position, sel_rgb );
				hsb = ColorHSB.rgb_to_hsb( color );
			}
			else
			{
				hsb = position_to_hsb( position, sel_hsb );
				color = ColorHSB.hsb_to_rgb( hsb );
			}
			update_hex_rgb();
			set_cc_marker();

			if ( mode == 0 )
				change_rcx2_rgb_matrix( color, sel_rgb );
			else
				on_timer_redraw( on_ccb_md_timer );
		}

		private function update_hex_rgb() : void
		{
			if ( !hexrgb )
				return;

			hexrgb.text = colorValue = zn( color.toString( 16 ).toUpperCase(), 6 )
		}

		private static function zn( s : String, n : uint ) : String
		{
			var i : int = n - s.length;

			while ( --i >= 0 )
			{
				s = "0" + s;
			}

			return s;
		}
	}
}
