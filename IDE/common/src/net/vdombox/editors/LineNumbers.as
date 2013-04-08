package net.vdombox.editors
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class LineNumbers extends Sprite
	{
		public var fmt : TextFormat;

		public var box : Point;

		private static var cache : Array = [];

		private var begin : int;

		private var markLines : Array;

		private var markColor : uint;

		private var markTips : Array;

		private var numbers : Sprite;

		private var marks : Sprite;


		public function LineNumbers( boxSize : Point, fmt : TextFormat )
		{
			this.fmt = fmt;
			box = boxSize;
			markLines = [];
			addChild( marks = new Sprite );
			addChild( numbers = new Sprite );
			numbers.mouseEnabled = false;
		}

		private function checkCreateItem( no : Number ) : Bitmap
		{
			if ( cache[ no ] )
				return new Bitmap( cache[ no ] );

			var tf : TextField = new TextField;
			tf.width = box.x * 5;
			var fmt2 : TextFormat = new TextFormat;
			fmt2.align = "right";
			tf.text = String( no );
			tf.setTextFormat( fmt );
			tf.setTextFormat( fmt2 );

			var bd : BitmapData = new BitmapData( box.x * 5, box.y, true, 0xA0A0A1A1 );
			bd.draw( tf, new Matrix( 1, 0, 0, 1, -1, -1 ) );
			cache[ no ] = bd;
			return new Bitmap( bd );
		}

		public function clearCache() : void
		{
			cache = [];
		}

		public function draw( begin : int, size : Number, max : int ) : void
		{
			this.begin = begin;

			while ( numbers.numChildren )
				numbers.removeChildAt( 0 );

			for ( var i : Number = 0; i < size && ( i + begin ) < max; i++ )
			{
				var bmp : Bitmap = checkCreateItem( i + begin + 1 );
				bmp.y = i * box.y;
				numbers.addChild( bmp );
			}

			drawMark();
		}



		public function mark( lines : Array, tips : Array, color : uint ) : void
		{
			markLines = lines;
			markColor = color;
			markTips = tips;
			drawMark();
		}

		public function drawMark() : void
		{
			while ( marks.numChildren )
				marks.removeChildAt( 0 );
			for ( var i : int = 0; i < markLines.length; i++ )
			{
				var m : Sprite = new Sprite;

				m.graphics.beginFill( markColor, .6 );
				m.graphics.drawRect( 0, 0, box.x * 5, box.y - 1 );
				m.y = ( markLines[ i ] - begin - 1 ) * box.y;

				//				JSharedToolTip.getSharedInstance().registerComponent(m, markTips[i]);


				marks.addChild( m );
			}
		}


	}
}