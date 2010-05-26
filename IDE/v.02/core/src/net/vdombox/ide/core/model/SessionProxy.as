package net.vdombox.ide.core.model
{
	import net.vdombox.ide.core.model.vo.ErrorVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	public class SessionProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "SessionProxy";
		
		public static const ERROR : String = "error";
		
		public function SessionProxy()
		{
			super( NAME, {} );
		}
		
		override public function onRegister() : void
		{
		}
		
		override public function onRemove() : void
		{
			data = null;
		}
		
		public function get errorVO () : ErrorVO
		{
			return data[ ERROR ] as ErrorVO;
		}
		
		public function set errorVO ( value : ErrorVO ) : void
		{
			data[ ERROR ] = value;
		}
		
		public function getObject( objectID : String ) : Object
		{
			if ( !data.hasOwnProperty( objectID ) )
				data[ objectID ] = {};
			
			return data[ objectID ];
		}
		
		public function cleanup() : void
		{
			data = {};
		}
	}
}