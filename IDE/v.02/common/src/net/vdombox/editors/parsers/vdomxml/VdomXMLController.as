package net.vdombox.editors.parsers.vdomxml
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import net.vdombox.editors.ScriptAreaComponent;
	import net.vdombox.editors.parsers.Controller;
	
	import ro.victordramba.thread.ThreadEvent;
	import ro.victordramba.thread.ThreadsController;

	[Event( type="flash.events.Event", name="change" )]

	public class VdomXMLController extends Controller
	{
		public function VdomXMLController( stage : Stage, textField : ScriptAreaComponent )
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

		public function restoreTypeDB() : void
		{
			throw new Error( 'restoreTypeDB not supported' );
			var so : SharedObject = SharedObject.getLocal( 'ascc-type' );
			TypeDB.setDB( 'restored', so.data.typeDB );
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

		public function getAttributesList( index : int ) : Vector.<Object>
		{
			return parser.newResolver().getAttributesList( index );
		}

		public function getAllTypes() : Vector.<Object>
		{
			return parser.newResolver().getAllTypes();
		}

		public function isInTag( pos : int ) : Boolean
		{
			return parser.newResolver().isInTag( pos );
		}

		public function isInAttribute( pos : int ) : Boolean
		{
			return parser.newResolver().isInAttribute( pos );
		}
	}
}