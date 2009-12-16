package net.vdombox.ide.common
{
	import mx.modules.ModuleBase;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeAware;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	import net.vdombox.ide.common.interfaces.IVIModule;
	
	public class VIModule extends ModuleBase implements IPipeAware, IVIModule
	{
		public function VIModule( facade : IFacade = null )
		{
			super();
			this.facade = facade;
		}

		protected var facade : IFacade;
		
		public function get moduleID() : String
		{
			return null;
		}
		
		public function get moduleName() : String
		{
			return null;
		}
		
		public function get version() : String
		{
			return null;
		}
		
		public function get hasToolset() : Boolean
		{
			return false;
		}
		
		public function get hasSettings() : Boolean
		{
			return false;
		}
		
		public function get hasBody() : Boolean
		{
			return false;
		}
		
		public function getToolset() : void
		{
		}
		
		public function getSettingsScreen() : void
		{
		}
		
		public function getBody() : void
		{
		}
		
		public function initializeSettings() : void
		{
		}
		
		public function tearDown() : void
		{
		}
		
		/**
		 * Accept an input pipe.
		 * <P>
		 * Registers an input pipe with this module's Junction.
		 */
		public function acceptInputPipe( name : String, pipe : IPipeFitting ) : void
		{
			facade.sendNotification( JunctionMediator.ACCEPT_INPUT_PIPE, pipe, name );
		}

		/**
		 * Accept an output pipe.
		 * <P>
		 * Registers an input pipe with this module's Junction.
		 */
		public function acceptOutputPipe( name : String, pipe : IPipeFitting ) : void
		{
			facade.sendNotification( JunctionMediator.ACCEPT_OUTPUT_PIPE, pipe, name );
		}
	}
}