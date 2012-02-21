package net.vdombox.ide.modules.tree.view
{
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.geom.Point;
	
	import mx.binding.utils.BindingUtils;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.tree.model.vo.LinkageVO;
	import net.vdombox.ide.modules.tree.model.vo.TreeElementVO;
	import net.vdombox.ide.modules.tree.view.components.Linkage;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class LinkageMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "LinkageMediator";

		public function LinkageMediator( viewComponent : Linkage )
		{
			super( NAME + Notifications.DELIMITER + viewComponent.uid, viewComponent );
		}

		private var _linkageVO : LinkageVO;

		public function get linkage() : Linkage
		{
			return viewComponent as Linkage;
		}

		public function get linkageVO() : LinkageVO
		{
			return linkage ? linkage.linkageVO : null;
		}

		override public function onRegister() : void
		{
		}

		override public function onRemove() : void
		{
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( Notifications.SHOW_SIGNATURE );
			interests.push( Notifications.HIDE_SIGNATURE );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			switch ( name )
			{
				case Notifications.SHOW_SIGNATURE:
				{
					linkage.signatureVisible = true;
					break
				}
					
				case Notifications.HIDE_SIGNATURE:
				{
					linkage.signatureVisible = false;
					break
				}
			}
		}
	}
}