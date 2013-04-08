package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.modules.wysiwyg.interfaces.IEditor;
	import net.vdombox.ide.modules.wysiwyg.view.VdomObjectEditorMediator;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class EditorCreatedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var editor : IEditor = notification.getBody() as IEditor;

			if ( editor )
				facade.registerMediator( new VdomObjectEditorMediator( editor ) );
		}
	}
}
