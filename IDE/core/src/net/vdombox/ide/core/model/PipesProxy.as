package net.vdombox.ide.core.model
{
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Pipe;

	public class PipesProxy extends Proxy
	{
		public static const NAME : String = "PipesProxy";

		public function PipesProxy( data : Object = null )
		{
			super( NAME, data );
		}

		private var _storage : Object;

		override public function onRegister() : void
		{
			_storage = {};
		}

		override public function onRemove() : void
		{
			_storage = null;
		}

		public function savePipe( moduleID : String, pipeName : String, pipe : Pipe ) : void
		{
			if ( !_storage.hasOwnProperty( moduleID ) )
			{
				_storage[ moduleID ] = {};
			}

			if ( !_storage[ moduleID ].hasOwnProperty( pipeName ) )
			{
				_storage[ moduleID ][ pipeName ] = pipe;
			}
		}

		public function getPipe( moduleID : String, pipeName : String ) : IPipeFitting
		{
			var result : IPipeFitting;

			if ( _storage.hasOwnProperty( moduleID ) && _storage[ moduleID ].hasOwnProperty( pipeName ) )
				result = _storage[ moduleID ][ pipeName ];

			return result;
		}

		public function getPipes( moduleID : String ) : Object
		{
			var result : Object;

			if ( _storage.hasOwnProperty( moduleID ) )
				result = _storage[ moduleID ];

			return result;
		}

		public function removePipe( moduleID : String, pipeName : String ) : void
		{
			if ( !_storage.hasOwnProperty( moduleID ) || !_storage[ moduleID ].hasOwnProperty( pipeName ) )
				return;

			delete _storage[ moduleID ][ pipeName ];

		}

		public function removePipes( moduleID : String ) : void
		{
			if ( _storage.hasOwnProperty( moduleID ) )
				delete _storage[ moduleID ];
		}

		public function cleanup() : void
		{
			_storage = {};
		}
	}
}
