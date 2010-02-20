package net.vdombox.ide.modules.tree.view
{
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.geom.Point;
	
	import mx.binding.utils.BindingUtils;
	
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.vo.LinkageVO;
	import net.vdombox.ide.modules.tree.model.vo.TreeElementVO;
	import net.vdombox.ide.modules.tree.view.components.Linkage;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class LinkageMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ArrowMediator";

		private static var count : uint = 0;

		public function LinkageMediator( viewComponent : Linkage )
		{
			super( NAME + ApplicationFacade.DELIMITER + count, viewComponent );

			count++;
		}

		private var _linkageVO : LinkageVO;

		public function get linkage() : Linkage
		{
			return viewComponent as Linkage;
		}

		public function get linkageVO() : LinkageVO
		{
			return linkage.linkageVO;
		}

		override public function onRegister() : void
		{
		}

		override public function onRemove() : void
		{
		}
	}
}