package net.vdombox.ide.common
{
	import mx.modules.Module;
	import mx.styles.StyleManager;
	
	import net.vdombox.ide.common.interfaces.IVIModule;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeAware;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	
	public class VIModule extends Module implements IPipeAware, IVIModule
	{
		public function VIModule( facade : IFacade = null )
		{
			super();
			this.facade = facade;
		}

		protected var facade : IFacade;
		
		/**
		 * 2. The first time called by the VIModuleMediator and JunctionMediator in load modules
		 */		
		public function get moduleID() : String
		{
			return null;
		}
		
		public function get moduleName() : String
		{
			return null;
		}
		
		public function get categoryID() : String
		{
			return null;
		}
		
		public function get categoryName() : String
		{
			return null;
		}
		
		public function get version() : String
		{
			return null;
		}
		
		/**
		 * 3. Called MainWindowMediator when show Modules  
		 */		
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
		
		/**
		 * 1. Called by the Core (VdomIDE) after creating module.
		 */
		public function startup() : void
		{
		}
		
		/**
		 * 4. Called MainWindowMediator when show Modules  
		 */	
		public function getToolset() : void
		{
		}
		
		public function getSettingsScreen() : void
		{
		}
		
		/**
		 * 5. Called by the Core (VdomIDE) when loading moduls and after select module.
		 */
		public function getBody() : void
		{
		}
		
		public function initializeSettings() : void
		{
		}
		
		/** 
		 * Called when unload module
		 */		
		public function tearDown() : void
		{
		}
		
		/**
		 * Accept an input pipe.
		 * <P>
		 * Registers an input pipe with this module's Junction.
		 * </P>
		 */
		public function acceptInputPipe( name : String, pipe : IPipeFitting ) : void
		{
			facade.sendNotification( JunctionMediator.ACCEPT_INPUT_PIPE, pipe, name );
		}

		/**
		 * Accept an output pipe.
		 * <P>
		 * Registers an input pipe with this module's Junction.
		 * </P>
		 */
		public function acceptOutputPipe( name : String, pipe : IPipeFitting ) : void
		{
			facade.sendNotification( JunctionMediator.ACCEPT_OUTPUT_PIPE, pipe, name );
		}
	}
}