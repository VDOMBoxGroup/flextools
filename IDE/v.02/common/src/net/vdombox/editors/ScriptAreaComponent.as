package net.vdombox.editors
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.vdombox.editors.parsers.base.Controller;
	import net.vdombox.ide.common.events.ScriptAreaComponenrEvent;
	import net.vdombox.ide.common.model._vo.ColorSchemeVO;
	
	import ro.victordramba.scriptarea.ScriptAreaEvents;
	
	import spark.core.SpriteVisualElement;

	public class ScriptAreaComponent extends SpriteVisualElement
	{
		public function ScriptAreaComponent()
		{
			super();

			area = new ScriptAreaEvents();
			
			area.width = width;

			addChild( area );

			lineNums = new LineNumbers( area.boxSize, area.textFormat );
			lineNums.y = 2;

			addChild( lineNums );

			addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true );
			addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true );
			
			addEventListener(FocusEvent.FOCUS_IN, function(e:Event):void {
				stage.focus = area;
			});
		}

		private var area : ScriptAreaEvents;

		private var viewportSizeTesting : Boolean = false;

		private var lineNums : LineNumbers;

		private var viewPos : Point = new Point();
		
		public function get assistMenuOpened():Boolean
		{
			return area.assistMenuOpened;
		}

		public function set assistMenuOpened(value:Boolean):void
		{
			area.assistMenuOpened = value;
		}

		public function set controller( value : Controller ) : void
		{
			area.controller = value;
		}
		
		public function get controller( ) : Controller
		{
			return area.controller;
		}

		public function get caretIndex() : int
		{
			return area.caretIndex;
		}
		
		public function set caretIndex( value : int ) : void
		{
			area.caretIndex = value;
		}
		
		public function setFocus() : void
		{
			if ( stage )
				stage.focus = area;
		}

		public function get selectionBeginIndex() : int
		{
			return area.selectionBeginIndex;
		}

		public function get selectionEndIndex() : int
		{
			return area.selectionEndIndex;
		}

		public function get text() : String
		{
			return area.text;
		}

		public function set text( text : String ) : void
		{
			area.text = text;
			area_changeHandler( new Event( Event.CHANGE ) );
		}

		public function get internalFocusObject() : InteractiveObject
		{
			return area ? area : null;
		}

		public function get scrollV() : int
		{
			return area.scrollV;
		}

		public function set scrollV( value : int ) : void
		{
			area.scrollV = value;
		}

		public function get scrollH() : int
		{
			return area.scrollH;
		}

		public function set scrollH( value : int ) : void
		{
			area.scrollH = value;
		}

		public function get maxScrollV() : int
		{
			return area.maxScrollV;
		}

		public function get maxScrollH() : int
		{
			return area.maxScrollH;
		}

		override public function set width( value : Number ) : void
		{
			super.width = value;

			update();
		}

		override public function set height( value : Number ) : void
		{
			super.height = value;

			update();
		}
		
		public function set scriptLang( value : String ) : void
		{
			area.scriptLang = value;
		}

		override public function setLayoutBoundsSize( width : Number, height : Number, postLayoutTransform : Boolean = true ) : void
		{
			super.setLayoutBoundsSize( width, height, postLayoutTransform )
				
			update();
		}

		public function markLines( lines : Array /*of int*/, tips : Array /*of String*/, color : uint = 0xff0000 ) : void
		{
			lineNums.mark( lines, tips, color );
		}

		public function clearFormatRuns() : void
		{
			area.clearFormatRuns();
		}

		public function addFormatRun( beginIndex : int, endIndex : int, bold : Boolean, italic : Boolean, color : String, error : Boolean = false ) : void
		{
			area.addFormatRun( beginIndex, endIndex, bold, italic, color, error );
		}


		public function applyFormatRuns() : void
		{
			area.applyFormatRuns();
		}

		public function getPointForIndex( index : int ) : Point
		{
			var p : Point = area.getPointForIndex( index );
			p.offset( lineNums.width, 0 );
			return p;
		}

		public function replaceText( startIndex : int, endIndex : int, text : String ) : void
		{
			area.replaceText( startIndex, endIndex, text );
		}


		public function setSelection( beginIndex : int, endIndex : int ) : void
		{
			area.setSelection( beginIndex, endIndex );
		}
		
		public function get selectionText() : String
		{
			return area.selectionText;
		}
		
		public function findText( findText : String, type : int, caseSensitive : Boolean ) : Boolean
		{
			return area.findText( findText, type, caseSensitive );
		}
		
		public function replaceFind( findText : String, replaceText : String, replaceAll : Boolean = false ) : void
		{
			area.replaceFind( findText, replaceText, replaceAll );
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

		private function update() : void
		{
			area.x = area.boxSize.x * 5;
			//			area.y = b.y;
			area.width = width - 1;
			area.height = height - 1;

			//scroll
			scrollRect = new Rectangle( viewPos.x, 0, width, height );
			area.scrollRect = new Rectangle( viewPos.x, 0, width, height );
			area.scrollV = viewPos.y;
			updateNums();
		}

		private function updateNums() : void
		{
			lineNums.draw( area.scrollV, Number( area.height ) / area.boxSize.y, 100000 );
		}

		private function addedToStageHandler( event : Event ) : void
		{
			addEventListener( FocusEvent.FOCUS_IN, focusInHandler, false, 0, true );
			addEventListener( FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler, false, 0, true );

			if ( area )
			{
				area.addEventListener( Event.SCROLL, area_srollHandler, false, 0, true );
				area.addEventListener( Event.CHANGE, area_changeHandler, false, 0, true );
				area.addEventListener( ScriptAreaComponenrEvent.TEXT_INPUT, area_textInputHandler, false, 0, true );
			}

			if ( lineNums )
				lineNums.addEventListener( MouseEvent.MOUSE_DOWN, area.onMouseDown, false, 0, true );

			updateScrollBars();
		}

		private function removedFromStageHandler( event : Event ) : void
		{
			removeEventListener( FocusEvent.FOCUS_IN, focusInHandler );
			removeEventListener( FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler );

			if ( area )
			{
				area.removeEventListener( Event.SCROLL, area_srollHandler );
				area.removeEventListener( Event.CHANGE, area_changeHandler );
				area.removeEventListener( ScriptAreaComponenrEvent.TEXT_INPUT, area_textInputHandler );
			}

			if ( lineNums )
				lineNums.removeEventListener( MouseEvent.MOUSE_DOWN, area.onMouseDown );
		}

		private function focusInHandler( event : FocusEvent ) : void
		{
			stage.focus = area;
		}

		private function keyFocusChangeHandler( event : FocusEvent ) : void
		{
			event.preventDefault();
		}

		private function area_srollHandler( event : Event ) : void
		{
			if ( viewportSizeTesting )
				return;

			if ( viewPos.y != area.scrollV )
			{
				viewPos.y = area.scrollV;
				updateNums();
//				fireStateChanged( true );
			}
		}
		
		public function sendUpdate() : void
		{
			area.dipatchChange();
		}

		private function area_changeHandler( event : Event ) : void
		{
			dispatchEvent( new Event( Event.CHANGE ) );
		}
		
		private function area_textInputHandler( event : ScriptAreaComponenrEvent ) : void
		{
			dispatchEvent( new ScriptAreaComponenrEvent( ScriptAreaComponenrEvent.TEXT_INPUT ) );
		}

		private function updateScrollBars() : void
		{
		}
		
		public function undo_fun() : void
		{
			area.undo_fun();
		}
		
		public function redo_fun() : void
		{
			area.redo_fun();
		}
		
		public function goToPos( pos : int, len : int ) : void
		{
			area.goToPos(pos, len);
		}
		
		public function set colorScheme( value : ColorSchemeVO ) : void
		{
			area.colorScheme = value;
		}
		
		public function set fontSize( value : uint ) : void
		{
			area.fontSize = value;
			lineNums.box = area.boxSize;
			lineNums.fmt = area.textFormat;
			
			lineNums.clearCache();
			update()
		}
		
		public function renameByArray( words : Array, oldName : String, newName : String ) : void
		{
			area.renameByArray( words, oldName, newName );
		}
		
		public function set selectKeyByAutoComplte( value : String ) : void
		{
			area.selectKeyByAutoComplte = value;
		}
		
		public function get letterBoxHeight():int
		{
			return area.letterBoxHeight;
		}
	}
}