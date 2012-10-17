package net.vdombox.ide.modules.scripts.model
{
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class GoToPositionProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "GoToPositionProxy";
		
		private var transition : Object = [];
		
		public function GoToPositionProxy()
		{
			super( NAME );
		}
		
		public function add( actionVO : Object, position : int, length : int ) : void
		{
			transition[ actionVO.name ] = { position : position, length : length };
		}
		
		public function getPosition( actionVO : Object ) : Object
		{
			if ( transition.hasOwnProperty( actionVO.name ) )
			{
				var detail : Object = transition[ actionVO.name ];
				delete transition[ actionVO.name ];
				return detail;
			}
			
			return null;
		}
	}
}