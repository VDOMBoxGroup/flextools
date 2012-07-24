package net.vdombox.editors.parsers.python
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import net.vdombox.editors.HashLibraryArray;
	import net.vdombox.editors.Location;
	import net.vdombox.editors.ScriptAreaComponent;
	import net.vdombox.editors.parsers.Controller;
	import net.vdombox.editors.parsers.Field;
	import net.vdombox.editors.parsers.Token;
	import net.vdombox.ide.common.interfaces.IEventBaseVO;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	
	import ro.victordramba.thread.ThreadEvent;
	import ro.victordramba.thread.ThreadsController;

	[Event( type="flash.events.Event", name="change" )]

	public class PythonController extends Controller
	{
		public function PythonController( stage : Stage, textField : ScriptAreaComponent, __actionVO : IEventBaseVO )
		{
			fld = textField;
			_actionVO = __actionVO;
			
			//TODO refactor, Controller should probably be a singleton
			
			tc = new ThreadsController( stage );
			
			parser = new Parser;
			
			tc.addEventListener( ThreadEvent.THREAD_READY, function( e : ThreadEvent ) : void
			{
				if ( e.thread != parser )
					return;
				
				parser.applyFormats( fld );
				//cursorMoved(textField.caretIndex);
				status = 'Parse time: ' + ( getTimer() - t0 ) + 'ms ' + parser.tokenCount + ' tokens';
				dispatchEvent( new Event( 'status' ) );
			} );
			
			tc.addEventListener( ThreadEvent.PROGRESS, function( e : ThreadEvent ) : void
			{
				if ( e.thread != parser )
					return;
				status = '';
				percentReady = parser.percentReady;
				dispatchEvent( new Event( 'status' ) );
			} );
		}

		private var parser : Parser;

		public function saveTypeDB() : void
		{
			var file : FileReference = new FileReference;
			var ret : ByteArray = parser.getTypeData();
			file.save( ret, 'globals.amf' );
		}

		public function restoreTypeDB() : void
		{
			throw new Error( 'restoreTypeDB not supported' );
			var so : SharedObject = SharedObject.getLocal( 'ascc-type' );
			ClassDB.setDB( 'restored', so.data.typeDB );
		}

		public function sourceChanged( source : String, fileName : String ) : void
		{
			t0 = getTimer();
			parser.load( source, fileName );
			if ( tc.isRunning( parser ) )
				tc.kill( parser );
			tc.run( parser );
			status = 'Processing ...';
		}

		public function getMemberList( index : int ) : Vector.<String>
		{
			return parser.newResolver().getMemberList( fld.text, index , _actionVO );
		}

		public function getFunctionDetails( index : int ) : String
		{
			return parser.newResolver().getFunctionDetails( fld.text, index );
		}

		public function getTypeOptions() : Vector.<String>
		{
			return parser.newResolver().getAllTypes();
		}

		public function getAllOptions( index : int ) : Vector.<String>
		{
			return parser.newResolver().getAllOptions( index );
		}

		public function getMissingImports( name : String, pos : int ) : Vector.<String>
		{
			return parser.newResolver().getMissingImports( name, pos );
		}

		public function isInScope( name : String, pos : int ) : Boolean
		{
			return parser.newResolver().isInScope( name, pos );
		}

		public function findDefinition( index : int ) : Location
		{
			var field : Field = parser.newResolver().findDefinition( fld.text, index );
			if ( !field )
				return null;
			
			for ( var parent : Field = field, i : int = 0; parent && i < 10; parent = parent.parent, i++ )
			{
				if ( parent.sourcePath )
				{
					return new Location( parent.sourcePath, field.pos );
				}
			}
			return new Location( null, field.pos );
		}
		
		public override function set actionVO( actVO : Object ) : void
		{
			_actionVO = actVO;
			parser.actionVO = actVO;
		}
		
		public override function getTokenByPos( pos : int ) : Token
		{
			return parser.getTokenByPos( pos );
		}
	}
}