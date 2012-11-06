package net.vdombox.editors.parsers.vscript
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import net.vdombox.editors.ScriptAreaComponent;
	import net.vdombox.editors.parsers.AutoCompleteItemVO;
	import net.vdombox.editors.parsers.ClassDB;
	import net.vdombox.editors.parsers.base.Controller;
	import net.vdombox.editors.parsers.base.Token;
	
	import ro.victordramba.thread.ThreadEvent;
	import ro.victordramba.thread.ThreadsController;
	
	[Event( type="flash.events.Event", name="change" )]
	
	public class VScriptController extends Controller
	{
		public function VScriptController( stage : Stage, textField : ScriptAreaComponent, __actionVO : Object )
		{
			fld = textField;
			
			_actionVO = __actionVO;
			
			tc = new ThreadsController( stage );
			
			parser = new VScriptParser;		
			
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
		
		public override function getMemberList( index : int ) : Vector.<AutoCompleteItemVO>
		{
			return VScriptParser( parser ).newResolver().getMemberList( fld.text, index , _actionVO );
		}
		
		public function getFunctionDetails( index : int ) : String
		{
			return VScriptParser( parser ).newResolver().getFunctionDetails( fld.text, index );
		}
		
		public override function getTypeOptions() : Vector.<AutoCompleteItemVO>
		{
			return VScriptParser( parser ).newResolver().getAllTypes();
		}
		
		public override function getAllOptions( index : int ) : Vector.<AutoCompleteItemVO>
		{
			return VScriptParser( parser ).newResolver().getAllOptions( index );
		}
		
		public function getMissingImports( name : String, pos : int ) : Vector.<String>
		{
			return VScriptParser( parser ).newResolver().getMissingImports( name, pos );
		}
		
		public function isInScope( name : String, pos : int ) : Boolean
		{
			return VScriptParser( parser ).newResolver().isInScope( name, pos );
		}
		
		public override function getTokenByPos( pos : int ) : Token
		{
			return parser.getTokenByPos( pos );
		}
		
		public function runSlice() : Boolean
		{
			return parser.runSlice();
		}
		
		public override function get commentString() : String
		{
			return "'";
		}
		
		public override function get lang() : String
		{
			return "vscript";
		}
		
		public override function getRegisterWord( string : String ) : String
		{
			return string.toLowerCase();
		}
	}
}