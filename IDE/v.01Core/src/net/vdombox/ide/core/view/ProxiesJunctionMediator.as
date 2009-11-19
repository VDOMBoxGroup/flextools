package net.vdombox.ide.core.view
{
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	
	public class ProxiesJunctionMediator extends JunctionMediator
	{
		public static const NAME : String = 'ProxiesJunctionMediator';
		
		public function ProxiesJunctionMediator()
		{
			super( NAME, new Junction());
		}
		
		private var moduleProxy : ModulesProxy;
		
		override public function onRegister() : void
		{
			moduleProxy = facade.retrieveProxy( ModulesProxy.NAME ) as ModulesProxy ;
			
			junction.registerPipe( PipeNames.PROXIESOUT, Junction.OUTPUT, new TeeSplit());
			
			junction.registerPipe( PipeNames.PROXIESIN, Junction.INPUT, new TeeMerge());
			junction.addPipeListener( PipeNames.PROXIESIN, this, handlePipeMessage );
		}
	}
}