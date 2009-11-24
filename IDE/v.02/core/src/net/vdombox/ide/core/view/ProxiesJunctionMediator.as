package net.vdombox.ide.core.view
{
	import net.vdombox.ide.common.PPMPlaceNames;
	import net.vdombox.ide.common.PipeNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.ModulesProxy;
	import net.vdombox.ide.core.model.PipesProxy;
	import net.vdombox.ide.core.model.vo.ModuleVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeAware;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Pipe;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeMerge;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeSplit;

	public class ProxiesJunctionMediator extends JunctionMediator
	{
		public static const NAME : String = 'ProxiesJunctionMediator';

		public function ProxiesJunctionMediator()
		{
			super( NAME, new Junction());
		}

		private var moduleProxy : ModulesProxy;
		
		private var pipesProxy : PipesProxy;
		
		override public function onRegister() : void
		{
			moduleProxy = facade.retrieveProxy( ModulesProxy.NAME ) as ModulesProxy;
			pipesProxy = facade.retrieveProxy( PipesProxy.NAME ) as PipesProxy;

			junction.registerPipe( PipeNames.PROXIESOUT, Junction.OUTPUT, new TeeSplit());

			junction.registerPipe( PipeNames.PROXIESIN, Junction.INPUT, new TeeMerge());
			junction.addPipeListener( PipeNames.PROXIESIN, this, handlePipeMessage );
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.CONNECT_MODULE_TO_PROXIES );
			interests.push( ApplicationFacade.DISCONNECT_MODULE_TO_PROXIES );
			
			interests.push( ApplicationFacade.SERVER_PROXY_RESPONSE );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var moduleID : String
			var proxiesOut : TeeSplit;
			
			switch ( notification.getName() )
			{
				case ApplicationFacade.CONNECT_MODULE_TO_PROXIES:
				{
					moduleID  = notification.getBody().toString();
					
					var moduleVO : ModuleVO = moduleProxy.getModuleByID( moduleID ) as ModuleVO;
					
					var module : IPipeAware = moduleVO.module as IPipeAware;
					
					// Connect the core's PROXYIN to the module's PROXYOUT
					var moduleToCoreProxies : Pipe = new Pipe();
					module.acceptOutputPipe( PipeNames.PROXIESOUT, moduleToCoreProxies );
					
					var proxiesIn : TeeMerge = junction.retrievePipe( PipeNames.PROXIESIN ) as TeeMerge;
					proxiesIn.connectInput( moduleToCoreProxies );
					
					// Connect the core's PROXYOUT to the module's PROXYIN
					var coreToModuleProxies : Pipe = new Pipe();
					module.acceptInputPipe( PipeNames.PROXIESIN, coreToModuleProxies );
					
					proxiesOut = junction.retrievePipe( PipeNames.PROXIESOUT ) as TeeSplit;
					proxiesOut.connect( coreToModuleProxies );
					
					pipesProxy.savePipe( moduleVO.moduleID, PipeNames.PROXIESIN, coreToModuleProxies );
					
					sendNotification( ApplicationFacade.MODULE_TO_PROXIES_CONNECTED, moduleVO );
					
					break;
				}
				
				case ApplicationFacade.DISCONNECT_MODULE_TO_PROXIES:
				{
					moduleID = notification.getBody().toString();
					
					var pipe : IPipeFitting = pipesProxy.getPipe( moduleID, PipeNames.PROXIESIN );
					
					proxiesOut = junction.retrievePipe( PipeNames.PROXIESOUT ) as TeeSplit;
					
					proxiesOut.disconnectFitting( pipe );
					
					pipesProxy.removePipe( moduleID, PipeNames.PROXIESIN );
					break;
				}
				
				case ApplicationFacade.SERVER_PROXY_RESPONSE:
				{
					var body : Object = notification.getBody();
					
					junction.sendMessage( PipeNames.PROXIESOUT,
										  new ProxiesPipeMessage( body.operation, PPMPlaceNames.SERVER, body.target, body.parameters )
					);
					break;
				}
			}
		}
		
		override public function handlePipeMessage( message : IPipeMessage ) : void
		{
			var ppMessage : ProxiesPipeMessage = message as ProxiesPipeMessage;
			
			switch ( ppMessage.place )
			{
				case PPMPlaceNames.SERVER:
				{
					sendNotification( ApplicationFacade.SERVER_PROXY_REQUEST, 
									  { operation : ppMessage.operation, target : ppMessage.target, parameters : ppMessage.parameters }
					);
					
					break;
				}
				case PPMPlaceNames.RESOURCES:
				{
					sendNotification( ApplicationFacade.SERVER_PROXY_REQUEST, 
						{ operation : ppMessage.operation, target : ppMessage.target, parameters : ppMessage.parameters }
					);
					
					break;
				}	
			}
		}
	}
}