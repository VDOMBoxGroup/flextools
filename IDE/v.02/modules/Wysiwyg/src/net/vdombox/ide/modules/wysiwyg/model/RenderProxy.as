package net.vdombox.ide.modules.wysiwyg.model
{
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.vo.ItemVO;
	
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
		
		override public function onRegister() : void
		{
			typesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;
		}
		
		override public function onRemove() : void
		{
			typesProxy = null;
		}
		
		public function setRawRenderData( rawRenderData : XML ) : void
		{
			_renderData = new ItemVO();
			
			createAttributes( _renderData, rawRenderData );
			createChildren( _renderData, rawRenderData )
			
			sendNotification( ApplicationFacade.RENDER_DATA_CHANGED, _renderData );
		}
		
		public function get renderData() : ItemVO
		{
			return _renderData;
		}
		
		private function createAttributes( itemVO : ItemVO, rawRenderData : XML ) : void
		{
			itemVO.id = rawRenderData.@id;
			itemVO.name = rawRenderData.name();
			
			itemVO.visible = rawRenderData.@visible == 1 ? true : false;
			
			itemVO.zindex = rawRenderData.@zindex;
			itemVO.hierarchy = rawRenderData.@hierarchy;
			itemVO.order = rawRenderData.@order;
			
			itemVO.typeVO = typesProxy.getTypeVObyID( rawRenderData.@typeID );
			
			delete rawRenderData.@id;
			delete rawRenderData.@zindex;
			delete rawRenderData.@hierarchy;
			delete rawRenderData.@order;
			delete rawRenderData.@visible;
			delete rawRenderData.@typeID;
			
			var attribute : XML;
			var attributeVO : AttributeVO;
			
			itemVO.attributes = [];
			
			for each ( attribute in rawRenderData.@* )
			{
				attributeVO = new AttributeVO( attribute.name(), attribute[ 0 ] );
				itemVO.attributes.push( attributeVO );
			}
		}
		
		private function createChildren( itemVO : ItemVO, rawRenderData : XML ) : void
		{
			var childItemVO : ItemVO;
			var child : XML;
			
			itemVO.children = [];
			itemVO.content = new XMLList();
			
			for each ( child in rawRenderData.* )
			{
				var childName : String = child.name();
				
				if( childName == "container" || childName == "table" || childName == "row" || childName == "cell" )
				{
					childItemVO = new ItemVO();
					
					createAttributes( childItemVO, child );
					createChildren( childItemVO, child );
						
					childItemVO.parent = itemVO;
					
					itemVO.children.push( childItemVO );
				}
				else
				{
					itemVO.content += child.copy();
				}
			}
		}
	}
}