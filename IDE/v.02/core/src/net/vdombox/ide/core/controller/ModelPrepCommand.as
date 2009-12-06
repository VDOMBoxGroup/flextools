package net.vdombox.ide.core.controller
{	
	import net.vdombox.ide.core.model.LocalesProxy;
	import net.vdombox.ide.core.model.ModulesProxy;
	import net.vdombox.ide.core.model.PipesProxy;
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.SettingsStorageProxy;
	import net.vdombox.ide.core.model.SharedObjectProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ModelPrepCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			facade.registerProxy( new SharedObjectProxy() );
			facade.registerProxy( new SettingsStorageProxy() );			
			facade.registerProxy( new LocalesProxy() );
			facade.registerProxy( new ModulesProxy() );			
			facade.registerProxy( new PipesProxy() );
			facade.registerProxy( new ServerProxy() );
		}
	}
}