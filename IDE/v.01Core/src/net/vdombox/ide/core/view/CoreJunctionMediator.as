package net.vdombox.ide.core.view
{
	import net.vdombox.ide.common.LoggingJunctionMediator;
	import net.vdombox.ide.common.MessageHeaders;
	import net.vdombox.ide.common.PipeNames;
	import net.vdombox.ide.common.UIQueryMessage;
	import net.vdombox.ide.common.UIQueryMessageNames;
	import net.vdombox.ide.core.ApplicationFacade;
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

		private var outMap : Object = {};

		/**
		 * Called when the Mediator is registered.
		 * <P>
		 * Registers a Merging Tee for STDIN,
		 * and sets this as the Pipe Listener.</P>
		 * <P>
		 * Registers a Pipe for STDLOG and
		 * connects it to LoggerModule.</P>
		 */
		override public function onRegister() : void
		{
			// The STDOUT pipe from the shell to all modules 
			junction.registerPipe( PipeNames.STDOUT, Junction.OUTPUT, new TeeSplit());

			// The STDIN pipe to the shell from all modules 
			junction.registerPipe( PipeNames.STDIN, Junction.INPUT, new TeeMerge());
			junction.addPipeListener( PipeNames.STDIN, this, handlePipeMessage );

			// The STDLOG pipe from the shell to the logger
			junction.registerPipe( PipeNames.STDLOG, Junction.OUTPUT, new Pipe());
//			sendNotification( ApplicationFacade.CONNECT_CORE_TO_LOGGER, junction );

		}

		/**
		 * ShellJunction related Notification list.
		 * <P>
		 * Adds subclass interests to JunctionMediator interests.</P>
		 */
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			interests.push( ApplicationFacade.CONNECT_MODULE_TO_CORE );
			interests.push( ApplicationFacade.SELECTED_MODULE_CHANGED );
			return interests;
		}

		/**
		 * Handle ShellJunction related Notifications.
		 */
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
					module = moduleVO.body as IPipeAware;
					
					var moduleToShell : Pipe = new Pipe();
					module.acceptOutputPipe( PipeNames.STDCORE, moduleToShell );
					
					var coreIn : TeeMerge = junction.retrievePipe( PipeNames.STDIN ) as TeeMerge;
					coreIn.connectInput( moduleToShell );

					// Connect the shell's STDOUT to the module's STDIN
					var coreToModule : Pipe = new Pipe();
					module.acceptInputPipe( PipeNames.STDIN, coreToModule );
					
					coreOut = junction.retrievePipe( PipeNames.STDOUT ) as TeeSplit;
					coreOut.connect( coreToModule );

					outMap[ moduleVO.moduleID ] = coreToModule;

					sendNotification( ApplicationFacade.MODULE_READY, moduleVO );
					break;
				}

				case ApplicationFacade.DISCONNECT_MODULE_TO_CORE:
				{
					moduleVO = note.getBody() as ModuleVO;

					coreOut = junction.retrievePipe( PipeNames.STDOUT ) as TeeSplit;
					coreOut.disconnectFitting( outMap[ moduleVO.moduleID ]);
					
					delete outMap[ moduleVO.moduleID ];
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

		/**
		 * Handle incoming pipe messages for the ShellJunction.
		 * <P>
		 * The LoggerModule sends its LogButton and LogWindow instances
		 * to the Shell for display management via an output Pipe it
		 * knows as STDSHELL. The PrattlerModule instances also send
		 * their manufactured FeedWindow instances to the shell via
		 * their STDSHELL pipe. Those messages all show up and are
		 * handled here.</P>
		 * <P>
		 * Note that we are handling PipeMessages with the same idiom
		 * as Notifications. Conceptually they are the same, and the
		 * Mediator role doesn't change much. It takes these messages
		 * and turns them into notifications to be handled by other
		 * actors in the main app / shell.</P>
		 * <P>
		 * Also, it is logging its actions by sending INFO messages
		 * to the STDLOG output pipe.</P>
		 */
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
			else if ( message is Message )
			{
				switch ( message.getHeader())
				{
					case MessageHeaders.SELECT_MODULE:
					{
						sendNotification( ApplicationFacade.CHANGE_SELECTED_MODULE, message.getBody());
						break;
					}
				}
			}
		}
	}
}