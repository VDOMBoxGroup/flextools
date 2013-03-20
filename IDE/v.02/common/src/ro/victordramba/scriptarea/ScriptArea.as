package ro.victordramba.scriptarea
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import net.vdombox.editors.parsers.base.BlockPosition;
	import net.vdombox.editors.parsers.base.Controller;
	import net.vdombox.editors.parsers.base.Token;
	import net.vdombox.ide.common.model._vo.ColorSchemeVO;
	import net.vdombox.utils.StringUtils;

	public class ScriptArea extends Base
	{
		static protected var NL : String = "\r";

		public function ScriptArea()
		{
			mouseChildren = false;
			mouseEnabled = true;
			buttonMode = true;
			useHandCursor = false;
			
			backgroundShape = new Shape;
			addChild( backgroundShape );
			
			selectionShapeRects = new Shape;
			addChild( selectionShapeRects );
			
			selectionShape = new Shape;
			addChild( selectionShape );
			
			indentLinesShape = new Shape;
			addChild( indentLinesShape );
			
			linesShape = new Shape;
			addChild( linesShape );
			
			tf = new TextField;
			tf.multiline = true;
			tf.wordWrap = false;
			//tf.background = true;

			fmt = new TextFormat( "Courier New", 14, 0 );

			for each ( var fnt : Font in Font.enumerateFonts( true ) )
			{
				if ( fnt.fontName == "Liberation Mono" )
				{
					fmt.font = fnt.fontName;
					fmt.size = 13;
					break;
				}
			}

			tf.defaultTextFormat = fmt;


			tf.text = " ";
			_letterBoxHeight = tf.getLineMetrics( 0 ).height;
			letterBoxWidth = tf.getLineMetrics( 0 ).width;
			tf.text = "";

			addChild( tf );

			cursor = new ScriptCursor();
			cursor.visible = false;
			cursor.x = tf.x;
			cursor.y = tf.y;

			ScriptCursor.height = letterBoxHeight;

			addChild( cursor );
		}

		protected var _caret : int;
		protected var _start : int;
		protected var _selStart : int = 0;
		protected var _selEnd : int = 0;

		protected var cursor : ScriptCursor;

		protected var _text : String = "";

		protected var visibleRows : int;

		private var tf : TextField;

		private var _letterBoxHeight : int;
		private var letterBoxWidth : int;

		private var _scrollH : int = 0;
		private var _scrollV : int = 0;

		private var firstPos : int = 0;
		private var lastPos : int = 0;

		private var _maxScrollH : int = 0;
		private var _maxScrollV : int = 0;
		
		private var backgroundShape : Shape;
		private var backgroundShapeColor : uint = 0xFFFFFF;

		private var selectionShape : Shape;
		private var selectionShapeColor : uint = 0x3399FF;
		
		private var selectionShapeRects : Shape;
		private var selectionShapeRectsColor : uint = 0xD4D4D4;
		
		private var indentLinesShape : Shape;
		private var indentLinesShapeColor : uint = 0x000000;
			
		private var selectionSkobkiColor : uint = 0xc0c0c0;
		
		private var needChangeColorSelected : Boolean = true;
		
		private var linesShape : Shape;

		private var undoBuff : Array = [];
		private var redoBuff : Array = [];

		//format. very simplified
		private var runs : Array = [];

		private var fmt : TextFormat;

		private var savedUndoIndex : int = 0;
		
		public var controller : Controller;
		
		private var defaultColor : uint = 0xFFFFFF;
		
		protected var _indentLines : Array;
		
		public var showIndentLines : Boolean = false;
		
		public function set indentLines(value:Array):void
		{
			_indentLines = value;
			
			if ( showIndentLines )
				updateIndentLines();
			else
				clearIndentLines();
		}
		
		private function clearIndentLines() : void
		{
			var g : Graphics = indentLinesShape.graphics;
			
			g.clear();
		}
		
		private function updateIndentLines() : void
		{
			var g : Graphics = indentLinesShape.graphics;
			
			g.clear();
			
			g.beginFill( indentLinesShapeColor, 1 );
			
			var point1 : Point;
			var point2 : Point;
			var step : int = 3;
			var px : int = 0;
			var py : int = 0;
			
			for each ( var blockPosition : BlockPosition in _indentLines )
			{				
				if ( text.charAt( blockPosition.start - 1 ) == '\r' ||  text.charAt( blockPosition.start - 1 ) == '\n' || blockPosition.start == 0)
					continue;
				
				point1 = getPointForIndex( blockPosition.start );
				point2 = getPointForIndex( blockPosition.end );
				
				px = point1.x;
				
				py = point1.y + _letterBoxHeight + 3;
				point2.y += _letterBoxHeight;
				
				while ( py < point2.y )
				{
					g.drawCircle( point1.x - indentLinesShape.x, py - indentLinesShape.y, 0.5 );
					
					py += step;
				}
			}
		}

		public function get letterBoxHeight():int
		{
			return _letterBoxHeight;
		}

		public function set colorScheme( value : ColorSchemeVO ) : void
		{
			backgroundShapeColor = value.backGroundColor;
			defaultColor = value.defaul_t;
			selectionShapeColor = value.selectionColor;
			selectionShapeRectsColor = value.selectionRectsColor;
			indentLinesShapeColor = value.indentLinesShapeColor;
			needChangeColorSelected = value.needChangeColorSelected;
			cursor.color= value.cursorColor;
		}
		
		public function set fontSize( value : uint ) : void
		{			
			fmt = new TextFormat( "Courier New", value, 0 );
			
			tf.defaultTextFormat = fmt;
			
			var tmp : String = tf.text;
				
			tf.text = " ";
			
			_letterBoxHeight = tf.getLineMetrics( 0 ).height;
			letterBoxWidth = tf.getLineMetrics( 0 ).width;
			
			tf.text = tmp;
			
			ScriptCursor.height = letterBoxHeight;
			
			updateCaret();
			updateScrollProps();
			updateSize();
		}

		public function get textFormat() : TextFormat
		{
			return fmt;
		}

		public function get length() : int
		{
			return _text.length;
		}

		public function set scrollH( value : int ) : void
		{
			if ( -tf.x == value )
				return;

			tf.x = selectionShape.x = selectionShapeRects.x = linesShape.x = indentLinesShape.x = -value;

			updateCaret();
			dispatchEvent( new Event( Event.SCROLL, true ) );
		}

		public function get scrollH() : int
		{
			return -tf.x;
		}

		public function set scrollV( value : int ) : void
		{
			if ( _scrollV == value )
				return;

			_scrollV = Math.min( Math.max( 0, value ), _maxScrollV );

			//tf.y = selectionShape.y = selectionShapeRects.y = linesShape.y = indentLinesShape.y = -_scrollV * _letterBoxHeight;
			
			updateScrollProps();

			updateCaret();
			
			/*if ( !blocked )
			{
				t.start();
				blocked = true;
			}*/

			_setSelection( _selStart, _selEnd );
			
			ClearLines();
			
			if ( showIndentLines )
				updateIndentLines();

			dispatchEvent( new Event( Event.SCROLL, true ) );
		}

		public function get scrollV() : int
		{
			return _scrollV;
		}

		public function get boxSize() : Point
		{
			return new Point( letterBoxWidth, letterBoxHeight );
		}

		public function get maxScrollH() : int
		{
			return tf.width - width > 0 ? tf.width - width : 0;
		}

		public function get maxScrollV() : int
		{
			return _maxScrollV;
		}

		public function get caretIndex() : int
		{
			return _caret;
		}
		
		public function set caretIndex( value : int ) : void
		{
			if ( value < 0 || value > text.length )
				return;
			
			_caret = value;
			_setSelection( value, value );
			updateCaret();
		}

		public function get selectionBeginIndex() : int
		{
			return _selStart;
		}

		public function get selectionEndIndex() : int
		{
			return _selEnd;
		}
		
		public function get selectionText() : String
		{
			return _text.substring( _selStart, _selEnd );
		}

		public function get text() : String
		{
			return _text;
		}

		public function set text( str : String ) : void
		{
			replaceText( 0, length, str );
		}

		public function get changed() : Boolean
		{
			return undoBuff.length != savedUndoIndex;
		}

		public function appendText( text : String ) : void
		{
			replaceText( _text.length, _text.length, text );
		}

		public function setSelection( beginIndex : int, endIndex : int ) : void
		{
			_setSelection( beginIndex, endIndex, true );
		}

		public function gotoLine( line : int ) : void
		{
			var pos : int = -1;

			while ( line > 0 )
			{
				pos = _text.indexOf( NL, pos + 1 );
				line--;
			}

			setSelection( pos, pos );
		}
		
		public function replaceFind( findText : String, reText : String, replaceAll : Boolean = false ) : void
		{
			if ( findText == "" )
				return;
			
			var index : int;
			
			if ( replaceAll )
			{
				index = text.indexOf( findText );
				while ( index != -1 )
				{
					replaceText( index, index + findText.length, reText );
					index = text.indexOf( findText, index + 1 );
				}
			}
			else
			{
				index = text.indexOf( findText, _caret );
				
				if ( index == -1 )
					return;
				
				replaceText( index, index + findText.length, reText );
			}
			
			_caret = index;
			
			updateCaret();
			checkScrollToCursor();
			updateScrollProps();
			
			var g : Graphics = selectionShape.graphics;
			g.clear();
			
			g.beginFill( selectionShapeColor, 1 );
			
			var p0 : Point = getPointForIndex( index );
			var p1 : Point = getPointForIndex( index + _replaceText.length );
			
			g.drawRect( p0.x, p0.y, p1.x - p0.x, letterBoxHeight );
			
			selectionRects( findText );
			
			_replaceText( 0, 0, "" );
		}	
		
		private var _selectRects : Array = new Array();
		
		private function clearRect() : void
		{
			var g : Graphics = selectionShapeRects.graphics;
			g.clear();
			
			g = selectionShape.graphics;
			g.clear();
		}
		
		public function findText( findText : String, type : int, caseSensitive : Boolean ) : Boolean
		{
			clearRect();
			
			if ( findText == "" )
			{
				_setSelection( 0, 0 );
				return false;
			}
				
			var index : int;
			var string : String = caseSensitive ? text.toLocaleLowerCase() : text;
			
			if ( type == 0 )
			{
				index = string.indexOf( findText, _caret );
				
				if ( index == -1 )
					index = string.indexOf( findText );
			}
			
			else if ( type == 1 )
			{
				var saveInd : int = -1;
				var ind : int = string.indexOf( findText );
				var car : int = _caret;
				
				while ( saveInd == -1 && ind != -1)
				{
					while ( ind < car && ind != -1 )
					{
						saveInd = ind;
						ind = string.indexOf( findText, ind + 1 );
					}
					
					if ( saveInd == -1 )
						car = text.length - 1;
				}
				
				index = saveInd;
			}
			else if ( type == 2 )
			{
				index = string.indexOf( findText, _caret );
				
				if ( index == _caret )
					index = string.indexOf( findText, _caret + 1 );
				
				if ( index == -1 )
					index = string.indexOf( findText );
			}
			
			if ( index == -1 )
			{
				_setSelection( 0, 0 );
				return false;
			}
			
			goToPos( index, findText.length );
			
			//selectionRects( findText );
			
			_replaceText( 0, 0, "" );
			
			return true;
		}
		
		public function goToPos( pos : int, len : int ) : void
		{
			_caret = pos;
			
			updateCaret();
			checkScrollToCursor();
			updateScrollProps();
			
			_selStart = pos;
			_selEnd = pos + len;
			
			var g : Graphics = selectionShape.graphics;
			g.clear();
			
			g.beginFill( selectionShapeColor, 1 );
			
			var p0 : Point = getPointForIndex( _selStart );
			var p1 : Point = getPointForIndex( _selEnd );
			
			g.drawRect( p0.x, p0.y, p1.x - p0.x, letterBoxHeight );
			
			//setSelectionRects();
			
			_replaceText( 0, 0, "" );
		}
		
		private function selectionRects( findText : String ) : void
		{
			var index : int = text.indexOf( findText );
			var step : int = findText.length;
			
			var g : Graphics = selectionShapeRects.graphics;
			g.clear();
			g.beginFill( selectionShapeRectsColor, .9 );
			
			var t : Token = controller.getTokenByPos( index );
			while ( index != -1 )
			{
				var p0 : Point = getPointForIndex( index );
				var p1 : Point = getPointForIndex( index + step );
					
				g.drawRect( p0.x, p0.y, p1.x - p0.x, letterBoxHeight );
				
				index = text.indexOf( findText, index + 1 );
			}
		}
		
		private function setSelectionRects() : void
		{
			var g : Graphics = selectionShapeRects.graphics;
			g.clear();
			
			if ( _selStart == _selEnd )
				return;
			
			var t : Token = controller.getTokenByPos( _selStart );
			
			if ( !t )
				return;
			
			var _start : int = _selStart;
			var _end : int = _selStart;
			
			var _startRect : int;
			var _endRect : int;
			
			while ( /\w/.test( _text.charAt( _start ) ) )
				_start--;
			
			_start++;
			
			while ( /\w/.test( _text.charAt( _end ) ) )
				_end++;
			
			var strFind : String = text.slice( _start, _end );
			var strTemp : String;
			
			if ( strFind == "" )
				return;
			
			var index : int = text.indexOf( strFind );
			var step : int = _end - _start;
			
			g.beginFill( selectionShapeRectsColor, 1 );
			
			while ( index != -1 )
			{
				_startRect = _endRect = index;
				
				while ( /\w/.test( _text.charAt( _startRect ) ) )
					_startRect--;
				
				_startRect++;
				
				while ( /\w/.test( _text.charAt( _endRect ) ) )
					_endRect++;
					
				if ( text.slice( _startRect, _endRect ) == strFind )
				{
					
					var p0 : Point = getPointForIndex( index );
					var p1 : Point = getPointForIndex( index + step );
					
					var t2 : Token = controller.getTokenByPos( index );
					if ( !t2 )
						return;
					
					if ( t.string == t2.string )
						g.drawRect( p0.x, p0.y, p1.x - p0.x, letterBoxHeight );
				}
				
				index = text.indexOf( strFind, index + 1 );
			}
		}

		public function _setSelection( beginIndex : int, endIndex : int, caret : Boolean = false ) : void
		{
			_selStart = beginIndex;
			_selEnd = endIndex;
			
			_start = _selStart;

			if ( _selStart > _selEnd )
			{
				var tmp : int = _selEnd;
				_selEnd = _selStart;
				_selStart = tmp;
				
				_start = _selEnd;
			}

			var p0 : Point = getPointForIndex( Math.max( _selStart, firstPos ) );
			var p1 : Point = getPointForIndex( Math.min( _selEnd, lastPos ) );
			var g : Graphics = selectionShape.graphics;

			g.clear();
			
			setSelectionRects();

			if ( _selStart != _selEnd && _selStart <= lastPos && _selEnd >= firstPos )
			{
				g.beginFill( selectionShapeColor, 1 );

				if ( p0.y == p1.y )
				{
					g.drawRect( p0.x, p0.y, p1.x - p0.x, letterBoxHeight );
				}
				else
				{
					g.drawRect( p0.x, p0.y, tf.width - p0.x, letterBoxHeight );
					var rows : int = ( p1.y - p0.y ) / letterBoxHeight;

					for ( var i : int = 1; i < rows; i++ )
					{
						g.drawRect( 1, p0.y + letterBoxHeight * i, tf.width, letterBoxHeight );
					}

					//if selection is past last visible pos, we draw a full line
					g.drawRect( 1, p0.y + letterBoxHeight * i, lastPos >= _selEnd ? p1.x : width, letterBoxHeight );
				}
			}

			if ( caret )
			{
				cursor.visible = _caret <= lastPos && _caret >= firstPos;
				_caret = endIndex;
				cursor.pauseBlink();
				cursor.setX( p1.x + tf.x );
				cursor.y = p1.y + tf.y;
				checkScrollToCursor();
			}
			
			_replaceText( 0, 0, "" );
		}

		public function updateCaret() : void
		{
			cursor.visible = _caret <= lastPos && _caret >= firstPos;
			cursor.pauseBlink();
			var p : Point = getPointForIndex( _caret );
			cursor.setX( p.x + tf.x );
			cursor.y = p.y + tf.y;
		}

		//call this when the file is saved so we know if the file is changed
		public function saved() : void
		{
			savedUndoIndex = undoBuff.length;
		}

		public function resetUndo() : void
		{
			undoBuff.length = 0;
			redoBuff.length = 0;
		}

		public function replaceText( startIndex : int, endIndex : int, text : String ) : void
		{
			if( !text )
				text = "";
			
			text = text.replace( /\r\n/g, NL );
			text = text.replace( /\n/g, NL );
			
			if ( _text == text )
				return;
			
			undoBuff.push( { s: startIndex, e: startIndex + text.length, t: _text.substring( startIndex, endIndex ) } );
			redoBuff.length = 0;
			_replaceText( startIndex, endIndex, text );
		}

		public function replaceSelection( text : String ) : void
		{
			replaceText( _selStart, _selEnd, text );
			updateSize();
			//FIXME filter text
			_setSelection( _selStart + text.length, _selStart + text.length, true );
		}

		public function getPointForIndex( index : int ) : Point
		{
			var pos : int = 0;
			var lines : int = 0;
			var lastNL : int = 0;

			while ( true )
			{
				pos = _text.indexOf( NL, pos ) + 1;

				if ( pos == 0 || pos > index )
					break;

				lines++;
				lastNL = pos;
			}

			//count tabs
			for ( var i : int = lastNL, tabs : int = 0; i < index; i++ )
			{
				if ( _text.charAt( i ) == "\t" )
					tabs++;
			}
			text.charAt(378)

			//simple tabs, just 4 spaces, no align
			return new Point( ( index - lastNL + tabs * 3 ) * letterBoxWidth + 1, ( lines - _scrollV ) * letterBoxHeight + 2 );
		}

		public function addFormatRun( beginIndex : int, endIndex : int, bold : Boolean, italic : Boolean, color : String, error : Boolean = false ) : void
		{
			if ( beginIndex > _selStart && beginIndex < _selEnd )
			{
				if ( endIndex < _selEnd )
					return;
				else
					beginIndex = _selEnd;
			}
			
			if ( endIndex > _selStart && endIndex < _selEnd )
			{
				endIndex = _selStart;
			}
				
			runs.push( { begin: beginIndex, end: endIndex, color: color, bold: bold, italic: italic, error : error } );
		}

		public function clearFormatRuns() : void
		{
			runs.length = 0;
		}

		public function applyFormatRuns() : void
		{
			_replaceText( 0, 0, "" );
		}
		
		public function addIndentLines( indentLines : Array ) : void
		{
			this.indentLines = indentLines;
		}

		protected function undo() : void
		{		
			if ( undoBuff.length <= 1 )
				return;
			
			var o : Object = undoBuff.pop();
			redoBuff.push( { s: o.s, e: o.s + o.t.length, t: _text.substring( o.s, o.e ) } );
			
			_replaceText( o.s, o.e, o.t );
			_caret = o.s + o.t.length;
			_setSelection( _caret, _caret, true );
		}

		protected function redo() : void
		{
			if ( redoBuff.length == 0 )
				return;

			var o : Object = redoBuff.pop();
			undoBuff.push( { s: o.s, e: o.s + o.t.length, t: _text.substring( o.s, o.e ) } );

			_replaceText( o.s, o.e, o.t );
			_caret = o.s + o.t.length;
			_setSelection( _caret, _caret, true );
		}

		override protected function updateSize() : void
		{
			super.updateSize();

//			tf.width = width;
			tf.height = height;
			visibleRows = Math.floor( ( height - 4 ) / letterBoxHeight );
			updateScrollProps();
			cursor.setSize( width, letterBoxHeight );
		}

		protected function checkScrollToCursor() : void
		{
			var ct : int, pos : int;
			if ( _caret > lastPos )
			{
				//let's count NL between lastPos and caret
				for ( ct = 0, pos = lastPos; pos != -1 && pos < _caret; ct++ )
				{
					pos = _text.indexOf( NL, pos + 1 );
				}

				scrollV += ct;
			}

			//TODO similar
			if ( _caret < firstPos )
			{
				//now count NL between firstPos and caret
				for ( ct = 0, pos = _caret; pos != -1 && pos < firstPos; ct++ )
				{
					pos = _text.indexOf( NL, pos + 1 );
				}

				scrollV -= ct;
			}
		}

		protected function getIndexForPoint( p : Point ) : int
		{
			if ( p.y < 0 )
				return firstPos;

			var pos : int = 0;
			var y : int = letterBoxHeight;

			while ( p.y + _scrollV * letterBoxHeight > y )
			{
				pos = _text.indexOf( NL, pos ) + 1;

				if ( pos > lastPos )
					return lastPos;

				if ( pos == 0 )
				{
					pos = _text.length;
					break;
				}

				y += letterBoxHeight;
			}

			var cx : int = 0;
			var c : String;

			for ( var i : int = pos; i < _text.length && ( c = _text.charAt( i ) ) != NL; i++ )
			{
				cx += ( c == "\t" ? 4 : 1 ) * letterBoxWidth;

				if ( cx > p.x - tf.x )
					break;
			}

			return i;
		}

		private function updateScrollProps() : void
		{
			var lineCount : int = 1;
			var position : int = 0;
			var prevPosition : int = 0;

			var i : int;
			var length : int;
			var maxLength : int;

			//compute maxscroll
			while ( ( position = _text.indexOf( NL, position ) ) != -1 )
			{
				var sub : String = _text.substring( prevPosition, position );

				var j : int
				var c : String;

				length = position - prevPosition + 1;

				for ( j = prevPosition; j < position; j++ )
				{
					c = _text.charAt( j )

					if ( c == "\t" )
						length += 3;
				}

				if ( length > maxLength )
					maxLength = length;

				prevPosition = ++position;

				lineCount++;
			}

			if ( maxLength == 0 )
				maxLength = _text.length;

			_maxScrollV = Math.max( 0, lineCount - visibleRows );

			var newWidth : Number = Math.max( maxLength * ( letterBoxWidth + 1 ), width ); //TODO почему + 1
			
			if( tf.width != newWidth )
			{
				tf.width = newWidth;
				_setSelection( selectionBeginIndex, selectionEndIndex, true )
				updateCaret();
			}
			
			//var newX : Number = tf.width - width;
			
			if( width <= 0 )
				return;
			
			var newX : Number = cursor.getX() - tf.x - width + 48;
			
			if ( tf.x < newX && cursor.getX() > width - 48 )
			{
				if ( newX < 0 )
					newX = 0;
				tf.x = -newX;
				selectionShape.x = selectionShapeRects.x = linesShape.x = indentLinesShape.x = -newX;
			} 
			else if ( cursor.getX() < 0 )
			{
				if ( cursor.getX() < tf.x )
				{
					tf.x = 0;
					selectionShape.x -= 0;
				}
				else
				{
					var getX : int = cursor.getX();
					tf.x -= getX;
					selectionShape.x -= getX;
					selectionShapeRects.x -= getX;
					linesShape.x -= getX;
					indentLinesShape.x -= getX;
				}
			}

			if ( _scrollV > _maxScrollV )
			{
				scrollV = _maxScrollV;
				return;
			}

			for ( i = _scrollV, position = 0; i > 0; i-- )
			{
				position = _text.indexOf( NL, position ) + 1;
			}

			firstPos = position;

			for ( i = visibleRows, position = firstPos - 1; i > 0; i-- )
			{
				position = _text.indexOf( NL, position + 1 );
				if ( position == -1 )
				{
					position = _text.length;
					break;
				}
			}

			lastPos = position;

			_replaceText( 0, 0, "" );
		}
		
		private function setBackgroundSize() : void
		{
			backgroundShape.width = width;
			backgroundShape.height = height;
			
			var g : Graphics = backgroundShape.graphics;
			g.clear();
			
			g.beginFill( backgroundShapeColor, 1 );
			
			g.drawRect( 0, 0, width, height );
		}

		private function _replaceText( startIndex : int, endIndex : int, text : String ) : void
		{
			_text = _text.substr( 0, startIndex ) + text + _text.substr( endIndex );

			if ( text.indexOf( NL ) != -1 || startIndex != endIndex )
				updateScrollProps();
			else
				lastPos += text.length;

			var i : int;
			var o : Object; //the run


			//1 remove formats for deleted text
			var delta : int = endIndex - startIndex;

			for ( i = 0; i < runs.length; i++ )
			{
				o = runs[ i ];
				if ( o.begin < startIndex && o.end < startIndex )
					continue;

				if ( o.begin > startIndex && o.end < endIndex )
				{
					runs.splice( i, 1 );
					i--;
					continue;
				}

				if ( o.begin > startIndex )
					o.begin -= Math.min( o.begin - startIndex, delta );

				o.end -= Math.min( o.end - startIndex, delta );
			}

			//2 stretch format for inserted text
			delta = text.length;

			for ( i = 0; i < runs.length; i++ )
			{
				o = runs[ i ];

				if ( o.begin < startIndex && o.end < startIndex )
					continue;

				if ( o.begin >= startIndex )
					o.begin += delta;

				if ( o.end >= startIndex )
					o.end += delta;
			}

			//apply formats
			var slices : Array = [];
			var pos : int = firstPos;

			for ( i = 0; i < runs.length; i++ )
			{
				o = runs[ i ];
				if ( o.begin < firstPos && o.end < firstPos )
					continue;

				if ( o.begin > lastPos && o.end > lastPos )
					break;
				
				if ( o.begin > pos )
				{
					slices.push( setColorForSimpleText( pos, o.begin ) );
				}
				
				slices.push( setColorForSpecialText() );

				if ( o.end > lastPos )
				{
					pos = lastPos;
					break;
				}
				pos = o.end;
			}

			if ( pos < lastPos )
				slices.push( setColorForSimpleText( pos, lastPos ));

			var visibleText : String = slices.join( "" );

			//simple tabs, 4 spaces, no align
			visibleText = visibleText.replace( /\t/g, "    " );
			//visibleText = visibleText.replace( /&/g, "&amp;" );
			
			trace( "visibleText" );
			trace( visibleText );

			tf.htmlText = visibleText;
			
			if ( tf.width < tf.textWidth )
				tf.width = tf.textWidth + 10;
			
			setBackgroundSize();
			
			function setColorForSpecialText() : String
			{
				var str : String;
				
				if ( o.begin >= _selStart && o.begin <= _selEnd && needChangeColorSelected )
				{
					if ( o.end < _selEnd )
						str = "<font color=\"#" + "ffffff" + "\">" + StringUtils.toHtmlEnc( _text.substring( Math.max( o.begin, firstPos ), o.end ) ) + "</font>";
					else
					{
						str = "<font color=\"#" + "ffffff" + "\">" + StringUtils.toHtmlEnc( _text.substring( Math.max( o.begin, firstPos ), _selEnd ) ) + "</font>";
						str += "<font color=\"#" + o.color + "\">" + StringUtils.toHtmlEnc( _text.substring( _selEnd, o.end ) ) + "</font>";
					}
				}
				else if ( o.begin <= _selStart && o.end >= _selStart  && needChangeColorSelected )
				{
					var tt : int = o.end < lastPos ? o.end : lastPos;
					if ( o.end <= _selEnd )
					{
						str = "<font color=\"#" + o.color + "\">" + StringUtils.toHtmlEnc( _text.substring( Math.max( o.begin, firstPos ), Math.max( _selStart, firstPos ) ) ) + "</font>";
						str += "<font color=\"#" + "ffffff" + "\">" + StringUtils.toHtmlEnc( _text.substring( Math.max( _selStart, firstPos ), tt ) ) + "</font>";
					}
					else
					{
						str = "<font color=\"#" + o.color + "\">" + StringUtils.toHtmlEnc( _text.substring( Math.max( o.begin, firstPos ), Math.max( _selStart, firstPos ) ) ) + "</font>";
						str += "<font color=\"#" + "ffffff" + "\">" + StringUtils.toHtmlEnc( _text.substring( Math.max( _selStart, firstPos ), Math.max( _selEnd, firstPos ) ) ) + "</font>";
						str += "<font color=\"#" + o.color + "\">" + StringUtils.toHtmlEnc( _text.substring( Math.max( _selEnd, firstPos ),  tt ) ) + "</font>";
					}
				}
				else
				{
					str = "<font color=\"#" + o.color + "\">" + StringUtils.toHtmlEnc( _text.substring( Math.max( o.begin, firstPos ), o.end ) ) + "</font>";
					
					if ( o.bold )
						str = "<b>" + str + "</b>";
					
					if ( o.italic )
						str = "<i>" + str + "</i>";
					
					if ( o.error )
						str = "<u>" + str + "</u>";
				}
				
				return str;
			}
			
			function setColorForSimpleText( begin : int, end : int ) : String
			{
				var str : String;
				
				if ( begin >= _selStart && begin <= _selEnd  && needChangeColorSelected )
				{
					if ( end <= _selEnd )
						str = "<font color=\"#" + "ffffff" + "\">" + StringUtils.toHtmlEnc( _text.substring( Math.max( begin, firstPos ), end ) ) + "</font>";
					else
					{
						str = "<font color=\"#" + "ffffff" + "\">" + StringUtils.toHtmlEnc( _text.substring( Math.max( begin, firstPos ), _selEnd ) ) + "</font>";
						str += StringUtils.toHtmlEnc( _text.substring( _selEnd, end ) );
					}
				}
				else if ( begin <= _selStart && end >= _selStart && needChangeColorSelected )
				{
					if ( end <= _selEnd )
					{
						str = StringUtils.toHtmlEnc( _text.substring( Math.max( begin, firstPos ), _selStart ) );
						str += "<font color=\"#" + "ffffff" + "\">" + StringUtils.toHtmlEnc( _text.substring( _selStart, end ) ) + "</font>";
					}
					else
					{
						str = StringUtils.toHtmlEnc( _text.substring( Math.max( begin, firstPos ), _selStart ) );
						str += "<font color=\"#" + "ffffff" + "\">" + StringUtils.toHtmlEnc( _text.substring( _selStart, _selEnd ) ) + "</font>";
						str += StringUtils.toHtmlEnc( _text.substring( _selEnd, end ) );
					}
				}
				else
				{
					str = StringUtils.toHtmlEnc( _text.substring( Math.max( begin, firstPos ), end ) );
				}
				
				return str;
			}
		}
		
		protected function drawGoToToken( pos : int, len : int ):void
		{
			var g : Graphics = linesShape.graphics;
			g.clear();
			
			g.beginFill( 0x0000FF, 1 );
			
			var p0 : Point = getPointForIndex( pos );
			var p1 : Point = getPointForIndex( pos + len );
			
			g.drawRect( p0.x, p0.y + letterBoxHeight, p1.x - p0.x, 1 );
		}
		
		protected function ClearLines():void
		{
			var g : Graphics = linesShape.graphics;
			g.clear();
		}
		
		protected function drawSkobki( pos1 : int, pos2 : int ) : void
		{
			var g : Graphics = linesShape.graphics;
			
			g.beginFill( selectionSkobkiColor, 0.8 );
			
			var p : Point = getPointForIndex( pos1 );
			
			g.drawRect( p.x, p.y, letterBoxWidth, letterBoxHeight );
			
			p = getPointForIndex( pos2 );
			
			g.drawRect( p.x, p.y, letterBoxWidth, letterBoxHeight );
		}
	}
}