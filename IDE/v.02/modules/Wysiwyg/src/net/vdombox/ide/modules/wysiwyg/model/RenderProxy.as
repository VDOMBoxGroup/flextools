package net.vdombox.ide.modules.wysiwyg.model
{
	import mx.collections.XMLListCollection;
	
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.ObjectVO;
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

			renderVO = cache[ itemID ] ? cache[ itemID ] : new RenderVO( pageVO );

			cache[ renderVO.vdomObjectVO.id ] = renderVO;

			createAttributes( renderVO, rawRenderData );
			createChildren( renderVO, rawRenderData );

			return renderVO;
		}

		private function createAttributes( renderVO : RenderVO, rawRenderData : XML ) : void
		{
			var typeVO : TypeVO;

			renderVO.visible = rawRenderData.@visible == 1 ? true : false;

			renderVO.zindex = uint( rawRenderData.@zindex );
			renderVO.hierarchy = uint( rawRenderData.@hierarchy );
			renderVO.order = uint( rawRenderData.@order );

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

			var attributesList : XMLList = rawRenderData.attributes();

			if ( attributesList && attributesList.length() > 0 )
			{
				renderVO.attributes = [];

				for each ( attribute in attributesList )
				{
					attributeVO = new AttributeVO( attribute.name(), attribute[ 0 ] );
					renderVO.attributes.push( attributeVO );
				}
			}
		}

		private function createChildren( renderVO : RenderVO, rawRenderData : XML ) : void
		{
			var pageVO : PageVO = renderVO.vdomObjectVO is PageVO ? renderVO.vdomObjectVO as PageVO : ObjectVO( renderVO.vdomObjectVO ).pageVO;
			var objectVO : ObjectVO;
			
			var typeVO : TypeVO;
			var typeID : String;
			
			var childRenderVO : RenderVO;
			
			var childXML : XML;
			var childName : String;
			var childID : String;

			for each ( childXML in rawRenderData.* )
			{
				childName = childXML.name();
				childID = childXML.@id;

				typeID = childXML.@typeID;
				
				if ( childName == "container" || childName == "table" || childName == "row" || childName == "cell" )
				{
					
					typeVO = typesProxy.getTypeVObyID( typeID );
					
					if ( !childID || ! typeVO )
						continue;

					objectVO = new ObjectVO( pageVO, typeVO );
					
					childRenderVO = new RenderVO( objectVO );

					createAttributes( childRenderVO, childXML );
					createChildren( childRenderVO, childXML );

					childRenderVO.parent = renderVO;

					if( !renderVO.children )
						renderVO.children = [];
						
					
					renderVO.children.push( childRenderVO );

					cache[ childRenderVO.vdomObjectVO.id ] = childRenderVO;
				}
				else
				{
					if( !renderVO.content )
						renderVO.content = childXML.copy();
					else
						renderVO.content += childXML.copy();
				}
			}

			if ( renderVO.content && renderVO.content.length() > 0 )
			{
				var editableAttribute : XML;

				editableAttribute = renderVO.content.@ediatable[ 0 ];

				if ( !editableAttribute )
					editableAttribute = renderVO.content..@editable[ 0 ];

				if ( editableAttribute )
				{
					if( !renderVO.attributes )
						renderVO.attributes = [];
					
					renderVO.attributes.push( new AttributeVO( "editable", editableAttribute ) );
				}
			}
		}
	}
}