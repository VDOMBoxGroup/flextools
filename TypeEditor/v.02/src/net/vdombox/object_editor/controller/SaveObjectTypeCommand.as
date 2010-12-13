package net.vdombox.object_editor.controller
{
	import flash.filesystem.File;
	
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	
	import org.osmf.utils.OSMFStrings;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class SaveObjectTypeCommand extends SimpleCommand 
	{
		override public function execute( note:INotification ) :void
		{
			var objTypeVO:ObjectTypeVO = note.getBody() as ObjectTypeVO;
				
		}
	}
}