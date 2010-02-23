package net.vdombox.ide.modules.wysiwyg.view.components
{
	import mx.collections.ArrayList;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.modules.wysiwyg.model.vo.ItemVO;
	import net.vdombox.ide.modules.wysiwyg.view.skins.ItemSkin;
	
	import spark.components.IItemRenderer;
	import spark.components.SkinnableDataContainer;
	import spark.layouts.BasicLayout;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;

	public class Item extends SkinnableDataContainer implements IItemRenderer
	{
		public function Item()
		{
			super();

			itemRendererFunction = chooseItemRenderer;
			setStyle( "skinClass", ItemSkin );
		}

		public function get selected() : Boolean
		{
			return false;
		}

		public function set selected( value : Boolean ) : void
		{
		}

		public function get showsCaret() : Boolean
		{
			return false;
		}

		public function set showsCaret( value : Boolean ) : void
		{
		}

		public function get label() : String
		{
			return null;
		}

		public function set label( value : String ) : void
		{
		}

		public function get data() : Object
		{
			return null;
		}

		public function set data( value : Object ) : void
		{
			var itemVO : ItemVO = value as ItemVO;

			if ( !itemVO )
				return;

			var attributeVO : AttributeVO = itemVO.getAttributeByName( "width" );

			if ( attributeVO )
				width = int( attributeVO.value );

			attributeVO = itemVO.getAttributeByName( "height" );

			if ( attributeVO )
				height = int( attributeVO.value );

			attributeVO = itemVO.getAttributeByName( "top" );

			if ( attributeVO )
				y = int( attributeVO.value );

			attributeVO = itemVO.getAttributeByName( "left" );

			if ( attributeVO )
				x = int( attributeVO.value );

			if ( itemVO && itemVO.children.length > 0 )
			{
				dataProvider = new ArrayList( itemVO.children );
			}
		}

		public function chooseItemRenderer( itemVO : ItemVO ) : IFactory
		{
			var itemFactory : ClassFactory;

			switch ( itemVO.type )
			{
				case "container":
				{
					itemFactory = new ClassFactory( Item );
					itemFactory.properties = { layout: new BasicLayout() };
					break;
				}

				case "table":
				{
					itemFactory = new ClassFactory( Item );
					itemFactory.properties = { layout: new VerticalLayout() };
					break;
				}

				case "row":
				{
					itemFactory = new ClassFactory( Item );
					itemFactory.properties = { layout: new HorizontalLayout(), percentWidth : 100, percentHeight : 100 };
					break;
				}

				case "cell":
				{
					itemFactory = new ClassFactory( Item );
					itemFactory.properties = { layout: new BasicLayout(), percentWidth : 100, percentHeight : 100 };
					break;
				}
			}

			return itemFactory;
		}
	}
}