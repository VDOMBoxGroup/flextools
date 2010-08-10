package net.vdombox.ide.modules.wysiwyg.model
{
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.vo.RenderVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class RenderProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "RenderProxy";

		public function RenderProxy()
		{
			super( NAME );
		}

		private var typesProxy : TypesProxy;
		private var _renderData : ItemVO;

		private var cache : Object;

		override public function onRegister() : void
		{
			typesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;
			cache = {};
		}

		override public function onRemove() : void
		{
			typesProxy = null;
			cache = null;
		}

		public function renderItem( pageVO : PageVO, rawRenderData : XML ) : RenderVO
		{
			var itemID : String = rawRenderData.@id;
			var renderVO : RenderVO;

			renderVO = cache[ itemID ] ? cache[ itemID ] : new RenderVO( itemID );
			renderVO.vdomObjectVO = pageVO;

			cache[ renderItem.id ] = renderItem;

			createAttributes( renderVO, rawRenderData );
			createChildren( renderVO, rawRenderData );

			return renderItem;
		}

		private function createAttributes( renderVO : RenderVO, rawRenderData : XML ) : void
		{
			var typeVO : TypeVO;

			renderVO.name = rawRenderData.name();

			renderVO.visible = rawRenderData.@visible == 1 ? true : false;

			renderVO.zindex = uint( rawRenderData.@zindex );
			renderVO.hierarchy = uint( rawRenderData.@hierarchy );
			renderVO.order = uint( rawRenderData.@order );

			typeVO = typesProxy.getTypeVObyID( rawRenderData.@typeID );

			if ( typeVO )
				itemVO.typeVO = typeVO;
			else
				var d : * = "";

			renderVO.staticFlag = rawRenderData.@contents == "static" ? true : false;

			delete rawRenderData.@id;
			delete rawRenderData.@zindex;
			delete rawRenderData.@hierarchy;
			delete rawRenderData.@order;
			delete rawRenderData.@visible;
			delete rawRenderData.@typeID;
			delete rawRenderData.@contents;

			var attribute : XML;
			var attributeVO : AttributeVO;

			itemVO.attributes = [];

			for each ( attribute in rawRenderData.@* )
			{
				attributeVO = new AttributeVO( attribute.name(), attribute[ 0 ] );
				itemVO.attributes.push( attributeVO );
			}
		}

		private function createChildren( renderVO : RenderVO, rawRenderData : XML ) : void
		{
			var childItemVO : ItemVO;
			var child : XML;

			renderVO.children = [];
			renderVO.content = new XMLList();

			for each ( child in rawRenderData.* )
			{
				var childName : String = child.name();
				var childID : String = child.@id;

				if ( childName == "container" || childName == "table" || childName == "row" || childName == "cell" )
				{
					if ( !childID )
						continue;

					childItemVO = new ItemVO( childID );
					childItemVO.pageVO = itemVO.pageVO;

					createAttributes( childItemVO, child );
					createChildren( childItemVO, child );

					childItemVO.parent = itemVO;

					itemVO.children.push( childItemVO );

					cache[ childItemVO.id ] = childItemVO;
				}
				else
				{
					itemVO.content += child.copy();
				}
			}

			if ( itemVO.content.length() > 0 )
			{
				var editableAttribute : XML;

				editableAttribute = itemVO.content.@ediatable[ 0 ];

				if ( !editableAttribute )
					editableAttribute = itemVO.content..@editable[ 0 ];

				if ( editableAttribute )
					itemVO.attributes.push( new AttributeVO( "editable", editableAttribute ) );
			}
		}
	}
}