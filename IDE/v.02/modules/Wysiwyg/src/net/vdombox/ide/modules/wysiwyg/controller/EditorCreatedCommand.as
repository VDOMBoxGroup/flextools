package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.modules.wysiwyg.interfaces.IEditor;
	import net.vdombox.ide.modules.wysiwyg.view.ObjectEditorMediator;
	import net.vdombox.ide.modules.wysiwyg.view.components.ObjectEditor;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class EditorCreatedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var editor : IEditor = notification.getBody() as IEditor;
			
			if( editor is ObjectEditor )
				facade.registerMediator( new ObjectEditorMediator( editor as ObjectEditor ) );
		}
	}
}