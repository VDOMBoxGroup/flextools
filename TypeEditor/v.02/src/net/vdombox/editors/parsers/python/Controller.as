package net.vdombox.editors.parsers.python
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import net.vdombox.editors.Location;
	import net.vdombox.editors.ScriptAreaComponent;
	
	import ro.victordramba.thread.ThreadEvent;
	import ro.victordramba.thread.ThreadsController;

	[Event( type="flash.events.Event", name="change" )]

	public class Controller extends EventDispatcher
	{
		public function Controller( stage : Stage, textField : ScriptAreaComponent )
		{
			fld = textField;
			
			//TODO refactor, Controller should probably be a singleton
			if ( !tc )
			{
				tc = new ThreadsController( stage );
				//TypeDB.setDB('global', TypeDB.formByteArray(new GlobalTypesAsset));
				//TypeDB.setDB('playerglobal', TypeDB.formByteArray(new PlayerglobalAsset));
			}
			
			parser = new Parser;
			
			//parser.addTypeData(TypeDB.formByteArray(new GlobalTypesAsset), 'global');
			//parser.addTypeData(TypeDB.formByteArray(new PlayerglobalAsset), 'player');
			//parser.addTypeData(TypeDB.formByteArray(new ASwingAsset), 'aswing');
			
			
			
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
		
		private var t0 : Number;
		static private var tc : ThreadsController;

		public var status : String;
		public var percentReady : Number = 0;
		//public var tokenInfo:String;
		//public var scopeInfo:Array/*of String*/
		//public var typeInfo:Array/*of String*/

		private var fld : ScriptAreaComponent;

		

		public function saveTypeDB() : void
		{
			/*var so:SharedObject = SharedObject.getLocal('ascc-type');
			   so.data.typeDB = parser.getTypeData();
			 so.flush();*/

			var file : FileReference = new FileReference;
			var ret : ByteArray = parser.getTypeData();
			file.save( ret, 'globals.amf' );

		}

		public function restoreTypeDB() : void
		{
			throw new Error( 'restoreTypeDB not supported' );
			var so : SharedObject = SharedObject.getLocal( 'ascc-type' );
			TypeDB.setDB( 'restored', so.data.typeDB );
		}

		/*public function addTypeDB(typeDB:TypeDB, name:String):void
		   {
		   parser.addTypeData(typeDB, name);
		 }*/

//		public function loadSWFLib( swfData : ByteArray, fileName : String ) : void
//		{
//			TypeDB.setDB( fileName, SWFParser.parse( swfData ) );
//		}

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
			return parser.newResolver().getMemberList( fld.text, index );
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
	}
}