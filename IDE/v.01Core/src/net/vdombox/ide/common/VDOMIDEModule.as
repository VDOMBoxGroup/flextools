package net.vdombox.ide.common
{
	import mx.modules.ModuleBase;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeAware;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	
	public class VDOMIDEModule extends ModuleBase implements IPipeAware
	{
		
		/**
		 * Standard output pipe name constant.
		 */
		public static const STDOUT:String 				= 'standardOutput';
		
		/**
		 * Standard input pipe name constant.
		 */
		public static const STDIN:String 				= 'standardInput';
		
		/**
		 * Standard log pipe name constant.
		 */
		public static const STDLOG:String 				= 'standardLog';
		
		/**
		 * Standard shell pipe name constant.
		 */
		public static const STDSHELL:String 			= 'standardShell';
		
		/**
		 * Constructor.
		 * <P>
		 * In subclass, create appropriate facade and pass 
		 * to super.</P>
		 */
		public function VDOMIDEModule( facade:IFacade )
		{
			super();
			this.facade = facade;
		}
		
		/**
		 * Accept an input pipe.
		 * <P>
		 * Registers an input pipe with this module's Junction.
		 */
		public function acceptInputPipe( name:String, pipe:IPipeFitting ):void
		{
			facade.sendNotification( JunctionMediator.ACCEPT_INPUT_PIPE, pipe, name );							
		}
		
		/**
		 * Accept an output pipe.
		 * <P>
		 * Registers an input pipe with this module's Junction.
		 */
		public function acceptOutputPipe( name:String, pipe:IPipeFitting ):void
		{
			facade.sendNotification( JunctionMediator.ACCEPT_OUTPUT_PIPE, pipe, name );							
		}
		
		protected var facade:IFacade;
	}
}