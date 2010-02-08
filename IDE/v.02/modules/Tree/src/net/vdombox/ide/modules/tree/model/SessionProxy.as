package net.vdombox.ide.modules.tree.model
{
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	public class SessionProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "RecipientsProxy";
		
		public function SessionProxy( )
		{
			super( NAME, {} );	
		}
		
		override public function onRemove() : void
		{
			data = null;
		} 
		
		public function getObject( objectID : String ) : Object
		{	
			if( !data.hasOwnProperty( objectID ) )
				data[ objectID ] = {};	
			 
			return data[ objectID ];
		}
	}
}