package net.vdombox.ide.core.view
{
	import net.vdombox.ide.common.LogMessage;
	import net.vdombox.ide.common.LoggingJunctionMediator;
	import net.vdombox.ide.common.PipeNames;
	import net.vdombox.ide.common.SimpleMessage;
	import net.vdombox.ide.common.SimpleMessageHeaders;
	import net.vdombox.ide.common.UIQueryMessage;
	import net.vdombox.ide.common.UIQueryMessageNames;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.PipesProxy;
	import net.vdombox.ide.core.model.vo.ModuleVO;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeAware;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Pipe;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeMerge;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeSplit;

	public class CoreJunctionMediator extends LoggingJunctionMediator
	{
		public static const NAME : String = "CoreJunctionMediator";

		public function CoreJunctionMediator()
		{
			super( NAME, new Junction() );
		}

		private var pipesProxy : PipesProxy;

		override public function onRegister() : void
		{
			pipesProxy = facade.retrieveProxy( PipesProxy.NAME ) as PipesProxy;

			junction.registerPipe( PipeNames.STDOUT, Junction.OUTPUT, new TeeSplit() );

			junction.registerPipe( PipeNames.STDIN, Junction.INPUT, new TeeMerge() );
			junction.addPipeListener( PipeNames.STDIN, this, handlePipeMessage );

			junction.registerPipe( PipeNames.STDLOG, Junction.OUTPUT, new Pipe() );
			junction.addPipeListener( PipeNames.STDLOG, this, handlePipeMessage );
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.CONNECT_MODULE_TO_CORE );
			interests.push( ApplicationFacade.SELECTED_MODULE_CHANGED );

			interests.push( ApplicationFacade.MODULE_TO_PROXIES_CONNECTED );
			interests.push( ApplicationFacade.MODULE_SETTINGS_GETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var moduleVO : ModuleVO;
			var module : IPipeAware;
			var coreOut : TeeSplit;

			switch ( notification.getName() )
			{
				case ApplicationFacade.CONNECT_MODULE_TO_CORE:
				{
					// Connect a module's STDSHELL to the shell's STDIN
					moduleVO = notification.getBody() as ModuleVO;
					module = moduleVO.module as IPipeAware;

					var moduleToCore : Pipe = new Pipe();
					module.acceptOutputPipe( PipeNames.STDCORE, moduleToCore );

					var moduleToLog : Pipe = new Pipe();
					module.acceptOutputPipe( PipeNames.STDLOG, moduleToLog );

					var coreIn : TeeMerge = junction.retrievePipe( PipeNames.STDIN ) as TeeMerge;
					coreIn.connectInput( moduleToCore );
					coreIn.connectInput( moduleToLog );

					// Connect the shell's STDOUT to the module's STDIN
					var coreToModule : Pipe = new Pipe();
					module.acceptInputPipe( PipeNames.STDIN, coreToModule );

					coreOut = junction.retrievePipe( PipeNames.STDOUT ) as TeeSplit;
					coreOut.connect( coreToModule );

					pipesProxy.savePipe( moduleVO.moduleID, PipeNames.STDIN, coreToModule );

//					sendNotification( ApplicationFacade.MODULE_READY, moduleVO );
					break;
				}

				case ApplicationFacade.DISCONNECT_MODULE_TO_CORE:
				{
					moduleVO = notification.getBody() as ModuleVO;

					coreOut = junction.retrievePipe( PipeNames.STDOUT ) as TeeSplit;

					var pipes : Object = pipesProxy.getPipes( moduleVO.moduleID );

					for each ( var pipe : Pipe in pipes )
					{
						coreOut.disconnectFitting( pipe );
					}

					pipesProxy.removePipes( moduleVO.moduleID );
					break;
				}

				case ApplicationFacade.MODULE_TO_PROXIES_CONNECTED:
				{
					moduleVO = notification.getBody() as ModuleVO;

					junction.sendMessage( PipeNames.STDOUT,
										  new SimpleMessage( SimpleMessageHeaders.PROXIES_PIPE_CONNECTED, null, moduleVO.moduleID ) );
					break;
				}

				case ApplicationFacade.SELECTED_MODULE_CHANGED:
				{
					moduleVO = notification.getBody() as ModuleVO;

					junction.sendMessage( PipeNames.STDOUT, new SimpleMessage( SimpleMessageHeaders.MODULE_SELECTED, null, moduleVO.moduleID ) );
					break;
				}

				case ApplicationFacade.MODULE_SETTINGS_GETTED:
				{
					junction.sendMessage( PipeNames.STDOUT, notification.getBody() as IPipeMessage );
					break;
				}

				case ApplicationFacade.MODULE_SETTINGS_SETTED:
				{
					junction.sendMessage( PipeNames.STDOUT, notification.getBody() as IPipeMessage );
					break;
				}

				default:
				{
					super.handleNotification( notification );
				}
			}
		}

		override public function handlePipeMessage( message : IPipeMessage ) : void
		{
			if ( message is UIQueryMessage )
				sendNotification( ApplicationFacade.PROCESS_UIQUERY_MESSAGE, message );
			else if ( message is SimpleMessage )
				sendNotification( ApplicationFacade.PROCESS_SIMPLE_MESSAGE, message );
			else if ( message is LogMessage )
				sendNotification( ApplicationFacade.PROCESS_LOG_MESSAGE, message );
		}
	}
}