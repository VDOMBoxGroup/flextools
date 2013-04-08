package net.vdombox.editors.parsers.base
{
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;

	import net.vdombox.editors.ScriptAreaComponent;
	import net.vdombox.editors.parsers.AutoCompleteItemVO;
	import net.vdombox.ide.common.model._vo.ColorSchemeVO;

	import ro.victordramba.thread.ThreadsController;

	public class Controller extends EventDispatcher
	{
		protected var fld : ScriptAreaComponent;

		protected var tc : ThreadsController;

		public var status : String;

		public var percentReady : Number = 0;

		protected var t0 : Number;

		protected var _actionVO : Object;

		protected var parser : Parser;

		public function Controller()
		{
		}

		public function getTokenByPos( pos : int ) : Token
		{
			return null
		}

		public function getTokens() : Array
		{
			return parser.getTokens();
		}

		public function set actionVO( actVO : Object ) : void
		{
			_actionVO = actVO;
		}

		public function get actionVO() : Object
		{
			return _actionVO;
		}

		public function getAllOptions( index : int ) : Vector.<AutoCompleteItemVO>
		{
			return null;
		}

		public function getMemberList( index : int ) : Vector.<AutoCompleteItemVO>
		{
			return null;
		}

		public function getTypeOptions() : Vector.<AutoCompleteItemVO>
		{
			return null;
		}

		public function getFunctionDetails( index : int ) : String
		{
			return null;
		}


		public function get commentString() : String
		{
			return null;
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

		public function set colorScheme( colorSchemeVO : ColorSchemeVO ) : void
		{
			parser.colorScheme = colorSchemeVO;
		}

		public function get lang() : String
		{
			return "";
		}

		public function getRegisterWord( string : String ) : String
		{
			return string;
		}
	}
}
