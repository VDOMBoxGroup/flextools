package net.vdombox.ide.common
{
	import mx.core.UIComponent;
	import mx.modules.ModuleBase;
	
	import net.vdombox.ide.core.interfaces.IToolset;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeAware;
	
	public class VIModule extends ModuleBase implements IPipeAware, IVIModule
	{
		public function VIModule( facade : IFacade )
		{
			super();
			this.facade = facade;
		}

		protected var facade : IFacade;
		
		public function get moduleID() : String
		{
			return null;
		}
		
		public function getToolset() : void
		{
		}
		
		public function getPropertyScreen() : void
		{
		}
		
		public function getBody() : void
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