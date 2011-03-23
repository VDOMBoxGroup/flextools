package net.vdombox.ide.core.view
{
	import net.vdombox.ide.common.PPMPlaceNames;
	import net.vdombox.ide.common.PipeNames;
	import net.vdombox.ide.common.ProxyMessage;
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

	/**
	 * @flowerModelElementId _DHGdYEomEeC-JfVEe_-0Aw
	 * adasdas
	 */
	
	public class ProxiesJunctionMediator extends JunctionMediator
	{
		public static const NAME : String = "ProxiesJunctionMediator";

		public function ProxiesJunctionMediator()
		{
			super( NAME, new Junction() );
		}

		private var moduleProxy : ModulesProxy;

		private var pipesProxy : PipesProxy;

		override public function onRegister() : void
		{
			moduleProxy = facade.retrieveProxy( ModulesProxy.NAME ) as ModulesProxy;
			pipesProxy = facade.retrieveProxy( PipesProxy.NAME ) as PipesProxy;

			junction.registerPipe( PipeNames.PROXIESOUT, Junction.OUTPUT, new TeeSplit() );

			junction.registerPipe( PipeNames.PROXIESIN, Junction.INPUT, new TeeMerge() );
			junction.addPipeListener( PipeNames.PROXIESIN, this, handlePipeMessage );
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.CONNECT_MODULE_TO_PROXIES );
			interests.push( ApplicationFacade.DISCONNECT_MODULE_TO_PROXIES );

			interests.push( ApplicationFacade.SERVER_PROXY_RESPONSE );
			interests.push( ApplicationFacade.STATES_PROXY_RESPONSE );
			interests.push( ApplicationFacade.APPLICATION_PROXY_RESPONSE );
			interests.push( ApplicationFacade.PAGE_PROXY_RESPONSE );
			interests.push( ApplicationFacade.OBJECT_PROXY_RESPONSE );
			interests.push( ApplicationFacade.TYPES_PROXY_RESPONSE );
			interests.push( ApplicationFacade.RESOURCES_PROXY_RESPONSE );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var moduleID : String
			
			var proxiesOut : TeeSplit;
			var proxiesIn : TeeMerge;

			var body : Object = notification.getBody();

			switch ( notification.getName() )
			{
				case ApplicationFacade.CONNECT_MODULE_TO_PROXIES:
				{
					moduleID = body.toString();

					var moduleVO : ModuleVO = moduleProxy.getModuleByID( moduleID );

					var module : IPipeAware = moduleVO.module as IPipeAware;

					// Connect the core's PROXYIN to the module's PROXYOUT
					var moduleToCoreProxies : Pipe = pipesProxy.getPipe( moduleID, PipeNames.PROXIESOUT ) as Pipe;
					
					if ( !moduleToCoreProxies )
					{
						moduleToCoreProxies = new Pipe();
						module.acceptOutputPipe( PipeNames.PROXIESOUT, moduleToCoreProxies );
						
						proxiesIn = junction.retrievePipe( PipeNames.PROXIESIN ) as TeeMerge;
						proxiesIn.connectInput( moduleToCoreProxies );
						
						pipesProxy.savePipe( moduleID, PipeNames.PROXIESOUT, moduleToCoreProxies );
					}
					
					// Connect the core's PROXYOUT to the module's PROXYIN
					var coreToModuleProxies : Pipe = pipesProxy.getPipe( moduleID, PipeNames.PROXIESIN ) as Pipe;

					if ( !coreToModuleProxies )
					{
						coreToModuleProxies = new Pipe();

						module.acceptInputPipe( PipeNames.PROXIESIN, coreToModuleProxies );

						proxiesOut = junction.retrievePipe( PipeNames.PROXIESOUT ) as TeeSplit;
						proxiesOut.connect( coreToModuleProxies );

						pipesProxy.savePipe( moduleVO.moduleID, PipeNames.PROXIESIN, coreToModuleProxies );
					}

					sendNotification( ApplicationFacade.MODULE_TO_PROXIES_CONNECTED, moduleVO );

					break;
				}

				case ApplicationFacade.DISCONNECT_MODULE_TO_PROXIES:
				{
					moduleID = body.toString();

					var inPipe : IPipeFitting = pipesProxy.getPipe( moduleID, PipeNames.PROXIESIN );
					var outPipe : IPipeFitting = pipesProxy.getPipe( moduleID, PipeNames.PROXIESOUT );

					proxiesOut = junction.retrievePipe( PipeNames.PROXIESOUT ) as TeeSplit;
					proxiesIn = junction.retrievePipe( PipeNames.PROXIESIN ) as TeeMerge;

					proxiesOut.disconnectFitting( inPipe );
//					proxiesIn.disconnect()
					

					pipesProxy.removePipe( moduleID, PipeNames.PROXIESIN );
					pipesProxy.removePipe( moduleID, PipeNames.PROXIESOUT );

					break;
				}

				case ApplicationFacade.SERVER_PROXY_RESPONSE:
				{
				}

				case ApplicationFacade.STATES_PROXY_RESPONSE:
				{
				}

				case ApplicationFacade.APPLICATION_PROXY_RESPONSE:
				{
				}

				case ApplicationFacade.PAGE_PROXY_RESPONSE:
				{
				}

				case ApplicationFacade.OBJECT_PROXY_RESPONSE:
				{
				}

				case ApplicationFacade.TYPES_PROXY_RESPONSE:
				{
				}

				case ApplicationFacade.RESOURCES_PROXY_RESPONSE:
				{
					junction.sendMessage( PipeNames.PROXIESOUT, body as ProxyMessage );

					break;
				}
			}
		}

		override public function handlePipeMessage( message : IPipeMessage ) : void
		{
			var ppMessage : ProxyMessage = message as ProxyMessage;

			switch ( ppMessage.proxy )
			{
				case PPMPlaceNames.SERVER:
				{
					sendNotification( ApplicationFacade.SERVER_PROXY_REQUEST, ppMessage );

					break;
				}

				case PPMPlaceNames.STATES:
				{
					sendNotification( ApplicationFacade.STATES_PROXY_REQUEST, ppMessage );

					break;
				}

				case PPMPlaceNames.TYPES:
				{
					sendNotification( ApplicationFacade.TYPES_PROXY_REQUEST, ppMessage );

					break;
				}

				case PPMPlaceNames.RESOURCES:
				{
					sendNotification( ApplicationFacade.RESOURCES_PROXY_REQUEST, ppMessage );

					break;
				}

				case PPMPlaceNames.APPLICATION:
				{
					sendNotification( ApplicationFacade.APPLICATION_PROXY_REQUEST, ppMessage );
					
					break;
				}

				case PPMPlaceNames.PAGE:
				{
					sendNotification( ApplicationFacade.PAGE_PROXY_REQUEST, ppMessage );

					break;
				}

				case PPMPlaceNames.OBJECT:
				{
					sendNotification( ApplicationFacade.OBJECT_PROXY_REQUEST, ppMessage );

					break;
				}
			}
		}
	}
}