package net.vdombox.ide.core.view
{
	import net.vdombox.ide.common.LogMessage;
	import net.vdombox.ide.common.LoggingJunctionMediator;
	import net.vdombox.ide.common.MessageHeaders;
	import net.vdombox.ide.common.PipeNames;
	import net.vdombox.ide.common.UIQueryMessage;
	import net.vdombox.ide.common.UIQueryMessageNames;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.ModulesProxy;
	import net.vdombox.ide.core.model.vo.ModuleVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeAware;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.messages.Message;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Pipe;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeMerge;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeSplit;

	public class CoreJunctionMediator extends LoggingJunctionMediator
	{
		public static const NAME : String = 'CoreJunctionMediator';

		public function CoreJunctionMediator()
		{
			super( NAME, new Junction());
		}

		private var moduleProxy : ModulesProxy;
		
		private var pipeStorage : PipeStorage = new PipeStorage();

		override public function onRegister() : void
		{
			moduleProxy = facade.retrieveProxy( ModulesProxy.NAME ) as ModulesProxy ;
			 
			junction.registerPipe( PipeNames.STDOUT, Junction.OUTPUT, new TeeSplit());
 
			junction.registerPipe( PipeNames.STDIN, Junction.INPUT, new TeeMerge());
			junction.addPipeListener( PipeNames.STDIN, this, handlePipeMessage );

			junction.registerPipe( PipeNames.STDLOG, Junction.OUTPUT, new Pipe());
			junction.addPipeListener( PipeNames.STDLOG, this, handlePipeMessage );
			
			junction.registerPipe( PipeNames.PROXIESOUT, Junction.OUTPUT, new TeeSplit());
			
			junction.registerPipe( PipeNames.PROXIESIN, Junction.INPUT, new TeeMerge());
			junction.addPipeListener( PipeNames.PROXIESIN, this, handlePipeMessage );
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			interests.push( ApplicationFacade.CONNECT_MODULE_TO_CORE );
			interests.push( ApplicationFacade.SELECTED_MODULE_CHANGED );
			return interests;
		}

		override public function handleNotification( note : INotification ) : void
		{
			var moduleVO : ModuleVO;
			var module : IPipeAware;
			var coreOut : TeeSplit;

			switch ( note.getName())
			{
				case ApplicationFacade.CONNECT_MODULE_TO_CORE:
				{
//					sendNotification( LogMessage.SEND_TO_LOG, "Connecting new module instance to Shell.", LogMessage.LEVELS[ LogMessage.DEBUG ]);

					// Connect a module's STDSHELL to the shell's STDIN
					moduleVO = note.getBody() as ModuleVO;
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

					pipeStorage.savePipe( moduleVO.moduleID, PipeNames.STDIN, coreToModule );
//					stdOutMap[ moduleVO.moduleID ] = coreToModule;

					sendNotification( ApplicationFacade.MODULE_READY, moduleVO );
					break;
				}

				case ApplicationFacade.DISCONNECT_MODULE_TO_CORE:
				{
					moduleVO = note.getBody() as ModuleVO;

					coreOut = junction.retrievePipe( PipeNames.STDOUT ) as TeeSplit;
					
					var pipes : Object = pipeStorage.getPipes( moduleVO.moduleID );
					
					for each ( var pipe : Pipe in pipes )
					{
						coreOut.disconnectFitting( pipe );
					}
					
					pipeStorage.removePipes( moduleVO.moduleID );
				}

				case ApplicationFacade.SELECTED_MODULE_CHANGED:
				{
					junction.sendMessage( PipeNames.STDOUT, new Message( Message.NORMAL, MessageHeaders.MODULE_SELECTED, note.getBody()));
				}
				default:
				{
					super.handleNotification( note );
				}
			}
		}

		override public function handlePipeMessage( message : IPipeMessage ) : void
		{
			if ( message is UIQueryMessage )
			{
				switch ( UIQueryMessage( message ).name )
				{
					case UIQueryMessageNames.TOOLSET_UI:
					{
						sendNotification( ApplicationFacade.SHOW_TOOLSET, UIQueryMessage( message ).component, UIQueryMessage( message ).name );
						break;
					}

					case UIQueryMessageNames.MAIN_CONTENT_UI:
					{
						sendNotification( ApplicationFacade.SHOW_MAIN_CONTENT, UIQueryMessage( message ).component, UIQueryMessage( message ).name );
						break;
					}
				}
			}
			else if ( message is LogMessage )
			{
				trace( message.getBody() );
			}
			else if ( message is Message )
			{
				switch ( message.getHeader())
				{
					case MessageHeaders.SELECT_MODULE:
					{
						sendNotification( ApplicationFacade.CHANGE_SELECTED_MODULE, message.getBody());
						break;
					}
					
					case MessageHeaders.CONNECT_PROXIES_PIPE:
					{
						var moduleID : String = message.getBody().toString();
						
						var moduleVO : ModuleVO = moduleProxy.getModuleByID( moduleID ) as ModuleVO;
						var module : IPipeAware = moduleVO.module as IPipeAware;
						
						var moduleToCoreProxies : Pipe = new Pipe();
						module.acceptOutputPipe( PipeNames.PROXIESOUT, moduleToCoreProxies );
						
						var proxiesIn : TeeMerge = junction.retrievePipe( PipeNames.PROXIESIN ) as TeeMerge;
						proxiesIn.connectInput( moduleToCoreProxies );
						
						// Connect the shell's STDOUT to the module's STDIN
						var coreToModuleProxies : Pipe = new Pipe();
						module.acceptInputPipe( PipeNames.PROXIESIN, coreToModuleProxies );
						
						var proxiesOut : TeeSplit = junction.retrievePipe( PipeNames.PROXIESOUT ) as TeeSplit;
						proxiesOut.connect( coreToModuleProxies );
						
						pipeStorage.savePipe( moduleVO.moduleID, PipeNames.PROXIESIN, coreToModuleProxies );
						
						junction.sendMessage( PipeNames.STDOUT, new Message( Message.NORMAL, MessageHeaders.PROXIES_PIPE_CONNECTED, moduleID ))
					}
						
					case MessageHeaders.DISCONNECT_PROXIES_PIPE:
					{
						// TODO сделать disconnect.
					}
				}
			}
		}
		
		private function connectProxiesPipe( moduleID : String ) : void
		{
			var d : * = "";
		}
	}
}

import org.puremvc.as3.multicore.utilities.pipes.plumbing.Pipe;

class PipeStorage
{
	public function PipeStorage()
	{
		_storage = {};
	}
	
	private var _storage : Object;
	
	public function savePipe( moduleID : String, pipeName : String, pipe : Pipe ) : void
	{
		if ( !_storage.hasOwnProperty( moduleID ) )
		{
			_storage[ moduleID ] = {};
		}
		
		if ( _storage[ moduleID ].hasOwnProperty( pipeName ) )
		{
			_storage[ moduleID ][ pipeName ] = pipe;
		}
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
		if ( !_storage.hasOwnProperty( moduleID ) && !_storage[ moduleID ].hasOwnProperty( pipeName ) )
			return;
		
		delete _storage[ moduleID ][ pipeName ];
		
	}
	
	public function removePipes( moduleID : String ) : void
	{
		if( _storage.hasOwnProperty( moduleID ) )
			delete _storage[ moduleID ];
	}
}