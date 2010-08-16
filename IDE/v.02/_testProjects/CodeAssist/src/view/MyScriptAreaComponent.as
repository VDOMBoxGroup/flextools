package view
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import ro.victordramba.scriptarea.ScriptAreaEvents;
	
	import spark.core.SpriteVisualElement;

	public class MyScriptAreaComponent extends SpriteVisualElement
	{
		public function MyScriptAreaComponent()
		{
			super();

			area = new ScriptAreaEvents;

			addChild( area );

			addEventListener( FocusEvent.FOCUS_IN, function( e : FocusEvent ) : void
			{
				stage.focus = area;
			} );

			addEventListener( FocusEvent.KEY_FOCUS_CHANGE, function( e : Event ) : void
			{
				e.preventDefault();
			} );

			area.addEventListener( Event.SCROLL, function( e : Event ) : void
			{
				if ( viewportSizeTesting )
					return;
				if ( viewPos.y != area.scrollY )
				{
					viewPos.y = area.scrollY;
					updateNums();
//					fireStateChanged( true );
				}
			} );

			area.addEventListener( Event.CHANGE, function( e : Event ) : void
			{
//				revalidate();
			} );

			lineNums = new LineNumbers( area.boxSize, area.textFormat );
			lineNums.y = 2;
			addChild( lineNums );

			lineNums.addEventListener( MouseEvent.MOUSE_DOWN, area.onMouseDown );
		}

		private var area:ScriptAreaEvents;
		private var viewportSizeTesting:Boolean = false;
		private var lineNums:LineNumbers;
		
		private var viewPos:Point = new Point();
		
		public function markLines( lines : Array /*of int*/, tips : Array /*of String*/, color : uint = 0xff0000 ) : void
		{
			lineNums.mark( lines, tips, color );
		}

		public function getInternalFocusObject() : InteractiveObject
		{
			return area;
		}

		public function isEditable() : Boolean
		{
			return true;
		}

		public function setEditable( value : Boolean ) : void
		{

		}

		private function updateNums() : void
		{
			lineNums.draw( area.scrollY, area.height / area.boxSize.y, 100000 );
		}

		public function paint( width : Number, height : Number ) : void
		{
			area.x = area.boxSize.x * 5;
//			area.y = b.y;
			area.width = width - 1;
			area.height = height-1;
			//scroll
			area.scrollRect = new Rectangle(viewPos.x, 0, width, height);
			area.scrollY = viewPos.y;
			updateNums();
		}
		
		public function clearFormatRuns() : void
		{
			area.clearFormatRuns();
		}

		public function addFormatRun( beginIndex : int, endIndex : int, bold : Boolean, italic : Boolean, color : String ) : void
		{
			area.addFormatRun( beginIndex, endIndex, bold, italic, color );
		}


		public function applyFormatRuns() : void
		{
			area.applyFormatRuns();
		}

		public function get caretIndex() : int
		{
			return area.caretIndex;
		}

		public function get selectionBeginIndex() : int
		{
			return area.selectionBeginIndex;
		}

		public function get selectionEndIndex() : int
		{
			return area.selectionEndIndex;
		}

		public function getPointForIndex( index : int ) : Point
		{
			var p : Point = area.getPointForIndex( index );
			p.offset( lineNums.width, 0 );
			return p;
		}


		public function set text( text : String ) : void
		{
			area.text = text;
//			revalidate();
		}

		public function get text() : String
		{
			return area.text;
		}

		public function replaceText( startIndex : int, endIndex : int, text : String ) : void
		{
			area.replaceText( startIndex, endIndex, text );
		}

		public function setSelection( beginIndex : int, endIndex : int ) : void
		{
			area.setSelection( beginIndex, endIndex );
		}


		//------------------------------------------------------------------------------------
		// Viewportable
		//------------------------------------------------------------------------------------

		public function getVerticalUnitIncrement() : int
		{
			return 1;
		}

		public function getVerticalBlockIncrement() : int
		{
			return 10;
		}

		public function getHorizontalUnitIncrement() : int
		{
			return area.boxSize.x;
		}

		public function getHorizontalBlockIncrement() : int
		{
			return area.boxSize.x * 10;
		}

		public function setVerticalUnitIncrement( increment : int ) : void
		{
		}

		public function setVerticalBlockIncrement( increment : int ) : void
		{
		}

		public function setHorizontalUnitIncrement( increment : int ) : void
		{
		}

		public function setHorizontalBlockIncrement( increment : int ) : void
		{
		}
	}
}