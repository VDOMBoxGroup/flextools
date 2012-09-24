package net.vdombox.editors.parsers.vdomxml
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import net.vdombox.editors.ScriptAreaComponent;
	import net.vdombox.editors.parsers.AutoCompleteItemVO;
	import net.vdombox.editors.parsers.base.Controller;
	import net.vdombox.editors.parsers.vdomxml.TypeDB;
	import net.vdombox.editors.parsers.vdomxml.VdomXMLParser;
	
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

			_parser = new VdomXMLParser();

			tc.addEventListener( ThreadEvent.THREAD_READY, function( e : ThreadEvent ) : void
			{
				if ( e.thread != _parser )
					return;

				_parser.applyFormats( fld );
				//cursorMoved(textField.caretIndex);
				status = 'Parse time: ' + ( getTimer() - t0 ) + 'ms ' + _parser.tokenCount + ' tokens';
				dispatchEvent( new Event( 'status' ) );
			} );

			tc.addEventListener( ThreadEvent.PROGRESS, function( e : ThreadEvent ) : void
			{
				if ( e.thread != _parser )
					return;
				status = '';
				percentReady = _parser.percentReady;
				dispatchEvent( new Event( 'status' ) );
			} );
		}

		private var _parser : VdomXMLParser;

		public function restoreTypeDB() : void
		{
			throw new Error( 'restoreTypeDB not supported' );
			var so : SharedObject = SharedObject.getLocal( 'ascc-type' );
			TypeDB.setDB( 'restored', so.data.typeDB );
		}

		public override function sourceChanged( source : String, fileName : String ) : void
		{
			t0 = getTimer();
			_parser.load( source, fileName );
			if ( tc.isRunning( _parser ) )
				tc.kill( _parser );
			tc.run( _parser );
			status = 'Processing ...';
		}

		public function getAttributesList( index : int ) : Vector.<AutoCompleteItemVO>
		{
			return _parser.newResolver().getAttributesList( index );
		}

		public function getAllTypes() : Vector.<AutoCompleteItemVO>
		{
			return _parser.newResolver().getAllTypes();
		}

		public function isInTag( pos : int ) : Boolean
		{
			return _parser.newResolver().isInTag( pos );
		}

		public function isInAttribute( pos : int ) : Boolean
		{
			return _parser.newResolver().isInAttribute( pos );
		}
		
		public override function get lang() : String
		{
			return "vdomxml";
		}
	}
}